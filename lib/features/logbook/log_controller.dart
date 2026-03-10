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

  String get _teamId => currentUser['teamId'] ?? '';

  LogController({required this.currentUser}) {
    _myBox = Hive.box<Logbook>('offline_logs');
    loadLogs(_teamId);
    _setupConnectivityListener();
  }

  final ValueNotifier<List<Logbook>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<Logbook>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool?> syncStatusNotifier = ValueNotifier(null);

  final MongoService _mongo = MongoService();
  static const String _src = 'log_controller.dart';

  List<Logbook> get logs => logsNotifier.value;

  void _setLogs(List<Logbook> list) {
    logsNotifier.value = list;
    filteredLogs.value = list;
  }

  dynamic _findHiveKey(String? id) =>
      _myBox.keys.firstWhere((k) => _myBox.get(k)?.id == id, orElse: () => null);

  Future<void> _markSynced(dynamic key, Logbook log) =>
      _myBox.put(key, log.copyWith(isSynced: true, isDeleted: false));

  void _updateNotifier(String? id, Logbook updated) {
    final list = List<Logbook>.from(logsNotifier.value);
    final idx = list.indexWhere((l) => l.id == id);
    if (idx != -1) {
      list[idx] = updated;
      _setLogs(list);
    }
  }

  Future<void> _log(String msg, {int level = 2}) =>
      LogHelper.writeLog(msg, source: _src, level: level);

  Future<bool> loadLogs(String teamId) async {
    // Tampilkan cache lokal dulu (instan)
    final localData = _myBox.values.where((l) => l.teamId == teamId).toList();
    _setLogs(localData);
    await _log('INFO: Cache lokal dimuat (${localData.length} item).', level: 3);

    isLoading.value = true;
    try {
      final cloudData = await _mongo.getLogs(teamId);

      // Hapus cache lama kecuali item pending
      final keysToDelete = _myBox.keys.where((k) {
        final l = _myBox.get(k);
        return l != null && l.teamId == teamId && l.isSynced && !l.isDeleted;
      }).toList();
      await _myBox.deleteAll(keysToDelete);
      await _myBox.addAll(cloudData);

      // Merge: Cloud + pending lokal (excl. soft-deleted)
      final pending = _myBox.values
          .where((l) => l.teamId == teamId && (!l.isSynced || l.isDeleted))
          .toList();
      final pendingIds = pending.map((l) => l.id).toSet();
      _setLogs([
        ...cloudData.where((l) => !pendingIds.contains(l.id)),
        ...pending.where((l) => !l.isDeleted),
      ]);

      await _log('SYNC: ${cloudData.length} log diperbarui dari Atlas (team=$teamId).');
      return true;
    } catch (e) {
      await _log('OFFLINE: Menggunakan cache lokal. Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFromDisk({bool syncCloud = true}) => loadLogs(_teamId);
  Future<bool> fetchLogs() => loadLogs(_teamId);

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
      if (!online) return;

      await _log('NETWORK: Koneksi pulih, memulai pending sync queue...', level: 3);
      await _syncPendingQueue();
      syncStatusNotifier.value = await loadLogs(_teamId);
      await Future.delayed(const Duration(seconds: 3));
      syncStatusNotifier.value = null;
    });
  }

  Future<void> _syncPendingQueue() async {
    for (final key in _myBox.keys.toList()) {
      final log = _myBox.get(key);
      if (log == null) continue;

      if (log.isDeleted) {
        await _processPendingDelete(key, log);
      } else if (!log.isSynced) {
        await _processPendingWrite(key, log);
      }
    }
  }

  Future<void> _processPendingDelete(dynamic key, Logbook log) async {
    try {
      if (log.id != null) {
        await _mongo.deleteLog(ObjectId.fromHexString(log.id!), log.authorId);
      }
      await _myBox.delete(key);
      await _log('PENDING DELETE: "${log.title}" dihapus dari Cloud.');
    } catch (e) {
      await _log('PENDING DELETE FAIL: "${log.title}" - $e', level: 1);
    }
  }

  Future<void> _processPendingWrite(dynamic key, Logbook log) async {
    // Cek apakah data sudah ada di Cloud berdasarkan ID untuk menghindari duplikasi
    final existsInCloud = await _mongo.existsLog(log.id);
    try {
      if (existsInCloud) {
        await _mongo.updateLog(log);
        await _markSynced(key, log);
        await _log('PENDING UPDATE: "${log.title}" diperbarui ke Cloud.');
      } else {
        await _mongo.insertLog(log);
        await _markSynced(key, log);
        await _log('PENDING SYNC: "${log.title}" dikirim ke Cloud.');
      }
    } catch (e) {
      await _log('PENDING SYNC FAIL: "${log.title}" - $e', level: 1);
    }
  }

  Future<void> addLog(
    String title, String desc, String category,
    String authorId, String teamId, bool isPublic,
  ) async {
    final newLog = Logbook(
      id: ObjectId().oid, title: title, description: desc,
      date: DateTime.now(), category: category,
      authorId: authorId, teamId: teamId,
      isPublic: isPublic, isSynced: false, isDeleted: false,
    );

    final hiveKey = await _myBox.add(newLog);
    _setLogs([...logsNotifier.value, newLog]);

    try {
      await _mongo.insertLog(newLog);
      final synced = newLog.copyWith(isSynced: true);
      await _myBox.put(hiveKey, synced);
      _updateNotifier(newLog.id, synced);
      await _log('SUCCESS: "${newLog.title}" tersinkron ke Cloud.');
    } catch (e) {
      await _log('OFFLINE: "${newLog.title}" tersimpan lokal (pending). Error: $e', level: 1);
    }
  }

  Future<void> updateLog(
    int index, String newTitle, String newDesc,
    String newCategory, bool isPublic,
  ) async {
    final list = List<Logbook>.from(logsNotifier.value);
    final oldLog = list[index];

    final updated = oldLog.copyWith(
      title: newTitle, description: newDesc, date: DateTime.now(),
      category: newCategory, isPublic: isPublic,
      isSynced: false, isDeleted: false,
    );

    list[index] = updated;
    _setLogs(list);

    final key = _findHiveKey(oldLog.id);
    if (key != null) await _myBox.put(key, updated);

    try {
      await _mongo.updateLog(updated);
      final synced = updated.copyWith(isSynced: true);
      if (key != null) await _myBox.put(key, synced);
      _updateNotifier(updated.id, synced);
      await _log('SUCCESS: Update "${updated.title}" tersinkron ke Cloud.');
    } catch (e) {
      await _log('OFFLINE: Update "${updated.title}" tersimpan lokal (pending). Error: $e', level: 1);
    }
  }

  Future<void> removeLog(int index, String userRole, String userId) async {
    final list = List<Logbook>.from(logsNotifier.value);
    final target = list[index];

    if (!AccessControlService.canPerform(
      userRole, AccessControlService.actionDelete,
      isOwner: target.authorId == userId,
    )) {
      await _log('SECURITY BREACH: Unauthorized delete by $userId (role: $userRole)', level: 1);
      return;
    }

    list.removeAt(index);
    _setLogs(list);

    final key = _findHiveKey(target.id);

    try {
      if (target.id != null) {
        await _mongo.deleteLog(ObjectId.fromHexString(target.id!), target.authorId);
      }
      if (key != null) await _myBox.delete(key);
      await _log('DELETE: "${target.title}" dihapus dari Cloud & Hive.');
    } catch (e) {
      if (key != null) await _myBox.put(key, target.copyWith(isDeleted: true));
      await _log('OFFLINE DELETE: "${target.title}" ditandai soft-delete (pending). Error: $e', level: 1);
    }
  }

  void searchLog(String query) {
    filteredLogs.value = query.isEmpty
        ? logsNotifier.value
        : logsNotifier.value
            .where((l) => l.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
  }
}

