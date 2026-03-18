-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-03-2026 a las 00:14:52
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `inmobiliaria_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE `citas` (
  `id` int(11) NOT NULL,
  `propiedad_id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `agente_id` int(11) DEFAULT NULL,
  `fecha_cita` datetime NOT NULL,
  `estado` enum('pendiente','confirmada','cancelada','realizada') DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `citas`
--

INSERT INTO `citas` (`id`, `propiedad_id`, `cliente_id`, `agente_id`, `fecha_cita`, `estado`, `notas`, `fecha_solicitud`) VALUES
(6, 9, 2, NULL, '2026-03-26 14:00:00', 'confirmada', '', '2026-03-17 22:07:55'),
(7, 1, 2, NULL, '2026-04-10 16:00:00', 'pendiente', '', '2026-03-18 20:45:48'),
(8, 29, 2, NULL, '2026-03-17 14:00:00', 'pendiente', '', '2026-03-18 21:32:37'),
(9, 1, 4, NULL, '2026-03-20 09:00:00', 'confirmada', 'Quiero ver la cocina y el patio trasero.', '2026-03-18 21:44:54'),
(10, 1, 5, NULL, '2026-03-20 11:00:00', 'pendiente', 'Interesada en el precio y posibles descuentos.', '2026-03-18 21:44:54'),
(11, 1, 6, NULL, '2026-03-21 10:00:00', 'pendiente', 'Busco casa para familia de 4 personas.', '2026-03-18 21:44:54'),
(12, 2, 7, NULL, '2026-03-22 09:00:00', 'confirmada', 'Vivo en Bogotá, visita en mi próximo viaje.', '2026-03-18 21:44:54'),
(13, 2, 8, NULL, '2026-03-22 15:00:00', 'pendiente', 'Quiero ver el piso y la vista al lago.', '2026-03-18 21:44:54'),
(14, 4, 4, NULL, '2026-03-25 10:00:00', 'confirmada', 'Me interesa saber si tiene piscina climatizada.', '2026-03-18 21:44:54'),
(15, 4, 5, NULL, '2026-03-25 14:00:00', 'pendiente', 'Busco finca para fines de semana en familia.', '2026-03-18 21:44:54'),
(16, 6, 6, NULL, '2026-03-26 11:00:00', 'confirmada', 'Quiero ver la terraza y el gimnasio del edificio.', '2026-03-18 21:44:54'),
(17, 3, 7, NULL, '2026-03-27 09:00:00', 'pendiente', 'Necesito oficina para empresa de 5 personas.', '2026-03-18 21:44:54'),
(18, 5, 8, NULL, '2026-03-28 10:00:00', 'confirmada', 'Busco apto para arriendo por 6 meses.', '2026-03-18 21:44:54'),
(19, 7, 4, NULL, '2026-03-15 09:00:00', 'cancelada', 'Quería ver el local para una cafetería.', '2026-03-18 21:44:54'),
(20, 8, 5, NULL, '2026-03-10 10:00:00', 'realizada', 'Visita realizada. Interesada en el precio final.', '2026-03-18 21:44:54');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos`
--

CREATE TABLE `documentos` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `propiedad_id` int(11) DEFAULT NULL,
  `nombre_archivo` varchar(200) NOT NULL,
  `ruta_archivo` varchar(500) NOT NULL,
  `tipo_doc` varchar(80) DEFAULT NULL,
  `fecha_subida` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documentos`
--

INSERT INTO `documentos` (`id`, `cliente_id`, `propiedad_id`, `nombre_archivo`, `ruta_archivo`, `tipo_doc`, `fecha_subida`) VALUES
(1, 2, NULL, '1102348336.pdf', 'pendiente_de_envio_fisico', 'cedula', '2026-03-18 16:14:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `favoritos`
--

CREATE TABLE `favoritos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `propiedad_id` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `fotos_propiedades`
--

CREATE TABLE `fotos_propiedades` (
  `id` int(11) NOT NULL,
  `propiedad_id` int(11) NOT NULL,
  `url_foto` varchar(500) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `fotos_propiedades`
--

INSERT INTO `fotos_propiedades` (`id`, `propiedad_id`, `url_foto`, `es_principal`) VALUES
(1, 1, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70', 1),
(2, 1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=70', 0),
(3, 1, 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=70', 0),
(4, 2, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=70', 1),
(5, 2, 'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800&q=70', 0),
(6, 2, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=70', 0),
(7, 3, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=70', 1),
(8, 3, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&q=70', 0),
(9, 3, 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800&q=70', 0),
(10, 4, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=70', 1),
(11, 4, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70', 0),
(12, 4, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=70', 0),
(13, 5, 'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800&q=70', 1),
(14, 5, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=70', 0),
(15, 5, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=70', 0),
(16, 6, 'https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=800&q=70', 1),
(17, 6, 'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800&q=70', 0),
(18, 6, 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=70', 0),
(19, 7, 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=70', 1),
(20, 7, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 0),
(21, 7, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=70', 0),
(22, 8, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=70', 1),
(23, 8, 'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800&q=70', 0),
(24, 8, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=70', 0),
(25, 9, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=70', 1),
(26, 9, 'https://images.unsplash.com/photo-1503174971373-b1f69850bded?w=800&q=70', 0),
(27, 9, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=70', 0),
(28, 10, 'https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=800&q=70', 1),
(29, 10, 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&q=70', 0),
(30, 10, 'https://images.unsplash.com/photo-1555636222-cae831e670b3?w=800&q=70', 0),
(31, 11, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=70', 1),
(32, 11, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70', 0),
(33, 11, 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&q=70', 0),
(34, 12, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=70', 1),
(35, 12, 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800&q=70', 0),
(36, 12, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70', 0),
(37, 13, 'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800&q=70', 1),
(38, 13, 'https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=800&q=70', 0),
(39, 13, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=70', 0),
(40, 14, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=70', 1),
(41, 14, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&q=70', 0),
(42, 14, 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=800&q=70', 0),
(43, 15, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70', 1),
(44, 15, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=70', 0),
(45, 15, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=70', 0),
(46, 16, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=70', 1),
(47, 16, 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&q=70', 0),
(48, 16, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=70', 0),
(49, 17, 'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=800&q=70', 1),
(50, 17, 'https://images.unsplash.com/photo-1464082354059-27db6ce50048?w=800&q=70', 0),
(51, 17, 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=70', 0),
(52, 18, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=70', 1),
(53, 18, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 0),
(54, 18, 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800&q=70', 0),
(55, 19, 'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&q=70', 1),
(56, 19, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=70', 0),
(57, 19, 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800&q=70', 0),
(58, 20, 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=800&q=70', 1),
(59, 20, 'https://images.unsplash.com/photo-1581093196277-9f608bb3b511?w=800&q=70', 0),
(60, 21, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=70', 1),
(61, 21, 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800&q=70', 0),
(62, 21, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70', 0),
(63, 22, 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&q=70', 1),
(64, 22, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=70', 0),
(65, 23, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=70', 1),
(66, 23, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=70', 0),
(67, 24, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=70', 1),
(68, 24, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70', 0),
(69, 24, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 0),
(70, 25, 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&q=70', 1),
(71, 25, 'https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=800&q=70', 0),
(72, 26, 'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800&q=70', 1),
(73, 26, 'https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=800&q=70', 0),
(74, 26, 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=70', 0),
(75, 27, 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=800&q=70', 1),
(76, 27, 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=70', 0),
(77, 28, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=70', 1),
(78, 28, 'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800&q=70', 0),
(79, 28, 'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800&q=70', 0),
(80, 29, 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800&q=70', 1),
(81, 29, 'https://images.unsplash.com/photo-1570010589765-3c68e430f7d5?w=800&q=70', 0),
(82, 29, 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800&q=70', 0),
(83, 30, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&q=70', 1),
(84, 30, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=70', 0),
(85, 30, 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800&q=70', 0),
(86, 31, 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800&q=70', 1),
(87, 31, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=70', 0),
(88, 32, 'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800&q=70', 1),
(89, 32, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=70', 0),
(90, 33, 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800&q=70', 1),
(91, 33, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=70', 0),
(92, 33, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70', 0),
(93, 34, 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=70', 1),
(94, 34, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70', 0),
(95, 35, 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=800&q=70', 1),
(96, 35, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=70', 0),
(97, 36, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70', 1),
(98, 36, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 0),
(99, 36, 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=70', 0),
(100, 37, 'https://images.unsplash.com/photo-1503174971373-b1f69850bded?w=800&q=70', 1),
(101, 37, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=70', 0),
(102, 38, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=70', 1),
(103, 38, 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&q=70', 0),
(104, 39, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=70', 1),
(105, 39, 'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&q=70', 0),
(106, 39, 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800&q=70', 0),
(107, 40, 'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=70', 1),
(108, 40, 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=800&q=70', 0),
(109, 41, 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800&q=70', 1),
(110, 41, 'https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=800&q=70', 0),
(111, 41, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 0),
(112, 42, 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800&q=70', 1),
(113, 42, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=70', 0),
(114, 43, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70', 1),
(115, 43, 'https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=800&q=70', 0),
(116, 44, 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=70', 1),
(117, 44, 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=800&q=70', 0),
(118, 45, 'https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=800&q=70', 1),
(119, 45, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70', 0),
(120, 46, 'https://images.unsplash.com/photo-1600673132756-6d6a7b0b81ee?w=800&q=70', 1),
(121, 46, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70', 0),
(122, 46, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=70', 0),
(123, 47, 'https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=800&q=70', 1),
(124, 47, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70', 0),
(125, 48, 'https://images.unsplash.com/photo-1581093196277-9f608bb3b511?w=800&q=70', 1),
(126, 48, 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=800&q=70', 0),
(127, 49, 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800&q=70', 1),
(128, 49, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=70', 0),
(129, 49, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70', 0),
(130, 50, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=70', 1),
(131, 50, 'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=70', 0),
(132, 51, 'https://images.unsplash.com/photo-1464082354059-27db6ce50048?w=800&q=70', 1),
(133, 51, 'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=800&q=70', 0),
(134, 51, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=70', 0),
(135, 52, 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=70', 1),
(136, 52, 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&q=70', 0),
(137, 53, 'https://images.unsplash.com/photo-1555636222-cae831e670b3?w=800&q=70', 1),
(138, 53, 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&q=70', 0),
(139, 54, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70', 1),
(140, 54, 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800&q=70', 0),
(141, 54, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=70', 0),
(142, 55, 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&q=70', 1),
(143, 55, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70', 0),
(144, 56, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=70', 1),
(145, 56, 'https://images.unsplash.com/photo-1503174971373-b1f69850bded?w=800&q=70', 0),
(146, 57, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=70', 1),
(147, 57, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70', 0),
(148, 57, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70', 0),
(149, 58, 'https://images.unsplash.com/photo-1570010589765-3c68e430f7d5?w=800&q=70', 1),
(150, 58, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=70', 0),
(151, 58, 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=70', 0),
(152, 59, 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=800&q=70', 1),
(153, 59, 'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=70', 0),
(154, 60, 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=70', 1),
(155, 60, 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=800&q=70', 0),
(156, 60, 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=800&q=70', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `propiedades`
--

CREATE TABLE `propiedades` (
  `id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo` enum('casa','apartamento','terreno','oficina','local') NOT NULL,
  `operacion` enum('venta','arriendo') NOT NULL,
  `precio` decimal(15,2) NOT NULL,
  `area` decimal(10,2) DEFAULT NULL,
  `habitaciones` int(11) DEFAULT 0,
  `banos` int(11) DEFAULT 0,
  `garaje` tinyint(1) DEFAULT 0,
  `direccion` varchar(255) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `barrio` varchar(100) DEFAULT NULL,
  `latitud` decimal(10,8) DEFAULT NULL,
  `longitud` decimal(11,8) DEFAULT NULL,
  `estado` enum('disponible','reservada','vendida','arrendada') DEFAULT 'disponible',
  `propietario_id` int(11) DEFAULT NULL,
  `fecha_publicacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `usuario_id` int(11) DEFAULT 1,
  `foto_principal` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `propiedades`
--

INSERT INTO `propiedades` (`id`, `titulo`, `descripcion`, `tipo`, `operacion`, `precio`, `area`, `habitaciones`, `banos`, `garaje`, `direccion`, `ciudad`, `barrio`, `latitud`, `longitud`, `estado`, `propietario_id`, `fecha_publicacion`, `fecha_actualizacion`, `usuario_id`, `foto_principal`) VALUES
(1, 'Casa Moderna en Cabecera', 'Casa en venta ubicado en Cabecera, Bucaramanga. 180m².', 'casa', 'venta', 420000000.00, 180.00, 4, 3, 1, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70'),
(2, 'Apto Exclusivo Lagos del Cacique', 'Apartamento en venta ubicado en Lagos del Cacique, Bucaramanga. 110m².', 'apartamento', 'venta', 280000000.00, 110.00, 3, 2, 0, '', 'Bucaramanga', 'Lagos del Cacique', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=70'),
(3, 'Oficina Centro Empresarial', 'Oficina en arriendo ubicado en Centro, Bucaramanga. 65m².', 'oficina', 'arriendo', 2800000.00, 65.00, 0, 0, 0, '', 'Bucaramanga', 'Centro', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=70'),
(4, 'Casa Campestre Floridablanca', 'Casa en venta ubicado en Floridablanca, Floridablanca. 320m².', 'casa', 'venta', 950000000.00, 320.00, 5, 4, 1, '', 'Floridablanca', 'Floridablanca', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=70'),
(5, 'Apartamento Amoblado Sotomayor', 'Apartamento en arriendo ubicado en Sotomayor, Bucaramanga. 75m².', 'apartamento', 'arriendo', 1500000.00, 75.00, 2, 1, 0, '', 'Bucaramanga', 'Sotomayor', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800&q=70'),
(6, 'Penthouse Vista Panorámica BGA', 'Penthouse en venta ubicado en Norte, Bucaramanga. 250m².', '', 'venta', 680000000.00, 250.00, 4, 4, 1, '', 'Bucaramanga', 'Norte', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=800&q=70'),
(7, 'Casa Conjunto Cerrado Girón', 'Casa en venta ubicado en Girón, Girón. 145m².', 'casa', 'venta', 380000000.00, 145.00, 3, 2, 1, '', 'Girón', 'Girón', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&q=70'),
(8, 'Apartamento Nuevo El Jardín', 'Apartamento en arriendo ubicado en El Jardín, Bucaramanga. 90m².', 'apartamento', 'arriendo', 3500000.00, 90.00, 3, 2, 0, '', 'Bucaramanga', 'El Jardín', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=70'),
(9, 'Terreno Urbanizable Piedecuesta', 'Terreno en venta ubicado en Piedecuesta, Piedecuesta. 800m².', 'terreno', 'venta', 550000000.00, 800.00, 0, 0, 0, '', 'Piedecuesta', 'Piedecuesta', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=70'),
(10, 'Local Comercial Vía Principal', 'Local en arriendo ubicado en Cabecera, Bucaramanga. 120m².', 'local', 'arriendo', 4200000.00, 120.00, 0, 0, 0, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=800&q=70'),
(11, 'Apartamento VIS Morrorico', 'Apartamento en venta ubicado en Morrorico, Bucaramanga. 68m².', 'apartamento', 'venta', 195000000.00, 68.00, 2, 1, 0, '', 'Bucaramanga', 'Morrorico', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=70'),
(12, 'Mansión Exclusiva Lagos del Cacique', 'Casa en venta ubicado en Lagos del Cacique, Bucaramanga. 450m².', 'casa', 'venta', 1200000000.00, 450.00, 6, 5, 1, '', 'Bucaramanga', 'Lagos del Cacique', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=70'),
(13, 'Apartamento Cañaveral con Piscina', 'Apartamento en venta ubicado en Cañaveral, Floridablanca. 95m².', 'apartamento', 'venta', 320000000.00, 95.00, 3, 2, 0, '', 'Floridablanca', 'Cañaveral', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800&q=70'),
(14, 'Piso Corporativo Torre Empresarial', 'Oficina en arriendo ubicado en Zona Rosa, Bucaramanga. 200m².', 'oficina', 'arriendo', 5800000.00, 200.00, 0, 0, 1, '', 'Bucaramanga', 'Zona Rosa', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=70'),
(15, 'Casa de Lujo Sector Chico BGA', 'Casa en venta ubicado en El Chico, Bucaramanga. 380m².', 'casa', 'venta', 750000000.00, 380.00, 5, 4, 1, '', 'Bucaramanga', 'El Chico', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=70'),
(16, 'Estudio Amoblado Centro Histórico', 'Apartamento en arriendo ubicado en Centro Histórico, Bucaramanga. 55m².', 'apartamento', 'arriendo', 2200000.00, 55.00, 1, 1, 0, '', 'Bucaramanga', 'Centro Histórico', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=70'),
(17, 'Finca de Recreo Río de Oro', 'Finca en venta ubicado en Río de Oro, Bucaramanga. 1200m².', '', 'venta', 1500000000.00, 1200.00, 6, 4, 0, '', 'Bucaramanga', 'Río de Oro', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=800&q=70'),
(18, 'Casa Condominio Campestre Piedecuesta', 'Casa en venta ubicado en Piedecuesta, Piedecuesta. 160m².', 'casa', 'venta', 460000000.00, 160.00, 4, 3, 1, '', 'Piedecuesta', 'Piedecuesta', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=70'),
(19, 'Casa Premium Urbanización El Bosque', 'Casa en venta ubicado en El Bosque, Bucaramanga. 290m².', 'casa', 'venta', 890000000.00, 290.00, 5, 4, 1, '', 'Bucaramanga', 'El Bosque', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&q=70'),
(20, 'Bodega-Local Industrial Girón', 'Local en arriendo ubicado en Zona Industrial, Girón. 350m².', 'local', 'arriendo', 6500000.00, 350.00, 0, 0, 0, '', 'Girón', 'Zona Industrial', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=800&q=70'),
(21, 'Apto Moderno Sector Universitario UIS', 'Apartamento en venta ubicado en Sector UIS, Bucaramanga. 78m².', 'apartamento', 'venta', 235000000.00, 78.00, 2, 2, 0, '', 'Bucaramanga', 'Sector UIS', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=70'),
(22, 'Apartaestudio Amoblado Girardot', 'Apartamento en arriendo ubicado en Girardot, Bucaramanga. 50m².', 'apartamento', 'arriendo', 1800000.00, 50.00, 1, 1, 0, '', 'Bucaramanga', 'Girardot', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&q=70'),
(23, 'Lote Proyecto Urbanístico Lebrija', 'Terreno en venta ubicado en Lebrija, Lebrija. 2000m².', 'terreno', 'venta', 980000000.00, 2000.00, 0, 0, 0, '', 'Lebrija', 'Lebrija', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=70'),
(24, 'Casa Arquitectura Contemporánea Provenza', 'Casa en venta ubicado en Provenza, Bucaramanga. 205m².', 'casa', 'venta', 530000000.00, 205.00, 4, 3, 1, '', 'Bucaramanga', 'Provenza', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=70'),
(25, 'Local en Centro Comercial Cacique', 'Local en arriendo ubicado en CC Cacique, Bucaramanga. 140m².', 'local', 'arriendo', 4800000.00, 140.00, 0, 0, 0, '', 'Bucaramanga', 'CC Cacique', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&q=70'),
(26, 'Apartamento de Lujo Piso 18', 'Apartamento en venta ubicado en Cabecera, Bucaramanga. 130m².', 'apartamento', 'venta', 410000000.00, 130.00, 3, 3, 1, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800&q=70'),
(27, 'Hotel Boutique en Venta — Centro BGA', 'Edificio en venta ubicado en Centro, Bucaramanga. 5000m².', '', 'venta', 2600000000.00, 5000.00, 0, 0, 0, '', 'Bucaramanga', 'Centro', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=800&q=70'),
(28, 'Apartamento Remodelado Altos del Poblado', 'Apartamento en arriendo ubicado en Altos del Poblado, Bucaramanga. 82m².', 'apartamento', 'arriendo', 3200000.00, 82.00, 2, 2, 0, '', 'Bucaramanga', 'Altos del Poblado', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=70'),
(29, 'Casa Tradicional Sector Prado', 'Casa en venta ubicado en Prado, Bucaramanga. 240m².', 'casa', 'venta', 620000000.00, 240.00, 5, 3, 0, '', 'Bucaramanga', 'Prado', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800&q=70'),
(30, 'Sede Empresarial Completa Zona Norte', 'Oficina en arriendo ubicado en Zona Norte, Bucaramanga. 420m².', 'oficina', 'arriendo', 9500000.00, 420.00, 0, 0, 1, '', 'Bucaramanga', 'Zona Norte', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&q=70'),
(31, 'Apartamento Confort Sector Ricaurte', 'Apartamento en venta ubicado en Ricaurte, Bucaramanga. 102m².', 'apartamento', 'venta', 345000000.00, 102.00, 3, 2, 0, '', 'Bucaramanga', 'Ricaurte', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800&q=70'),
(32, 'Apto Amoblado Frente al Parque', 'Apartamento en arriendo ubicado en Mejoras Públicas, Bucaramanga. 88m².', 'apartamento', 'arriendo', 2900000.00, 88.00, 2, 2, 0, '', 'Bucaramanga', 'Mejoras Públicas', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800&q=70'),
(33, 'Villa con Piscina y Cancha — Floridablanca', 'Casa en venta ubicado en Villabel, Floridablanca. 400m².', 'casa', 'venta', 1100000000.00, 400.00, 6, 5, 0, '', 'Floridablanca', 'Villabel', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800&q=70'),
(34, 'Casa VIS Conjunto La Arboleda', 'Casa en venta ubicado en La Arboleda, Girón. 62m².', 'casa', 'venta', 175000000.00, 62.00, 3, 2, 0, '', 'Girón', 'La Arboleda', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=70'),
(35, 'Sede Clínica u Odontológica Equipada', 'Oficina en arriendo ubicado en Cabecera, Bucaramanga. 280m².', 'oficina', 'arriendo', 7200000.00, 280.00, 0, 0, 1, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=800&q=70'),
(36, 'Casa Remodelada Conjunto Lagos', 'Casa en venta ubicado en Lagos del Cacique, Bucaramanga. 175m².', 'casa', 'venta', 490000000.00, 175.00, 4, 3, 1, '', 'Bucaramanga', 'Lagos del Cacique', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=70'),
(37, 'Lote Comercial Vía a Piedecuesta', 'Terreno en venta ubicado en Anillo Vial, Bucaramanga. 600m².', 'terreno', 'venta', 730000000.00, 600.00, 0, 0, 0, '', 'Bucaramanga', 'Anillo Vial', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1503174971373-b1f69850bded?w=800&q=70'),
(38, 'Apartaestudio Estudiantil Bucarica', 'Apartamento en arriendo ubicado en Bucarica, Bucaramanga. 44m².', 'apartamento', 'arriendo', 1600000.00, 44.00, 1, 1, 0, '', 'Bucaramanga', 'Bucarica', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=70'),
(39, 'Casa Club House — Conjunto Privado', 'Casa en venta ubicado en Bello Horizonte, Bucaramanga. 310m².', 'casa', 'venta', 850000000.00, 310.00, 5, 4, 0, '', 'Bucaramanga', 'Bello Horizonte', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=70'),
(40, 'Dúplex Estilo Loft — Zona Rosa', 'Apartamento en arriendo ubicado en Zona Rosa, Bucaramanga. 115m².', 'apartamento', 'arriendo', 3800000.00, 115.00, 3, 2, 0, '', 'Bucaramanga', 'Zona Rosa', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=70'),
(41, 'Casa Amplia Sector Álamos', 'Casa en venta ubicado en Álamos, Bucaramanga. 220m².', 'casa', 'venta', 590000000.00, 220.00, 4, 3, 1, '', 'Bucaramanga', 'Álamos', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800&q=70'),
(42, 'Espacio Coworking Premium', 'Oficina en arriendo ubicado en Sotomayor, Bucaramanga. 180m².', 'oficina', 'arriendo', 5200000.00, 180.00, 0, 0, 0, '', 'Bucaramanga', 'Sotomayor', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800&q=70'),
(43, 'Apartamento Nuevo Entrega Inmediata', 'Apartamento en venta ubicado en Café Madrid, Bucaramanga. 85m².', 'apartamento', 'venta', 260000000.00, 85.00, 2, 2, 0, '', 'Bucaramanga', 'Café Madrid', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800&q=70'),
(44, 'Edificio Completo para Inversión', 'Edificio en venta ubicado en Cabecera, Bucaramanga. 8000m².', '', 'venta', 3300000000.00, 8000.00, 0, 0, 1, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=70'),
(45, 'Casa Bifamiliar Sector Manga', 'Casa en arriendo ubicado en La Manga, Bucaramanga. 145m².', 'casa', 'arriendo', 4100000.00, 145.00, 4, 2, 1, '', 'Bucaramanga', 'La Manga', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=800&q=70'),
(46, 'Casa Frente al Parque Estadio', 'Casa en venta ubicado en Estadio, Bucaramanga. 260m².', 'casa', 'venta', 660000000.00, 260.00, 5, 4, 1, '', 'Bucaramanga', 'Estadio', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600673132756-6d6a7b0b81ee?w=800&q=70'),
(47, 'Apartamento Para Estrenar — Sur BGA', 'Apartamento en venta ubicado en Sur, Bucaramanga. 70m².', 'apartamento', 'venta', 215000000.00, 70.00, 2, 1, 0, '', 'Bucaramanga', 'Sur', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=800&q=70'),
(48, 'Bodega Industrial Parque Tecnológico', 'Local en arriendo ubicado en Parque Tec., Piedecuesta. 500m².', 'local', 'arriendo', 8900000.00, 500.00, 0, 0, 0, '', 'Piedecuesta', 'Parque Tec.', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1581093196277-9f608bb3b511?w=800&q=70'),
(49, 'Residencia Ultra Lujo — Los Pinos', 'Casa en venta ubicado en Los Pinos, Floridablanca. 520m².', 'casa', 'venta', 1350000000.00, 520.00, 7, 6, 0, '', 'Floridablanca', 'Los Pinos', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800&q=70'),
(50, 'Apartamento Ejecutivo Amoblado', 'Apartamento en arriendo ubicado en Cabecera, Bucaramanga. 60m².', 'apartamento', 'arriendo', 2500000.00, 60.00, 1, 1, 0, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=70'),
(51, 'Hacienda Ganadera — San Gil', 'Finca en venta ubicado en San Gil, San Gil. 3500m².', '', 'venta', 1800000000.00, 3500.00, 0, 0, 0, '', 'San Gil', 'San Gil', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1464082354059-27db6ce50048?w=800&q=70'),
(52, 'Apartamento con Balcón Vista Ciudad', 'Apartamento en venta ubicado en Terrazas, Bucaramanga. 118m².', 'apartamento', 'venta', 375000000.00, 118.00, 3, 2, 0, '', 'Bucaramanga', 'Terrazas', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=70'),
(53, 'Local Gastronómico con Terraza', 'Local en arriendo ubicado en La Concordia, Bucaramanga. 230m².', 'local', 'arriendo', 6000000.00, 230.00, 0, 0, 0, '', 'Bucaramanga', 'La Concordia', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1555636222-cae831e670b3?w=800&q=70'),
(54, 'Casa Norte con Terraza y BBQ', 'Casa en venta ubicado en Norte, Bucaramanga. 155m².', 'casa', 'venta', 440000000.00, 155.00, 4, 3, 0, '', 'Bucaramanga', 'Norte', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=800&q=70'),
(55, 'Apto Conjunto Cerrado El Campestre', 'Apartamento en venta ubicado en El Campestre, Bucaramanga. 92m².', 'apartamento', 'venta', 310000000.00, 92.00, 2, 2, 0, '', 'Bucaramanga', 'El Campestre', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&q=70'),
(56, 'Lote con Nacedero de Agua', 'Terreno en venta ubicado en Vía Guane, Bucaramanga. 1500m².', 'terreno', 'venta', 420000000.00, 1500.00, 0, 0, 0, '', 'Bucaramanga', 'Vía Guane', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=70'),
(57, 'Casa de Lujo Amoblada Mensual', 'Casa en arriendo ubicado en Cabecera, Bucaramanga. 160m².', 'casa', 'arriendo', 4500000.00, 160.00, 4, 3, 0, '', 'Bucaramanga', 'Cabecera', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=70'),
(58, 'Casa Conjunto Premium Santa Barbara', 'Casa en venta ubicado en Santa Bárbara, Floridablanca. 210m².', 'casa', 'venta', 570000000.00, 210.00, 4, 3, 0, '', 'Floridablanca', 'Santa Bárbara', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1570010589765-3c68e430f7d5?w=800&q=70'),
(59, 'Apartamento Familiar Sector Toscana', 'Apartamento en arriendo ubicado en Toscana, Bucaramanga. 100m².', 'apartamento', 'arriendo', 3000000.00, 100.00, 3, 2, 0, '', 'Bucaramanga', 'Toscana', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=800&q=70'),
(60, 'Plaza Comercial — Inversión Estratégica', 'Edificio en venta ubicado en Vía Floridablanca, Floridablanca. 12000m².', '', 'venta', 4000000000.00, 12000.00, 0, 0, 1, '', 'Floridablanca', 'Vía Floridablanca', NULL, NULL, 'disponible', NULL, '2026-03-17 21:59:27', '2026-03-18 21:22:36', 1, 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=70'),
(61, 'casa en el bosque', 'casa de vaciones', 'casa', 'venta', 7000000.00, 1.00, 1, 1, 0, 'calle 23', 'reyroma', 'barrio13', NULL, NULL, 'disponible', NULL, '2026-03-17 22:48:12', '2026-03-17 22:48:12', 1, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `nombre`, `descripcion`) VALUES
(1, 'admin', 'Acceso total al sistema'),
(2, 'usuario', 'Solo visita la página'),
(3, 'cliente', 'Puede buscar y solicitar propiedades'),
(4, 'inmobiliaria', 'Gestiona propiedades y clientes');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitudes`
--

CREATE TABLE `solicitudes` (
  `id` int(11) NOT NULL,
  `propiedad_id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `tipo` enum('compra','arriendo') NOT NULL,
  `estado` enum('pendiente','en_revision','aprobada','rechazada') DEFAULT 'pendiente',
  `documentos` varchar(500) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitudes`
--

INSERT INTO `solicitudes` (`id`, `propiedad_id`, `cliente_id`, `tipo`, `estado`, `documentos`, `notas`, `fecha_solicitud`, `fecha_actualizacion`) VALUES
(1, 1, 4, '', 'pendiente', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54'),
(2, 8, 5, '', 'aprobada', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54'),
(3, 2, 6, '', 'pendiente', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54'),
(4, 5, 7, 'arriendo', 'aprobada', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54'),
(5, 3, 8, 'arriendo', 'rechazada', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54'),
(6, 7, 4, 'arriendo', 'pendiente', NULL, NULL, '2026-03-18 21:44:54', '2026-03-18 21:44:54');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sugerencias`
--

CREATE TABLE `sugerencias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `email` varchar(120) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sugerencias`
--

INSERT INTO `sugerencias` (`id`, `nombre`, `email`, `mensaje`, `fecha`) VALUES
(1, 'nicol', 'nikky@gmail.com', 'mas propiedades', '2026-03-18 18:07:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `rol_id` int(11) NOT NULL DEFAULT 3,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `apellido`, `email`, `password`, `telefono`, `direccion`, `foto_perfil`, `rol_id`, `activo`, `fecha_registro`) VALUES
(1, 'Admin', 'Sistema', 'admin@inmobiliaria.com', '$2a$10$N.zmdr9zkoa05OZQpPm2OuyNaUNXB1LGJe1BFCGKl/bxBGmVCZ9oe', NULL, NULL, NULL, 1, 1, '2026-03-11 22:44:03'),
(2, 'Aleja', 'colm', 'aleja@gmail.com', '12345678', '3299383933', NULL, NULL, 3, 1, '2026-03-16 03:36:00'),
(3, 'nicol', 'montoya', 'nimon@gmail.com', '12345678', '3748949478', NULL, NULL, 3, 1, '2026-03-16 04:10:57'),
(4, 'nikky', 'mon', 'nik@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', '3289765517', NULL, NULL, 4, 1, '2026-03-17 20:20:05'),
(5, 'margarita', 'perez', 'mar@gmail.com', '12345678', '3197464738', NULL, NULL, 3, 1, '2026-03-17 20:34:13'),
(6, 'Carlos', 'Mendoza Ruiz', 'carlos.mendoza@inmovista.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3001234567', NULL, NULL, 2, 1, '2026-03-18 21:41:57'),
(7, 'Valentina', 'Gómez Torres', 'valentina.gomez@inmovista.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3109876543', NULL, NULL, 2, 1, '2026-03-18 21:41:57'),
(8, 'Andrés', 'Ramírez Peña', 'andres.ramirez@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3152345678', NULL, NULL, 3, 1, '2026-03-18 21:41:57'),
(9, 'Laura', 'Castillo Vega', 'laura.castillo@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3203456789', NULL, NULL, 3, 1, '2026-03-18 21:41:57'),
(10, 'Miguel', 'Hernández Díaz', 'miguel.hernandez@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3014567890', NULL, NULL, 3, 1, '2026-03-18 21:41:57'),
(11, 'Sofía', 'López Moreno', 'sofia.lopez@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3185678901', NULL, NULL, 3, 1, '2026-03-18 21:41:57'),
(12, 'Juan', 'Vargas Salcedo', 'juan.vargas@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3006789012', NULL, NULL, 3, 1, '2026-03-18 21:41:57'),
(13, 'Diana', 'Rojas Pineda', 'diana.rojas@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3127890123', NULL, NULL, 4, 1, '2026-03-18 21:41:57'),
(14, 'Felipe', 'Torres Niño', 'felipe.torres@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3048901234', NULL, NULL, 4, 1, '2026-03-18 21:41:57'),
(15, 'Camila', 'Suárez Blanco', 'camila.suarez@gmail.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', '3169012345', NULL, NULL, 3, 0, '2026-03-18 21:41:57');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `citas`
--
ALTER TABLE `citas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `propiedad_id` (`propiedad_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `agente_id` (`agente_id`);

--
-- Indices de la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`);

--
-- Indices de la tabla `favoritos`
--
ALTER TABLE `favoritos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_fav` (`usuario_id`,`propiedad_id`),
  ADD KEY `propiedad_id` (`propiedad_id`);

--
-- Indices de la tabla `fotos_propiedades`
--
ALTER TABLE `fotos_propiedades`
  ADD PRIMARY KEY (`id`),
  ADD KEY `propiedad_id` (`propiedad_id`);

--
-- Indices de la tabla `propiedades`
--
ALTER TABLE `propiedades`
  ADD PRIMARY KEY (`id`),
  ADD KEY `propietario_id` (`propietario_id`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `propiedad_id` (`propiedad_id`),
  ADD KEY `cliente_id` (`cliente_id`);

--
-- Indices de la tabla `sugerencias`
--
ALTER TABLE `sugerencias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`),
  ADD KEY `rol_id` (`rol_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `citas`
--
ALTER TABLE `citas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `documentos`
--
ALTER TABLE `documentos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `favoritos`
--
ALTER TABLE `favoritos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `fotos_propiedades`
--
ALTER TABLE `fotos_propiedades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT de la tabla `propiedades`
--
ALTER TABLE `propiedades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `sugerencias`
--
ALTER TABLE `sugerencias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `citas`
--
ALTER TABLE `citas`
  ADD CONSTRAINT `citas_ibfk_1` FOREIGN KEY (`propiedad_id`) REFERENCES `propiedades` (`id`),
  ADD CONSTRAINT `citas_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `citas_ibfk_3` FOREIGN KEY (`agente_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD CONSTRAINT `documentos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `favoritos`
--
ALTER TABLE `favoritos`
  ADD CONSTRAINT `favoritos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `favoritos_ibfk_2` FOREIGN KEY (`propiedad_id`) REFERENCES `propiedades` (`id`);

--
-- Filtros para la tabla `fotos_propiedades`
--
ALTER TABLE `fotos_propiedades`
  ADD CONSTRAINT `fotos_propiedades_ibfk_1` FOREIGN KEY (`propiedad_id`) REFERENCES `propiedades` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `propiedades`
--
ALTER TABLE `propiedades`
  ADD CONSTRAINT `propiedades_ibfk_1` FOREIGN KEY (`propietario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  ADD CONSTRAINT `solicitudes_ibfk_1` FOREIGN KEY (`propiedad_id`) REFERENCES `propiedades` (`id`),
  ADD CONSTRAINT `solicitudes_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
