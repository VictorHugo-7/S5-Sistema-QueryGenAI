const express = require('express');
const router = express.Router();
const { getPerfil, updatePerfil } = require('../controllers/userController');
const authMiddleware = require('../middleware/auth');

router.get('/perfil',  authMiddleware, getPerfil);
router.put('/perfil',  authMiddleware, updatePerfil);

module.exports = router;
