import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StatPillWidget extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int targetValue;
  final String suffix;

  const StatPillWidget({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.targetValue,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final bgColor     = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final valueColor  = AppColors.textOf(context);
    final labelColor  = AppColors.text2Of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(icon, style: TextStyle(color: iconColor, fontSize: 15))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$targetValue$suffix',
                style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: labelColor, fontSize: 10.5)),
          ],
        ),
      ]),
    );
  }
}

class StatPillsRow extends StatelessWidget {
  const StatPillsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Expanded(child: StatPillWidget(
        icon: '⚡',
        iconBg: isDark ? const Color(0xFF1a1d35) : const Color(0xFFEEF0FF),
        iconColor: const Color(0xFF818cf8),
        label: 'Lorem', targetValue: 42, suffix: 'ms',
      )),
      const SizedBox(width: 10),
      Expanded(child: StatPillWidget(
        icon: '✓',
        iconBg: isDark ? const Color(0xFF0d2420) : const Color(0xFFE6FAF5),
        iconColor: const Color(0xFF34d399),
        label: 'Lorem', targetValue: 99, suffix: '%',
      )),
      const SizedBox(width: 10),
      Expanded(child: StatPillWidget(
        icon: '◈',
        iconBg: isDark ? const Color(0xFF261d0d) : const Color(0xFFFFF8E6),
        iconColor: const Color(0xFFf59e0b),
        label: 'Lorem', targetValue: 1247, suffix: '',
      )),
    ]);
  }
}