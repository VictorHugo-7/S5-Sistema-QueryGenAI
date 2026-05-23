import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_notifier.dart';
import '../main.dart';
import 'profile_modal.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showMenuButton;

  const AppHeader({
    super.key,
    required this.title,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeNotifier notifier = MyApp.of(context);
    final bool isDark = notifier.isDark;

    return SizedBox(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Menu button (mobile)
            if (showMenuButton)
              Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColors.textOf(context)),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            if (showMenuButton) const SizedBox(width: 8),

            // Título
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: AppColors.textOf(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // Perfil
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: AppColors.text2Of(context), size: 22),
              tooltip: 'Meu Perfil',
              onPressed: () => showProfileModal(context),
            ),

            const SizedBox(width: 4),

            // Dark/light mode
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: IconButton(
                key: ValueKey(isDark),
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.text2Of(context),
                  size: 22,
                ),
                tooltip: isDark ? 'Modo claro' : 'Modo escuro',
                onPressed: notifier.toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}