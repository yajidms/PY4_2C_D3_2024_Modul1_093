import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

import '../../helpers/log_helper.dart';
import '../../services/access_control_service.dart';
import '../../services/mongo_service.dart';
import '../logbook/models/log_model.dart';

class LogController {
  final Map<String, String> currentUser;
  late final Box<Logbook> _myBox;

  String get _role => currentUser['role'] ?? 'Anggota';

  /// Shorthand getter
  String get _teamId => currentUser['teamId'] ?? '';

  LogController({required this.currentUser}) {
    _myBox = Hive.box<Logbook>('offline_logs');
    // Muat data lokal dari Hive terlebih dahulu (instan, tanpa menyentuh cloud)
    // Sync ke cloud akan dilakukan oleh _initDatabase() di log_view.dart
    _loadLocalCache();
    _setupConnectivityListener();
  }

  final ValueNotifier<List<Logbook>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<Logbook>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // null = idle, true = sync berhasil, false = sync gagal/offline
  final ValueNotifier<bool?> syncStatusNotifier = ValueNotifier(null);

  // true = online, false = offline
  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier(true);

  final MongoService _mongo = MongoService();

  /// null = belum diketahui (state awal), true = sebelumnya offline, false = sebelumnya online
  bool? _wasOffline;

  List<Logbook> get logs => logsNotifier.value;

  /// Hanya muat cache lokal dari Hive (tanpa sync cloud) — dipanggil dari constructor
  void _loadLocalCache() {
    final bool isAsisten = _role == 'Asisten';
    final localData = isAsisten
        ? _myBox.values.toList()
        : _myBox.values.where((log) => log.teamId == _teamId).toList();
    logsNotifier.value = localData;
    filteredLogs.value = localData;
  }

  /// 1. LOAD DATA (Offline-First Strategy) — filter by teamId, kecuali Asisten
  Future<bool> loadLogs(String teamId) async {
    final bool isAsisten = _role == 'Asisten';

    // Langkah 1: Ambil data dari Hive (Instan)
    final localData = isAsisten
        ? _myBox.values.toList()
        : _myBox.values.where((log) => log.teamId == teamId).toList();

    logsNotifier.value = localData;
    filteredLogs.value = localData;

    await LogHelper.writeLog(
      'INFO: Cache lokal dimuat (${localData.length} item) dari Hive.',
      source: 'log_controller.dart',
      level: 3,
    );

    // Langkah 2: Sync dari Cloud (Background)
    isLoading.value = true;
    try {
      final cloudData = isAsisten
          ? await _mongo.getAllLogs()
          : await _mongo.getLogs(teamId);

      if (isAsisten) {
        await _myBox.clear();
      } else {
        final keysToDelete = _myBox.keys
            .where((k) => _myBox.get(k)?.teamId == teamId)
            .toList();
        await _myBox.deleteAll(keysToDelete);
      }
      await _myBox.addAll(cloudData);

      logsNotifier.value = cloudData;
      filteredLogs.value = cloudData;

      await LogHelper.writeLog(
        'SYNC: ${cloudData.length} log berhasil diperbarui dari Atlas (${isAsisten ? "all teams" : "team=$teamId"}).',
        source: 'log_controller.dart',
        level: 2,
      );
      return true; // sukses
    } catch (e) {
      await LogHelper.writeLog(
        'OFFLINE: Menggunakan data cache lokal. Error: $e',
        source: 'log_controller.dart',
        level: 2,
      );
      return false; // gagal/offline
    } finally {
      isLoading.value = false;
    }
  }

  // Alias untuk kompatibilitas pemanggil lama di log_view.dart
  Future<void> loadFromDisk({bool syncCloud = true}) => loadLogs(_teamId);

  /// Fetch dan kembalikan true jika berhasil sync dari Cloud
  Future<bool> fetchLogs() => loadLogs(_teamId);

  /// Mendengarkan perubahan status jaringan (Offline → Online)
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isOnline = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi);

        // Event pertama dari connectivity_plus adalah state awal (bukan perubahan).
        // Hanya catat kondisi awal tanpa memicu sync atau notifikasi.
        if (_wasOffline == null) {
          _wasOffline = !isOnline;
          isOnlineNotifier.value = isOnline;
          await LogHelper.writeLog(
            'NETWORK: State awal terdeteksi — ${isOnline ? "Online" : "Offline"}',
            source: 'log_controller.dart',
            level: 3,
          );
          return;
        }

        if (isOnline) {
          isOnlineNotifier.value = true;
          if (_wasOffline == true) {
            // Benar-benar baru pulih dari offline → tampilkan notifikasi
            await LogHelper.writeLog(
              'NETWORK: Koneksi pulih dari offline, mencoba sinkronisasi data pending...',
              source: 'log_controller.dart',
              level: 3,
            );
            final success = await loadLogs(_teamId);
            // Beri tahu UI bahwa sync otomatis selesai
            syncStatusNotifier.value = success;
            // Reset ke null setelah sebentar agar bisa trigger lagi berikutnya
            await Future.delayed(const Duration(seconds: 3));
            syncStatusNotifier.value = null;
          }
          _wasOffline = false;
        } else {
          _wasOffline = true;
          isOnlineNotifier.value = false;
          await LogHelper.writeLog(
            'NETWORK: Koneksi terputus.',
            source: 'log_controller.dart',
            level: 2,
          );
        }
      },
    );
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(
    String title,
    String desc,
    String category,
    String authorId,
    String teamId,
    bool isPublic,
  ) async {
    final newLog = Logbook(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now(),
      category: category,
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
    );

    // ACTION 1: Simpan ke Hive dan Update UI (Instan)
    await _myBox.add(newLog);
    final currentLogs = List<Logbook>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;

    // ACTION 2: Kirim ke MongoDB Atlas secara Asinkron (Background)
    try {
      await _mongo.insertLog(newLog);
      await LogHelper.writeLog(
        'SUCCESS: Data tersinkron ke Cloud',
        source: 'log_controller.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'WARNING: Data tersimpan di lokal (Hive), akan sinkron saat online.',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  /// 3. UPDATE DATA
  Future<void> updateLog(
    int index,
    String newTitle,
    String newDesc,
    String newCategory,
    bool isPublic,
  ) async {
    final currentLogs = List<Logbook>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = Logbook(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now(),
      category: newCategory,
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: isPublic,
    );

    // Update UI
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;

    // Cari & Update di Hive lokal
    final key = _myBox.keys.firstWhere(
      (k) => _myBox.get(k)?.id == oldLog.id,
      orElse: () => null,
    );
    if (key != null) {
      await _myBox.put(key, updatedLog);
    }

    // Sync ke Cloud
    try {
      await _mongo.updateLog(updatedLog);
      await LogHelper.writeLog(
        'SUCCESS: Update disinkronkan ke Cloud',
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Update (tersimpan lokal) - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  /// 4. DELETE DATA dengan RBAC security check
  Future<void> removeLog(int index, String userRole, String userId) async {
    final currentLogs = List<Logbook>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    // Lapisan Keamanan Tambahan
    final isOwner = targetLog.authorId == userId;
    if (!AccessControlService.canPerform(
      userRole,
      AccessControlService.actionDelete,
      isOwner: isOwner,
    )) {
      await LogHelper.writeLog(
        'SECURITY BREACH: Unauthorized delete attempt by $userId (role: $userRole)',
        source: 'log_controller.dart',
        level: 1,
      );
      return; // Hentikan eksekusi
    }

    // Hapus dari UI
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;

    // Hapus dari Hive
    final key = _myBox.keys.firstWhere(
      (k) => _myBox.get(k)?.id == targetLog.id,
      orElse: () => null,
    );
    if (key != null) {
      await _myBox.delete(key);
    }

    // Hapus dari Cloud
    try {
      if (targetLog.id != null) {
        await _mongo.deleteLog(
          ObjectId.fromHexString(targetLog.id!),
          targetLog.authorId,
        );
      }
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal hapus di Cloud (sudah terhapus di lokal) - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where(
            (log) => log.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }
}


