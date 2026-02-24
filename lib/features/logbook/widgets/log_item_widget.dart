import 'package:flutter/material.dart';
import '../models/log_model.dart';

//color yang dipakai
const Color _kCardBg = Color(0xFFFFFFFF);
const Color _kAccentBlue = Color(0xFF3D8BE8);
const Color _kTextDark = Color(0xFF2D3E50);
const Color _kTextLight = Color(0xFF7F8C8D);

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                decoration: const BoxDecoration(
                  color: _kAccentBlue,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              log.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _kTextDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Menampilkan tanggal
                          Text(
                            _formatSimpleDate(log.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kTextLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Deskripsi
                      Text(
                        log.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _kTextLight,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // button Edit & Delete
              Container(
                decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey.shade100))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onEditPressed,
                      icon: const Icon(Icons.edit_outlined),
                      color: _kAccentBlue,
                      tooltip: "Edit",
                    ),
                    IconButton(
                      onPressed: onDeletePressed,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent.shade200,
                      tooltip: "Hapus",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // fungsi untuk memformat tanggal
  String _formatSimpleDate(String dateString) {
    try {
      final DateTime dt = DateTime.parse(dateString);
      return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (e) {
      return "";
    }
  }
}