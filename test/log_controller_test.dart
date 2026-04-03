import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_093/features/logbook/log_controller.dart';

void main() {
  var actual, expected;

  group('Module 3 - LogController (Save Data to Disk)', () {
    late LogController controller;

    setUp(() async {
      // (1) setup (arrange, build)
      SharedPreferences.setMockInitialValues({}); // mock storage
      controller = LogController();
      await controller.loadFromDisk();
    });

    test('addLog should add a new log and update notifier', () {
      // (2) exercise (act, operate)
      controller.addLog("Test Title", "Test Desc", "Test Category");
      actual = controller.logsNotifier.value.length;
      expected = 1;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected log but got $actual');
      expect(controller.logsNotifier.value.first.title, "Test Title");
    });

    test('updateLog should modify an existing log', () {
      // (1) setup (arrange, build)
      controller.addLog("Old Title", "Old Desc", "Old Cat");

      // (2) exercise (act, operate)
      controller.updateLog(0, "New Title", "New Desc", "New Cat");
      actual = controller.logsNotifier.value.first.title;
      expected = "New Title";

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('removeLog should delete the log at given index', () {
      // (1) setup (arrange, build)
      controller.addLog("Log 1", "Desc 1", "Cat 1");
      controller.addLog("Log 2", "Desc 2", "Cat 2");

      // (2) exercise (act, operate)
      controller.removeLog(0);
      actual = controller.logsNotifier.value.length;
      expected = 1;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(controller.logsNotifier.value.first.title, "Log 2");
    });

    test('searchLog should filter logs based on query', () {
      // (1) setup (arrange, build)
      controller.addLog("Apple", "Desc", "Fruit");
      controller.addLog("Banana", "Desc", "Fruit");

      // (2) exercise (act, operate)
      controller.searchLog("app");
      actual = controller.filteredLogs.value.length;
      expected = 1;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(controller.filteredLogs.value.first.title, "Apple");
    });

    test('logs should persist using SharedPreferences', () async {
      // (1) setup (arrange, build)
      controller.addLog("Persisted Log", "Desc", "Cat");

      // (2) exercise (act, operate)
      // Buat instance baru untuk mensimulasikan restart aplikasi
      final newController = LogController();
      await newController.loadFromDisk();

      actual = newController.logsNotifier.value.length;
      expected = 1;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(newController.logsNotifier.value.first.title, "Persisted Log");
    });
  });
}
