import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

// Imports de Widgets (Gráficos)
import '../widgets/graphics/activity_bars_widget.dart';
import '../widgets/graphics/bar_chart_widget.dart';
import '../widgets/graphics/donut_chart_widget.dart';
import '../widgets/graphics/line_chart_widget.dart';
import '../widgets/graphics/stat_pill_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int    _step     = 0;
  bool   _loading  = false;
  bool   _obscure1 = true;
  bool   _obscure2 = true;
  String _email    = '';
  int    _tokenId  = 0;
  //String _senhaAtual = '';

  final _emailController   = TextEditingController();
  final _tokenController   = TextEditingController();
  final _senhaController   = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _senhaController.addListener(_onSenhaChanged);
  }

  void _onSenhaChanged() {
    if (!mounted) return;
    //setState(() => _senhaAtual = _senhaController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _senhaController.removeListener(_onSenhaChanged);
    _senhaController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMin8      => _senhaController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_senhaController.text);
  bool get _hasNumber    => RegExp(r'[0-9]').hasMatch(_senhaController.text);
  bool get _hasSpecial   =>
      RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(_senhaController.text);

  int get _strengthScore =>
      (_hasMin8 ? 1 : 0) +
      (_hasUppercase ? 1 : 0) +
      (_hasNumber ? 1 : 0) +
      (_hasSpecial ? 1 : 0);

  String get _strengthLabel {
    if (_senhaController.text.isEmpty) return '';
    if (_strengthScore <= 1) return 'Fraca';
    if (_strengthScore == 2) return 'Média';
    if (_strengthScore == 3) return 'Boa';
    return 'Forte';
  }

  Color get _strengthColor {
    if (_senhaController.text.isEmpty) return AppColors.border;
    if (_strengthScore <= 1) return AppColors.red;
    if (_strengthScore == 2) return const Color(0xFFE6A817);
    if (_strengthScore == 3) return const Color(0xFF4FC3F7);
    return AppColors.green;
  }

  Future<void> _nextStep() async {
    setState(() => _loading = true);
    try {
      final api = ApiService();

      if (_step == 0) {
        _email = _emailController.text.trim();
        if (_email.isEmpty) throw Exception('Insira seu e-mail');
        if (!RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$').hasMatch(_email)) {
          throw Exception('Insira um e-mail válido');
        }
        await api.solicitarRecuperacao(_email);
        if (!mounted) return;
        _showSnack('Código enviado para $_email', AppColors.green);
        setState(() => _step = 1);

      } else if (_step == 1) {
        final codigo = _tokenController.text.trim();
        if (codigo.isEmpty) throw Exception('Insira o código');
        final data = await api.verificarToken(_email, codigo);
        _tokenId = data['tokenId'];
        setState(() => _step = 2);

      } else {
        final nova    = _senhaController.text.trim();
        final confirm = _confirmController.text.trim();
        if (nova.length < 8) throw Exception('A senha deve ter pelo menos 8 caracteres');
        if (!RegExp(r'[A-Z]').hasMatch(nova)) throw Exception('A senha deve conter pelo menos uma letra maiúscula');
        if (!RegExp(r'[0-9]').hasMatch(nova)) throw Exception('A senha deve conter pelo menos um número');
        if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(nova)) throw Exception('A senha deve conter pelo menos um caractere especial');
        if (nova != confirm) throw Exception('As senhas não coincidem');
        await api.redefinirSenha(_tokenId, nova);
        if (!mounted) return;
        _showSnack('Senha redefinida com sucesso!', AppColors.green);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isDesktop
          ? Row(
              children: [
                Expanded(flex: 4, child: _buildLeftPanel()),
                Expanded(flex: 6, child: _buildRightPanel()),
              ],
            )
          : _buildLeftPanel(),
    );
  }

  Widget _buildLeftPanel() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LOGO
        SizedBox(
          width: 90,
          height: 90,
          child: Image.asset('assets/Logo QueryGen (1).png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: 'Query',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: 'Gen',
                style: TextStyle(
                    color: AppColors.accent2,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 36),

        // Barra de progresso
        Row(
          children: List.generate(3, (i) {
            final done   = i < _step;
            final active = i == _step;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: done || active ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),

        // Título
        Text(
          _step == 0
              ? 'Recuperar senha'
              : _step == 1
                  ? 'Verificar código'
                  : 'Nova senha',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtítulo
        Text(
          _step == 0
              ? 'Insira seu e-mail cadastrado para receber o código'
              : _step == 1
                  ? 'Insira o código de 6 dígitos enviado para $_email'
                  : 'Crie uma nova senha para sua conta',
          style: const TextStyle(color: AppColors.text2, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // ── Step 0: e-mail ───────────────────────────────────
        if (_step == 0)
          _buildField(
            'E-mail',
            'Insira seu e-mail',
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),

        // ── Step 1: código ──────────────────────────────────
        if (_step == 1) ...[
          _buildField(
            'Código de verificação',
            '000000',
            _tokenController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              try {
                await ApiService().solicitarRecuperacao(_email);
                if (!mounted) return;
                _showSnack('Código reenviado!', AppColors.green);
              } catch (e) {
                _showSnack(
                  e.toString().replaceAll('Exception: ', ''),
                  AppColors.red,
                );
              }
            },
            child: const Text(
              'Reenviar código',
              style: TextStyle(
                color: AppColors.accent2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // ── Step 2: nova senha com indicador de força ────────
        if (_step == 2) ...[
          _buildPasswordField(
            'Nova senha',
            'Mínimo 8 caracteres',
            _senhaController,
            obscure: _obscure1,
            onToggle: () => setState(() => _obscure1 = !_obscure1),
          ),

          // Indicador de força
          if (_senhaController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Força da senha:',
                    style: TextStyle(color: AppColors.text2, fontSize: 12)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _strengthLabel,
                    key: ValueKey(_strengthLabel),
                    style: TextStyle(
                      color: _strengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (ctx, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 4,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 4,
                    width: constraints.maxWidth * (_strengthScore / 4),
                    decoration: BoxDecoration(
                      color: _strengthColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ],

          const SizedBox(height: 14),

          // Checklist de requisitos
          _buildCheckItem('Mínimo de 8 caracteres', _hasMin8),
          _buildCheckItem('Pelo menos uma letra maiúscula', _hasUppercase),
          _buildCheckItem('Pelo menos um número', _hasNumber),
          _buildCheckItem('Pelo menos um caractere especial', _hasSpecial),

          const SizedBox(height: 18),
          _buildPasswordField(
            'Confirmar senha',
            'Repita a senha',
            _confirmController,
            obscure: _obscure2,
            onToggle: () => setState(() => _obscure2 = !_obscure2),
          ),
        ],

        const SizedBox(height: 28),

        // Botão principal
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _loading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_step == 0
                    ? 'Enviar código'
                    : _step == 1
                        ? 'Verificar código'
                        : 'Redefinir senha'),
          ),
        ),

        const SizedBox(height: 20),

        // Voltar
        GestureDetector(
          onTap: () => _step > 0
              ? setState(() => _step--)
              : Navigator.pop(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: AppColors.text3, size: 14),
              SizedBox(width: 6),
              Text('Voltar',
                  style: TextStyle(color: AppColors.text3, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // Item de checklist animado
  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              checked ? Icons.check : Icons.check,
              key: ValueKey(checked),
              size: 16,
              color: checked ? AppColors.green : AppColors.text3,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: checked ? AppColors.green : AppColors.text3,
              fontSize: 13,
              fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.text2,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller, {
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.text2,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5)),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.text3,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0b0d14),
        border: Border(
          left: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatPillsRow(),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(height: 280, child: LineChartWidget()),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: SizedBox(height: 280, child: DonutChartWidget()),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SizedBox(height: 280, child: BarChartWidget()),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: SizedBox(height: 280, child: ActivityBarsWidget()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}