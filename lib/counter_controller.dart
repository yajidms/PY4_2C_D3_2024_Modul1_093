class CounterController {
  int _counter = 0; // Variabel private state
  int _step = 1;

  int get value => _counter; // Getter nilai counter
  int get step => _step;

  void setStep(int val) {
    _step = val;
  }

  void increment() {
    _counter += _step;
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
    } else {
      _counter = 0;
    }
  }

  void reset() => _counter = 0;
}