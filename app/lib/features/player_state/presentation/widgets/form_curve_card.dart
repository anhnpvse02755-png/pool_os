import 'package:flutter/material.dart';
import 'package:pool_os/features/player_state/domain/form_curve_analyzer.dart';

/// Task 07: renders a form curve — a per-rack sparkline with colored zone bands
/// (Cold/Warm-up/Peak/Fatigue) plus Coach-style plain-language explanations,
/// each backed by a computed number. Shows "not enough data" rather than
/// fabricating zones on thin data.
class FormCurveCard extends StatelessWidget {
  final FormCurve curve;
  const FormCurveCard({super.key, required this.curve});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(vi ? 'Phong độ theo Rack' : 'Form over racks',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (!curve.hasEnoughData)
              Text(
                vi
                    ? 'Chưa đủ dữ liệu để phân tích phong độ (cần ít nhất ${FormCurveAnalyzer.minRacksForCurve} rack).'
                    : 'Not enough data yet (need at least ${FormCurveAnalyzer.minRacksForCurve} racks).',
                style: TextStyle(color: Colors.grey[600]),
              )
            else ...[
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _FormCurvePainter(curve, theme),
                ),
              ),
              const SizedBox(height: 8),
              _legend(vi),
              const SizedBox(height: 12),
              ..._explanations(vi).map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 8),
                          child: Icon(Icons.chevron_right, size: 16),
                        ),
                        Expanded(child: Text(line, style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legend(bool vi) {
    Widget dot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ]);
    return Wrap(spacing: 12, runSpacing: 4, children: [
      dot(_zoneColor(FormZoneKind.cold), vi ? 'Lạnh' : 'Cold'),
      dot(_zoneColor(FormZoneKind.warmUp), vi ? 'Khởi động' : 'Warm-up'),
      dot(_zoneColor(FormZoneKind.peak), vi ? 'Đỉnh' : 'Peak'),
      dot(_zoneColor(FormZoneKind.fatigue), vi ? 'Xuống sức' : 'Fatigue'),
    ]);
  }

  /// Coach-style statements, each tied to a computed quantity (doc: no generic
  /// advice — every line cites a number).
  List<String> _explanations(bool vi) {
    final lines = <String>[];
    final steady = curve.zones.length == 1 && curve.zones.first.kind == FormZoneKind.steady;
    if (steady) {
      lines.add(vi
          ? 'Bạn giữ phong độ đều trong suốt ${curve.points.length} rack — không thấy giai đoạn nóng máy hay xuống sức rõ rệt.'
          : 'You held steady across all ${curve.points.length} racks — no clear warm-up or fatigue phase.');
      return lines;
    }
    if (curve.warmUpRacks > 0) {
      lines.add(vi
          ? 'Bạn thường cần khoảng ${curve.warmUpRacks} rack để vào phong độ tốt nhất.'
          : 'You usually need about ${curve.warmUpRacks} racks to reach peak form.');
    } else {
      lines.add(vi ? 'Bạn vào form nhanh — gần như không cần khởi động.' : 'You start hot — little warm-up needed.');
    }
    if (curve.peakRack != null) {
      lines.add(vi
          ? 'Phong độ đạt đỉnh quanh rack ${curve.peakRack}.'
          : 'Your form peaks around rack ${curve.peakRack}.');
    }
    if (curve.fatigueOnsetRack != null) {
      final z = curve.zones.firstWhere((z) => z.kind == FormZoneKind.fatigue,
          orElse: () => curve.zones.last);
      final mins = z.startMinute;
      final timePart = mins == null ? '' : (vi ? ' (~${mins.round()} phút)' : ' (~${mins.round()} min)');
      lines.add(vi
          ? 'Sau rack ${curve.fatigueOnsetRack}$timePart độ chính xác bắt đầu giảm.'
          : 'After rack ${curve.fatigueOnsetRack}$timePart your accuracy starts to drop.');
    } else {
      lines.add(vi ? 'Không thấy dấu hiệu xuống sức trong buổi này.' : 'No fatigue drop detected this session.');
    }
    return lines;
  }

  static Color _zoneColor(FormZoneKind k) {
    switch (k) {
      case FormZoneKind.cold:
        return Colors.blueGrey;
      case FormZoneKind.warmUp:
        return Colors.orange;
      case FormZoneKind.peak:
        return Colors.green;
      case FormZoneKind.fatigue:
        return Colors.red;
      case FormZoneKind.steady:
        return Colors.teal;
    }
  }
}

class _FormCurvePainter extends CustomPainter {
  final FormCurve curve;
  final ThemeData theme;
  _FormCurvePainter(this.curve, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = curve.points;
    if (pts.isEmpty) return;
    final n = pts.length;

    // Zone band backgrounds (by rack number range).
    final rackToX = <int, double>{};
    for (var i = 0; i < n; i++) {
      rackToX[pts[i].rackNumber] = n == 1 ? 0 : size.width * i / (n - 1);
    }
    for (final z in curve.zones) {
      final x0 = (rackToX[z.startRack] ?? 0) - (size.width / (n * 2));
      final x1 = (rackToX[z.endRack] ?? size.width) + (size.width / (n * 2));
      final band = Paint()..color = FormCurveCard._zoneColor(z.kind).withAlpha(28);
      canvas.drawRect(
        Rect.fromLTRB(x0.clamp(0, size.width), 0, x1.clamp(0, size.width), size.height),
        band,
      );
    }

    // Curve using the smoothed form signal (0..1).
    final line = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = theme.colorScheme.primary;
    final path = Path();
    final series = curve.smoothed.isNotEmpty
        ? curve.smoothed
        : pts.map((p) => p.formSignal).toList();
    for (var i = 0; i < n; i++) {
      final x = n == 1 ? size.width / 2 : size.width * i / (n - 1);
      final y = size.height - series[i].clamp(0.0, 1.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _FormCurvePainter old) => old.curve != curve;
}
