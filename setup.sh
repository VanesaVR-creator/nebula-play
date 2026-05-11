#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  NEBULA PLAY — Script de instalación automática (Mac/Linux)
# ═══════════════════════════════════════════════════════════

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo ""
echo -e "${CYAN}  ✦ NEBULA PLAY — Instalación${NC}"
echo "  ──────────────────────────────"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
  echo -e "${YELLOW}  ⚠️  Node.js no encontrado. Instálalo desde https://nodejs.org${NC}"; exit 1
fi
echo -e "${GREEN}  ✓ Node.js $(node -v)${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
  echo -e "${YELLOW}  ⚠️  npm no encontrado.${NC}"; exit 1
fi
echo -e "${GREEN}  ✓ npm $(npm -v)${NC}"

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
  echo -e "${YELLOW}  ⚠️  PostgreSQL no encontrado. Instálalo desde https://postgresql.org${NC}"; exit 1
fi
echo -e "${GREEN}  ✓ PostgreSQL disponible${NC}"

echo ""
echo "  Instalando dependencias npm..."
npm install

echo ""
echo -e "${CYAN}  Configuración de base de datos${NC}"
echo "  ──────────────────────────────"
read -p "  Nombre de usuario PostgreSQL [postgres]: " PG_USER
PG_USER=${PG_USER:-postgres}
read -s -p "  Contraseña de PostgreSQL: " PG_PASS
echo ""
read -p "  Nombre de la base de datos [BDNebulaPlay]: " PG_DB
PG_DB=${PG_DB:-BDNebulaPlay}

# Create DB and load schema
echo "  Creando base de datos..."
PGPASSWORD="$PG_PASS" createdb -U "$PG_USER" "$PG_DB" 2>/dev/null || echo "  (La base de datos ya existe, continuando...)"

echo "  Cargando esquema..."
PGPASSWORD="$PG_PASS" psql -U "$PG_USER" -d "$PG_DB" -f "database/BDNebulaPlay.sql" -q

echo "  Cargando datos de demostración..."
PGPASSWORD="$PG_PASS" psql -U "$PG_USER" -d "$PG_DB" -f "database/seed_demo_profesional.sql" -q 2>/dev/null || \
  PGPASSWORD="$PG_PASS" psql -U "$PG_USER" -d "$PG_DB" -f "database/seed_empresas_vacantes_candidatos.sql" -q 2>/dev/null || \
  echo "  (Datos de demo no cargados — puedes hacerlo manualmente)"

# Write .env
cat > .env << ENVEOF
DATABASE_URL=postgresql://${PG_USER}:${PG_PASS}@localhost:5432/${PG_DB}
PORT=4000
SESSION_SECRET=nebula_secret_$(openssl rand -hex 12 2>/dev/null || echo "presentation2024")
ENVEOF

echo ""
echo -e "${GREEN}  ✓ Instalación completa${NC}"
echo ""
echo "  Para iniciar la plataforma ejecuta:"
echo -e "  ${CYAN}  npm start${NC}"
echo ""
echo "  Luego abre en tu navegador:"
echo -e "  ${CYAN}  http://localhost:4000${NC}"
echo ""
