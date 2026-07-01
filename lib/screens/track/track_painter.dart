// CustomPainter: draws the curved trail + animated stick figures
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/user_profile.dart';

class TrackPainter extends CustomPainter {
  final List<UserProfile> members;
  final double walkAnim; // 0..1 oscillation for leg swing
  final String localUid;

  TrackPainter({
    required this.members,
    required this.walkAnim,
    required this.localUid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildTrailPath(size);
    _drawTrail(canvas, size, path);
    _drawFlag(canvas, size, path);
    _drawFigures(canvas, size, path);
  }

  // Smooth S-curve trail matching the prototype
  Path _buildTrailPath(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.06, h * 0.88)
      ..cubicTo(
        w * 0.06, h * 0.55,
        w * 0.34, h * 0.68,
        w * 0.34, h * 0.42,
      )
      ..cubicTo(
        w * 0.34, h * 0.16,
        w * 0.62, h * 0.30,
        w * 0.62, h * 0.14,
      )
      ..cubicTo(
        w * 0.62, h * 0.02,
        w * 0.86, h * 0.08,
        w * 0.96, h * 0.06,
      );
  }

  void _drawTrail(Canvas canvas, Size size, Path path) {
    // Sand background track
    final bgPaint = Paint()
      ..color = AppColors.sandDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    // Dashed center line
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, path, dashPaint, dashLength: 4, gapLength: 12);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {required double dashLength, required double gapLength}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        if (drawing) {
          final end = math.min(dist + dashLength, metric.length);
          canvas.drawPath(metric.extractPath(dist, end), paint);
        }
        dist += drawing ? dashLength : gapLength;
        drawing = !drawing;
      }
    }
  }

  void _drawFlag(Canvas canvas, Size size, Path path) {
    final metrics = path.computeMetrics();
    final metric = metrics.first;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;

    final pos = tangent.position;
    final flagPaint = Paint()..color = AppColors.ink..strokeWidth = 2.5..strokeCap = StrokeCap.round;

    // Pole
    canvas.drawLine(Offset(pos.dx, pos.dy - 2), Offset(pos.dx, pos.dy - 32), flagPaint);

    // Flag rectangle
    final flagRect = Rect.fromLTWH(pos.dx, pos.dy - 32, 16, 10);
    canvas.drawRect(flagRect, Paint()..color = AppColors.ink);
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy - 32, 4, 10), Paint()..color = AppColors.white);
    canvas.drawRect(Rect.fromLTWH(pos.dx + 8, pos.dy - 32, 4, 10), Paint()..color = AppColors.white);
  }

  void _drawFigures(Canvas canvas, Size size, Path path) {
    final metrics = path.computeMetrics();
    final metric = metrics.first;

    // Sort so higher % renders on top
    final sorted = [...members]..sort((a, b) => a.pct.compareTo(b.pct));

    for (int i = 0; i < sorted.length; i++) {
      final user = sorted[i];
      final pct = user.pct.clamp(0.01, 1.0);
      final tangent = metric.getTangentForOffset(metric.length * pct);
      if (tangent == null) continue;

      final pos = tangent.position;
      final color = kAvatarColors[user.color] ?? AppColors.coral;
      final darkColor = kAvatarColorsDark[user.color] ?? AppColors.coralDark;

      // Alternate label above/below to avoid overlaps
      final labelAbove = i % 2 == 0;
      final isWalking = user.uid == localUid;
      final legAngle = isWalking ? math.sin(walkAnim * math.pi * 2) * 0.3 : 0.0;

      _drawStickFigure(canvas, pos, color, legAngle);
      _drawLabel(canvas, pos, user, darkColor, labelAbove);

      // Celebration emoji at goal
      if (user.goalHit) {
        _drawEmoji(canvas, Offset(pos.dx, pos.dy - 44), '🎉');
      }
    }
  }

  void _drawStickFigure(Canvas canvas, Offset center, Color color, double legAngle) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(center.dx, center.dy - 22), 6, fillPaint);

    // Body
    canvas.drawLine(
      Offset(center.dx, center.dy - 16),
      Offset(center.dx, center.dy),
      paint,
    );

    // Arms
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx - 7, center.dy - 4), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx + 7, center.dy - 4), paint);

    // Legs (animated)
    final leftAngle = math.pi / 2 + legAngle;
    final rightAngle = math.pi / 2 - legAngle;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + math.cos(leftAngle + math.pi) * 11, center.dy + math.sin(leftAngle + math.pi) * 11),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + math.cos(rightAngle + math.pi) * 11, center.dy + math.sin(rightAngle + math.pi) * 11),
      paint,
    );
  }

  void _drawLabel(Canvas canvas, Offset pos, UserProfile user, Color color, bool above) {
    final yOffset = above ? -42.0 : 24.0;
    final label = '${user.name}\n${user.steps.toLocaleString()} steps';

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + yOffset));
  }

  void _drawEmoji(Canvas canvas, Offset pos, String emoji) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(TrackPainter old) =>
      old.walkAnim != walkAnim || old.members != members;
}

extension _StepFormat on int {
  String toLocaleString() {
    final s = toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}
