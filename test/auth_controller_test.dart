import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_093/features/auth/login_controller.dart';

void main() {
  var actual, expected;

  group('Module 2 - LoginController (Authentication)', () {
    late LoginController controller;

    setUp(() {
      // (1) setup (arrange, build)
      controller = LoginController();
    });

    test('login should return true for valid credentials', () {
      // (2) exercise (act, operate)
      actual = controller.login("admin", "123");
      expected = true;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('login should return false for invalid password', () {
      // (2) exercise (act, operate)
      actual = controller.login("admin", "wrongpassword");
      expected = false;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    test('login should return false for unregistered user', () {
      // (2) exercise (act, operate)
      actual = controller.login("unknown_user", "123");
      expected = false;

      // (3) verify (assert, check)
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });
  });
}