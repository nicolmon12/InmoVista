# InmoVista — Documentación Scrum Completa

**Proyecto:** InmoVista — Sistema de Administración Inmobiliaria  
**Asignatura:** Programación Java  
**Docente:** Julian Barney Jaimes Rincón  
**Fecha inicio:** 27-02-2026  
**Tecnologías:** Java EE, JSP, JDBC, MySQL, Bootstrap 5, Apache Tomcat

---

## Roles Scrum

| Rol | Responsabilidad |
|-----|----------------|
| **Product Owner** | Define y prioriza el Product Backlog, valida que cada historia cumpla el DoD |
| **Scrum Master** | Facilita las ceremonias, elimina impedimentos, asegura el proceso Scrum |
| **Development Team** | Diseña, implementa y prueba las funcionalidades del sprint |

---

## Product Backlog Inicial (Priorizado)

| ID | Historia de Usuario | Prioridad | Puntos | Estado |
|----|---------------------|-----------|--------|--------|
| US-01 | Como visitante, quiero una landing page atractiva con búsqueda rápida de propiedades | Alta | 8 | ✅ Done |
| US-02 | Como usuario, quiero registrarme y loguearme para acceder a funcionalidades personalizadas | Alta | 5 | ✅ Done |
| US-03 | Como cliente, quiero buscar y filtrar propiedades por ubicación, precio y tipo | Alta | 8 | ✅ Done |
| US-04 | Como empleado de inmobiliaria, quiero agregar y editar propiedades con fotos y descripción | Alta | 8 | ✅ Done |
| US-05 | Como administrador, quiero gestionar usuarios (agregar, editar, eliminar, activar) | Media | 5 | ✅ Done |
| US-06 | Como cualquier usuario autenticado, quiero un dashboard personalizado por rol | Media | 5 | ✅ Done |
| US-07 | Como inmobiliario, quiero listar mis propiedades y ver solicitudes de clientes | Media | 5 | ✅ Done |
| US-08 | Como cliente, quiero solicitar citas para visitar propiedades | Baja | 3 | ✅ Done |
| US-09 | Como cliente, quiero entregar documentos de compra o arriendo digitalmente | Baja | 3 | ✅ Done |
| US-10 | Como visitante, quiero un asistente virtual (bot) que resuelva mis preguntas | Baja | 3 | ✅ Done |
| US-11 | Como usuario, quiero enviar sugerencias o preguntas por correo desde el bot | Baja | 2 | ✅ Done |
| US-12 | Como administrador, quiero ver reportes de propiedades, citas y solicitudes | Media | 5 | ✅ Done |

---

## Sprint 1 — Fundamentos y Autenticación

**Duración:** 7 días (Semana 1)  
**Objetivo del Sprint:** Tener la base del sistema funcional: landing page, autenticación y estructura de roles.

### Sprint Planning

**¿Qué vamos a hacer?**  
Construir la infraestructura base: base de datos, autenticación, landing page y estructura de navegación.

**Historias seleccionadas:**

| US | Historia | Criterios de Aceptación (DoD) |
|----|----------|-------------------------------|
| US-01 | Landing page atractiva | La página carga en menos de 3s, muestra propiedades destacadas, tiene buscador funcional y es responsiva en móvil |
| US-02 | Registro y login | El usuario puede crear cuenta con email único, iniciar sesión con credenciales válidas, y la sesión persiste correctamente |
| US-06 | Dashboard por rol | Cada rol (admin, inmobiliaria, cliente, usuario) ve un dashboard diferente al iniciar sesión |

**Tareas técnicas:**
- Diseño e implementación del esquema de base de datos (tablas: usuarios, roles, propiedades, fotos_propiedades)
- Configuración de Apache Tomcat y conexión JDBC
- Implementación de `header.jsp`, `footer.jsp`, `sidebar.jsp` como componentes reutilizables
- Desarrollo de `index.jsp` con hero section, categorías y propiedades destacadas
- Desarrollo de `login.jsp` y `registro.jsp` con validaciones
- Implementación de control de sesiones y redirección por rol
- Desarrollo de `admin.jsp`, `inmobiliaria.jsp`, `cliente.jsp`, `usuario.jsp` básicos

### Sprint Review

**¿Qué se completó?**
- ✅ Landing page con diseño cinematográfico premium (hero animado, partículas, ticker, categorías)
- ✅ Sistema de autenticación completo con manejo de sesiones
- ✅ Redirección automática según rol al iniciar sesión
- ✅ Dashboards básicos para los 4 roles
- ✅ Base de datos creada con tablas principales
- ✅ Header y footer responsivos con navbar adaptable por sesión

**Demostración:** Se mostró el flujo completo de registro → login → dashboard diferenciado por rol.

**Feedback:** El diseño visual superó las expectativas. Se acordó mantener la paleta dorado/negro para toda la aplicación.

### Sprint Retrospective

**¿Qué salió bien?**
- La estructura de componentes JSP reutilizables ahorró tiempo
- El diseño con Bootstrap 5 + CSS personalizado resultó cohesivo desde el inicio

**¿Qué mejorar?**
- La conexión JDBC debería centralizarse en una clase utilitaria en lugar de repetirse en cada JSP
- Los estilos deberían estar en `estilos.css` desde el principio para evitar duplicaciones

**Acciones para el siguiente sprint:**
- Centralizar lógica de conexión DB
- Documentar el esquema de BD actualizado

---

## Sprint 2 — Gestión de Propiedades y Roles

**Duración:** 7 días (Semana 2)  
**Objetivo del Sprint:** Implementar el CRUD completo de propiedades y los dashboards funcionales por rol.

### Sprint Planning

**¿Qué vamos a hacer?**  
Construir la gestión completa de propiedades y las funcionalidades específicas de cada rol.

**Historias seleccionadas:**

| US | Historia | Criterios de Aceptación (DoD) |
|----|----------|-------------------------------|
| US-03 | Búsqueda y filtro de propiedades | El usuario puede filtrar por tipo, operación, ciudad y precio; los resultados se actualizan correctamente |
| US-04 | CRUD de propiedades | La inmobiliaria puede crear, editar y eliminar propiedades con foto principal; los cambios se reflejan en lista y detalle |
| US-05 | Gestión de usuarios | El admin puede activar/desactivar usuarios, cambiar roles y eliminar cuentas inactivas |
| US-07 | Vista inmobiliaria | La inmobiliaria ve sus propiedades listadas y puede gestionar solicitudes de clientes |

**Tareas técnicas:**
- Desarrollo de `lista.jsp` con filtros dinámicos
- Desarrollo de `formulario.jsp` para crear/editar propiedades
- Desarrollo de `detalle.jsp` con información completa de la propiedad
- Desarrollo de `usuarios.jsp` para gestión de admin
- Implementación de `inmobiliaria.jsp` con tabs: propiedades, citas, solicitudes
- Tabla `fotos_propiedades` para múltiples imágenes por propiedad
- Implementación de `pendiente-aprobacion.jsp` para usuarios recién registrados

### Sprint Review

**¿Qué se completó?**
- ✅ Listado de propiedades con filtros por tipo, operación, ciudad y precio
- ✅ Formulario de creación y edición de propiedades con validaciones
- ✅ Detalle de propiedad con galería de fotos y formulario de cita
- ✅ Panel de administración con gestión completa de usuarios
- ✅ Panel de inmobiliaria con propiedades propias, citas pendientes y solicitudes
- ✅ Página de espera para cuentas pendientes de aprobación

**Demostración:** Se mostró el flujo inmobiliaria: crear propiedad → cliente la ve en lista → cliente solicita cita → inmobiliaria confirma.

**Feedback:** El sistema de tabs en los dashboards facilita la navegación. Se aprobó el diseño de cards para propiedades.

### Sprint Retrospective

**¿Qué salió bien?**
- Los componentes del Sprint 1 se reutilizaron perfectamente
- El sistema de tabs en dashboards resultó intuitivo

**¿Qué mejorar?**
- Las consultas SQL en JSP deberían migrarse a servlets o DAOs para mejor separación de responsabilidades
- Las validaciones del formulario deben hacerse tanto en cliente como en servidor

**Acciones para el siguiente sprint:**
- Agregar validaciones JavaScript en formularios
- Implementar manejo de errores más robusto

---

## Sprint 3 — Funcionalidades Avanzadas e Integración

**Duración:** 7 días (Semana 3)  
**Objetivo del Sprint:** Agregar funcionalidades avanzadas: citas completas, bot, email, reportes y subida de documentos.

### Sprint Planning

**¿Qué vamos a hacer?**  
Completar el sistema con funcionalidades diferenciadas: bot inteligente, integración Gmail, reportes y gestión documental.

**Historias seleccionadas:**

| US | Historia | Criterios de Aceptación (DoD) |
|----|----------|-------------------------------|
| US-08 | Solicitar citas | El cliente puede agendar cita desde detalle de propiedad; la cita aparece en su dashboard y en el de la inmobiliaria |
| US-09 | Subida de documentos | El cliente puede subir archivos (PDF, imagen) como papeles de compra/arriendo; la inmobiliaria los puede ver |
| US-10 | Asistente virtual | El bot responde preguntas sobre propiedades, zonas, precios, proceso de compra y requisitos de arriendo |
| US-11 | Sugerencias por email | El usuario puede enviar sugerencias desde el bot; llegan al correo de la inmobiliaria con formato profesional |
| US-12 | Reportes | El admin y la inmobiliaria ven KPIs: propiedades disponibles, citas pendientes, solicitudes activas |

**Tareas técnicas:**
- Completar flujo de citas en `cliente.jsp` y `inmobiliaria.jsp`
- Desarrollar `documentos.jsp` para subida de papeles
- Crear `SubirDocumentoServlet.java` para manejo de archivos
- Desarrollar `bot.js` con 15+ categorías de respuesta y respuestas rotativas
- Crear `ContactoServlet.java` para envío de emails via Gmail SMTP
- Desarrollar `reportes.jsp` con KPIs y gráficas
- Implementar `superadmin.jsp` para acceso de emergencia
- Integrar `chatbot.jsp` en el sistema

### Sprint Review

**¿Qué se completó?**
- ✅ Flujo completo de citas: solicitud → confirmación/cancelación → historial
- ✅ Sistema de subida de documentos para clientes
- ✅ Bot InmoBot con 15+ categorías y respuestas variadas por rotación
- ✅ Flujo de sugerencias en el bot: nombre → email → mensaje → confirmación → envío Gmail
- ✅ Reportes con KPIs en tiempo real desde BD
- ✅ Panel superadmin para administración de emergencia

**Demostración:** Se mostró el flujo completo: usuario llega al índice → usa el bot → envía sugerencia → llega email al administrador.

**Feedback:** El bot con respuestas variadas hace la experiencia más natural. Los reportes con KPIs visuales dan valor real al sistema.

### Sprint Retrospective

**¿Qué salió bien?**
- La integración del bot fue más simple de lo esperado gracias a la arquitectura modular de `bot.js`
- El flujo de sugerencias por email añade valor diferencial al proyecto

**¿Qué mejorar?**
- La lógica de negocio debería estar completamente en servlets, no en JSPs
- Implementar paginación en listas con muchos registros
- Agregar más pruebas de validación de formularios

**Logros del proyecto completo:**
- Sistema funcional con 4 roles diferenciados
- 15+ páginas JSP implementadas
- Bot inteligente con integración Gmail
- Base de datos normalizada con 7 tablas
- Diseño responsivo y accesible

---

## Definición de Done (DoD) General

Una historia de usuario se considera **Done** cuando:
1. ✅ La funcionalidad está implementada y es accesible desde el navegador
2. ✅ Los datos se persisten correctamente en la base de datos
3. ✅ El diseño es responsivo (probado en móvil y escritorio)
4. ✅ Los errores se manejan con mensajes claros al usuario
5. ✅ El control de acceso por rol está implementado (no se puede acceder sin el rol correcto)
6. ✅ La funcionalidad fue probada manualmente con casos válidos e inválidos
