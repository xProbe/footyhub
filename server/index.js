/**
 * Backend login FootyHub — Express + Bcrypt + JWT.
 * Jalankan: npm install && npm start (port 3000).
 * Untuk Flutter Android Emulator gunakan http://10.0.2.2:3000/api
 */
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'footyhub-dev-secret-ganti-di-produksi';
const SALT_ROUNDS = 10;

/** @type {Map<string, { hash: string, name: string, nim: string }>} */
const users = new Map();

app.use(cors());
app.use(express.json());

function signToken(username, payload) {
  return jwt.sign(
    { sub: username, name: payload.name, nim: payload.nim },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, password, name, nim } = req.body || {};
    if (!username || !password || !name || !nim) {
      return res.status(400).json({ error: 'username, password, name, nim wajib diisi' });
    }
    const u = String(username).trim();
    if (users.has(u)) {
      return res.status(409).json({ error: 'username sudah dipakai' });
    }
    const hash = await bcrypt.hash(String(password), SALT_ROUNDS);
    users.set(u, { hash, name: String(name), nim: String(nim) });
    const token = signToken(u, { name, nim });
    return res.status(201).json({
      token,
      user: { username: u, name, nim },
    });
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body || {};
    if (!username || !password) {
      return res.status(400).json({ error: 'username dan password wajib' });
    }
    const u = String(username).trim();
    const row = users.get(u);
    if (!row) {
      return res.status(401).json({ error: 'username atau password salah' });
    }
    const ok = await bcrypt.compare(String(password), row.hash);
    if (!ok) {
      return res.status(401).json({ error: 'username atau password salah' });
    }
    const token = signToken(u, { name: row.name, nim: row.nim });
    return res.json({
      token,
      user: { username: u, name: row.name, nim: row.nim },
    });
  } catch (e) {
    return res.status(500).json({ error: String(e.message || e) });
  }
});

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`FootyHub auth API http://0.0.0.0:${PORT}`);
});
