import 'package:flutter/material.dart';

class CounterHeader extends StatelessWidget {
  final int step;
  final int value;
  final ValueChanged<int> onStepChanged;

  const CounterHeader({
    super.key,
    required this.step,
    required this.value,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Step: $step", style: const TextStyle(fontSize: 20)),
        Slider(
          value: step.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: step.toString(),
          onChanged: (val) => onStepChanged(val.toInt()),
        ),
        const Divider(),
        const Text("Total Hitungan:"),
        Text(
          '$value',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}