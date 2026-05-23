import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DonutChartWidget extends StatelessWidget {
  final String label;
  final List<DonutSegment> segments;

  const DonutChartWidget({
    super.key,
    this.label = 'Lorem',
    this.segments = const [
      DonutSegment(label: 'Lorem', value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'Lorem', value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'Lorem', value: 0.18, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final bgColor     = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final labelColor  = AppColors.text2Of(context);
    final valueColor  = AppColors.textOf(context);
    final legendColor = AppColors.text2Of(context);
    final pctColor    = AppColors.textOf(context);
    final trackColor  = AppColors.borderOf(context);
    final centerLabelColor = AppColors.text3Of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
          Text('Lorem', style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: segments,
                      trackColor: trackColor,
                      centerLabelColor: centerLabelColor,
                      centerValueColor: valueColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(segments.length, (i) {
                      final seg = segments[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Row(children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle)),
                          const SizedBox(width: 7),
                          Text(seg.label, style: TextStyle(color: legendColor, fontSize: 12)),
                          const Spacer(),
                          Text('${(seg.value * 100).toInt()}%',
                              style: TextStyle(color: pctColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DonutSegment {
  final String label;
  final double value;
  final Color color;
  const DonutSegment({required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final Color trackColor;
  final Color centerLabelColor;
  final Color centerValueColor;

  _DonutPainter({
    required this.segments,
    required this.trackColor,
    required this.centerLabelColor,
    required this.centerValueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 10;
    const sw = 13.0;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..color = trackColor);

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = seg.value * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweep, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round..color = seg.color,
      );
      startAngle += sweep;
    }

    final tp = TextPainter(
      text: TextSpan(text: 'Total', style: TextStyle(color: centerLabelColor, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 14));

    final tp2 = TextPainter(
      text: TextSpan(text: '88%', style: TextStyle(color: centerValueColor, fontSize: 17, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(cx - tp2.width / 2, cy - 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.trackColor != trackColor || old.centerValueColor != centerValueColor;
}