import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final VoidCallback? onTap;
  final bool canEdit;
  final bool canDelete;
  final bool isOnline;
  final Color? cardColor;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTap,
    this.canEdit = true,
    this.canDelete = true,
    this.isOnline = true,
    this.cardColor,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mechanical':
        return Icons.build_outlined;
      case 'electronic':
        return Icons.electrical_services_outlined;
      case 'software':
        return Icons.code_outlined;
      default:
        return Icons.label_outline;
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'mechanical':
        return Colors.green.shade700;
      case 'electronic':
        return Colors.blue.shade700;
      case 'software':
        return Colors.purple.shade700;
      default:
        return Colors.teal;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mechanical':
        return Colors.green.shade100;
      case 'electronic':
        return Colors.blue.shade100;
      case 'software':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor ?? _kCardBg,
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
                                color: isOnline
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOnline
                                        ? Icons.cloud_done_outlined
                                        : Icons.cloud_off_outlined,
                                    size: 13,
                                    color: isOnline
                                        ? Colors.blue
                                        : Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOnline ? 'Cloud' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isOnline
                                          ? Colors.blue
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // PRIVACY INDICATOR CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: log.isPublic
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    log.isPublic ? Icons.public : Icons.lock,
                                    size: 13,
                                    color: log.isPublic
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.isPublic ? 'Publik' : 'Privat',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: log.isPublic
                                          ? Colors.green.shade700
                                          : Colors.grey.shade600,
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
                                      color: _getCategoryIconColor(
                                        log.category,
                                      ),
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
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (canEdit)
                        IconButton(
                          onPressed: onEditPressed,
                          icon: const Icon(Icons.edit_outlined),
                          color: _kAccentBlue,
                          tooltip: "Edit",
                        ),
                      if (canDelete)
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
      ),
    );
  }

  // fungsi untuk memformat tanggal
  String _formatSimpleDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    }
  }
}
