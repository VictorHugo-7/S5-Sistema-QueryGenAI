const db = require('../db/connection');
const bcrypt = require('bcrypt');

async function getPerfil(req, res) {
  try {
    const [rows] = await db.query(
      'SELECT id, email, nome, foto, created_at FROM usuarios WHERE id = ?',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ erro: 'Usuário não encontrado' });
    }
    return res.json(rows[0]);
  } catch (err) {
    return res.status(500).json({ erro: 'Erro ao buscar perfil' });
  }
}

async function updatePerfil(req, res) {
  try {
    const { nome, foto, novaSenha } = req.body;
    const updates = [];
    const values = [];

    if (nome !== undefined) {
      updates.push('nome = ?');
      values.push(nome);
    }

    if (foto !== undefined) {
      updates.push('foto = ?');
      values.push(foto);
    }

    if (novaSenha) {
      const senhaHash = await bcrypt.hash(novaSenha, 10);
      updates.push('senha_hash = ?');
      values.push(senhaHash);
    }

    if (updates.length === 0) {
      return res.status(400).json({ erro: 'Nenhum campo para atualizar' });
    }

    values.push(req.user.id);
    await db.query(
      `UPDATE usuarios SET ${updates.join(', ')} WHERE id = ?`,
      values
    );

    return res.json({ mensagem: 'Perfil atualizado com sucesso' });
  } catch (err) {
    return res.status(500).json({ erro: 'Erro ao atualizar perfil' });
  }
}

module.exports = { getPerfil, updatePerfil };
