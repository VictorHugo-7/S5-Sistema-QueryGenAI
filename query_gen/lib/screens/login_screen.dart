import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

// Imports de Widgets (Gráficos)
import '../widgets/graphics/activity_bars_widget.dart';
import '../widgets/graphics/bar_chart_widget.dart';
import '../widgets/graphics/donut_chart_widget.dart';
import '../widgets/graphics/line_chart_widget.dart';
import '../widgets/graphics/stat_pill_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _keepConnected = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  final _emailController        = TextEditingController();
  final _senhaController        = TextEditingController();
  final _nomeController         = TextEditingController();
  final _confirmSenhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    _confirmSenhaController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    _senhaController.clear();
    _nomeController.clear();
    _confirmSenhaController.clear();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  String? _validatePassword(String password) {
    if (password.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'A senha deve conter pelo menos uma letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'A senha deve conter pelo menos um número';
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(password)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _showSnack('Preencha todos os campos', AppColors.red);
      return;
    }


    if (!_isValidEmail(email)) {
      _showSnack('Insira um e-mail válido', AppColors.red);
      return;
    }

    if (!_isLogin) {
      final passwordError = _validatePassword(senha);
      if (passwordError != null) {
        _showSnack(passwordError, AppColors.red);
        return;
      }
      final confirm = _confirmSenhaController.text.trim();
      if (senha != confirm) {
        _showSnack('As senhas não coincidem', AppColors.red);
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final api = ApiService();
      if (_isLogin) {
        final data = await api.login(email, senha);
        await AuthService().saveToken(
          data['token'],
          data['email'],
          nome: data['nome'] as String?,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        final nome = _nomeController.text.trim();
        await api.register(email, senha, nome);
        _showSnack('Conta criada! Faça login.', AppColors.green);
        setState(() {
          _isLogin = true;
          _clearFields();
        });
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    if (!isDesktop) return Scaffold(backgroundColor: AppColors.bg, body: _buildLeftPanel());

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StatPillsRow(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LOGO SECTION
        Container(

  width: 90,
  height: 90,
  child: Image.asset(
    'assets/Logo QueryGen (1).png',
    fit: BoxFit.contain,
  ),
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
        Text(
          _isLogin ? 'Bem vindo de volta!' : 'Crie sua conta',
          style: const TextStyle(

              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),

        Text(
          _isLogin
              ? 'Insira seu e-mail e sua senha para continuar'
              : 'Preencha os dados abaixo para se cadastrar',
          style: const TextStyle(color: AppColors.text2, fontSize: 14),

          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // TAB SELECTOR COM EFEITO SLIDE
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // O Indicador que desliza
              AnimatedAlign(
                alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    ),
                  ),
                ),
              ),
              // As opções de texto
              Row(
                children: [
                  _buildTab('Entrar', true),
                  _buildTab('Cadastrar', false),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (!_isLogin) ...[
          _buildField('Nome', 'Seu nome completo', _nomeController),
          const SizedBox(height: 16),
        ],
        _buildField('E-mail', 'exemplo@email.com', _emailController,
            keyboardType: TextInputType.emailAddress),

        const SizedBox(height: 18),
        _buildPasswordField(
          label: 'Senha',
          hint: _isLogin ? 'Insira sua senha' : 'Mínimo 8 caracteres',
          controller: _senhaController,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
        ),
        if (!_isLogin) ...[
          const SizedBox(height: 6),
          const Text(
            'Use 8+ caracteres com maiúscula, número e caractere especial.',
            style: TextStyle(color: AppColors.text3, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 18),
          _buildPasswordField(
            label: 'Confirmar senha',
            hint: 'Repita sua senha',
            controller: _confirmSenhaController,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ],

        const SizedBox(height: 16),
        if (_isLogin) _buildBottomRow(),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
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
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))

                : Text(_isLogin ? 'Entrar' : 'Cadastrar'),

          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isLoginTab) {
    final active = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(

        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() { 
          _isLogin = isLoginTab; 
          _clearFields(); 
        }),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),

            style: TextStyle(
              color: active ? Colors.white : AppColors.text2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter', // Opcional, ajuste conforme seu tema
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _keepConnected,
              onChanged: (v) => setState(() => _keepConnected = v ?? false),
              activeColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Lembrar de mim',
              style: TextStyle(color: AppColors.text2, fontSize: 12)),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          ),
          child: const Text('Esqueci a senha',
              style: TextStyle(
                  color: AppColors.accent2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.text2, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(label,
            style: const TextStyle(
                color: AppColors.text2,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
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


  
}



