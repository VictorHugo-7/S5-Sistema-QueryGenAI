import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int  _step    = 0;
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String _email   = '';
  int    _tokenId = 0;

  final _emailController   = TextEditingController();
  final _tokenController   = TextEditingController();
  final _senhaController   = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _senhaController.dispose();
    _confirmController.dispose();
    super.dispose();
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
        // Agora o backend retorna erro 404 se email não existir
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
    final isWide = Responsive.isWide(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () =>
              _step > 0 ? setState(() => _step--) : Navigator.pop(context),
        ),
        title: const Text('Recuperar senha'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 480 : double.infinity),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 28,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de progresso
                  Row(
                    children: List.generate(3, (i) {
                      final done   = i < _step;
                      final active = i == _step;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || active
                                ? AppColors.accent
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    _step == 0
                        ? 'Recuperar senha'
                        : _step == 1
                            ? 'Verificar código'
                            : 'Nova senha',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step == 0
                        ? 'Insira seu e-mail cadastrado para receber o código'
                        : _step == 1
                            ? 'Insira o código de 6 dígitos enviado para $_email'
                            : 'Crie uma nova senha para sua conta',
                    style: const TextStyle(
                        color: AppColors.text2, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 36),

                  if (_step == 0)
                    _buildField('E-mail', 'Insira seu e-mail',
                        _emailController,
                        keyboardType: TextInputType.emailAddress),

                  if (_step == 1) ...[
                    _buildField('Código de verificação', '000000',
                        _tokenController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
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
                        child: const Text('Reenviar código',
                            style: TextStyle(
                                color: AppColors.accent2, fontSize: 14)),
                      ),
                    ),
                  ],

                  if (_step == 2) ...[
                    _buildField('Nova senha', 'Mínimo 8 caracteres',
                        _senhaController,
                        obscure: _obscure1,
                        toggleObscure: () =>
                            setState(() => _obscure1 = !_obscure1)),
                    const SizedBox(height: 18),
                    _buildField('Confirmar senha', 'Repita a senha',
                        _confirmController,
                        obscure: _obscure2,
                        toggleObscure: () =>
                            setState(() => _obscure2 = !_obscure2)),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _nextStep,
                      child: _loading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_step == 0
                              ? 'Enviar código'
                              : _step == 1
                                  ? 'Verificar código'
                                  : 'Redefinir senha'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
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
          keyboardType: keyboardType,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.text3,
                      size: 20,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}