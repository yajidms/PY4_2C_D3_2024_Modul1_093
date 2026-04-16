import 'package:flutter/material.dart';

class DetectionResult {
  final Rect box;     // Koordinat normalisasi (0.0 sampai 1.0)
  final String label; // Tipe kerusakan (misal: D40 Pothole)
  final double score; // Persentase keyakinan (Confidence)

  DetectionResult({
    required this.box,
    required this.label,
    required this.score,
  });
}
