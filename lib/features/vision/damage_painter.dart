import 'package:flutter/material.dart';
import 'models/detection_result.dart';

class DamagePainter extends CustomPainter {
  final DetectionResult? detection;

  DamagePainter(this.detection);

  @override
  void paint(Canvas canvas, Size size) {
    if (detection == null) return;

    bool isSevere = detection!.label.contains("D40");
    Color targetColor = isSevere ? Colors.redAccent : Colors.orangeAccent;

    final paint = Paint()
      ..color = targetColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    double left = detection!.box.left * size.width;
    double top = detection!.box.top * size.height;
    double boxWidth = detection!.box.width * size.width;
    double boxHeight = detection!.box.height * size.height;

    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);

    canvas.drawRect(rect, paint);

    const double crosshairLength = 15.0;

    // Kiri Atas
    canvas.drawLine(Offset(left, top), Offset(left + crosshairLength, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + crosshairLength), paint);
    // Kanan Atas
    canvas.drawLine(Offset(left + boxWidth, top), Offset(left + boxWidth - crosshairLength, top), paint);
    canvas.drawLine(Offset(left + boxWidth, top), Offset(left + boxWidth, top + crosshairLength), paint);
    // Kiri Bawah
    canvas.drawLine(Offset(left, top + boxHeight), Offset(left + crosshairLength, top + boxHeight), paint);
    canvas.drawLine(Offset(left, top + boxHeight), Offset(left, top + boxHeight - crosshairLength), paint);
    // Kanan Bawah
    canvas.drawLine(Offset(left + boxWidth, top + boxHeight), Offset(left + boxWidth - crosshairLength, top + boxHeight), paint);
    canvas.drawLine(Offset(left + boxWidth, top + boxHeight), Offset(left + boxWidth, top + boxHeight - crosshairLength), paint);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: targetColor.withValues(alpha: 0.8),
      shadows: const [
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 3.0,
          color: Colors.black54,
        ),
      ],
    );

    final textSpan = TextSpan(
      text: " ${detection!.label} ",
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    double textY = top - 25;
    if (textY < 0) {
      textY = top + boxHeight + 5;
    }

    textPainter.paint(canvas, Offset(left, textY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    return oldDelegate.detection != detection;
  }
}