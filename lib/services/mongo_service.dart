import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  DbCollection? _collection;

  // Lock untuk mencegah race condition pada pemanggilan connect() secara bersamaan
  Future<void>? _connectingFuture;

  final String _source = 'mongo_service.dart';

  String _ensureDatabaseInUri(String rawUri, String dbName) {
    final parsedUri = Uri.parse(rawUri);
    final hasDbInPath =
        parsedUri.pathSegments.isNotEmpty &&
        parsedUri.pathSegments.first.isNotEmpty;

    if (hasDbInPath) {
      return rawUri;
    }

    return parsedUri.replace(path: '/$dbName').toString();
  }

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await LogHelper.writeLog(
        'INFO: Koleksi belum siap, mencoba rekoneksi...',
        source: _source,
        level: 3,
      );
      await connect();
    }
    return _collection!;
  }

  Future<void> connect() async {
    // Jika koneksi sudah aktif, langsung return tanpa buat koneksi baru
    if (_db != null && _db!.isConnected && _collection != null) {
      await LogHelper.writeLog(
        'DATABASE: Koneksi sudah aktif, memakai sesi yang ada.',
        source: _source,
        level: 3,
      );
      return;
    }

    // Jika ada proses koneksi yang sedang berjalan, tunggu hasilnya (cegah race condition)
    if (_connectingFuture != null) {
      await LogHelper.writeLog(
        'DATABASE: Menunggu proses koneksi yang sedang berjalan...',
        source: _source,
        level: 3,
      );
      return _connectingFuture!;
    }

    // Mulai proses koneksi baru dengan Completer sebagai lock
    final completer = Completer<void>();
    _connectingFuture = completer.future;

    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null || dbUri.trim().isEmpty) {
        throw Exception('MONGODB_URI tidak ditemukan di .env');
      }

      final dbName = dotenv.env['MONGODB_DB_NAME']?.trim();
      if (dbName == null || dbName.isEmpty) {
        throw Exception('MONGODB_DB_NAME tidak ditemukan di .env');
      }

      final collectionName = dotenv.env['MONGODB_COLLECTION_NAME']?.trim();
      if (collectionName == null || collectionName.isEmpty) {
        throw Exception('MONGODB_COLLECTION_NAME tidak ditemukan di .env');
      }

      final normalizedUri = _ensureDatabaseInUri(dbUri, dbName);

      _db = await Db.create(normalizedUri);
      await _db!.open().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception(
            'Koneksi Timeout. Cek IP Whitelist (0.0.0.0/0) atau Sinyal HP.',
          );
        },
      );

      _collection = _db!.collection(collectionName);

      await LogHelper.writeLog(
        'DATABASE: Terhubung ke $dbName.$collectionName',
        source: _source,
        level: 2,
      );

      completer.complete();
    } catch (e) {
      // Reset state agar koneksi bisa dicoba ulang
      _db = null;
      _collection = null;

      await LogHelper.writeLog(
        'DATABASE: Gagal Koneksi - $e',
        source: _source,
        level: 1,
      );

      completer.completeError(e);
      rethrow;
    } finally {
      // Selalu hapus lock setelah selesai (berhasil maupun gagal)
      _connectingFuture = null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRawLogs(String teamId) async {
    final collection = await _getSafeCollection();
    return collection.find(where.eq('teamId', teamId)).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchAllRawLogs() async {
    final collection = await _getSafeCollection();
    return collection.find().toList();
  }

  /// READ: Mengambil semua data dari Cloud (tanpa filter), untuk Asisten
  Future<List<Logbook>> getAllLogs() async {
    await LogHelper.writeLog(
      'INFO: Fetching ALL data (Asisten access)',
      source: _source,
      level: 3,
    );

    try {
      final data = await _fetchAllRawLogs();
      await LogHelper.writeLog(
        'READ: ${data.length} log berhasil diambil (all teams).',
        source: _source,
        level: 2,
      );
      return data.map((json) => Logbook.fromMap(json)).toList();
    } catch (firstError) {
      await LogHelper.writeLog(
        'WARN: Fetch semua log gagal, mencoba reconnect - $firstError',
        source: _source,
        level: 1,
      );
      await close();
      await connect();
      try {
        final data = await _fetchAllRawLogs();
        return data.map((json) => Logbook.fromMap(json)).toList();
      } catch (secondError) {
        await LogHelper.writeLog(
          'ERROR: Fetch semua log gagal setelah reconnect - $secondError',
          source: _source,
          level: 1,
        );
        return [];
      }
    }
  }


  /// READ: Mengambil data dari Cloud berdasarkan Team ID
  Future<List<Logbook>> getLogs(String teamId) async {
    await LogHelper.writeLog(
      'INFO: Fetching data for Team: $teamId',
      source: _source,
      level: 3,
    );

    try {
      final data = await _fetchRawLogs(teamId);
      await LogHelper.writeLog(
        'READ: ${data.length} log berhasil diambil untuk team=$teamId.',
        source: _source,
        level: 2,
      );
      return data.map((json) => Logbook.fromMap(json)).toList();
    } catch (firstError) {
      await LogHelper.writeLog(
        'WARN: Fetch pertama gagal, mencoba reconnect sekali lagi - $firstError',
        source: _source,
        level: 1,
      );

      await close();
      await connect();

      try {
        final data = await _fetchRawLogs(teamId);
        await LogHelper.writeLog(
          'READ: Reconnect berhasil, ${data.length} log diambil untuk team=$teamId.',
          source: _source,
          level: 2,
        );
        return data.map((json) => Logbook.fromMap(json)).toList();
      } catch (secondError) {
        await LogHelper.writeLog(
          'ERROR: Fetch Failed setelah reconnect - $secondError',
          source: _source,
          level: 1,
        );
        return [];
      }
    }
  }

  /// CREATE: Menambahkan data baru.
  Future<void> insertLog(Logbook log) async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog(
        "CREATE: Menyimpan log '${log.title}' untuk user=${log.authorId}",
        source: _source,
        level: 3,
      );
      await collection.insertOne(log.toMap());

      await LogHelper.writeLog(
        "CREATE: Data '${log.title}' berhasil disimpan.",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Insert Failed - $e',
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// UPDATE: Memperbarui data berdasarkan ID.
  Future<void> updateLog(Logbook log) async {
    try {
      final collection = await _getSafeCollection();
      if (log.id == null) {
        throw Exception('ID Log tidak ditemukan untuk update');
      }

      // id sekarang bertipe String, konversi ke ObjectId untuk query MongoDB
      final objectId = ObjectId.fromHexString(log.id!);

      await LogHelper.writeLog(
        "UPDATE: Memperbarui log id=${log.id} user=${log.authorId}",
        source: _source,
        level: 3,
      );
      await collection.replaceOne(
        where.id(objectId).eq('authorId', log.authorId),
        log.toMap(),
      );

      await LogHelper.writeLog(
        "UPDATE: Log '${log.title}' berhasil diperbarui.",
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'DATABASE: Update Gagal - $e',
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// DELETE: Menghapus dokumen berdasarkan ObjectId.
  Future<void> deleteLog(ObjectId id, String authorId) async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog(
        'DELETE: Menghapus log id=$id author=$authorId',
        source: _source,
        level: 3,
      );
      await collection.remove(where.id(id).eq('authorId', authorId));

      await LogHelper.writeLog(
        'DELETE: Hapus ID $id berhasil untuk author=$authorId.',
        source: _source,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'DATABASE: Hapus Gagal - $e',
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// Menutup koneksi ke MongoDB.
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _collection = null;
      _connectingFuture = null;

      await LogHelper.writeLog(
        'DATABASE: Koneksi ditutup',
        source: _source,
        level: 2,
      );
    }
  }

  Db? get db => _db;
}
