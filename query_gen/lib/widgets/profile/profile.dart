import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/navbar/navbar.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nomeController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _senhaController   = TextEditingController();
  final _confirmController = TextEditingController();

  bool        _loading        = false;
  bool        _loadingPerfil  = true;
  bool        _obscureSenha   = true;
  bool        _obscureConfirm = true;
  Uint8List?  _fotoBytes;
  bool        _fotoChanged    = false;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadPerfil() async {
    try {
      final data = await ApiService().getPerfil();
      if (!mounted) return;
      Uint8List? fotoBytes;
      final fotoRaw = data['foto'] as String?;
      if (fotoRaw != null && fotoRaw.isNotEmpty) {
        try {
          fotoBytes = base64Decode(fotoRaw);
        } catch (_) {}
      }
      setState(() {
        _nomeController.text  = data['nome']  ?? '';
        _emailController.text = data['email'] ?? '';
        _fotoBytes     = fotoBytes;
        _loadingPerfil = false;
      });
    } catch (_) {
      if (!mounted) return;
      final email = await AuthService().getEmail();
      final nome  = await AuthService().getNome();
      if (!mounted) return;
      setState(() {
        _emailController.text = email ?? '';
        _nomeController.text  = nome  ?? '';
        _loadingPerfil = false;
      });
    }
  }

  Future<void> _alterarFoto() async {
    final picker = ImagePicker();

    // No web, maxWidth/maxHeight/imageQuality são ignorados pelo plugin
    final XFile? picked = kIsWeb
        ? await picker.pickImage(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 400,
            maxHeight: 400,
            imageQuality: 80,
          );

    if (picked == null) return;

    Uint8List bytes = await picked.readAsBytes();
    if (kIsWeb) bytes = await _compressImage(bytes);

    setState(() {
      _fotoBytes   = bytes;
      _fotoChanged = true;
    });
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 400,
      targetHeight: 400,
    );
    final frame    = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> _salvarPerfil() async {
    FocusScope.of(context).unfocus();

    final nome    = _nomeController.text.trim();
    final senha   = _senhaController.text.trim();
    final confirm = _confirmController.text.trim();

    if (senha.isNotEmpty) {
      if (senha.length < 8) {
        _showSnack('A senha deve ter pelo menos 8 caracteres', AppColors.red);
        return;
      }
      if (!RegExp(r'[A-Z]').hasMatch(senha)) {
        _showSnack('A senha deve conter pelo menos uma letra maiúscula', AppColors.red);
        return;
      }
      if (!RegExp(r'[0-9]').hasMatch(senha)) {
        _showSnack('A senha deve conter pelo menos um número', AppColors.red);
        return;
      }
      if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(senha)) {
        _showSnack('A senha deve conter pelo menos um caractere especial', AppColors.red);
        return;
      }
      if (senha != confirm) {
        _showSnack('As senhas não coincidem', AppColors.red);
        return;
      }
    }

    setState(() => _loading = true);

    try {
      await ApiService().updatePerfil(
        nome:      nome.isNotEmpty ? nome : null,
        foto:      _fotoChanged && _fotoBytes != null
                       ? base64Encode(_fotoBytes!)
                       : null,
        novaSenha: senha.isNotEmpty ? senha : null,
      );

      if (nome.isNotEmpty) await AuthService().saveNome(nome);

      if (!mounted) return;
      setState(() => _fotoChanged = false);
      _showSnack('Perfil atualizado com sucesso!', AppColors.green);
      _senhaController.clear();
      _confirmController.clear();
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
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: isWide
          ? null
          : const Drawer(
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
                                icon: const Icon(Icons.menu,
                                    color: AppColors.text),
                                onPressed: () =>
                                    Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                          if (!isWide) const SizedBox(width: 8),
                          const Text(
                            'Meu Perfil',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  Expanded(
                    child: _loadingPerfil
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildAvatar(),
                                    const SizedBox(height: 32),
                                    _buildForm(),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            _loading ? null : _salvarPerfil,
                                        icon: _loading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2))
                                            : const Icon(
                                                Icons.save_outlined,
                                                size: 20),
                                        label: Text(_loading
                                            ? 'Salvando...'
                                            : 'Salvar Alterações'),
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

  Widget _buildAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _alterarFoto,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.panel,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: ClipOval(
              child: _fotoBytes != null
                  ? Image.memory(
                      _fotoBytes!,
                      fit: BoxFit.cover,
                      width: 110,
                      height: 110,
                    )
                  : const Center(
                      child: Icon(Icons.person,
                          size: 50, color: AppColors.text3),
                    ),
            ),
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
              child: const Icon(Icons.camera_alt,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
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

          _buildReadOnlyField('E-mail', _emailController),
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

          _buildField(
            'Nova senha',
            'Mínimo 8 caracteres',
            _senhaController,
            obscure: _obscureSenha,
            toggleObscure: () =>
                setState(() => _obscureSenha = !_obscureSenha),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use 8+ caracteres com maiúscula, número e caractere especial.',
            style: TextStyle(
                color: AppColors.text3, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 20),

          _buildField(
            'Confirmar nova senha',
            'Repita a senha',
            _confirmController,
            obscure: _obscureConfirm,
            toggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
      String label, TextEditingController controller) {
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
          readOnly: true,
          style: const TextStyle(color: AppColors.text3, fontSize: 15),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.lock_outline,
                color: AppColors.text3, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
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
