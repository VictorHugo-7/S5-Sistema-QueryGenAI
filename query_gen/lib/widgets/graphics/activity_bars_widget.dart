import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ActivityBarsWidget extends StatelessWidget {
  final String title;
  final List<ActivityItem> items;

  const ActivityBarsWidget({
    super.key,
    this.title = 'Lorem',
    this.items = const [
      ActivityItem(label: '/lorem', value: 0.72, color: Color(0xFF6366f1)),
      ActivityItem(label: '/lorem', value: 0.45, color: Color(0xFF818cf8)),
      ActivityItem(label: '/lorem', value: 0.88, color: Color(0xFF34d399)),
      ActivityItem(label: '/lorem', value: 0.31, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final bgColor     = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final titleColor  = AppColors.text2Of(context);
    final labelColor  = AppColors.text2Of(context);
    final trackColor  = AppColors.surfaceOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF34d399),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF34d399).withOpacity(0.6), blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 6),
            Text(title.toUpperCase(),
                style: TextStyle(color: titleColor, fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 14),
          Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
                child: Row(children: [
                  SizedBox(width: 80,
                      child: Text(item.label, style: TextStyle(color: labelColor, fontSize: 11.5))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(children: [
                        Container(height: 26, color: trackColor),
                        FractionallySizedBox(
                          widthFactor: item.value.clamp(0.0, 1.0),
                          child: Container(
                            height: 26,
                            decoration: BoxDecoration(
                                color: item.color.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text('${(item.value * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: item.color, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ),
                ]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String label;
  final double value;
  final Color color;
  const ActivityItem({required this.label, required this.value, required this.color});
}