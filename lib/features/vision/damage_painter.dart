import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Konfigurasi "Kuas" Digital
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // 2. Menghitung Dimensi Kotak (Area Pemindaian Statis)
    // Membuat kotak di tengah layar seluas 50% dari lebar layar (Logical Pixels)
    double boxSize = size.width * 0.5;
    double left = (size.width - boxSize) / 2;
    double top = (size.height - boxSize) / 2;

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);

    // 3. Menggambar Kotak ke Kanvas
    canvas.drawRect(rect, paint);

    // Menggambar Crosshair Anchor pada sudut kotak
    const double crosshairLength = 15.0;

    // Sudut Kiri Atas
    canvas.drawLine(
      Offset(left, top),
      Offset(left + crosshairLength, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + crosshairLength),
      paint,
    );
    // Sudut Kanan Atas
    canvas.drawLine(
      Offset(left + boxSize, top),
      Offset(left + boxSize - crosshairLength, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxSize, top),
      Offset(left + boxSize, top + crosshairLength),
      paint,
    );
    // Sudut Kiri Bawah
    canvas.drawLine(
      Offset(left, top + boxSize),
      Offset(left + crosshairLength, top + boxSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + boxSize),
      Offset(left, top + boxSize - crosshairLength),
      paint,
    );
    // Sudut Kanan Bawah
    canvas.drawLine(
      Offset(left + boxSize, top + boxSize),
      Offset(left + boxSize - crosshairLength, top + boxSize),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxSize, top + boxSize),
      Offset(left + boxSize, top + boxSize - crosshairLength),
      paint,
    );

    // 4. Konstruksi Label Tipe Kerusakan (Sesuai instruksi Task 3)
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.redAccent,
    );

    const textSpan = TextSpan(
      text: " Searching for Road Damage... ",
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    // 5. Proses Layouting & Rendering Teks
    textPainter.layout();

    // Penempatan presisi: Jika koordinat Y teks negatif (terpotong atas), pindahkan ke bawah kotak
    double textY = top - 25;
    if (textY < 0) {
      textY = top + boxSize + 5;
    }

    textPainter.paint(canvas, Offset(left, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Pada Task 3 ini bersifat statis, kembalikan false untuk menghemat CPU.
    return false;
  }
}