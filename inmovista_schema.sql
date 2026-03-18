-- ============================================================
--  InmoVista — Esquema de Base de Datos
--  Motor: MySQL 8.x
--  Fecha: 2026-02-27
-- ============================================================

-- Crear y seleccionar la base de datos
CREATE DATABASE IF NOT EXISTS inmovista_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE inmovista_db;

-- ─────────────────────────────────────────────────────────────
-- TABLA: roles
-- Catálogo de roles del sistema
-- ─────────────────────────────────────────────────────────────
CREATE TABLE roles (
  id     INT          NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(30)  NOT NULL UNIQUE,   -- 'admin','inmobiliaria','cliente','usuario'
  PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO roles (nombre) VALUES
  ('admin'), ('inmobiliaria'), ('cliente'), ('usuario');

-- ─────────────────────────────────────────────────────────────
-- TABLA: usuarios
-- Todos los usuarios del sistema con su rol asignado
-- ─────────────────────────────────────────────────────────────
CREATE TABLE usuarios (
  id               INT           NOT NULL AUTO_INCREMENT,
  nombre           VARCHAR(80)   NOT NULL,
  apellido         VARCHAR(80)   NOT NULL,
  email            VARCHAR(120)  NOT NULL UNIQUE,
  password         VARCHAR(255)  NOT NULL,          -- hash bcrypt
  telefono         VARCHAR(20)   DEFAULT NULL,
  rol_id           INT           NOT NULL,
  activo           TINYINT(1)    NOT NULL DEFAULT 0, -- 0=pendiente, 1=activo
  fecha_registro   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB;

-- Usuario administrador por defecto
INSERT INTO usuarios (nombre, apellido, email, password, rol_id, activo)
VALUES ('Admin', 'InmoVista', 'admin@inmovista.com', '$2a$10$placeholder_hash', 1, 1);

-- ─────────────────────────────────────────────────────────────
-- TABLA: propiedades
-- Catálogo de propiedades inmobiliarias
-- ─────────────────────────────────────────────────────────────
CREATE TABLE propiedades (
  id                INT            NOT NULL AUTO_INCREMENT,
  titulo            VARCHAR(150)   NOT NULL,
  descripcion       TEXT           DEFAULT NULL,
  tipo              ENUM('casa','apartamento','terreno','oficina','local','otro')
                                   NOT NULL DEFAULT 'casa',
  operacion         ENUM('venta','arriendo')
                                   NOT NULL DEFAULT 'venta',
  precio            DECIMAL(15,2)  NOT NULL,
  area              DECIMAL(10,2)  DEFAULT NULL,    -- m²
  habitaciones      TINYINT        DEFAULT 0,
  banos             TINYINT        DEFAULT 0,
  garaje            TINYINT(1)     DEFAULT 0,
  estado            ENUM('disponible','arrendado','vendido','inactivo')
                                   NOT NULL DEFAULT 'disponible',
  direccion         VARCHAR(200)   DEFAULT NULL,
  ciudad            VARCHAR(80)    DEFAULT NULL,
  barrio            VARCHAR(80)    DEFAULT NULL,
  foto_principal    VARCHAR(500)   DEFAULT NULL,    -- URL o ruta relativa
  agente_id         INT            DEFAULT NULL,    -- usuario con rol inmobiliaria
  fecha_publicacion DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_propiedad_agente FOREIGN KEY (agente_id) REFERENCES usuarios(id)
                                  ON DELETE SET NULL
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- TABLA: fotos_propiedades
-- Galería de fotos adicionales por propiedad
-- ─────────────────────────────────────────────────────────────
CREATE TABLE fotos_propiedades (
  id           INT          NOT NULL AUTO_INCREMENT,
  propiedad_id INT          NOT NULL,
  url          VARCHAR(500) NOT NULL,
  orden        TINYINT      DEFAULT 0,
  PRIMARY KEY (id),
  CONSTRAINT fk_foto_propiedad FOREIGN KEY (propiedad_id) REFERENCES propiedades(id)
                               ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- TABLA: citas
-- Solicitudes de visita de clientes a propiedades
-- ─────────────────────────────────────────────────────────────
CREATE TABLE citas (
  id               INT      NOT NULL AUTO_INCREMENT,
  cliente_id       INT      NOT NULL,
  propiedad_id     INT      NOT NULL,
  agente_id        INT      DEFAULT NULL,
  fecha_cita       DATETIME DEFAULT NULL,
  notas            TEXT     DEFAULT NULL,
  estado           ENUM('pendiente','confirmada','cancelada','realizada')
                            NOT NULL DEFAULT 'pendiente',
  fecha_solicitud  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_cita_cliente   FOREIGN KEY (cliente_id)   REFERENCES usuarios(id),
  CONSTRAINT fk_cita_propiedad FOREIGN KEY (propiedad_id) REFERENCES propiedades(id),
  CONSTRAINT fk_cita_agente    FOREIGN KEY (agente_id)    REFERENCES usuarios(id)
                               ON DELETE SET NULL
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- TABLA: solicitudes
-- Solicitudes formales de compra o arriendo
-- ─────────────────────────────────────────────────────────────
CREATE TABLE solicitudes (
  id               INT      NOT NULL AUTO_INCREMENT,
  cliente_id       INT      NOT NULL,
  propiedad_id     INT      NOT NULL,
  agente_id        INT      DEFAULT NULL,
  tipo             ENUM('venta','arriendo') NOT NULL,
  estado           ENUM('pendiente','aprobada','rechazada')
                            NOT NULL DEFAULT 'pendiente',
  fecha_solicitud  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_sol_cliente   FOREIGN KEY (cliente_id)   REFERENCES usuarios(id),
  CONSTRAINT fk_sol_propiedad FOREIGN KEY (propiedad_id) REFERENCES propiedades(id),
  CONSTRAINT fk_sol_agente    FOREIGN KEY (agente_id)    REFERENCES usuarios(id)
                              ON DELETE SET NULL
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- TABLA: documentos
-- Archivos subidos por clientes para compra/arriendo
-- ─────────────────────────────────────────────────────────────
CREATE TABLE documentos (
  id               INT          NOT NULL AUTO_INCREMENT,
  cliente_id       INT          NOT NULL,
  propiedad_id     INT          DEFAULT NULL,
  solicitud_id     INT          DEFAULT NULL,
  nombre_archivo   VARCHAR(200) NOT NULL,
  ruta_archivo     VARCHAR(500) NOT NULL,   -- ruta en servidor
  tipo_doc         VARCHAR(80)  DEFAULT NULL, -- 'cedula','comprobante','contrato', etc.
  fecha_subida     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_doc_cliente    FOREIGN KEY (cliente_id)   REFERENCES usuarios(id),
  CONSTRAINT fk_doc_propiedad  FOREIGN KEY (propiedad_id) REFERENCES propiedades(id)
                               ON DELETE SET NULL,
  CONSTRAINT fk_doc_solicitud  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id)
                               ON DELETE SET NULL
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- TABLA: favoritos
-- Propiedades guardadas como favoritas por clientes
-- ─────────────────────────────────────────────────────────────
CREATE TABLE favoritos (
  id           INT      NOT NULL AUTO_INCREMENT,
  cliente_id   INT      NOT NULL,
  propiedad_id INT      NOT NULL,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_favorito (cliente_id, propiedad_id),
  CONSTRAINT fk_fav_cliente   FOREIGN KEY (cliente_id)   REFERENCES usuarios(id),
  CONSTRAINT fk_fav_propiedad FOREIGN KEY (propiedad_id) REFERENCES propiedades(id)
                              ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────
-- Datos de ejemplo
-- ─────────────────────────────────────────────────────────────
INSERT INTO propiedades (titulo, tipo, operacion, precio, area, habitaciones, banos, ciudad, barrio, estado)
VALUES
  ('Casa Moderna en Cabecera',   'casa',        'venta',   420000000, 180, 4, 3, 'Bucaramanga', 'Cabecera',          'disponible'),
  ('Apto Lagos del Cacique',     'apartamento', 'venta',   280000000, 110, 3, 2, 'Bucaramanga', 'Lagos del Cacique', 'disponible'),
  ('Oficina Centro Empresarial', 'oficina',     'arriendo',  2800000,  65, 0, 1, 'Bucaramanga', 'Centro',            'disponible'),
  ('Casa Campestre Floridablanca','casa',        'venta',   950000000, 320, 5, 4, 'Floridablanca','Altos',            'disponible'),
  ('Apto Amoblado Sotomayor',    'apartamento', 'arriendo',  1500000,  75, 2, 1, 'Bucaramanga', 'Sotomayor',         'disponible'),
  ('Penthouse Vista Panorámica', 'apartamento', 'venta',   680000000, 250, 4, 4, 'Bucaramanga', 'Norte',             'disponible');
