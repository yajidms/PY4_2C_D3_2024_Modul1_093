class CounterController {
  int _counter = 0;
  int _step = 1;

  //penambahan variabel list untuk history atau riwayat
  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;

  //getter untuk mengambil riwayat atau history
  List<String> get history => _history;

  void setStep(int val) {
    _step = val;
  }

  // untuk pencatatan history
  void increment() {
    _counter += _step;
    _addHistory("Ditambah $_step menjadi $_counter");
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
      _addHistory("Dikurang $_step menjadi $_counter");
    } else {
      _counter = 0;
      _addHistory("Dikurang mentok ke 0");
    }
  }

  //untuk hapus history saat melakukan reset
  void reset() {
    _counter = 0;
    _history.clear();
  }

  // untuk memeriksa data lama yang lebih dari 5 (perubahan ke terbaru)
  void _addHistory(String message) {
    _history.insert(0, message);

    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}