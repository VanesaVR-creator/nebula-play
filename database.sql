--
-- PostgreSQL database dump
--

\restrict CEzfLwSRJyi2KM0M8C2toNAtkcZghe62REHGBx0uYmVlO3JngyfGbLyKzmMAc90

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-03-06 00:33:51

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 233 (class 1255 OID 16483)
-- Name: check_limite_curriculums(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_limite_curriculums() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
    	IF (SELECT COUNT(*) FROM curriculums WHERE id_postulante = NEW.id_postulante AND activo = true) >= 8 THEN
        RAISE EXCEPTION 'Límite alcanzado: máximo 8 curriculums por postulante';
    	END IF;
    	RETURN NEW;
	END;
	$$;


ALTER FUNCTION public.check_limite_curriculums() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 16546)
-- Name: administradores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administradores (
    id_admin integer NOT NULL,
    nombre_admin character varying(150) NOT NULL,
    rol character varying(50) DEFAULT 'administrador'::character varying,
    fecha_asignacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.administradores OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16560)
-- Name: contenido_estatico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contenido_estatico (
    id_contenido integer DEFAULT 1 NOT NULL,
    id_admin_ultima_modificacion integer NOT NULL,
    mision text,
    vision text,
    imagen_mision bytea,
    imagen_vision bytea,
    valor1_titulo character varying(100) DEFAULT 'Integridad en el manejo de datos'::character varying,
    valor1_descripcion text,
    valor1_imagen bytea,
    valor2_titulo character varying(100) DEFAULT 'Impacto en el desarrollo personal'::character varying,
    valor2_descripcion text,
    valor2_imagen bytea,
    valor3_titulo character varying(100) DEFAULT 'Adaptabilidad al futuro'::character varying,
    valor3_descripcion text,
    valor3_imagen bytea,
    valor4_titulo character varying(100) DEFAULT 'Colaboración sostenible'::character varying,
    valor4_descripcion text,
    valor4_imagen bytea,
    datos_informativos text,
    imagen_informativa bytea,
    lista_precios_imagen bytea,
    whatsapp_link character varying(255),
    horario text,
    direccion text,
    correo_contacto character varying(100),
    facebook_link character varying(255),
    instagram_link character varying(255),
    linkedin_link character varying(255),
    youtube_link character varying(255),
    leyenda_telefono text,
    numero_telefono character varying(50),
    leyenda_llamadas text,
    whatsapp_chat_link character varying(255),
    leyenda_videollamadas text,
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unico_registro CHECK ((id_contenido = 1))
);


ALTER TABLE public.contenido_estatico OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16463)
-- Name: curriculums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curriculums (
    id_curriculum integer NOT NULL,
    id_postulante integer NOT NULL,
    titulo character varying(200) NOT NULL,
    archivo_pdf bytea NOT NULL,
    nombre_archivo character varying(255),
    fecha_subida timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true
);


ALTER TABLE public.curriculums OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16462)
-- Name: curriculums_id_curriculum_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.curriculums_id_curriculum_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.curriculums_id_curriculum_seq OWNER TO postgres;

--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 222
-- Name: curriculums_id_curriculum_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.curriculums_id_curriculum_seq OWNED BY public.curriculums.id_curriculum;


--
-- TOC entry 224 (class 1259 OID 16485)
-- Name: empresas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empresas (
    id_empresa integer NOT NULL,
    nombre_empresa character varying(150) NOT NULL,
    descripcion text,
    vision text,
    mision text,
    clientes text,
    sedes text,
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.empresas OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16582)
-- Name: historial_cambios_empresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_cambios_empresa (
    id_cambio integer NOT NULL,
    id_empresa integer NOT NULL,
    id_admin_modificador integer NOT NULL,
    campo_modificado character varying(50),
    valor_anterior text,
    valor_nuevo text,
    fecha_cambio timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.historial_cambios_empresa OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16581)
-- Name: historial_cambios_empresa_id_cambio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_cambios_empresa_id_cambio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_cambios_empresa_id_cambio_seq OWNER TO postgres;

--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 231
-- Name: historial_cambios_empresa_id_cambio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historial_cambios_empresa_id_cambio_seq OWNED BY public.historial_cambios_empresa.id_cambio;


--
-- TOC entry 228 (class 1259 OID 16522)
-- Name: postulaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.postulaciones (
    id_postulacion integer NOT NULL,
    id_curriculum integer NOT NULL,
    id_vacante integer NOT NULL,
    fecha_postulacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character varying(20) DEFAULT 'pendiente'::character varying,
    CONSTRAINT postulaciones_estado_check CHECK (((estado)::text = ANY ((ARRAY['pendiente'::character varying, 'visto'::character varying, 'contactado'::character varying, 'descartado'::character varying])::text[])))
);


ALTER TABLE public.postulaciones OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16521)
-- Name: postulaciones_id_postulacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.postulaciones_id_postulacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.postulaciones_id_postulacion_seq OWNER TO postgres;

--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 227
-- Name: postulaciones_id_postulacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.postulaciones_id_postulacion_seq OWNED BY public.postulaciones.id_postulacion;


--
-- TOC entry 221 (class 1259 OID 16445)
-- Name: postulantes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.postulantes (
    id_postulante integer NOT NULL,
    nombre_completo character varying(150) NOT NULL,
    fecha_nacimiento date NOT NULL,
    experiencia_especialidad text,
    sexo character varying(20),
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT postulantes_sexo_check CHECK (((sexo)::text = ANY ((ARRAY['Masculino'::character varying, 'Femenino'::character varying, 'Otro'::character varying, 'Prefiero no decir'::character varying])::text[])))
);


ALTER TABLE public.postulantes OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16431)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
    email character varying(100) NOT NULL,
    contrasena character varying(255) NOT NULL,
    tipo_usuario character varying(20),
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true,
    CONSTRAINT usuarios_tipo_usuario_check CHECK (((tipo_usuario)::text = ANY ((ARRAY['postulante'::character varying, 'empresa'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16430)
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_usuario_seq OWNED BY public.usuarios.id_usuario;


--
-- TOC entry 226 (class 1259 OID 16501)
-- Name: vacantes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vacantes (
    id_vacante integer NOT NULL,
    id_empresa integer NOT NULL,
    imagen_vacante bytea NOT NULL,
    nombre_imagen character varying(255),
    fecha_publicacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activa boolean DEFAULT true
);


ALTER TABLE public.vacantes OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16500)
-- Name: vacantes_id_vacante_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vacantes_id_vacante_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vacantes_id_vacante_seq OWNER TO postgres;

--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 225
-- Name: vacantes_id_vacante_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vacantes_id_vacante_seq OWNED BY public.vacantes.id_vacante;


--
-- TOC entry 4897 (class 2604 OID 16466)
-- Name: curriculums id_curriculum; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.curriculums ALTER COLUMN id_curriculum SET DEFAULT nextval('public.curriculums_id_curriculum_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 16585)
-- Name: historial_cambios_empresa id_cambio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cambios_empresa ALTER COLUMN id_cambio SET DEFAULT nextval('public.historial_cambios_empresa_id_cambio_seq'::regclass);


--
-- TOC entry 4906 (class 2604 OID 16525)
-- Name: postulaciones id_postulacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulaciones ALTER COLUMN id_postulacion SET DEFAULT nextval('public.postulaciones_id_postulacion_seq'::regclass);


--
-- TOC entry 4893 (class 2604 OID 16434)
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuarios_id_usuario_seq'::regclass);


--
-- TOC entry 4902 (class 2604 OID 16504)
-- Name: vacantes id_vacante; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacantes ALTER COLUMN id_vacante SET DEFAULT nextval('public.vacantes_id_vacante_seq'::regclass);


--
-- TOC entry 5114 (class 0 OID 16546)
-- Dependencies: 229
-- Data for Name: administradores; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.administradores (id_admin, nombre_admin, rol, fecha_asignacion) VALUES (4, 'Admin Principal', 'administrador', '2026-03-05 23:59:30.045305');


--
-- TOC entry 5115 (class 0 OID 16560)
-- Dependencies: 230
-- Data for Name: contenido_estatico; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5108 (class 0 OID 16463)
-- Dependencies: 223
-- Data for Name: curriculums; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (1, 1, 'CV Java Developer', '\x636f6e74656e69646f5f7064665f31', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (2, 1, 'CV Proyectos Web', '\x636f6e74656e69646f5f7064665f32', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (3, 1, 'CV Experiencia', '\x636f6e74656e69646f5f7064665f33', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (4, 1, 'CV Certificaciones', '\x636f6e74656e69646f5f7064665f34', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (5, 1, 'CV Educación', '\x636f6e74656e69646f5f7064665f35', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (6, 1, 'CV Idiomas', '\x636f6e74656e69646f5f7064665f36', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (7, 1, 'CV Habilidades', '\x636f6e74656e69646f5f7064665f37', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (8, 1, 'CV Referencias', '\x636f6e74656e69646f5f7064665f38', NULL, '2026-03-06 00:01:16.784454', '2026-03-06 00:01:16.784454', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (10, 2, 'CV Diseño Gráfico', '\x7064665f6d617269615f31', NULL, '2026-03-06 00:05:04.312022', '2026-03-06 00:05:04.312022', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (11, 2, 'CV UX/UI', '\x7064665f6d617269615f32', NULL, '2026-03-06 00:05:04.312022', '2026-03-06 00:05:04.312022', true);
INSERT INTO public.curriculums (id_curriculum, id_postulante, titulo, archivo_pdf, nombre_archivo, fecha_subida, fecha_actualizacion, activo) VALUES (12, 2, 'CV Ilustración', '\x7064665f6d617269615f33', NULL, '2026-03-06 00:05:04.312022', '2026-03-06 00:05:04.312022', true);


--
-- TOC entry 5109 (class 0 OID 16485)
-- Dependencies: 224
-- Data for Name: empresas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.empresas (id_empresa, nombre_empresa, descripcion, vision, mision, clientes, sedes, fecha_actualizacion) VALUES (3, 'Tecnologías Innovadoras S.A.', 'Empresa de desarrollo de software', NULL, NULL, NULL, NULL, '2026-03-05 23:59:16.267598');


--
-- TOC entry 5117 (class 0 OID 16582)
-- Dependencies: 232
-- Data for Name: historial_cambios_empresa; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5113 (class 0 OID 16522)
-- Dependencies: 228
-- Data for Name: postulaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.postulaciones (id_postulacion, id_curriculum, id_vacante, fecha_postulacion, estado) VALUES (10, 1, 1, '2026-03-06 00:06:37.533801', 'pendiente');
INSERT INTO public.postulaciones (id_postulacion, id_curriculum, id_vacante, fecha_postulacion, estado) VALUES (11, 2, 2, '2026-03-06 00:06:37.533801', 'pendiente');
INSERT INTO public.postulaciones (id_postulacion, id_curriculum, id_vacante, fecha_postulacion, estado) VALUES (12, 1, 2, '2026-03-06 00:06:37.533801', 'pendiente');
INSERT INTO public.postulaciones (id_postulacion, id_curriculum, id_vacante, fecha_postulacion, estado) VALUES (13, 11, 2, '2026-03-06 00:15:40.564225', 'pendiente');


--
-- TOC entry 5106 (class 0 OID 16445)
-- Dependencies: 221
-- Data for Name: postulantes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.postulantes (id_postulante, nombre_completo, fecha_nacimiento, experiencia_especialidad, sexo, fecha_actualizacion) VALUES (1, 'Juan Pérez', '1995-05-15', 'Desarrollador Java 3 años', 'Masculino', '2026-03-05 23:59:00.884718');
INSERT INTO public.postulantes (id_postulante, nombre_completo, fecha_nacimiento, experiencia_especialidad, sexo, fecha_actualizacion) VALUES (2, 'María García', '1998-08-22', 'Diseñadora gráfica', 'Femenino', '2026-03-05 23:59:00.884718');


--
-- TOC entry 5105 (class 0 OID 16431)
-- Dependencies: 220
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuarios (id_usuario, email, contrasena, tipo_usuario, fecha_registro, activo) VALUES (1, 'juan@email.com', 'clave123', 'postulante', '2026-03-05 23:58:23.051178', true);
INSERT INTO public.usuarios (id_usuario, email, contrasena, tipo_usuario, fecha_registro, activo) VALUES (2, 'maria@email.com', 'clave456', 'postulante', '2026-03-05 23:58:23.051178', true);
INSERT INTO public.usuarios (id_usuario, email, contrasena, tipo_usuario, fecha_registro, activo) VALUES (3, 'empresa1@empresa.com', 'clave789', 'empresa', '2026-03-05 23:58:23.051178', true);
INSERT INTO public.usuarios (id_usuario, email, contrasena, tipo_usuario, fecha_registro, activo) VALUES (4, 'admin@plataforma.com', 'admin123', 'admin', '2026-03-05 23:58:23.051178', true);


--
-- TOC entry 5111 (class 0 OID 16501)
-- Dependencies: 226
-- Data for Name: vacantes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (1, 3, '\x696d6167656e5f73696d756c6164615f31', 'Desarrollador Java', '2026-03-06 00:02:31.132849', '2026-03-06 00:02:31.132849', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (2, 3, '\x696d6167656e5f73696d756c6164615f32', 'Diseñador UX/UI', '2026-03-06 00:02:31.132849', '2026-03-06 00:02:31.132849', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (3, 3, '\x696d6167656e5f73696d756c6164615f31', 'Desarrollador Java', '2026-03-06 00:05:17.992803', '2026-03-06 00:05:17.992803', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (4, 3, '\x696d6167656e5f73696d756c6164615f32', 'Diseñador UX/UI', '2026-03-06 00:05:17.992803', '2026-03-06 00:05:17.992803', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (5, 3, '\x696d6167656e5f73696d756c6164615f31', 'Desarrollador Java', '2026-03-06 00:05:21.433567', '2026-03-06 00:05:21.433567', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (6, 3, '\x696d6167656e5f73696d756c6164615f32', 'Diseñador UX/UI', '2026-03-06 00:05:21.433567', '2026-03-06 00:05:21.433567', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (7, 3, '\x696d6167656e5f73696d756c6164615f31', 'Desarrollador Java', '2026-03-06 00:06:37.533801', '2026-03-06 00:06:37.533801', true);
INSERT INTO public.vacantes (id_vacante, id_empresa, imagen_vacante, nombre_imagen, fecha_publicacion, fecha_actualizacion, activa) VALUES (8, 3, '\x696d6167656e5f73696d756c6164615f32', 'Diseñador UX/UI', '2026-03-06 00:06:37.533801', '2026-03-06 00:06:37.533801', true);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 222
-- Name: curriculums_id_curriculum_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.curriculums_id_curriculum_seq', 12, true);


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 231
-- Name: historial_cambios_empresa_id_cambio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_cambios_empresa_id_cambio_seq', 1, false);


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 227
-- Name: postulaciones_id_postulacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.postulaciones_id_postulacion_seq', 13, true);


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 4, true);


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 225
-- Name: vacantes_id_vacante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vacantes_id_vacante_seq', 8, true);


--
-- TOC entry 4941 (class 2606 OID 16554)
-- Name: administradores administradores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradores
    ADD CONSTRAINT administradores_pkey PRIMARY KEY (id_admin);


--
-- TOC entry 4943 (class 2606 OID 16574)
-- Name: contenido_estatico contenido_estatico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenido_estatico
    ADD CONSTRAINT contenido_estatico_pkey PRIMARY KEY (id_contenido);


--
-- TOC entry 4930 (class 2606 OID 16477)
-- Name: curriculums curriculums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.curriculums
    ADD CONSTRAINT curriculums_pkey PRIMARY KEY (id_curriculum);


--
-- TOC entry 4932 (class 2606 OID 16494)
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id_empresa);


--
-- TOC entry 4945 (class 2606 OID 16593)
-- Name: historial_cambios_empresa historial_cambios_empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cambios_empresa
    ADD CONSTRAINT historial_cambios_empresa_pkey PRIMARY KEY (id_cambio);


--
-- TOC entry 4937 (class 2606 OID 16535)
-- Name: postulaciones postulaciones_id_curriculum_id_vacante_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulaciones
    ADD CONSTRAINT postulaciones_id_curriculum_id_vacante_key UNIQUE (id_curriculum, id_vacante);


--
-- TOC entry 4939 (class 2606 OID 16533)
-- Name: postulaciones postulaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulaciones
    ADD CONSTRAINT postulaciones_pkey PRIMARY KEY (id_postulacion);


--
-- TOC entry 4928 (class 2606 OID 16456)
-- Name: postulantes postulantes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulantes
    ADD CONSTRAINT postulantes_pkey PRIMARY KEY (id_postulante);


--
-- TOC entry 4924 (class 2606 OID 16444)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 4926 (class 2606 OID 16442)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4935 (class 2606 OID 16514)
-- Name: vacantes vacantes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacantes
    ADD CONSTRAINT vacantes_pkey PRIMARY KEY (id_vacante);


--
-- TOC entry 4933 (class 1259 OID 16520)
-- Name: idx_vacantes_empresa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vacantes_empresa ON public.vacantes USING btree (id_empresa);


--
-- TOC entry 4956 (class 2620 OID 16484)
-- Name: curriculums trigger_limite_curriculums; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_limite_curriculums BEFORE INSERT ON public.curriculums FOR EACH ROW EXECUTE FUNCTION public.check_limite_curriculums();


--
-- TOC entry 4952 (class 2606 OID 16555)
-- Name: administradores administradores_id_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradores
    ADD CONSTRAINT administradores_id_admin_fkey FOREIGN KEY (id_admin) REFERENCES public.usuarios(id_usuario) ON DELETE CASCADE;


--
-- TOC entry 4953 (class 2606 OID 16575)
-- Name: contenido_estatico contenido_estatico_id_admin_ultima_modificacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenido_estatico
    ADD CONSTRAINT contenido_estatico_id_admin_ultima_modificacion_fkey FOREIGN KEY (id_admin_ultima_modificacion) REFERENCES public.administradores(id_admin);


--
-- TOC entry 4947 (class 2606 OID 16478)
-- Name: curriculums curriculums_id_postulante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.curriculums
    ADD CONSTRAINT curriculums_id_postulante_fkey FOREIGN KEY (id_postulante) REFERENCES public.postulantes(id_postulante) ON DELETE CASCADE;


--
-- TOC entry 4948 (class 2606 OID 16495)
-- Name: empresas empresas_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.usuarios(id_usuario) ON DELETE CASCADE;


--
-- TOC entry 4954 (class 2606 OID 16599)
-- Name: historial_cambios_empresa historial_cambios_empresa_id_admin_modificador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cambios_empresa
    ADD CONSTRAINT historial_cambios_empresa_id_admin_modificador_fkey FOREIGN KEY (id_admin_modificador) REFERENCES public.administradores(id_admin);


--
-- TOC entry 4955 (class 2606 OID 16594)
-- Name: historial_cambios_empresa historial_cambios_empresa_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cambios_empresa
    ADD CONSTRAINT historial_cambios_empresa_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa);


--
-- TOC entry 4950 (class 2606 OID 16536)
-- Name: postulaciones postulaciones_id_curriculum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulaciones
    ADD CONSTRAINT postulaciones_id_curriculum_fkey FOREIGN KEY (id_curriculum) REFERENCES public.curriculums(id_curriculum) ON DELETE CASCADE;


--
-- TOC entry 4951 (class 2606 OID 16541)
-- Name: postulaciones postulaciones_id_vacante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulaciones
    ADD CONSTRAINT postulaciones_id_vacante_fkey FOREIGN KEY (id_vacante) REFERENCES public.vacantes(id_vacante) ON DELETE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 16457)
-- Name: postulantes postulantes_id_postulante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.postulantes
    ADD CONSTRAINT postulantes_id_postulante_fkey FOREIGN KEY (id_postulante) REFERENCES public.usuarios(id_usuario) ON DELETE CASCADE;


--
-- TOC entry 4949 (class 2606 OID 16515)
-- Name: vacantes vacantes_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vacantes
    ADD CONSTRAINT vacantes_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa) ON DELETE CASCADE;


-- Completed on 2026-03-06 00:33:52

--
-- PostgreSQL database dump complete
--

\unrestrict CEzfLwSRJyi2KM0M8C2toNAtkcZghe62REHGBx0uYmVlO3JngyfGbLyKzmMAc90

