import 'package:shared_preferences/shared_preferences.dart';
class CounterController {
  int _counter = 0;
  int _step = 1;

  //penambahan variabel list untuk history atau riwayat
  final List<String> _history = [];

  String _activeUser = "";

  int get value => _counter;
  int get step => _step;

  //getter untuk mengambil riwayat atau history
  List<String> get history => _history;

  Future<void> initUser(String username) async {
    _activeUser = username;
    await _loadData();
  }

  // Fungsi untuk memuat data dari SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('${_activeUser}_counter') ?? 0;

  }

  // Fungsi untuk menyimpan data ke SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_activeUser}_counter', _counter);
  }

  // Fungsi untuk menambahkan catatan ke riwayat
  void _addHistory(String action, int amount) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "[$time] User $_activeUser: $action $amount");
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // untuk pencatatan history
  void increment() {
    _counter += _step;
    _addHistory("Ditambah", _step);
    _saveData();
  }

  void decrement() {
    _counter -= _step;
    _addHistory("Dikurang", _step);
    _saveData();
  }

  //untuk hapus history saat melakukan reset
  void reset() {
    _counter = 0;
    _history.clear();
    _history.insert(0, "Data di-reset ke 0");
    _saveData();
  }

  void setStep(int newStep) {
    _step = newStep;
  }
}