function requireAuth(req, res, next) {
  if (!req.session.user) {
    return res.status(401).json({ error: 'Debes iniciar sesión.' });
  }
  next();
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.session.user) {
      return res.status(401).json({ error: 'Debes iniciar sesión.' });
    }
    if (!roles.includes(req.session.user.tipo_usuario)) {
      return res.status(403).json({ error: 'No tienes permisos para esta acción.' });
    }
    next();
  };
}

module.exports = { requireAuth, requireRole };
