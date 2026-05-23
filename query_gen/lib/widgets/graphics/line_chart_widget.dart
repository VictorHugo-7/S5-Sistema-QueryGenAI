import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LineChartWidget extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data2025;
  final List<double> data2024;
  final List<String> xLabels;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    this.label = 'Lorem',
    this.value = 'R\$ 237k',
    this.delta = '▲ 14.2%',
    this.data2025 = const [0.15, 0.28, 0.42, 0.48, 0.60, 0.64, 0.74, 0.84],
    this.data2024 = const [0.05, 0.10, 0.18, 0.25, 0.32, 0.36, 0.40, 0.44],
    this.xLabels = const ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago'],
    this.lineColor = const Color(0xFF6366f1),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor      = AppColors.panelOf(context);
    final borderColor  = AppColors.borderOf(context);
    final labelColor   = AppColors.text2Of(context);
    final valueColor   = AppColors.textOf(context);
    final xLabelColor  = AppColors.text3Of(context);
    final ghostColor   = AppColors.borderOf(context);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: TextStyle(color: valueColor, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(delta, style: const TextStyle(color: Color(0xFF34d399), fontSize: 12)),
                  ],
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _LegendDot(color: lineColor, label: '2025', labelColor: labelColor),
                const SizedBox(height: 4),
                _LegendDot(color: ghostColor, label: '2024', labelColor: labelColor),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(
                data2025: data2025,
                data2024: data2024,
                lineColor: lineColor,
                ghostColor: ghostColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels.map((l) => Text(l, style: TextStyle(color: xLabelColor, fontSize: 9.5))).toList(),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data2025;
  final List<double> data2024;
  final Color lineColor;
  final Color ghostColor;

  _LinePainter({required this.data2025, required this.data2024, required this.lineColor, required this.ghostColor});

  List<Offset> _points(List<double> data, Size size) {
    final n = data.length;
    return List.generate(n, (i) => Offset(i / (n - 1) * size.width, (1.0 - data[i]) * size.height));
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts25 = _points(data2025, size);
    final pts24 = _points(data2024, size);

    canvas.drawPath(_smoothPath(pts24),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = ghostColor);

    final linePath = _smoothPath(pts25);
    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(areaPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.22), lineColor.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(linePath, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = lineColor);

    for (final pt in pts25) {
      canvas.drawCircle(pt, 3.5, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.lineColor != lineColor || old.ghostColor != ghostColor;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color labelColor;
  const _LegendDot({required this.color, required this.label, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: labelColor, fontSize: 11)),
    ]);
  }
}