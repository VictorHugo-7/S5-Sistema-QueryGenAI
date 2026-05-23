import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

void showProfileModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _ProfileModal(),
  );
}

class _ProfileModal extends StatefulWidget {
  const _ProfileModal();

  @override
  State<_ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<_ProfileModal> {
  final _nomeController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _senhaController   = TextEditingController();
  final _confirmController = TextEditingController();

  bool       _loading        = false;
  bool       _loadingPerfil  = true;
  bool       _obscureSenha   = true;
  bool       _obscureConfirm = true;
  Uint8List? _fotoBytes;
  bool       _fotoChanged    = false;

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
        try { fotoBytes = base64Decode(fotoRaw); } catch (_) {}
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
    setState(() { _fotoBytes = bytes; _fotoChanged = true; });
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
        bytes, targetWidth: 400, targetHeight: 400);
    final frame    = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _salvarPerfil() async {
    FocusScope.of(context).unfocus();
    final nome    = _nomeController.text.trim();
    final senha   = _senhaController.text.trim();
    final confirm = _confirmController.text.trim();

    if (senha.isNotEmpty) {
      if (senha.length < 8)                                             { _showSnack('A senha deve ter pelo menos 8 caracteres', AppColors.red); return; }
      if (!RegExp(r'[A-Z]').hasMatch(senha))                           { _showSnack('A senha deve conter pelo menos uma letra maiúscula', AppColors.red); return; }
      if (!RegExp(r'[0-9]').hasMatch(senha))                           { _showSnack('A senha deve conter pelo menos um número', AppColors.red); return; }
      if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(senha)) { _showSnack('A senha deve conter pelo menos um caractere especial', AppColors.red); return; }
      if (senha != confirm)                                             { _showSnack('As senhas não coincidem', AppColors.red); return; }
    }

    setState(() => _loading = true);
    try {
      await ApiService().updatePerfil(
        nome:      nome.isNotEmpty ? nome : null,
        foto:      _fotoChanged && _fotoBytes != null ? base64Encode(_fotoBytes!) : null,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 32,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        decoration: BoxDecoration(
          color: AppColors.bgOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Column(
          children: [
            // Header do modal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderOf(context))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Meu Perfil',
                      style: TextStyle(
                          color: AppColors.textOf(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.text3Of(context), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: _loadingPerfil
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildAvatar(context),
                          const SizedBox(height: 24),
                          _buildForm(context),
                        ],
                      ),
                    ),
            ),

            // Footer com botão salvar
            if (!_loadingPerfil)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderOf(context))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _salvarPerfil,
                    icon: _loading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_loading ? 'Salvando...' : 'Salvar Alterações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _alterarFoto,
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.panelOf(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderOf(context), width: 2),
            ),
            child: ClipOval(
              child: _fotoBytes != null
                  ? Image.memory(_fotoBytes!, fit: BoxFit.cover, width: 90, height: 90)
                  : Center(child: Icon(Icons.person, size: 40, color: AppColors.text3Of(context))),
            ),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: _alterarFoto,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgOf(context), width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DADOS PESSOAIS',
              style: TextStyle(
                  color: AppColors.text2Of(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _buildField(context, 'Nome completo', 'Seu nome', _nomeController),
          const SizedBox(height: 16),
          _buildReadOnlyField(context, 'E-mail', _emailController),
          const SizedBox(height: 24),
          Divider(color: AppColors.borderOf(context), height: 1),
          const SizedBox(height: 20),
          Text('ALTERAR SENHA',
              style: TextStyle(
                  color: AppColors.text2Of(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text('Deixe em branco caso não queira alterar',
              style: TextStyle(color: AppColors.text3Of(context), fontSize: 12)),
          const SizedBox(height: 16),
          _buildField(context, 'Nova senha', 'Mínimo 8 caracteres', _senhaController,
              obscure: _obscureSenha,
              toggleObscure: () => setState(() => _obscureSenha = !_obscureSenha)),
          const SizedBox(height: 16),
          _buildField(context, 'Confirmar nova senha', 'Repita a senha', _confirmController,
              obscure: _obscureConfirm,
              toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm)),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: AppColors.text2Of(context), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(color: AppColors.text3Of(context), fontSize: 14),
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.lock_outline, color: AppColors.text3Of(context), size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
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
            style: TextStyle(color: AppColors.text2Of(context), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: AppColors.textOf(context), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.text3Of(context)),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.text3Of(context),
                      size: 18,
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