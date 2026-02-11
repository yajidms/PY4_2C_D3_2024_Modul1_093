import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;

  const HistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Perubahan (Max 5):",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: history.isEmpty
              ? const Center(child: Text("Belum ada riwayat"))
              : ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(history[index]),
                  subtitle: Text("Data ke-${index + 1}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}