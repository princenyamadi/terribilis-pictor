import 'package:flutter/material.dart';
import 'package:terriblis_pictor/drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine?>? lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines!.length; ++i) {
      if (lines![i] == null) continue;
      for (int j = 0; j < lines![i]!.path.length - 1; ++j) {
        if (lines![i]!.path[j] != null && lines![i]!.path[j + 1] != null) {
          paint.color = lines![i]!.color;
          paint.strokeWidth = lines![i]!.width;
          canvas.drawLine(lines![i]!.path[j] as Offset,
              lines![i]!.path[j + 1] as Offset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
