import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/chart_widget.dart';
import '../widgets/data_table_widget.dart';
import '../utils/responsive.dart';
import '../widgets/navbar/navbar.dart';
import '../widgets/profile_modal.dart';
import '../main.dart';

class ChartScreen extends StatelessWidget {
  final List<dynamic> dados;
  final String tipoGrafico;
  final String? eixoX;
  final String? eixoY;
  final String descricao;

  const ChartScreen({
    super.key,
    required this.dados,
    required this.tipoGrafico,
    this.eixoX,
    this.eixoY,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      drawer: isWide ? null : const Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: NavBar(currentIndex: 0),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const NavBar(currentIndex: 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 76,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isWide)
                            Builder(
                              builder: (ctx) => IconButton(
                                icon: Icon(Icons.menu, color: AppColors.textOf(context)),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios,
                                size: 20, color: AppColors.textOf(context)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              descricao,
                              style: TextStyle(
                                  color: AppColors.textOf(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Builder(builder: (ctx) {
                            final notifier = MyApp.of(ctx);
                            return Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: Icon(Icons.person_outline,
                                    color: AppColors.text2Of(context), size: 22),
                                onPressed: () => showProfileModal(context),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: IconButton(
                                  key: ValueKey(notifier.isDark),
                                  icon: Icon(
                                    notifier.isDark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                    color: AppColors.text2Of(context), size: 22),
                                  onPressed: notifier.toggle,
                                ),
                              ),
                            ]);
                          }),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: AppColors.borderOf(context), height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.panelOf(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderOf(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(_iconGrafico(), color: AppColors.accent2, size: 16),
                                    const SizedBox(width: 8),
                                    Text(_labelGrafico(),
                                        style: TextStyle(
                                            color: AppColors.text2Of(context),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text('${dados.length} registros',
                                          style: const TextStyle(
                                              color: AppColors.accent2,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ChartWidget(dados: dados, tipoGrafico: tipoGrafico, eixoX: eixoX, eixoY: eixoY),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.panelOf(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderOf(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.table_chart_outlined,
                                        color: AppColors.text2Of(context), size: 16),
                                    const SizedBox(width: 8),
                                    Text('TABELA DE DADOS',
                                        style: TextStyle(
                                            color: AppColors.text2Of(context),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5)),
                                    const Spacer(),
                                    if (dados.length > 100)
                                      Text('Exibindo 100 primeiros',
                                          style: TextStyle(
                                              color: AppColors.text3Of(context), fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                DataTableWidget(dados: dados),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconGrafico() {
    switch (tipoGrafico) {
      case 'pizza': return Icons.pie_chart_outline;
      case 'linha': return Icons.show_chart;
      default:      return Icons.bar_chart;
    }
  }

  String _labelGrafico() {
    switch (tipoGrafico) {
      case 'pizza': return 'GRÁFICO DE PIZZA';
      case 'linha': return 'GRÁFICO DE LINHA';
      default:      return 'GRÁFICO DE BARRAS';
    }
  }
}