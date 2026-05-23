import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_notifier.dart';
import '../../services/auth_service.dart';
import '../../screens/home_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/login_screen.dart';
import '../../widgets/profile/profile.dart';
import '../../main.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  const NavBar({super.key, required this.currentIndex});

  void _handleTap(BuildContext context, int index) async {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else if (index == 4) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeNotifier notifier = MyApp.of(context);
    final bool isDark = notifier.isDark;

    final Color bgColor    = AppColors.panelOf(context);
    final Color borderColor = AppColors.borderOf(context);
    final Color textColor  = AppColors.textOf(context);
    final Color text2Color = AppColors.text2Of(context);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 76,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Query',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const TextSpan(
                            text: 'Gen',
                            style: TextStyle(
                                color: AppColors.accent2,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(color: borderColor, height: 1),
          const SizedBox(height: 24),

          // Menu items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(context, 0, Icons.auto_awesome, 'Scripts'),
                  _buildMenuItem(context, 1, Icons.history, 'Histórico'),
                ],
              ),
            ),
          ),

          // Rodapé: tema + perfil + sair
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                // Botão de toggle dark/light
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: notifier.toggle,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              key: ValueKey(isDark),
                              color: text2Color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              isDark ? 'Modo claro' : 'Modo escuro',
                              key: ValueKey(isDark),
                              style: TextStyle(
                                color: text2Color,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isDark,
                            onChanged: (_) => notifier.toggle(),
                            activeColor: AppColors.accent,
                            activeTrackColor: AppColors.accent.withOpacity(0.3),
                            inactiveThumbColor: AppColors.amber,
                            inactiveTrackColor: AppColors.amber.withOpacity(0.25),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Divider(color: borderColor, height: 16),

                _buildMenuItem(context, 3, Icons.person_outline, 'Perfil'),
                const SizedBox(height: 8),
                _buildMenuItem(context, 4, Icons.logout, 'Sair',
                    isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    final bool isSelected = currentIndex == index && !isLogout;
    final Color itemColor =
        isSelected ? AppColors.accent2 : AppColors.text2Of(context);
    final Color selectedBgColor = AppColors.accent.withOpacity(0.15);
    final Color logoutColor = AppColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        onTap: () => _handleTap(context, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isLogout ? logoutColor : itemColor, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isLogout ? logoutColor : itemColor,
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}