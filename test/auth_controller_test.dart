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

    test(
      'login should return true for username with trailing/leading spaces (Bug Fixed on Client Side)',
      () {
        String inputUsername = " admin ";
        String inputPassword = "123";
        actual = controller.login(inputUsername.trim(), inputPassword.trim());
        expected = true;
        expect(actual, expected, reason: 'Expected $expected but got $actual');
      },
    );
  });
}