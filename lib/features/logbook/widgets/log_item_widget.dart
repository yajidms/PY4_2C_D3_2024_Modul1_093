import 'package:flutter/material.dart';
import '../models/log_model.dart';

//color yang dipakai
const Color _kCardBg = Color(0xFFFFFFFF);
const Color _kAccentBlue = Color(0xFF3D8BE8);
const Color _kTextDark = Color(0xFF2D3E50);
const Color _kTextLight = Color(0xFF7F8C8D);

class LogItemWidget extends StatelessWidget {
  final Logbook log;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Icons.work_outline;
      case 'Urgent':
        return Icons.warning_amber_rounded;
      case 'Kuliah':
        return Icons.school_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue;
      case 'Urgent':
        return Colors.red;
      case 'Kuliah':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade50;
      case 'Urgent':
        return Colors.red.shade50;
      case 'Kuliah':
        return Colors.orange.shade50;
      default:
        return Colors.teal.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                decoration: const BoxDecoration(color: _kAccentBlue),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_done_outlined,
                                  size: 13,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Cloud',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(log.category),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(log.category),
                                  size: 13,
                                  color: _getCategoryIconColor(log.category),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  log.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getCategoryIconColor(log.category),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                  border: Border(left: BorderSide(color: Colors.grey.shade100)),
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
  String _formatSimpleDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

}