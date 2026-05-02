import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/navbar/navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscureSenha = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nomeController.text = ""; 
    _emailController.text = "";
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    FocusScope.of(context).unfocus();
    
    final senha = _senhaController.text.trim();
    final confirm = _confirmController.text.trim();

    if (senha.isNotEmpty && senha != confirm) {
      _showSnack('As senhas não coincidem', AppColors.red);
      return;
    }

    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _showSnack('Perfil atualizado com sucesso!', AppColors.green);
      _senhaController.clear();
      _confirmController.clear();
    } catch (e) {
      _showSnack('Erro ao atualizar perfil', AppColors.red);
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
      duration: const Duration(seconds: 3),
    ));
  }

  void _alterarFoto() {
    _showSnack('Abrir galeria de imagens...', AppColors.accent2);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: isWide ? null : const Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: NavBar(currentIndex: 3),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const NavBar(currentIndex: 3),

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
                                icon: const Icon(Icons.menu, color: AppColors.text),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                          if (!isWide) const SizedBox(width: 8),
                          const Text(
                            'Meu Perfil',
                            style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: AppColors.panel,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border, width: 2),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.person, size: 50, color: AppColors.text3),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _alterarFoto,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.bg, width: 3),
                                        ),
                                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.panel,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('DADOS PESSOAIS',
                                        style: TextStyle(
                                            color: AppColors.text2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 20),

                                    _buildField('Nome completo', 'Seu nome', _nomeController),
                                    const SizedBox(height: 20),
                                    
                                    _buildField('E-mail', 'Seu e-mail', _emailController, keyboardType: TextInputType.emailAddress),
                                    const SizedBox(height: 32),

                                    const Divider(color: AppColors.border, height: 1),
                                    const SizedBox(height: 24),

                                    const Text('ALTERAR SENHA',
                                        style: TextStyle(
                                            color: AppColors.text2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 8),
                                    const Text('Deixe em branco caso não queira alterar',
                                        style: TextStyle(color: AppColors.text3, fontSize: 13)),
                                    const SizedBox(height: 20),

                                    _buildField('Nova senha', 'Mínimo 6 caracteres', _senhaController, 
                                        obscure: _obscureSenha, 
                                        toggleObscure: () => setState(() => _obscureSenha = !_obscureSenha)),
                                    const SizedBox(height: 20),

                                    _buildField('Confirmar nova senha', 'Repita a senha', _confirmController, 
                                        obscure: _obscureConfirm, 
                                        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _loading ? null : _salvarPerfil,
                                  icon: _loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Icon(Icons.save_outlined, size: 20),
                                  label: Text(_loading ? 'Salvando...' : 'Salvar Alterações'),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
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
            hintStyle: const TextStyle(color: AppColors.text3),
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