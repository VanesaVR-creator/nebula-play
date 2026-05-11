require('dotenv').config();
const path = require('path');
const express = require('express');
const session = require('express-session');
const multer = require('multer');
const bcrypt = require('bcrypt');
const pool = require('./db');
const { requireAuth, requireRole } = require('./middleware');

const app = express();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });
const PORT = process.env.PORT || 4000;

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(session({
  secret: process.env.SESSION_SECRET || 'nebula_secret_dev',
  resave: false,
  saveUninitialized: false,
  cookie: { httpOnly: true, sameSite: 'lax' },
}));

app.use(express.static(path.join(__dirname, '..', 'public')));


// Fallback para formularios HTML tradicionales. La app principal usa /api/auth/login,
// pero esta ruta evita que el login falle si el navegador envía el formulario sin JavaScript.
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.redirect('/?error=missing');

    const { rows } = await pool.query(
      'SELECT id_usuario, email, contrasena, tipo_usuario, activo FROM usuarios WHERE email = $1 LIMIT 1',
      [email]
    );
    const user = rows[0];
    if (!user || !user.activo) return res.redirect('/?error=invalid');

    const valid = await comparePassword(password, user.contrasena);
    if (!valid) return res.redirect('/?error=invalid');

    req.session.user = sanitizeUserRow(user);
    if (user.tipo_usuario === 'empresa') return res.redirect('/pages/company.html');
    if (user.tipo_usuario === 'admin') return res.redirect('/pages/admin.html');
    return res.redirect('/pages/profile.html');
  } catch (error) {
    console.error('Error en /login:', error);
    return res.redirect('/?error=server');
  }
});

function inferMimeByName(name = '') {
  const ext = name.toLowerCase().split('.').pop();
  if (ext === 'png') return 'image/png';
  if (ext === 'jpg' || ext === 'jpeg') return 'image/jpeg';
  if (ext === 'webp') return 'image/webp';
  if (ext === 'gif') return 'image/gif';
  if (ext === 'pdf') return 'application/pdf';
  if (ext === 'doc') return 'application/msword';
  if (ext === 'docx') return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  return 'application/octet-stream';
}

function sanitizeUserRow(row) {
  return row ? {
    id_usuario: row.id_usuario,
    email: row.email,
    tipo_usuario: row.tipo_usuario,
    activo: row.activo,
  } : null;
}

async function comparePassword(input, stored) {
  if (!stored) return false;
  if (stored.startsWith('$2a$') || stored.startsWith('$2b$') || stored.startsWith('$2y$')) {
    return bcrypt.compare(input, stored);
  }
  return input === stored;
}

async function getStaticContent() {
  const { rows } = await pool.query('SELECT * FROM contenido_estatico WHERE id_contenido = 1');
  if (rows.length > 0) return rows[0];
  return {
    mision: 'Conectar el mejor talento con oportunidades reales a través de una experiencia moderna, clara y eficiente.',
    vision: 'Ser una plataforma de reclutamiento confiable e innovadora para postulantes, empresas y administradores.',
    valor1_titulo: 'Integridad',
    valor1_descripcion: 'Gestionamos la información con responsabilidad y transparencia.',
    valor2_titulo: 'Innovación',
    valor2_descripcion: 'Usamos tecnología para optimizar el proceso de reclutamiento.',
    valor3_titulo: 'Adaptabilidad',
    valor3_descripcion: 'Nos adaptamos a las necesidades de empresas y candidatos.',
    valor4_titulo: 'Colaboración',
    valor4_descripcion: 'Impulsamos conexiones de valor entre talento y organización.',
    datos_informativos: 'Nebula Play es una plataforma académica y funcional orientada al reclutamiento digital, gestión de vacantes y postulación con currículums.',
    whatsapp_link: 'https://wa.me/525500000000',
    horario: 'Lunes a Viernes de 9:00 a 18:00',
    direccion: 'Ciudad de México, México',
    correo_contacto: 'contacto@nebula.com',
    facebook_link: '#',
    instagram_link: '#',
    linkedin_link: '#',
    youtube_link: '#',
    leyenda_telefono: 'Puedes llamarnos en horario laboral para resolver dudas.',
    numero_telefono: '+52 55 1234 5678',
    leyenda_llamadas: 'Atención telefónica para dudas generales y soporte.',
    whatsapp_chat_link: 'https://wa.me/525500000000',
    leyenda_videollamadas: 'Solicita una videollamada vía WhatsApp para soporte especializado.',
  };
}

function estimateMatch(vacancyName = '', curriculumTitle = '', experience = '') {
  const sourceA = `${vacancyName} ${experience}`.toLowerCase();
  const sourceB = `${curriculumTitle} ${experience}`.toLowerCase();
  const keywords = ['java', 'diseño', 'ux', 'ui', 'desarrollador', 'marketing', 'datos', 'analista', 'devops', 'manager'];
  let score = 40;
  for (const kw of keywords) {
    if (sourceA.includes(kw) && sourceB.includes(kw)) score += 8;
  }
  if (vacancyName && curriculumTitle && sourceA.split(' ')[0] === sourceB.split(' ')[0]) score += 10;
  return Math.min(score, 98);
}

app.get('/api/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ ok: true, db: true });
  } catch (error) {
    res.status(500).json({ ok: false, db: false, error: error.message });
  }
});

app.get('/api/auth/me', (req, res) => {
  res.json({ user: req.session.user || null });
});

app.post('/api/auth/logout', (req, res) => {
  req.session.destroy(() => res.json({ ok: true }));
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email y contraseña son obligatorios.' });
    }

    const { rows } = await pool.query(
      'SELECT id_usuario, email, contrasena, tipo_usuario, activo FROM usuarios WHERE email = $1 LIMIT 1',
      [email]
    );

    const user = rows[0];
    if (!user || !user.activo) {
      return res.status(401).json({ error: 'Credenciales inválidas.' });
    }

    const valid = await comparePassword(password, user.contrasena);
    if (!valid) {
      return res.status(401).json({ error: 'Credenciales inválidas.' });
    }

    req.session.user = sanitizeUserRow(user);
    res.json({ ok: true, user: req.session.user, redirect: user.tipo_usuario === 'empresa' ? '/pages/company.html' : user.tipo_usuario === 'admin' ? '/pages/admin.html' : '/pages/profile.html' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/auth/register-user', upload.single('foto_perfil'), async (req, res) => {
  const client = await pool.connect();
  try {
    const {
      nombre_completo,
      fecha_nacimiento,
      sexo,
      email,
      password,
      puesto,
      anios_experiencia,
      descripcion_experiencia,
    } = req.body;

    if (!nombre_completo || !fecha_nacimiento || !sexo || !email || !password || !puesto || !anios_experiencia) {
      return res.status(400).json({ error: 'Completa todos los campos obligatorios.' });
    }

    await client.query('BEGIN');
    const passwordHash = await bcrypt.hash(password, 10);

    const userResult = await client.query(
      `INSERT INTO usuarios (email, contrasena, tipo_usuario, activo)
       VALUES ($1, $2, 'postulante', true)
       RETURNING id_usuario, email, tipo_usuario, activo`,
      [email, passwordHash]
    );

    const user = userResult.rows[0];
    const experiencia = `${puesto} - ${anios_experiencia}. ${descripcion_experiencia || ''}`.trim();

    await client.query(
      `INSERT INTO postulantes (id_postulante, nombre_completo, fecha_nacimiento, experiencia_especialidad, sexo)
       VALUES ($1, $2, $3, $4, $5)`,
      [user.id_usuario, nombre_completo, fecha_nacimiento, experiencia, sexo]
    );

    await client.query('COMMIT');
    req.session.user = sanitizeUserRow(user);
    res.json({ ok: true, user: req.session.user, redirect: '/pages/profile.html' });
  } catch (error) {
    await client.query('ROLLBACK');
    if (error.code === '23505') return res.status(409).json({ error: 'El correo ya está registrado.' });
    res.status(500).json({ error: error.message });
  } finally {
    client.release();
  }
});

app.post('/api/auth/register-company', upload.single('logo_empresa'), async (req, res) => {
  const client = await pool.connect();
  try {
    const {
      nombre_empresa,
      rfc,
      industria,
      ubicacion,
      sitio_web,
      email,
      telefono,
      responsable,
      puesto_responsable,
      password,
    } = req.body;

    if (!nombre_empresa || !email || !password || !industria || !ubicacion || !responsable) {
      return res.status(400).json({ error: 'Completa los campos obligatorios.' });
    }

    await client.query('BEGIN');
    const passwordHash = await bcrypt.hash(password, 10);

    const userResult = await client.query(
      `INSERT INTO usuarios (email, contrasena, tipo_usuario, activo)
       VALUES ($1, $2, 'empresa', true)
       RETURNING id_usuario, email, tipo_usuario, activo`,
      [email, passwordHash]
    );

    const user = userResult.rows[0];
    const descripcion = `Industria: ${industria}. RFC: ${rfc || 'No especificado'}. Responsable: ${responsable}. Puesto: ${puesto_responsable || 'No especificado'}. Sitio web: ${sitio_web || 'No especificado'}. Teléfono: ${telefono || 'No especificado'}. Ubicación: ${ubicacion}.`;

    await client.query(
      `INSERT INTO empresas (id_empresa, nombre_empresa, descripcion, sedes)
       VALUES ($1, $2, $3, $4)`,
      [user.id_usuario, nombre_empresa, descripcion, ubicacion]
    );

    await client.query('COMMIT');
    req.session.user = sanitizeUserRow(user);
    res.json({ ok: true, user: req.session.user, redirect: '/pages/company.html' });
  } catch (error) {
    await client.query('ROLLBACK');
    if (error.code === '23505') return res.status(409).json({ error: 'El correo ya está registrado.' });
    res.status(500).json({ error: error.message });
  } finally {
    client.release();
  }
});

app.get('/api/content', async (_req, res) => {
  try {
    const content = await getStaticContent();
    res.json(content);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/jobs', async (req, res) => {
  try {
    const q = (req.query.q || '').trim().toLowerCase();
    const { rows } = await pool.query(
      `SELECT v.id_vacante, v.nombre_imagen, v.fecha_publicacion, e.id_empresa, e.nombre_empresa, e.descripcion, e.mision, e.vision, e.clientes, e.sedes
       FROM vacantes v
       INNER JOIN empresas e ON e.id_empresa = v.id_empresa
       WHERE v.activa = true
       ORDER BY v.fecha_publicacion DESC`
    );

    const data = rows
      .filter((row) => {
        if (!q) return true;
        return [row.nombre_imagen, row.nombre_empresa, row.descripcion].join(' ').toLowerCase().includes(q);
      })
      .map((row) => ({
        id_vacante: row.id_vacante,
        titulo: (row.nombre_imagen || 'Vacante sin nombre').replace(/\.(png|jpg|jpeg|webp|gif)$/i, ''),
        empresa: row.nombre_empresa,
        descripcion: row.descripcion || 'Vacante publicada por la empresa.',
        fecha_publicacion: row.fecha_publicacion,
        imagen_url: `/api/vacancies/${row.id_vacante}/image`,
      }));

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/jobs/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT v.id_vacante, v.nombre_imagen, v.fecha_publicacion, e.id_empresa, e.nombre_empresa, e.descripcion, e.mision, e.vision, e.clientes, e.sedes
       FROM vacantes v
       INNER JOIN empresas e ON e.id_empresa = v.id_empresa
       WHERE v.id_vacante = $1 LIMIT 1`,
      [req.params.id]
    );
    if (!rows[0]) return res.status(404).json({ error: 'Vacante no encontrada.' });

    const row = rows[0];
    res.json({
      id_vacante: row.id_vacante,
      titulo: (row.nombre_imagen || 'Vacante').replace(/\.(png|jpg|jpeg|webp|gif)$/i, ''),
      empresa: row.nombre_empresa,
      descripcion: row.descripcion || 'Vacante publicada por la empresa.',
      fecha_publicacion: row.fecha_publicacion,
      imagen_url: `/api/vacancies/${row.id_vacante}/image`,
      empresa_info: {
        descripcion: row.descripcion,
        mision: row.mision,
        vision: row.vision,
        clientes: row.clientes,
        sedes: row.sedes,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/vacancies/:id/image', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT imagen_vacante, nombre_imagen FROM vacantes WHERE id_vacante = $1 LIMIT 1', [req.params.id]);
    if (!rows[0]) return res.status(404).send('No encontrada');
    res.setHeader('Content-Type', inferMimeByName(rows[0].nombre_imagen || 'vacante.png'));
    res.send(rows[0].imagen_vacante);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.get('/api/companies/search', async (req, res) => {
  try {
    const q = `%${(req.query.q || '').trim().toLowerCase()}%`;
    const { rows } = await pool.query(
      `SELECT id_empresa, nombre_empresa, descripcion, mision, vision, clientes, sedes
       FROM empresas
       WHERE LOWER(nombre_empresa) LIKE $1
       ORDER BY nombre_empresa ASC`,
      [q]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/candidate/profile', requireRole('postulante'), async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT u.id_usuario, u.email, p.nombre_completo, p.fecha_nacimiento, p.sexo, p.experiencia_especialidad
       FROM usuarios u
       INNER JOIN postulantes p ON p.id_postulante = u.id_usuario
       WHERE u.id_usuario = $1 LIMIT 1`,
      [req.session.user.id_usuario]
    );
    res.json(rows[0] || null);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/candidate/profile', requireRole('postulante'), async (req, res) => {
  try {
    const { nombre_completo, fecha_nacimiento, sexo, experiencia_especialidad } = req.body;
    await pool.query(
      `UPDATE postulantes
       SET nombre_completo = $1, fecha_nacimiento = $2, sexo = $3, experiencia_especialidad = $4, fecha_actualizacion = CURRENT_TIMESTAMP
       WHERE id_postulante = $5`,
      [nombre_completo, fecha_nacimiento, sexo, experiencia_especialidad, req.session.user.id_usuario]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/candidate/cvs', requireRole('postulante'), async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id_curriculum, titulo, nombre_archivo, fecha_subida
       FROM curriculums
       WHERE id_postulante = $1 AND activo = true
       ORDER BY fecha_subida DESC`,
      [req.session.user.id_usuario]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/candidate/cvs', requireRole('postulante'), upload.single('curriculum'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Debes seleccionar un archivo.' });
    const titulo = req.body.titulo || req.file.originalname;
    await pool.query(
      `INSERT INTO curriculums (id_postulante, titulo, archivo_pdf, nombre_archivo, activo)
       VALUES ($1, $2, $3, $4, true)`,
      [req.session.user.id_usuario, titulo, req.file.buffer, req.file.originalname]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/candidate/cvs/:id', requireRole('postulante'), async (req, res) => {
  try {
    await pool.query(
      `UPDATE curriculums SET activo = false, fecha_actualizacion = CURRENT_TIMESTAMP
       WHERE id_curriculum = $1 AND id_postulante = $2`,
      [req.params.id, req.session.user.id_usuario]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/candidate/cvs/:id/file', requireRole('postulante', 'empresa', 'admin'), async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT archivo_pdf, nombre_archivo FROM curriculums WHERE id_curriculum = $1 LIMIT 1', [req.params.id]);
    if (!rows[0]) return res.status(404).send('No encontrado');
    res.setHeader('Content-Type', inferMimeByName(rows[0].nombre_archivo || 'archivo.pdf'));
    res.send(rows[0].archivo_pdf);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.get('/api/candidate/applications', requireRole('postulante'), async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT po.id_postulacion, po.fecha_postulacion, po.estado, c.titulo AS curriculum_titulo,
              v.id_vacante, v.nombre_imagen AS vacante_titulo, e.nombre_empresa
       FROM postulaciones po
       INNER JOIN curriculums c ON c.id_curriculum = po.id_curriculum
       INNER JOIN vacantes v ON v.id_vacante = po.id_vacante
       INNER JOIN empresas e ON e.id_empresa = v.id_empresa
       WHERE c.id_postulante = $1
       ORDER BY po.fecha_postulacion DESC`,
      [req.session.user.id_usuario]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/jobs/:id/apply', requireRole('postulante'), async (req, res) => {
  try {
    const { id_curriculum } = req.body;
    if (!id_curriculum) return res.status(400).json({ error: 'Debes elegir un CV.' });

    const checkCv = await pool.query('SELECT id_curriculum FROM curriculums WHERE id_curriculum = $1 AND id_postulante = $2 AND activo = true', [id_curriculum, req.session.user.id_usuario]);
    if (!checkCv.rows[0]) return res.status(400).json({ error: 'El CV seleccionado no es válido.' });

    await pool.query(
      'INSERT INTO postulaciones (id_curriculum, id_vacante, estado) VALUES ($1, $2, $3)',
      [id_curriculum, req.params.id, 'pendiente']
    );
    res.json({ ok: true, message: 'Postulación enviada correctamente.' });
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Ya te postulaste con ese CV a esta vacante.' });
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/jobs/:id/match', requireRole('postulante'), async (req, res) => {
  try {
    const { id_curriculum } = req.query;
    const vacancyRes = await pool.query('SELECT nombre_imagen FROM vacantes WHERE id_vacante = $1 LIMIT 1', [req.params.id]);
    const cvRes = await pool.query(
      `SELECT c.titulo, p.experiencia_especialidad
       FROM curriculums c
       INNER JOIN postulantes p ON p.id_postulante = c.id_postulante
       WHERE c.id_curriculum = $1 AND c.id_postulante = $2 LIMIT 1`,
      [id_curriculum, req.session.user.id_usuario]
    );
    if (!vacancyRes.rows[0] || !cvRes.rows[0]) return res.status(404).json({ error: 'No se pudo calcular la compatibilidad.' });
    const score = estimateMatch(vacancyRes.rows[0].nombre_imagen, cvRes.rows[0].titulo, cvRes.rows[0].experiencia_especialidad);
    res.json({ score, label: score >= 80 ? 'Alta compatibilidad' : score >= 60 ? 'Compatibilidad media' : 'Compatibilidad inicial' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/company/profile', requireRole('empresa'), async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM empresas WHERE id_empresa = $1 LIMIT 1', [req.session.user.id_usuario]);
    res.json(rows[0] || null);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/company/profile', requireRole('empresa'), async (req, res) => {
  try {
    const { nombre_empresa, descripcion, mision, vision, clientes, sedes } = req.body;
    await pool.query(
      `UPDATE empresas
       SET nombre_empresa = $1, descripcion = $2, mision = $3, vision = $4, clientes = $5, sedes = $6, fecha_actualizacion = CURRENT_TIMESTAMP
       WHERE id_empresa = $7`,
      [nombre_empresa, descripcion, mision, vision, clientes, sedes, req.session.user.id_usuario]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/company/vacancies', requireRole('empresa'), async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id_vacante, nombre_imagen, fecha_publicacion, activa
       FROM vacantes WHERE id_empresa = $1
       ORDER BY fecha_publicacion DESC`,
      [req.session.user.id_usuario]
    );
    res.json(rows.map((row) => ({ ...row, imagen_url: `/api/vacancies/${row.id_vacante}/image` })));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/company/vacancies', requireRole('empresa'), upload.single('imagen_vacante'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Debes subir una imagen.' });
    const title = req.body.nombre_imagen || req.file.originalname;
    await pool.query(
      `INSERT INTO vacantes (id_empresa, imagen_vacante, nombre_imagen, activa)
       VALUES ($1, $2, $3, true)`,
      [req.session.user.id_usuario, req.file.buffer, title]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/company/vacancies/:id', requireRole('empresa', 'admin'), async (req, res) => {
  try {
    if (req.session.user.tipo_usuario === 'empresa') {
      await pool.query('UPDATE vacantes SET activa = false WHERE id_vacante = $1 AND id_empresa = $2', [req.params.id, req.session.user.id_usuario]);
    } else {
      await pool.query('UPDATE vacantes SET activa = false WHERE id_vacante = $1', [req.params.id]);
    }
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/company/candidates', requireRole('empresa'), async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT po.id_postulacion, po.estado, po.fecha_postulacion,
              v.id_vacante, v.nombre_imagen AS vacante_titulo,
              c.id_curriculum, c.titulo AS curriculum_titulo,
              p.id_postulante, p.nombre_completo, p.experiencia_especialidad
       FROM postulaciones po
       INNER JOIN vacantes v ON v.id_vacante = po.id_vacante
       INNER JOIN curriculums c ON c.id_curriculum = po.id_curriculum
       INNER JOIN postulantes p ON p.id_postulante = c.id_postulante
       WHERE v.id_empresa = $1 AND v.activa = true
       ORDER BY v.id_vacante ASC, po.fecha_postulacion DESC`,
      [req.session.user.id_usuario]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.patch('/api/company/applications/:id/status', requireRole('empresa'), async (req, res) => {
  try {
    const { estado } = req.body;
    await pool.query(
      `UPDATE postulaciones po
       SET estado = $1
       FROM vacantes v
       WHERE po.id_postulacion = $2 AND po.id_vacante = v.id_vacante AND v.id_empresa = $3`,
      [estado, req.params.id, req.session.user.id_usuario]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/admin/overview', requireRole('admin'), async (_req, res) => {
  try {
    const [users, companies, vacancies] = await Promise.all([
      pool.query('SELECT COUNT(*)::int AS total FROM usuarios'),
      pool.query('SELECT COUNT(*)::int AS total FROM empresas'),
      pool.query('SELECT COUNT(*)::int AS total FROM vacantes WHERE activa = true'),
    ]);
    res.json({
      usuarios: users.rows[0].total,
      empresas: companies.rows[0].total,
      vacantes: vacancies.rows[0].total,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/admin/users', requireRole('admin'), async (_req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT u.id_usuario, u.email, u.tipo_usuario, p.nombre_completo, p.experiencia_especialidad
       FROM usuarios u
       LEFT JOIN postulantes p ON p.id_postulante = u.id_usuario
       ORDER BY u.id_usuario ASC`
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/admin/companies', requireRole('admin'), async (_req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM empresas ORDER BY id_empresa ASC');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/admin/vacancies', requireRole('admin'), async (_req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT v.id_vacante, v.nombre_imagen, v.activa, e.nombre_empresa
       FROM vacantes v
       INNER JOIN empresas e ON e.id_empresa = v.id_empresa
       ORDER BY v.id_vacante DESC`
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/admin/content', requireRole('admin'), async (req, res) => {
  try {
    const content = await getStaticContent();
    const merged = { ...content, ...req.body };
    await pool.query(
      `INSERT INTO contenido_estatico (id_contenido, id_admin_ultima_modificacion, mision, vision, valor1_titulo, valor1_descripcion,
        valor2_titulo, valor2_descripcion, valor3_titulo, valor3_descripcion, valor4_titulo, valor4_descripcion,
        datos_informativos, whatsapp_link, horario, direccion, correo_contacto, facebook_link, instagram_link, linkedin_link, youtube_link,
        leyenda_telefono, numero_telefono, leyenda_llamadas, whatsapp_chat_link, leyenda_videollamadas)
       VALUES (1, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25)
       ON CONFLICT (id_contenido) DO UPDATE SET
        id_admin_ultima_modificacion = EXCLUDED.id_admin_ultima_modificacion,
        mision = EXCLUDED.mision,
        vision = EXCLUDED.vision,
        valor1_titulo = EXCLUDED.valor1_titulo,
        valor1_descripcion = EXCLUDED.valor1_descripcion,
        valor2_titulo = EXCLUDED.valor2_titulo,
        valor2_descripcion = EXCLUDED.valor2_descripcion,
        valor3_titulo = EXCLUDED.valor3_titulo,
        valor3_descripcion = EXCLUDED.valor3_descripcion,
        valor4_titulo = EXCLUDED.valor4_titulo,
        valor4_descripcion = EXCLUDED.valor4_descripcion,
        datos_informativos = EXCLUDED.datos_informativos,
        whatsapp_link = EXCLUDED.whatsapp_link,
        horario = EXCLUDED.horario,
        direccion = EXCLUDED.direccion,
        correo_contacto = EXCLUDED.correo_contacto,
        facebook_link = EXCLUDED.facebook_link,
        instagram_link = EXCLUDED.instagram_link,
        linkedin_link = EXCLUDED.linkedin_link,
        youtube_link = EXCLUDED.youtube_link,
        leyenda_telefono = EXCLUDED.leyenda_telefono,
        numero_telefono = EXCLUDED.numero_telefono,
        leyenda_llamadas = EXCLUDED.leyenda_llamadas,
        whatsapp_chat_link = EXCLUDED.whatsapp_chat_link,
        leyenda_videollamadas = EXCLUDED.leyenda_videollamadas,
        fecha_actualizacion = CURRENT_TIMESTAMP`,
      [
        req.session.user.id_usuario,
        merged.mision,
        merged.vision,
        merged.valor1_titulo,
        merged.valor1_descripcion,
        merged.valor2_titulo,
        merged.valor2_descripcion,
        merged.valor3_titulo,
        merged.valor3_descripcion,
        merged.valor4_titulo,
        merged.valor4_descripcion,
        merged.datos_informativos,
        merged.whatsapp_link,
        merged.horario,
        merged.direccion,
        merged.correo_contacto,
        merged.facebook_link,
        merged.instagram_link,
        merged.linkedin_link,
        merged.youtube_link,
        merged.leyenda_telefono,
        merged.numero_telefono,
        merged.leyenda_llamadas,
        merged.whatsapp_chat_link,
        merged.leyenda_videollamadas,
      ]
    );
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


app.get('/test-db', async (_req, res) => {
  try {
    const result = await pool.query('SELECT id_usuario, email, tipo_usuario FROM usuarios ORDER BY id_usuario');
    res.json({ ok: true, usuarios: result.rows });
  } catch (error) {
    console.error('Error en test-db:', error);
    res.status(500).json({ ok: false, error: error.message });
  }
});

app.get('/debug-session', (req, res) => {
  res.json({ user: req.session.user || null });
});

app.get('/pages/:file', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'pages', _req.params.file));
});

app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Nebula Play corriendo en http://localhost:${PORT}`);
});
