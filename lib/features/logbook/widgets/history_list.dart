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
          "Riwayat Perubahan :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: history.isEmpty
              ? const Center(child: Text("Belum ada riwayat"))
              : ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              const addedColor = Color(0xFF228B22);
              const reducedColor = Color(0xFFFF0000);

              Color? pickAccentColor(String text) {
                if (text.contains('Ditambah')) return addedColor;
                if (text.contains('Dikurang')) return reducedColor;
                return null;
              }

              final entry = history[index];
              final accentColor = pickAccentColor(entry);
              final tileColor = accentColor?.withOpacity(0.18);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: tileColor,
                child: ListTile(
                  tileColor: tileColor,
                  leading: Icon(
                    Icons.history,
                    color: accentColor ?? Colors.blue,
                  ),
                  title: Text(
                    entry,
                  ),
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