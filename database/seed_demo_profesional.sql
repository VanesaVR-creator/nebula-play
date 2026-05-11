-- Datos demo profesionales para Nebula Play
-- Ejecutar después de cargar BDNebulaPlay.sql en pgAdmin o Query Tool.
-- Crea un postulante completo y una empresa con vacantes activas.

DO $$
DECLARE
  id_candidato integer;
  id_empresa_demo integer;
  id_cv_general integer;
  id_cv_data integer;
  id_vac_full integer;
  id_vac_data integer;
  png bytea := decode('89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d49444154789c6360f8cf00000003010001e221bc330000000049454e44ae426082', 'hex');
BEGIN
  INSERT INTO usuarios (email, contrasena, tipo_usuario, activo)
  VALUES ('ana.talento@demo.com', 'demo123', 'postulante', true)
  ON CONFLICT (email) DO UPDATE SET contrasena = EXCLUDED.contrasena, tipo_usuario = 'postulante', activo = true
  RETURNING id_usuario INTO id_candidato;

  INSERT INTO postulantes (id_postulante, nombre_completo, fecha_nacimiento, experiencia_especialidad, sexo)
  VALUES (
    id_candidato,
    'Ana Sofía Martínez López',
    '1999-04-18',
    'Desarrolladora Full Stack - 3 años. Experiencia en JavaScript, Node.js, PostgreSQL, React, diseño de interfaces, documentación técnica, trabajo en equipo y metodologías ágiles. Ha participado en proyectos web administrativos, dashboards y automatización de procesos.',
    'Femenino'
  )
  ON CONFLICT (id_postulante) DO UPDATE SET
    nombre_completo = EXCLUDED.nombre_completo,
    fecha_nacimiento = EXCLUDED.fecha_nacimiento,
    experiencia_especialidad = EXCLUDED.experiencia_especialidad,
    sexo = EXCLUDED.sexo,
    fecha_actualizacion = CURRENT_TIMESTAMP;

  INSERT INTO curriculums (id_postulante, titulo, archivo_pdf, nombre_archivo, activo)
  VALUES (id_candidato, 'CV Full Stack JavaScript', convert_to('PDF DEMO ANA FULL STACK', 'UTF8'), 'CV_Ana_FullStack.pdf', true)
  ON CONFLICT DO NOTHING
  RETURNING id_curriculum INTO id_cv_general;

  INSERT INTO curriculums (id_postulante, titulo, archivo_pdf, nombre_archivo, activo)
  VALUES (id_candidato, 'CV Análisis de Datos y PostgreSQL', convert_to('PDF DEMO ANA DATA SQL', 'UTF8'), 'CV_Ana_Datos_SQL.pdf', true)
  ON CONFLICT DO NOTHING
  RETURNING id_curriculum INTO id_cv_data;

  INSERT INTO usuarios (email, contrasena, tipo_usuario, activo)
  VALUES ('rrhh@technova.com', 'empresa123', 'empresa', true)
  ON CONFLICT (email) DO UPDATE SET contrasena = EXCLUDED.contrasena, tipo_usuario = 'empresa', activo = true
  RETURNING id_usuario INTO id_empresa_demo;

  INSERT INTO empresas (id_empresa, nombre_empresa, descripcion, vision, mision, clientes, sedes)
  VALUES (
    id_empresa_demo,
    'TechNova Solutions',
    'Empresa mexicana enfocada en desarrollo de software, automatización de procesos, analítica de datos y soluciones web para pequeñas y medianas empresas.',
    'Ser una organización líder en transformación digital, creando productos tecnológicos seguros, escalables y centrados en el usuario.',
    'Impulsar a las empresas mediante soluciones tecnológicas modernas, eficientes y medibles, conectando talento joven con proyectos reales de innovación.',
    'Retail, educación, manufactura, logística y servicios profesionales.',
    'Querétaro, Ciudad de México y modalidad remota'
  )
  ON CONFLICT (id_empresa) DO UPDATE SET
    nombre_empresa = EXCLUDED.nombre_empresa,
    descripcion = EXCLUDED.descripcion,
    vision = EXCLUDED.vision,
    mision = EXCLUDED.mision,
    clientes = EXCLUDED.clientes,
    sedes = EXCLUDED.sedes,
    fecha_actualizacion = CURRENT_TIMESTAMP;

  INSERT INTO vacantes (id_empresa, imagen_vacante, nombre_imagen, activa)
  VALUES (id_empresa_demo, png, 'Desarrollador Full Stack Junior.png', true)
  RETURNING id_vacante INTO id_vac_full;

  INSERT INTO vacantes (id_empresa, imagen_vacante, nombre_imagen, activa)
  VALUES (id_empresa_demo, png, 'Analista de Datos PostgreSQL.png', true)
  RETURNING id_vacante INTO id_vac_data;

  IF id_cv_general IS NOT NULL AND id_vac_full IS NOT NULL THEN
    INSERT INTO postulaciones (id_curriculum, id_vacante, estado)
    VALUES (id_cv_general, id_vac_full, 'pendiente')
    ON CONFLICT (id_curriculum, id_vacante) DO NOTHING;
  END IF;

  IF id_cv_data IS NOT NULL AND id_vac_data IS NOT NULL THEN
    INSERT INTO postulaciones (id_curriculum, id_vacante, estado)
    VALUES (id_cv_data, id_vac_data, 'visto')
    ON CONFLICT (id_curriculum, id_vacante) DO NOTHING;
  END IF;
END $$;

-- Accesos demo:
-- Postulante: ana.talento@demo.com / demo123
-- Empresa: rrhh@technova.com / empresa123
