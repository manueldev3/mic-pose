import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';
import 'package:supercontext/supercontext.dart';

double deg2rad(double deg) => deg * math.pi / 180;

/// Speed of Speech Graphic
class SpeechGraphic extends ConsumerWidget {
  const SpeechGraphic({
    super.key,
    required this.progress,
    this.title,
    this.startTitle,
    this.endTitle,
  });

  final double progress;
  final String? title;
  final String? startTitle;
  final String? endTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const SizedBox(
          width: 200,
          height: 200,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 64),
            child: Transform.rotate(
              angle: -1.4,
              child: CustomPaint(
                painter: CircularPaint(
                  progressValue: (1 / 225 * (progress > 100 ? 100 : progress)),
                ),
                child: const SizedBox(
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: title.isNotNull,
          child: Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Text(
              title ?? "",
              style: GoogleFonts.montserrat(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Visibility(
          visible: startTitle.isNotNull,
          child: Positioned(
            top: 64,
            left: 0,
            child: Text(
              startTitle ?? "",
              style: GoogleFonts.montserrat(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Visibility(
          visible: endTitle.isNotNull,
          child: Positioned(
            top: 64,
            right: 0,
            child: Text(
              endTitle ?? "",
              style: GoogleFonts.montserrat(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Text(
            "${progress.toStringAsFixed(0)}%",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CircularPaint extends CustomPainter {
  final double borderThickness;
  final double progressValue;

  CircularPaint({
    this.borderThickness = 3.5,
    required this.progressValue,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    final rect =
        Rect.fromCenter(center: center, width: size.width, height: size.height);

    Paint paint = Paint()
      ..color = const Color(0xFFE4E4E4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 48;

    //grey background
    canvas.drawArc(
      rect,
      deg2rad(-90),
      deg2rad(360 * (1 / 225 * 100)),
      false,
      paint,
    );

    Paint progressBarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 48
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xff86112E),
          const Color(0xff86112E).withOpacity(0.35),
        ],
      ).createShader(rect);
    canvas.drawArc(
      rect,
      deg2rad(-90),
      deg2rad(360 * progressValue),
      false,
      progressBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
