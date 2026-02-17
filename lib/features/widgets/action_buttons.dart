import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const ActionButtons({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: onReset,
          backgroundColor: Colors.red,
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onDecrement,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onIncrement,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}