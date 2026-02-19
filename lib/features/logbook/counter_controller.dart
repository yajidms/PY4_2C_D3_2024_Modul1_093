import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

  //variabel untuk menyimpan riwayat atau history
  List<String> _history = [];
  String _activeUser = "";
  int get value => _counter;
  int get step => _step;

  // getter untuk mengambil riwayat atau history
  List<String> get history => _history;

  Future<void> initData(String username) async {
    _activeUser = username;
    _counter = await loadLastValue(username);
    _history = await loadHistory(username);
  }

  Future<int> loadLastValue(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${username}_counter') ?? 0;
  }

  Future<void> saveLastValue(int value, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_counter', value);
  }

  //memuat fungsi baru untuk memuat riwayat history dari memori HP
  Future<List<String>> loadHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${username}_history') ?? [];
  }

  //menyimpan fungsi untuk menyimpan riwayat history ke memori HP
  Future<void> saveHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${username}_history', _history);
  }

  //fungsi untuk menambahkan riwayat atau history
  void _addHistory(String action, int amount) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "[$time] $action $amount");
    if (_history.length > 5) {
      _history.removeLast();
    }
    saveHistory(_activeUser);
  }

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
    final time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "[$time] Data di-reset ke 0");
    saveLastValue(_counter, _activeUser);
    saveHistory(_activeUser);
  }

  void setStep(int newStep) {
    _step = newStep;
  }
}