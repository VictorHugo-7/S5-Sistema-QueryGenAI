import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../services/api_service.dart';
import '../widgets/chart_widget.dart';
import '../widgets/data_table_widget.dart';
import '../widgets/app_header.dart';
import '../widgets/navbar/navbar.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _sql;
  String? _descricao;
  String  _tipoGrafico = 'barra';
  String? _eixoX;
  String? _eixoY;
  List<String>  _tabelas = [];
  List<dynamic> _dados   = [];

  static const _sugestoes = [
    'Volume de produção dos últimos 3 meses',
    'Faturamento do último mês por cliente',
    'Movimentações de estoque recentes',
    'Pedidos de compra por fornecedor',
    'Distribuição de notificações de qualidade por status',
    'Estoque atual por material',
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _gerar() async {
    final pergunta = _controller.text.trim();
    if (pergunta.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _sql = null; _dados = []; });
    try {
      final data = await ApiService().gerarScript(pergunta);
      setState(() {
        _sql         = data['sql'];
        _descricao   = data['descricao'];
        _tipoGrafico = data['grafico']  ?? 'barra';
        _eixoX       = data['eixo_x'];
        _eixoY       = data['eixo_y'];
        _tabelas     = List<String>.from(data['tabelas'] ?? []);
        _dados       = List<dynamic>.from(data['dados']  ?? []);
      });
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copiarSQL() {
    if (_sql == null) return;
    Clipboard.setData(ClipboardData(text: _sql!));
    _showSnack('SQL copiado!', AppColors.green);
  }

  void _abrirGrafico() {
    if (_dados.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChartScreen(
        dados: _dados, tipoGrafico: _tipoGrafico,
        eixoX: _eixoX, eixoY: _eixoY, descricao: _descricao ?? '',
      ),
    ));
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      drawer: isWide ? null : Drawer(
        backgroundColor: Colors.transparent, elevation: 0,
        child: const NavBar(currentIndex: 0),
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
                  AppHeader(title: 'Scripts', showMenuButton: !isWide),
                  Divider(color: AppColors.borderOf(context), height: 1),
                  Expanded(
                    child: isWide
                        ? _buildWebContent(context)
                        : _buildMobileContent(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 420, height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgOf(context),
            border: Border(right: BorderSide(color: AppColors.borderOf(context))),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildInputSection(context),
          ),
        ),
        Expanded(
          child: _sql == null
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: [
                    _buildResultCard(context),
                    if (_dados.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildChartCard(context),
                      const SizedBox(height: 20),
                      _buildTableCard(context),
                    ],
                  ]),
                ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSection(context),
          if (_sql != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(context),
            if (_dados.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildChartCard(context),
              const SizedBox(height: 16),
              _buildTableCard(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('O que você quer consultar?',
            style: TextStyle(color: AppColors.textOf(context),
                fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Descreva em português o que precisa extrair do SAP',
            style: TextStyle(color: AppColors.text2Of(context), fontSize: 14)),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: TextField(
            controller: _controller, maxLines: 4,
            style: TextStyle(color: AppColors.textOf(context), fontSize: 15, height: 1.5),
            decoration: InputDecoration(
              hintText: 'Ex: Quero ver o faturamento dos últimos 3 meses por cliente',
              hintStyle: TextStyle(color: AppColors.text3Of(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _gerar,
            icon: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_loading ? 'Gerando...' : 'Gerar Script SQL'),
          ),
        ),
        const SizedBox(height: 24),
        Text('Sugestões', style: TextStyle(color: AppColors.text2Of(context),
            fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _sugestoes.map((s) => GestureDetector(
            onTap: () => setState(() => _controller.text = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Text(s, style: TextStyle(color: AppColors.text2Of(context), fontSize: 12)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Icon(Icons.query_stats, color: AppColors.text3Of(context), size: 32),
        ),
        const SizedBox(height: 16),
        Text('Nenhuma consulta ainda',
            style: TextStyle(color: AppColors.text2Of(context),
                fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('Faça uma pergunta no painel ao lado',
            style: TextStyle(color: AppColors.text3Of(context), fontSize: 13)),
      ]),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(_descricao ?? 'Script gerado',
                style: TextStyle(color: AppColors.textOf(context),
                    fontSize: 14, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5)),
              child: const Text('Sucesso', style: TextStyle(
                  color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        if (_tabelas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(spacing: 6, children: _tabelas.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(t, style: const TextStyle(
                  color: AppColors.accent2, fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList()),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: AppColors.borderOf(context), height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SelectableText(_sql!, style: TextStyle(
              fontFamily: 'monospace', fontSize: 13,
              color: AppColors.text2Of(context), height: 1.7)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _copiarSQL,
              icon: const Icon(Icons.copy, size: 15),
              label: const Text('Copiar SQL', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                minimumSize: Size.zero,
                side: BorderSide(color: AppColors.borderOf(context)),
              ),
            )),
            if (_dados.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(
                onPressed: _abrirGrafico,
                icon: Icon(_iconGrafico(_tipoGrafico), size: 15),
                label: const Text('Ver gráfico', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  minimumSize: Size.zero,
                ),
              )),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_iconGrafico(_tipoGrafico), color: AppColors.accent2, size: 16),
          const SizedBox(width: 8),
          Text(_labelGrafico(_tipoGrafico), style: TextStyle(
              color: AppColors.text2Of(context), fontSize: 12,
              fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(5)),
            child: Text('${_dados.length} registros', style: const TextStyle(
                color: AppColors.accent2, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 20),
        ChartWidget(dados: _dados, tipoGrafico: _tipoGrafico, eixoX: _eixoX, eixoY: _eixoY),
      ]),
    );
  }

  Widget _buildTableCard(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.table_chart_outlined, color: AppColors.text2Of(context), size: 16),
          const SizedBox(width: 8),
          Text('TABELA DE DADOS', style: TextStyle(color: AppColors.text2Of(context),
              fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          const Spacer(),
          if (_dados.length > 100)
            Text('Exibindo 100 primeiros',
                style: TextStyle(color: AppColors.text3Of(context), fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        DataTableWidget(dados: _dados),
      ]),
    );
  }

  IconData _iconGrafico(String tipo) {
    switch (tipo) {
      case 'pizza': return Icons.pie_chart_outline;
      case 'linha': return Icons.show_chart;
      default:      return Icons.bar_chart;
    }
  }

  String _labelGrafico(String tipo) {
    switch (tipo) {
      case 'pizza': return 'GRÁFICO DE PIZZA';
      case 'linha': return 'GRÁFICO DE LINHA';
      default:      return 'GRÁFICO DE BARRAS';
    }
  }
}