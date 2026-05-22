const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db/connection');

async function register(req, res) {
  try {
    const { email, senha, nome } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ erro: 'Email e senha são obrigatórios' });
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    await db.query(
      'INSERT INTO usuarios (email, senha_hash, nome) VALUES (?, ?, ?)',
      [email, senhaHash, nome || null]
    );

    return res.status(201).json({ mensagem: 'Usuário criado com sucesso' });

  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ erro: 'Email já cadastrado' });
    }
    return res.status(500).json({ erro: 'Erro ao criar usuário' });
  }
}

async function login(req, res) {
  try {
    const { email, senha } = req.body;

    const [rows] = await db.query(
      'SELECT id, email, nome, senha_hash FROM usuarios WHERE email = ?',
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({ erro: 'Email ou senha incorretos' });
    }

    const usuario = rows[0];
    const senhaCorreta = await bcrypt.compare(senha, usuario.senha_hash);

    if (!senhaCorreta) {
      return res.status(401).json({ erro: 'Email ou senha incorretos' });
    }

    const token = jwt.sign(
      { id: usuario.id, email: usuario.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.json({ token, email: usuario.email, nome: usuario.nome || null });

  } catch (err) {
    return res.status(500).json({ erro: 'Erro ao fazer login' });
  }
}

module.exports = { register, login };