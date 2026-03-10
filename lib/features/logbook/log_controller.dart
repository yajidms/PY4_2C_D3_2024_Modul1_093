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

  /// Shorthand getter
  String get _teamId => currentUser['teamId'] ?? '';

  LogController({required this.currentUser}) {
    _myBox = Hive.box<Logbook>('offline_logs');
    loadLogs(_teamId);
    _setupConnectivityListener();
  }

  final ValueNotifier<List<Logbook>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<Logbook>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final MongoService _mongo = MongoService();

  List<Logbook> get logs => logsNotifier.value;

  /// 1. LOAD DATA (Offline-First Strategy) — filter by teamId
  Future<void> loadLogs(String teamId) async {
    // Langkah 1: Ambil data dari Hive (Instan) — tampilkan dulu ke UI
    final localData = _myBox.values
        .where((log) => log.teamId == teamId)
        .toList();

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
      final cloudData = await _mongo.getLogs(teamId);

      // Cegah duplikasi: bersihkan cache lama tim ini, ganti dengan data Cloud
      final keysToDelete = _myBox.keys
          .where((k) => _myBox.get(k)?.teamId == teamId)
          .toList();
      await _myBox.deleteAll(keysToDelete);
      await _myBox.addAll(cloudData);

      logsNotifier.value = cloudData;
      filteredLogs.value = cloudData;

      await LogHelper.writeLog(
        'SYNC: ${cloudData.length} log berhasil diperbarui dari Atlas (team=$teamId).',
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'OFFLINE: Menggunakan data cache lokal. Error: $e',
        source: 'log_controller.dart',
        level: 2,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Alias untuk kompatibilitas pemanggil lama di log_view.dart
  Future<void> loadFromDisk({bool syncCloud = true}) => loadLogs(_teamId);

  /// Alias refresh (dipanggil dari pull-to-refresh di UI)
  Future<void> fetchLogs() => loadLogs(_teamId);

  /// Mendengarkan perubahan status jaringan (Offline → Online)
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi)) {
          await LogHelper.writeLog(
            'NETWORK: Koneksi pulih, mencoba sinkronisasi data pending...',
            source: 'log_controller.dart',
            level: 3,
          );
          await _syncPendingData();
        }
      },
    );
  }

  /// Sinkronisasi otomatis saat koneksi kembali tersambung
  Future<void> _syncPendingData() async {
    await loadLogs(_teamId);
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(
    String title,
    String desc,
    String category,
    String authorId,
    String teamId,
  ) async {
    final newLog = Logbook(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now(),
      category: category,
      authorId: authorId,
      teamId: teamId,
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


