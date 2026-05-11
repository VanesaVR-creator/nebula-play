# ✦ NEBULA PLAY — Guía de Demostración para Presentación
 
> **URL:** `http://localhost:4000`

---

## Antes de comenzar

1. Asegúrate de que el servidor está corriendo: `npm start`
2. Abre el navegador en `http://localhost:4000`
3. Configura el navegador en pantalla completa (F11)

---

## PARTE 1 — Pantalla de inicio y login

### Mostrar
- La pantalla de bienvenida con el nombre **Nebula** prominente
- Los badges: "Matching con IA", "Gestión de CV", "Panel para empresas"
- Los dos botones de registro (candidato y empresa)
- El formulario de login

---

## PARTE 2 — Flujo del candidato (5–6 min)

### 2.1 Iniciar sesión como candidato

| Campo | Valor |
|-------|-------|
| Correo | `ana.talento@demo.com` |
| Contraseña | `demo123` |

> *(Si no existen, usa los datos de demo cargados en la BD o registra uno nuevo)*

### 2.2 Perfil del candidato

**Mostrar:**
- El avatar y nombre
- Las estadísticas: CV activos, postulaciones, estado
- La sección de experiencia laboral
- Los CVs cargados con botón "Ver archivo"
- Las postulaciones previas con su estado (pendiente/contactado)

**Acciones en vivo:**
- Clic en **"Editar perfil"** → Mostrar el modal con el formulario → Hacer un pequeño cambio → Guardar

### 2.3 Bolsa de trabajo

**Mostrar:**
- Tarjetas de vacantes con imágenes corporativas
- El buscador: escribir "diseño" o "desarrollador" para filtrar en tiempo real

**Acciones:**
- Clic en una vacante → Ver el detalle con imagen completa e info de la empresa

### 2.4 Postularse con IA (punto fuerte)

**En la pantalla de detalle de vacante:**
1. Seleccionar un CV del dropdown
2. Clic en **"✦ Calcular compatibilidad IA"**  
   → Se muestra el porcentaje (ej: "78% — Compatibilidad media")
3. Clic en **"Enviar postulación"**  
   → Mensaje de confirmación "¡Postulación enviada exitosamente!"

> *"El sistema analiza las palabras clave de la experiencia del candidato contra el título de la vacante y genera un score de compatibilidad. Esto ayuda al candidato a elegir el CV más adecuado y a la empresa a priorizar perfiles."*

### 2.5 Otras secciones del candidato

- **Acerca de nosotros** → Misión, visión y valores
- **Contacto** → Formulario de contacto + datos de la empresa
- **Ayuda** → FAQ interactivo (hacer clic en preguntas para expandir)

---

## PARTE 3 — Flujo de la empresa (4–5 min)

### 3.1 Cerrar sesión y entrar como empresa

- Clic en **"Cerrar sesión"** → Redirige al login
- Entrar con:

| Campo | Valor |
|-------|-------|
| Correo | `rrhh@technova.com` |
| Contraseña | `demo123` |

### 3.2 Panel de empresa — Perfil

**Mostrar:**
- El header con nombre de empresa y KPIs (vacantes, candidatos, contactados)
- El menú lateral con 4 secciones
- El formulario de perfil empresarial ya llenado

**Acciones:**
- Editar la misión o visión y guardar
- Mostrar que la información se actualiza en tiempo real

### 3.3 Publicar una vacante

1. Clic en **"Vacantes"** en el menú lateral
2. Escribir un título: *"Analista de Marketing Digital"*
3. Seleccionar una imagen de vacante (tener una preparada)
4. Clic en **"Publicar vacante"**
5. Mostrar la imagen en la galería

> *"Las vacantes se muestran como tarjetas visuales. Esto permite que la empresa mantenga su identidad visual en cada publicación."*

### 3.4 Revisar candidatos

1. Clic en **"Candidatos"** en el menú lateral
2. Mostrar la lista de postulantes con su nombre, experiencia y vacante aplicada
3. Clic en **"📄 Ver CV"** → Se abre el CV en PDF en nueva pestaña
4. Cambiar estado: clic en **"✉ Contactar"**  
   → El badge cambia a "contactado"
5. Mostrar el contador actualizado (KPI "Contactados")

---

## PARTE 4 — Panel de administrador (2 min)

### Cerrar sesión e iniciar como admin

| Campo | Valor |
|-------|-------|
| Correo | `admin@nebula.com` |
| Contraseña | `admin123` |

### Mostrar

- Los 3 KPIs globales: total de usuarios, empresas, vacantes activas
- **Pestaña Usuarios** → Lista de todos los candidatos registrados
- **Pestaña Empresas** → Lista de empresas con su descripción
- **Pestaña Vacantes** → Todas las vacantes con opción de desactivar
- **Pestaña Contenido** → Editar misión, visión, contacto en tiempo real

> *"El administrador tiene control total de la plataforma: puede gestionar usuarios, empresas, vacantes y el contenido informativo que ven todos los usuarios."*

---

## PARTE 5 — Aspectos técnicos (opcional, 1–2 min)

> Para audiencia técnica

- **Backend:** Node.js + Express + sesiones seguras
- **Base de datos:** PostgreSQL con triggers (límite de 8 CVs por candidato)
- **Frontend:** HTML, CSS y JavaScript vanilla — sin frameworks
- **IA básica:** Algoritmo de matching por palabras clave entre CV y vacante
- **Archivos:** CVs en PDF y DOC almacenados en BD como bytea; imágenes de vacantes igualmente
- **Seguridad:** Bcrypt para contraseñas, validación de roles por sesión

---

## Credenciales de demo rápidas

| Usuario | Email | Contraseña | Tipo |
|---------|-------|------------|------|
| Ana Martínez (candidato) | `ana.talento@demo.com` | `demo123` | postulante |
| TechNova (empresa) | `rrhh@technova.com` | `empresa123` | empresa |
| Administrador | `admin@plataforma.com` | `admin123` | admin |

> ⚠️ Estas credenciales dependen de los datos seed cargados. Verifica con `psql` que existan.

---

## Comandos útiles

```bash
# Iniciar el servidor
npm start

# Ver en modo desarrollo (con auto-reload)
npm run dev

# Verificar conexión a BD
curl http://localhost:4000/api/health

# Ver usuarios en BD
psql -U postgres -d BDNebulaPlay -c "SELECT email, tipo_usuario FROM usuarios;"
```

---

## Solución de problemas frecuentes

| Problema | Solución |
|----------|----------|
| `Error: connect ECONNREFUSED` | PostgreSQL no está corriendo. Inicia el servicio. |
| `Error: database "BDNebulaPlay" does not exist` | Ejecuta el setup o crea la BD manualmente. |
| Pantalla blanca al abrir | Revisa la consola del navegador (F12). Posible error de sesión. |
| Login no funciona | Verifica en `/api/health` que la BD esté conectada. |
| No hay vacantes | Carga el seed: `psql ... -f database/seed_demo_profesional.sql` |

