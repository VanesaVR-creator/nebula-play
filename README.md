# Nebula Play - versión profesional mejorada

Plataforma web de reclutamiento y perfiles profesionales con Node.js, Express, HTML, CSS, JavaScript y PostgreSQL.

## Requisitos

- Node.js instalado
- PostgreSQL instalado
- Base de datos `BDNebulaPlay` cargada
- Visual Studio Code

## 1. Configurar `.env`

El archivo `.env` debe estar en la raíz del proyecto, junto a `package.json`:

```env
DATABASE_URL=postgresql://postgres:hola@localhost:5432/BDNebulaPlay
PORT=4000
SESSION_SECRET=nebula_secret_123
```

Cambia `hola` si tu contraseña de PostgreSQL es diferente.

## 2. Cargar base de datos

En pgAdmin crea la base `BDNebulaPlay` y ejecuta:

1. `database/BDNebulaPlay.sql`
2. opcional: `database/seed_demo_profesional.sql`

El segundo archivo agrega un candidato completo y una empresa con vacantes.

## 3. Instalar dependencias

```bash
npm install
```

## 4. Ejecutar

```bash
npm run dev
```

Abrir:

```txt
http://localhost:4000
```

## 5. Verificar conexión

```txt
http://localhost:4000/api/health
```

Debe mostrar `db:true`.

## Usuarios de prueba

### Postulante existente
- Correo: `juan@email.com`
- Contraseña: `clave123`

### Empresa existente
- Correo: `empresa1@empresa.com`
- Contraseña: `clave789`

### Admin existente
- Correo: `admin@plataforma.com`
- Contraseña: `admin123`

### Postulante demo profesional
- Correo: `ana.talento@demo.com`
- Contraseña: `demo123`

### Empresa demo profesional
- Correo: `rrhh@technova.com`
- Contraseña: `empresa123`

## Mejoras incluidas

- Navbar funcional con enlaces activos
- Cierre de sesión con confirmación
- Modo oscuro y modo claro persistente
- Pie de página profesional
- Botón de archivo más compacto
- Perfil con modal real para editar datos
- Panel de empresa reorganizado
- Métricas de empresa y candidato
- SQL extra para cargar datos demo más completos
