import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: SRP"),
      ),
      // bagian dari Slider sama site button
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Column(
              children: [
                // menampilkan step
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
              child: Text("Riwayat Perubahan :", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            Expanded(
              // pembuatan list riwayat perubahan sebanyak 5 perubahan
              child: ListView.builder(
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
            onPressed: () => setState(() => _controller.reset()),
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