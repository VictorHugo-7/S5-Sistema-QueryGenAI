import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../services/api_service.dart';
import 'chart_screen.dart';
import '../widgets/navbar/navbar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _items   = [];
  bool          _loading = true;
  int?          _loadingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService().getHistorico();
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _verDados(dynamic item) async {
    setState(() => _loadingId = item['id']);
    try {
      final data = await ApiService().getHistoricoDados(item['id']);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChartScreen(
            dados:       List<dynamic>.from(data['dados'] ?? []),
            tipoGrafico: data['grafico']   ?? 'barra',
            eixoX:       data['eixo_x'],
            eixoY:       data['eixo_y'],
            descricao:   data['descricao'] ?? item['pergunta'] ?? '',
          ),
        ),
      );
    } catch (e) {
      _showSnack('Erro ao carregar dados', AppColors.red);
    } finally {
      if (mounted) setState(() => _loadingId = null);
    }
  }

  Future<void> _deletar(int id) async {
    await ApiService().deletarHistorico(id);
    setState(() => _items.removeWhere((i) => i['id'] == id));
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}/'
          '${dt.month.toString().padLeft(2,'0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2,'0')}:'
          '${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return raw; }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  // Estilo base para botões dentro dos cards (sobrescreve minimumSize infinito do tema)
  // static final _btnBase = ButtonStyle(
  //   minimumSize: WidgetStateProperty.all(Size.zero),
  //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //   padding: WidgetStateProperty.all(
  //     const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      drawer: isWide
          ? null
          : const Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: NavBar(currentIndex: 1),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const NavBar(currentIndex: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 76,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isWide)
                            Builder(
                              builder: (ctx) => IconButton(
                                icon: Icon(Icons.menu,
                                    color: AppColors.textOf(context)),
                                onPressed: () =>
                                    Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                          Text(
                            'Histórico',
                            style: TextStyle(
                                color: AppColors.textOf(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: AppColors.borderOf(context), height: 1),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent))
                        : _items.isEmpty
                            ? _buildEmptyState(context)
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.accent,
                                child: isWide
                                    ? _buildWebGrid(context)
                                    : _buildMobileList(context),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppColors.text3Of(context), size: 48),
          const SizedBox(height: 12),
          Text('Nenhum script gerado ainda',
              style: TextStyle(
                  color: AppColors.text2Of(context), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildWebGrid(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_items.length} scripts gerados',
              style: TextStyle(
                  color: AppColors.text2Of(context), fontSize: 13)),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _items
                    .map((item) => SizedBox(
                          width: cardWidth,
                          child: _buildCard(context, item),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCard(context, _items[i]),
    );
  }

  Widget _buildCard(BuildContext context, dynamic item) {
    final isLoadingThis = _loadingId == item['id'];
    final grafico = item['grafico'] ?? 'barra';

    final panelColor  = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final surfaceColor = AppColors.surfaceOf(context);

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item['pergunta'] ?? '',
                    style: TextStyle(
                        color: AppColors.textOf(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: AppColors.text3Of(context), size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(item['id']),
                ),
              ],
            ),
          ),

          // Data + badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                Text(_formatDate(item['created_at']),
                    style: TextStyle(
                        color: AppColors.text3Of(context), fontSize: 11)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_iconGrafico(grafico),
                          color: AppColors.text3Of(context), size: 10),
                      const SizedBox(width: 3),
                      Text(grafico,
                          style: TextStyle(
                              color: AppColors.text3Of(context),
                              fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: borderColor, height: 1),
          ),

          // SQL preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              item['sql_gerado'] ?? '',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppColors.text2Of(context),
                  height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoadingThis ? null : () => _verDados(item),
                  icon: isLoadingThis
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(_iconGrafico(grafico), size: 14),
                  label: const Text('Visualizar',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: item['sql_gerado'] ?? ''));
                    _showSnack('SQL copiado!', AppColors.green);
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copiar SQL',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent2,
                    side: BorderSide(color: borderColor),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconGrafico(String tipo) {
    switch (tipo) {
      case 'pizza': return Icons.pie_chart_outline;
      case 'linha': return Icons.show_chart;
      default:      return Icons.bar_chart;
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelOf(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderOf(context)),
        ),
        title: Text('Deletar',
            style: TextStyle(color: AppColors.textOf(context))),
        content: Text('Remover este script do histórico?',
            style: TextStyle(color: AppColors.text2Of(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: AppColors.text2Of(context))),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); _deletar(id); },
            child: const Text('Deletar',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}