import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // ── Troca o IP aqui quando mudar de rede ──
  static const _ipLocal = '10.2.0.135'; // <- coloca seu IP atual aqui
  static const _porta   = '3000';

  static String get _base => kIsWeb
      ? 'http://localhost:$_porta'
      : 'http://$_ipLocal:$_porta';

  final _auth = AuthService();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _parse(http.Response res) {
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(
          (data is Map ? data['erro'] : null) ?? 'Erro desconhecido');
    }
    return data as Map<String, dynamic>;
  }

  List<dynamic> _parseList(http.Response res) {
    if (res.statusCode >= 400) {
      final data = jsonDecode(res.body);
      throw Exception(
          (data is Map ? data['erro'] : null) ?? 'Erro desconhecido');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> register(
      String email, String senha, String nome) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'senha': senha, 'nome': nome}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> getPerfil() async {
    final res = await http.get(
      Uri.parse('$_base/api/perfil'),
      headers: await _authHeaders,
    );
    return _parse(res);
  }

  Future<void> updatePerfil({
    String? nome,
    String? foto,
    String? novaSenha,
  }) async {
    final body = <String, dynamic>{};
    if (nome != null)      body['nome']      = nome;
    if (foto != null)      body['foto']      = foto;
    if (novaSenha != null) body['novaSenha'] = novaSenha;

    final res = await http.put(
      Uri.parse('$_base/api/perfil'),
      headers: await _authHeaders,
      body: jsonEncode(body),
    );
    _parse(res);
  }

  Future<Map<String, dynamic>> gerarScript(String pergunta) async {
    final res = await http.post(
      Uri.parse('$_base/api/gerar-script'),
      headers: await _authHeaders,
      body: jsonEncode({'pergunta': pergunta}),
    );
    return _parse(res);
  }

  Future<List<dynamic>> getHistorico() async {
    final res = await http.get(
      Uri.parse('$_base/api/historico'),
      headers: await _authHeaders,
    );
    return _parseList(res);
  }

  Future<void> deletarHistorico(int id) async {
    await http.delete(
      Uri.parse('$_base/api/historico/$id'),
      headers: await _authHeaders,
    );
  }

  Future<Map<String, dynamic>> getHistoricoDados(int id) async {
    final res = await http.get(
      Uri.parse('$_base/api/historico/$id/dados'),
      headers: await _authHeaders,
    );
    return _parse(res);
  }

  Future<void> solicitarRecuperacao(String email) async {
    final res = await http.post(
      Uri.parse('$_base/recovery/solicitar'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _parse(res);
  }

  Future<Map<String, dynamic>> verificarToken(
      String email, String token) async {
    final res = await http.post(
      Uri.parse('$_base/recovery/verificar'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'token': token}),
    );
    return _parse(res);
  }

  Future<void> redefinirSenha(int tokenId, String novaSenha) async {
    final res = await http.post(
      Uri.parse('$_base/recovery/redefinir'),
      headers: _jsonHeaders,
      body: jsonEncode({'tokenId': tokenId, 'novaSenha': novaSenha}),
    );
    _parse(res);
  }
}
