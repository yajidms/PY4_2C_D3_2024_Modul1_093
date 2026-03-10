import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

import '../../helpers/log_helper.dart';
import '../../services/access_control_service.dart';
import '../../services/mongo_service.dart';
import '../logbook/models/log_model.dart';

class LogController {
  final String _activeUserId;
  late final Box<Logbook> _logBox;

  LogController({required String username})
      : _activeUserId = username.trim().toLowerCase() {
    _logBox = Hive.box<Logbook>('offline_logs');
    loadFromDisk(syncCloud: true);
  }

  final ValueNotifier<List<Logbook>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<Logbook>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final MongoService _mongo = MongoService();

  List<Logbook> get logs => logsNotifier.value;

  /// 1. LOAD DATA (Offline-First Strategy)
  Future<void> loadFromDisk({bool syncCloud = true}) async {
    // Ambil data dari Hive (Sangat Cepat/Instan)
    final localData = _logBox.values
        .where((log) => log.authorId == _activeUserId)
        .toList();

    logsNotifier.value = localData;
    filteredLogs.value = localData;

    await LogHelper.writeLog(
      'INFO: Cache lokal dimuat (${localData.length} item) dari Hive.',
      source: 'log_controller.dart',
      level: 3,
    );

    // Sync dari Cloud (Background Process)
    if (syncCloud) {
      await fetchLogs();
    }
  }

  /// Sinkronisasi Data dari MongoDB ke Lokal
  Future<void> fetchLogs() async {
    isLoading.value = true;
    try {
      final cloudData = await _mongo.getLogs(_activeUserId);

      // Bersihkan data lokal milik user ini, lalu timpa dengan data terbaru dari Cloud
      final keysToDelete = _logBox.keys
          .where((k) => _logBox.get(k)?.authorId == _activeUserId)
          .toList();
      await _logBox.deleteAll(keysToDelete);
      await _logBox.addAll(cloudData);

      logsNotifier.value = cloudData;
      filteredLogs.value = cloudData;

      await LogHelper.writeLog(
        'SYNC: ${cloudData.length} log berhasil diperbarui dari Cloud ke Hive.',
        source: 'log_controller.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'OFFLINE: Gagal sinkronisasi dari Cloud, menggunakan data lokal. Error: $e',
        source: 'log_controller.dart',
        level: 1,
      );
    } finally {
      isLoading.value = false;
    }
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
    await _logBox.add(newLog);
    final currentLogs = List<Logbook>.from(logsNotifier.value)..add(newLog);
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;

    // ACTION 2: Kirim ke MongoDB Atlas secara Asinkron (Background)
    try {
      await _mongo.insertLog(newLog);
      await LogHelper.writeLog('SUCCESS: Data tersinkron ke Cloud', source: 'log_controller.dart');
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
    final key = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == oldLog.id,
      orElse: () => null,
    );
    if (key != null) {
      await _logBox.put(key, updatedLog);
    }

    // Sync ke Cloud
    try {
      await _mongo.updateLog(updatedLog);
      await LogHelper.writeLog(
        "SUCCESS: Update disinkronkan ke Cloud",
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
    final key = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == targetLog.id,
      orElse: () => null,
    );
    if (key != null) {
      await _logBox.delete(key);
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
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}