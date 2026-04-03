import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_093/services/mongo_service.dart';

void main() {
  var actual, expected;

  group('Module 4 - MongoService (Database Connection)', () {
    late MongoService mongoService;

    setUpAll(() async {
      // (1) setup (arrange, build)
      // Memuat file .env sebelum seluruh test dijalankan
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      mongoService = MongoService();
    });

    tearDownAll(() async {
      // Membersihkan dan menutup koneksi setelah test selesai
      await mongoService.close();
    });

    test('dotenv should load MONGODB_URI successfully', () {
      // (2) exercise (act, operate)
      actual = dotenv.env['MONGODB_URI'] != null && dotenv.env['MONGODB_URI']!.isNotEmpty;
      expected = true;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('connect should successfully establish connection to MongoDB', () async {
      // (2) exercise (act, operate)
      await mongoService.connect();
      actual = mongoService.db?.isConnected;
      expected = true;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('close should terminate connection and set db to null', () async {
      // (1) setup (arrange, build)
      await mongoService.connect();

      // (2) exercise (act, operate)
      await mongoService.close();
      actual = mongoService.db;
      expected = null;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });
  });
}
