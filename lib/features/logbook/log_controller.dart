import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/log_helper.dart';
import '../../services/mongo_service.dart';
import '../logbook/models/log_model.dart';

class LogController {
  static final LogController _instance = LogController._internal();
  factory LogController() => _instance;

  LogController._internal() {
    // Warm start: tampilkan cache lokal dulu tanpa langsung hit cloud.
    loadFromDisk(syncCloud: false);
  }

  final ValueNotifier<List<Logbook>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<Logbook>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  static const String _storageKey = 'user_logs_data';
  final MongoService _mongo = MongoService();

  List<Logbook> get logs => logsNotifier.value;

  Map<String, dynamic> _toJsonMap(Logbook log) {
    return {
      '_id': log.id?.oid,
      'title': log.title,
      'description': log.description,
      'date': log.date.toIso8601String(),
    };
  }

  Logbook _fromJsonMap(Map<String, dynamic> map) {
    ObjectId? parsedId;
    final dynamic rawId = map['_id'];
    if (rawId is String && rawId.isNotEmpty) {
      parsedId = ObjectId.fromHexString(rawId);
    } else if (rawId is ObjectId) {
      parsedId = rawId;
    } else if (rawId is Map && rawId['\$oid'] is String) {
      parsedId = ObjectId.fromHexString(rawId['\$oid'] as String);
    }

    return Logbook(
      id: parsedId,
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      date: DateTime.tryParse((map['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(logsNotifier.value.map(_toJsonMap).toList());
      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal menyimpan cache lokal - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  /// Ambil data terbaru dari Cloud lalu sinkronkan notifier untuk UI.
  Future<void> fetchLogs() async {
    isLoading.value = true;
    await LogHelper.writeLog(
      'Memuat log dari Cloud...',
      source: 'log_controller.dart',
    );
    try {
      final dataFromCloud = await _mongo.getLogs();
      logsNotifier.value = dataFromCloud;
      filteredLogs.value = dataFromCloud;
      await saveToDisk();
      await LogHelper.writeLog(
        '${dataFromCloud.length} log berhasil dimuat.',
        source: 'log_controller.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'Gagal memuat log: $e',
        source: 'log_controller.dart',
        level: 1,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Alias kompatibilitas pemanggil lama.
  Future<void> loadFromCloud() => fetchLogs();

  Future<void> loadFromDisk({bool syncCloud = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = prefs.getString(_storageKey);

      if (encodedData != null && encodedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(encodedData) as List<dynamic>;
        final cachedLogs = decoded
            .whereType<Map>()
            .map((e) => _fromJsonMap(Map<String, dynamic>.from(e)))
            .toList();

        logsNotifier.value = cachedLogs;
        filteredLogs.value = cachedLogs;

        await LogHelper.writeLog(
          'INFO: Cache lokal dimuat (${cachedLogs.length} item).',
          source: 'log_controller.dart',
          level: 3,
        );
      }
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal membaca cache lokal - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }

    if (syncCloud) {
      // Setelah cache tampil, sinkronkan data terbaru dari cloud.
      await fetchLogs();
    }
  }

  //menambahkan log baru ke MongoDB Atlas
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = Logbook(
      id: ObjectId(),
      title: title,
      description: desc,
      date: DateTime.now(),
    );

    try {
      await _mongo.insertLog(newLog);

      final currentLogs = List<Logbook>.from(logsNotifier.value)..add(newLog);
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;
      await saveToDisk();

      await LogHelper.writeLog(
        'SUCCESS: Tambah data dengan ID lokal',
        source: 'log_controller.dart',
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Add - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  Future<void> updateLog(int index, String newTitle, String newDesc) async {
    final currentLogs = List<Logbook>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = Logbook(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now(),
    );

    try {
      await _mongo.updateLog(updatedLog);

      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;
      await saveToDisk();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Update - $e',
        source: 'log_controller.dart',
        level: 1,
      );
    }
  }

  //hapus log dari UI
  Future<void> removeLog(int index) async {
    final currentLogs = List<Logbook>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception('ID Log tidak ditemukan, tidak bisa menghapus di Cloud.');
      }

      await _mongo.deleteLog(targetLog.id!);

      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;
      filteredLogs.value = currentLogs;
      await saveToDisk();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: 'log_controller.dart',
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        'ERROR: Gagal sinkronisasi Hapus - $e',
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
