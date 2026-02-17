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

  Future<void> initData(String username) async {
    _activeUser = username;
    _counter = await loadLastValue(username);
  }

  // Fungsi untuk memuat data dari SharedPreferences
  Future<int> loadLastValue(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${username}_counter') ?? 0;
  }

  // Fungsi untuk menyimpan data ke SharedPreferences
  Future<void> saveLastValue(int value, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_counter', value);
  }

  // Fungsi untuk menambahkan catatan ke riwayat
  void _addHistory(String action, int amount) {
    _history.insert(0, "$action $amount");
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // untuk pencatatan history
  void increment() {
    _counter += _step;
    _addHistory("Ditambah", _step);
    saveLastValue(_counter, _activeUser);
  }

  void decrement() {
    _counter -= _step;
    _addHistory("Dikurang", _step);
    saveLastValue(_counter, _activeUser);
  }

  void reset() {
    _counter = 0;
    _history.clear();
    _history.insert(0, "Data di-reset ke 0");
    saveLastValue(_counter, _activeUser);
  }

  void setStep(int newStep) {
    _step = newStep;
  }
}