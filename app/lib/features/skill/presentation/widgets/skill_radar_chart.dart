import 'package:flutter/material.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SkillRadarChart extends StatelessWidget {
  final List<PlayerSkill> skills;
  final double size;

  const SkillRadarChart({
    super.key,
    required this.skills,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (skills.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            AppLocalizations.of(context).get('no_skills_yet'),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          skills: skills,
          primaryColor: colorScheme.primary,
          secondaryColor: colorScheme.secondary,
          gridColor: colorScheme.outline.withOpacity(0.3),
          backgroundColor: colorScheme.surface,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<PlayerSkill> skills;
  final Color primaryColor;
  final Color secondaryColor;
  final Color gridColor;
  final Color backgroundColor;

  _RadarChartPainter({
    required this.skills,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gridColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;

    _drawGrid(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawDataArea(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 5; level++) {
      final levelRadius = radius * (level / 5);
      _drawPolygon(canvas, center, levelRadius, gridPaint);
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angleStep = (2 * 3.14159) / skills.length;

    for (int i = 0; i < skills.length; i++) {
      final angle = -3.14159 / 2 + angleStep * i;
      final x = center.dx + radius * _cos(angle);
      final y = center.dy + radius * _sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final labelPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final angleStep = (2 * 3.14159) / skills.length;

    for (int i = 0; i < skills.length; i++) {
      final angle = -3.14159 / 2 + angleStep * i;
      final endX = center.dx + radius * _cos(angle);
      final endY = center.dy + radius * _sin(angle);

      canvas.drawLine(center, Offset(endX, endY), axisPaint);

      labelPaint.text = TextSpan(
        text: _getCategoryShortName(skills[i].category),
        style: TextStyle(
          color: primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      labelPaint.layout();

      final labelRadius = radius + 20;
      final labelX = center.dx + labelRadius * _cos(angle) - labelPaint.width / 2;
      final labelY = center.dy + labelRadius * _sin(angle) - labelPaint.height / 2;

      labelPaint.paint(canvas, Offset(labelX, labelY));
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius) {
    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final angleStep = (2 * 3.14159) / skills.length;

    for (int i = 0; i < skills.length; i++) {
      final angle = -3.14159 / 2 + angleStep * i;
      final valueRadius = radius * (skills[i].score / 100);
      final x = center.dx + valueRadius * _cos(angle);
      final y = center.dy + valueRadius * _sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    for (int i = 0; i < skills.length; i++) {
      final angle = -3.14159 / 2 + angleStep * i;
      final valueRadius = radius * (skills[i].score / 100);
      final x = center.dx + valueRadius * _cos(angle);
      final y = center.dy + valueRadius * _sin(angle);

      final dotPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  String _getCategoryShortName(String category) {
    switch (category) {
      case 'stroke':
        return 'STK';
      case 'position':
        return 'POS';
      case 'decision':
        return 'DEC';
      case 'pattern':
        return 'PAT';
      case 'breakShot':
        return 'BRK';
      case 'safety':
        return 'SFT';
      case 'mental':
        return 'MNT';
      case 'consistency':
        return 'CON';
      case 'equipment':
        return 'EQP';
      case 'recovery':
        return 'RCV';
      default:
        return category.substring(0, 3).toUpperCase();
    }
  }

  double _cos(double angle) => angle.isNaN ? 0 : angle.abs() < 0.0001 ? 1 : _cosImpl(angle);
  double _sin(double angle) => angle.isNaN ? 0 : angle.abs() < 0.0001 ? 0 : _sinImpl(angle);

  double _cosImpl(double x) {
    return x - x * x * x / 6 + x * x * x * x * x / 120;
  }

  double _sinImpl(double x) {
    return 1 - x * x / 2 + x * x * x * x / 24;
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.skills != skills;
  }
}
