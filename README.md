# Nebula Play

<p align="center">
  <strong>Plataforma web de reclutamiento, perfiles profesionales, empresas, vacantes y postulaciones.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" />
  <img src="https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white" />
  <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=000" />
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white" />
  <img src="https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" />
</p>

---

## Descripción general

**Nebula Play** es una plataforma web de reclutamiento diseñada para conectar candidatos con empresas mediante perfiles profesionales, publicación de vacantes, carga de currículums y postulación a empleos.

El sistema permite manejar tres tipos de usuarios:

| Tipo de usuario | Funciones principales |
|---|---|
| Postulante | Crear perfil, cargar CVs, buscar vacantes y postularse |
| Empresa | Administrar perfil empresarial, publicar vacantes y revisar candidatos |
| Administrador | Revisar usuarios, empresas, vacantes y contenido de la plataforma |

---

## Funcionalidades principales

### Postulante

- Registro e inicio de sesión.
- Perfil profesional con datos personales.
- Carga de currículums en formato PDF.
- Visualización de bolsa de trabajo.
- Postulación a vacantes usando un CV seleccionado.
- Consulta del estado de postulaciones.

### Empresa

- Registro e inicio de sesión empresarial.
- Perfil de empresa con misión, visión, clientes y sedes.
- Publicación de vacantes.
- Visualización de candidatos postulados.
- Revisión de CVs enviados por postulantes.

### Administrador

- Visualización general de usuarios.
- Gestión de empresas registradas.
- Revisión de vacantes publicadas.
- Edición de contenido informativo de la plataforma.

---

## Tecnologías utilizadas

| Tecnología | Uso dentro del proyecto |
|---|---|
| HTML | Estructura de las páginas |
| CSS | Diseño visual, modo claro/oscuro y estilos responsivos |
| JavaScript | Interactividad del frontend |
| Node.js | Entorno de ejecución del servidor |
| Express.js | Backend y rutas API |
| PostgreSQL | Base de datos relacional |
| pgAdmin | Administración de la base de datos |
| Multer | Carga de archivos PDF e imágenes |
| Express Session | Manejo de sesiones de usuario |
| Bcrypt | Cifrado y validación de contraseñas |
| Nodemon | Recarga automática del servidor en desarrollo |

---

## Estructura del proyecto

```txt
nebula-play/
│
├── database/
│   ├── BDNebulaPlay.sql
│   ├── seed_demo_profesional.sql
│   └── seed_empresas_vacantes_candidatos.sql
│
├── public/
│   ├── assets/
│   ├── js/
│   ├── pages/
│   └── index.html
│
├── src/
│   ├── db.js
│   ├── middleware.js
│   └── server.js
│
├── .env.example
├── .gitignore
├── package.json
└── README.md
