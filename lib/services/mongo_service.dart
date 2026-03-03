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

  static const String _defaultDbName = 'logbook_db';
  static const String _defaultCollectionName = 'logs';
  final String _source = 'mongo_service.dart';

  String _ensureDatabaseInUri(String rawUri, String dbName) {
    final parsedUri = Uri.parse(rawUri);
    final hasDbInPath =
        parsedUri.pathSegments.isNotEmpty && parsedUri.pathSegments.first.isNotEmpty;

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
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null || dbUri.isEmpty) {
        throw Exception('MONGODB_URI tidak ditemukan di .env');
      }

      final dbName = (dotenv.env['MONGODB_DB_NAME'] ?? _defaultDbName).trim();
      final collectionName =
          (dotenv.env['MONGODB_COLLECTION_NAME'] ?? _defaultCollectionName).trim();
      final normalizedUri = _ensureDatabaseInUri(dbUri, dbName);

      if (_db != null && _db!.isConnected && _collection != null) {
        await LogHelper.writeLog(
          'DATABASE: Koneksi sudah aktif, memakai sesi yang ada.',
          source: _source,
          level: 3,
        );
        return;
      }

      _db = await Db.create(normalizedUri);
      await _db!.open().timeout(
        const Duration(seconds: 15),
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
    } catch (e) {
      await LogHelper.writeLog(
        'DATABASE: Gagal Koneksi - $e',
        source: _source,
        level: 1,
      );
      rethrow;
    }
  }

  /// READ: Mengambil data dari Cloud.
  Future<List<Logbook>> getLogs() async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog(
        'INFO: Fetching data from Cloud...',
        source: _source,
        level: 3,
      );

      final List<Map<String, dynamic>> data = await collection.find().toList();
      await LogHelper.writeLog(
        'SUCCESS: ${data.length} data berhasil diambil.',
        source: _source,
        level: 2,
      );

      return data.map((json) => Logbook.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Fetch Failed - $e',
        source: _source,
        level: 1,
      );
      return [];
    }
  }

  /// CREATE: Menambahkan data baru.
  Future<void> insertLog(Logbook log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insertOne(log.toMap());

      await LogHelper.writeLog(
        "SUCCESS: Data '${log.title}' Saved to Cloud",
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

      await collection.replaceOne(where.id(log.id!), log.toMap());

      await LogHelper.writeLog(
        "DATABASE: Update '${log.title}' Berhasil",
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
  Future<void> deleteLog(ObjectId id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(id));

      await LogHelper.writeLog(
        'DATABASE: Hapus ID $id Berhasil',
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

      await LogHelper.writeLog(
        'DATABASE: Koneksi ditutup',
        source: _source,
        level: 2,
      );
    }
  }

  Db? get db => _db;
}
