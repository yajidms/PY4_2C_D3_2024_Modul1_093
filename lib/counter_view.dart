import 'package:flutter/material.dart';
import 'counter_controller.dart';
import 'widgets/counter_header.dart';
import 'widgets/history_list.dart';
import 'widgets/action_buttons.dart';

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
          content: const Text("Yakin reset data?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() => _controller.reset());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Data di-reset!")));
              },
              child: const Text(
                "Ya, Reset",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Refactored UI")),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //bagian header counter terutama untuk slider
            CounterHeader(
              step: _controller.step,
              value: _controller.value,
              onStepChanged: (val) => setState(() => _controller.setStep(val)),
            ),

            const SizedBox(height: 20),

            //bagian list riwayat
            Expanded(child: HistoryList(history: _controller.history)),
          ],
        ),
      ),

      //bagian action button
      floatingActionButton: ActionButtons(
        onIncrement: () => setState(() => _controller.increment()),
        onDecrement: () => setState(() => _controller.decrement()),
        onReset: _onReset,
      ),
    );
  }
}
