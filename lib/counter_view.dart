import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  void _onReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah Anda yakin ingin menghapus semua history dan mereset angka ke 0?"),
          actions: [
            // button cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            // button yes
            TextButton(
              onPressed: () {
                setState(() {
                  _controller.reset();
                });

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data berhasil di-reset!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green, // Warna hijau agar terlihat sukses
                  ),
                );
              },
              child: const Text("Ya, Reset", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: Task 3 (Complete)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // bagian dari Slider sama site button
            Column(
              // menampilkan step
              children: [
                Text("Step: ${_controller.step}", style: const TextStyle(fontSize: 20)),
                // slider untuk mengubah nilai Step
                Slider(
                  value: _controller.step.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _controller.step.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _controller.setStep(value.toInt());
                    });
                  },
                ),
                const Divider(),
                const Text("Total Hitungan:"),
                Text(
                  '${_controller.value}',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Riwayat Perubahan (Max 5):", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            Expanded(
              // pembuatan list riwayat perubahan sebanyak 5 perubahan
              child: _controller.history.isEmpty
                  ? const Center(child: Text("Belum ada riwayat"))
                  : ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.blue),
                      title: Text(_controller.history[index]),
                      subtitle: Text("Data ke-${index + 1}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // menampilkan button (reset, kurang, tambah)
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // tombol reset
          FloatingActionButton(
            onPressed: _onReset,
            backgroundColor: Colors.red,
            child: const Icon(Icons.refresh),
          ),
          // tombol decrement (-)
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.remove),
          ),
          // tombol increment (+)
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}