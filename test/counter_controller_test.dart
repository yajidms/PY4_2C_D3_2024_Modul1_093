import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_093/counter_controller.dart';

void main() {
  group('CounterController', () {
    late CounterController controller;

    setUp(() {
      controller = CounterController();
    });

    // TC01
    test('initial value should be 0', () {
      // (1) setup (arrange, build)
      // Controller initialized in setUp

      // (2) exercise (act, operate)
      final value = controller.value;

      // (3) verify (assert, check)
      expect(value, 0);
    });

    // TC02
    test('setStep should change step value', () {
      // (1) setup (arrange, build)
      // Controller initialized in setUp

      // (2) exercise (act, operate)
      controller.setStep(5);

      // (3) verify (assert, check)
      expect(controller.step, 5);
    });

    // TC03
    test('setStep should change step value even if negative', () {
      // (1) setup (arrange, build)
      controller.setStep(3);

      // (2) exercise (act, operate)
      controller.setStep(-1);

      // (3) verify (assert, check)
      expect(controller.step, -1);
    });

    // TC04
    test('increment should increase counter by step', () {
      // (1) setup (arrange, build)
      controller.setStep(2);

      // (2) exercise (act, operate)
      controller.increment();

      // (3) verify (assert, check)
      expect(controller.value, 2);
    });

    // TC05
    test('decrement should decrease counter by step if counter >= step', () {
      // (1) setup (arrange, build)
      controller.setStep(2);
      controller.increment();
      controller.increment(); // value is now 4

      // (2) exercise (act, operate)
      controller.decrement();

      // (3) verify (assert, check)
      expect(controller.value, 2);
    });

    // TC06
    test('decrement should set counter to 0 if counter < step', () {
      // (1) setup (arrange, build)
      controller.setStep(2);
      controller.increment(); // value is 2
      controller.setStep(3); // set step to 3, value is still 2

      // (2) exercise (act, operate)
      controller.decrement();

      // (3) verify (assert, check)
      expect(controller.value, 0);
    });

    // TC07
    test('reset should set counter to 0 and clear history', () {
      // (1) setup (arrange, build)
      controller.increment(); // value is 1, history has 1 item

      // (2) exercise (act, operate)
      controller.reset();

      // (3) verify (assert, check)
      expect(controller.value, 0);
      expect(controller.history, isEmpty);
    });

    // TC08
    test('history should add new item on increment/decrement', () {
      // (1) setup (arrange, build)
      // Controller initialized in setUp

      // (2) exercise (act, operate)
      controller.increment();

      // (3) verify (assert, check)
      expect(controller.history.length, 1);
      expect(controller.history.first, "Ditambah 1 menjadi 1");
    });

    // TC09
    test('history should keep maximum 5 items', () {
      // (1) setup (arrange, build)
      // Controller initialized in setUp

      // (2) exercise (act, operate)
      for (int i = 0; i < 6; i++) {
        controller.increment();
      }

      // (3) verify (assert, check)
      expect(controller.history.length, 5);
      expect(controller.history.first, "Ditambah 1 menjadi 6");
      expect(controller.history.last, "Ditambah 1 menjadi 2");
    });

    // TC10
    test('history adds new items to the beginning of the list', () {
      // (1) setup (arrange, build)
      controller.increment();

      // (2) exercise (act, operate)
      controller.increment();

      // (3) verify (assert, check)
      expect(controller.history.first, "Ditambah 1 menjadi 2");
      expect(controller.history[1], "Ditambah 1 menjadi 1");
    });
  });
}

