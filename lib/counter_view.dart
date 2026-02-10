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
        title: const Text("LogBook SRP bagian Task 1"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // menampilkan step
              Text("Step: ${_controller.step}", style: const TextStyle(fontSize: 20)),

              //slider untuk mengubah nilai Step
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

              const Divider(), // Garis pemisah estetis

              const Text("Total Hitungan:"),
              Text(
                '${_controller.value}',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
          const SizedBox(width: 10),

          // tombol decrement (-)
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),

          // tombol increment (+)
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}