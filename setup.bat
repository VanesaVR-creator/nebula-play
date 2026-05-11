@echo off
echo.
echo   Nebula Play - Instalacion automatica (Windows)
echo   ================================================
echo.

where node >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (echo   ERROR: Node.js no encontrado. Instala desde https://nodejs.org && pause && exit /b 1)
echo   OK: Node.js encontrado

where psql >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (echo   AVISO: psql no encontrado en PATH. Asegurate de que PostgreSQL este instalado.)

echo.
echo   Instalando dependencias...
call npm install

echo.
echo   Configuracion manual requerida:
echo   1. Abre el archivo .env en un editor de texto
echo   2. Reemplaza los valores de DATABASE_URL con tus credenciales de PostgreSQL
echo.
echo   Ejemplo de .env:
echo   DATABASE_URL=postgresql://postgres:TU_CONTRASENA@localhost:5432/BDNebulaPlay
echo   PORT=4000
echo   SESSION_SECRET=nebula_secret_2024
echo.
echo   3. Crea la base de datos en PostgreSQL:
echo      createdb -U postgres BDNebulaPlay
echo.
echo   4. Carga el esquema:
echo      psql -U postgres -d BDNebulaPlay -f database\BDNebulaPlay.sql
echo.
echo   5. Carga datos de demo:
echo      psql -U postgres -d BDNebulaPlay -f database\seed_demo_profesional.sql
echo.
echo   6. Inicia el servidor:
echo      npm start
echo.
echo   7. Abre en tu navegador: http://localhost:4000
echo.
pause
