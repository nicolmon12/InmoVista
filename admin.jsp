<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════
   ADMIN.JSP · InmoVista
   Dashboard completo del Administrador.
   Protección de sesión + carga de datos desde BD.
═══════════════════════════════════════════════════ */

// ── Protección de sesión ──────────────────────────
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolActual = (String) session.getAttribute("rolNombre");
if (!"admin".equals(rolActual)) {
    response.sendRedirect(request.getContextPath() + "/" + rolActual + ".jsp");
    return;
}

// ── Conexión BD ───────────────────────────────────
java.sql.Connection db = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");
} catch (Exception e) { db = null; }

// ── Variables de datos ────────────────────────────
int totalUsuarios = 0, totalPropiedades = 0, totalCitas = 0, totalSolicitudes = 0;
java.util.List<java.util.Map<String,Object>> todasCitas         = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> todasSolicitudes   = new java.util.ArrayList<>();
int totalAdmins = 0, totalInmobiliarias = 0, totalClientes = 0, totalUsuariosBasicos = 0;
java.util.List<java.util.Map<String,Object>> ultimosUsuarios   = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> ultimasPropiedades = new java.util.ArrayList<>();

// ── HANDLE POST: acciones del admin ──────────────
String flashMsg = null, flashErr = null;
String tab = request.getParameter("tab");
if (tab == null || tab.isEmpty()) tab = "dashboard";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    if (action == null) action = "";

    if ("aprobarCuenta".equals(action) && db != null) {
        try {
            java.sql.PreparedStatement ps = db.prepareStatement("UPDATE usuarios SET activo=1 WHERE id=?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate(); ps.close();
            flashMsg = "✓ Cuenta aprobada. El usuario ya puede iniciar sesión.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    } else if ("rechazarCuenta".equals(action) && db != null) {
        try {
            java.sql.PreparedStatement ps = db.prepareStatement("DELETE FROM usuarios WHERE id=? AND activo=0");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate(); ps.close();
            flashMsg = "Solicitud rechazada y eliminada.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    } else if ("eliminarUsuario".equals(action) && db != null) {
        try {
            String uid = request.getParameter("id");
            java.sql.PreparedStatement ps = db.prepareStatement("DELETE FROM usuarios WHERE id=?");
            ps.setInt(1, Integer.parseInt(uid));
            ps.executeUpdate(); ps.close();
            flashMsg = "Usuario eliminado correctamente.";
        } catch (Exception ex) { flashErr = "Error al eliminar: " + ex.getMessage(); }
    } else if ("toggleActivo".equals(action) && db != null) {
        try {
            String uid = request.getParameter("id");
            java.sql.PreparedStatement ps = db.prepareStatement(
                "UPDATE usuarios SET activo = 1 - activo WHERE id=?");
            ps.setInt(1, Integer.parseInt(uid));
            ps.executeUpdate(); ps.close();
            flashMsg = "Estado del usuario actualizado.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    } else if ("cambiarRol".equals(action) && db != null) {
        try {
            String uid   = request.getParameter("id");
            String rolId = request.getParameter("rolId");
            java.sql.PreparedStatement ps = db.prepareStatement(
                "UPDATE usuarios SET rol_id=? WHERE id=?");
            ps.setInt(1, Integer.parseInt(rolId));
            ps.setInt(2, Integer.parseInt(uid));
            ps.executeUpdate(); ps.close();
            flashMsg = "Rol actualizado correctamente.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    }

    if (db != null) { try { db.close(); } catch(Exception e){} }
    String redir = request.getContextPath() + "/admin.jsp?tab=" + tab;
    if (flashMsg != null) redir += "&msg=" + java.net.URLEncoder.encode(flashMsg,"UTF-8");
    if (flashErr != null) redir += "&err=" + java.net.URLEncoder.encode(flashErr,"UTF-8");
    response.sendRedirect(redir);
    return;
}

// ── GET: cargar stats desde BD ────────────────────
if (db != null) {
    try {
        // Conteos globales
        java.sql.ResultSet rs;
        rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios WHERE activo=1");
        if (rs.next()) totalUsuarios = rs.getInt(1); rs.close();

        rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM propiedades");
        if (rs.next()) totalPropiedades = rs.getInt(1); rs.close();

        rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM citas WHERE estado='pendiente'");
        if (rs.next()) totalCitas = rs.getInt(1); rs.close();

        rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM solicitudes WHERE estado='pendiente'");
        if (rs.next()) totalSolicitudes = rs.getInt(1); rs.close();

        // Distribución de roles
        rs = db.createStatement().executeQuery(
            "SELECT r.nombre, COUNT(u.id) as cnt FROM roles r LEFT JOIN usuarios u ON r.id=u.rol_id AND u.activo=1 GROUP BY r.id, r.nombre");
        while (rs.next()) {
            String rn = rs.getString("nombre"); int cnt = rs.getInt("cnt");
            if ("admin".equals(rn))          totalAdmins = cnt;
            else if ("inmobiliaria".equals(rn)) totalInmobiliarias = cnt;
            else if ("cliente".equals(rn))    totalClientes = cnt;
            else if ("usuario".equals(rn))    totalUsuariosBasicos = cnt;
        } rs.close();

        // Usuarios pendientes de aprobacion (activo=0)
        java.sql.PreparedStatement psPend = db.prepareStatement(
            "SELECT u.id, u.nombre, u.apellido, u.email, u.telefono, r.nombre AS rol, u.fecha_registro " +
            "FROM usuarios u JOIN roles r ON u.rol_id=r.id " +
            "WHERE u.activo=0 ORDER BY u.fecha_registro DESC");
        java.sql.ResultSet rsPend = psPend.executeQuery();
        java.util.List<java.util.Map<String,Object>> pendientes = new java.util.ArrayList<>();
        while (rsPend.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",       rsPend.getInt("id"));
            m.put("nombre",   rsPend.getString("nombre"));
            m.put("apellido", rsPend.getString("apellido"));
            m.put("email",    rsPend.getString("email"));
            m.put("telefono", rsPend.getString("telefono") != null ? rsPend.getString("telefono") : "");
            m.put("rol",      rsPend.getString("rol"));
            m.put("fecha",    rsPend.getString("fecha_registro") != null ? rsPend.getString("fecha_registro") : "");
            pendientes.add(m);
        } rsPend.close(); psPend.close();
        request.setAttribute("pendientes", pendientes);

        // Últimos usuarios
        java.sql.PreparedStatement ps = db.prepareStatement(
            "SELECT u.id, u.nombre, u.apellido, u.email, u.activo, r.nombre AS rol " +
            "FROM usuarios u JOIN roles r ON u.rol_id=r.id " +
            "ORDER BY u.fecha_registro DESC LIMIT 8");
        rs = ps.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",       rs.getInt("id"));
            m.put("nombre",   rs.getString("nombre"));
            m.put("apellido", rs.getString("apellido"));
            m.put("email",    rs.getString("email"));
            m.put("activo",   rs.getInt("activo") == 1);
            m.put("rol",      rs.getString("rol"));
            ultimosUsuarios.add(m);
        } rs.close(); ps.close();

        // Todas las citas
        java.sql.PreparedStatement psCitas = db.prepareStatement(
            "SELECT c.id, c.fecha_cita, c.notas, c.estado, " +
            "p.titulo AS prop_titulo, " +
            "u.nombre AS cli_nombre, u.apellido AS cli_apellido, u.email AS cli_email " +
            "FROM citas c " +
            "JOIN propiedades p ON c.propiedad_id=p.id " +
            "JOIN usuarios u ON c.cliente_id=u.id " +
            "ORDER BY c.fecha_cita DESC");
        java.sql.ResultSet rsCitas = psCitas.executeQuery();
        while (rsCitas.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",           rsCitas.getInt("id"));
            m.put("fechaCita",    rsCitas.getString("fecha_cita") != null ? rsCitas.getString("fecha_cita") : "");
            m.put("notas",        rsCitas.getString("notas") != null ? rsCitas.getString("notas") : "");
            m.put("estado",       rsCitas.getString("estado") != null ? rsCitas.getString("estado") : "pendiente");
            m.put("propTitulo",   rsCitas.getString("prop_titulo") != null ? rsCitas.getString("prop_titulo") : "—");
            m.put("clienteNombre",rsCitas.getString("cli_nombre") + " " + rsCitas.getString("cli_apellido"));
            m.put("clienteEmail", rsCitas.getString("cli_email") != null ? rsCitas.getString("cli_email") : "");
            todasCitas.add(m);
        } rsCitas.close(); psCitas.close();

        // Todas las solicitudes
        java.sql.PreparedStatement psSols = db.prepareStatement(
            "SELECT s.id, s.tipo, s.estado, s.fecha_solicitud, " +
            "p.titulo AS prop_titulo, " +
            "u.nombre AS cli_nombre, u.apellido AS cli_apellido " +
            "FROM solicitudes s " +
            "JOIN propiedades p ON s.propiedad_id=p.id " +
            "JOIN usuarios u ON s.cliente_id=u.id " +
            "ORDER BY s.fecha_solicitud DESC");
        java.sql.ResultSet rsSols = psSols.executeQuery();
        while (rsSols.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",           rsSols.getInt("id"));
            m.put("tipo",         rsSols.getString("tipo") != null ? rsSols.getString("tipo") : "venta");
            m.put("estado",       rsSols.getString("estado") != null ? rsSols.getString("estado") : "pendiente");
            m.put("fecha",        rsSols.getString("fecha_solicitud") != null ? rsSols.getString("fecha_solicitud") : "");
            m.put("propTitulo",   rsSols.getString("prop_titulo") != null ? rsSols.getString("prop_titulo") : "—");
            m.put("clienteNombre",rsSols.getString("cli_nombre") + " " + rsSols.getString("cli_apellido"));
            todasSolicitudes.add(m);
        } rsSols.close(); psSols.close();

        // Últimas propiedades
        java.sql.PreparedStatement ps2 = db.prepareStatement(
            "SELECT id, titulo, tipo, operacion, ciudad, precio, estado FROM propiedades ORDER BY id DESC LIMIT 6");
        rs = ps2.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",        rs.getInt("id"));
            m.put("titulo",    rs.getString("titulo"));
            m.put("tipo",      rs.getString("tipo"));
            m.put("operacion", rs.getString("operacion"));
            m.put("ciudad",    rs.getString("ciudad"));
            m.put("precio",    rs.getDouble("precio"));
            m.put("estado",    rs.getString("estado"));
            ultimasPropiedades.add(m);
        } rs.close(); ps2.close();

        db.close();
    } catch (Exception ex) {
        if (db != null) { try { db.close(); } catch(Exception e){} }
    }
}

// ── Demo fallback si BD no disponible ─────────────
if (ultimosUsuarios.isEmpty()) {
    String[][] demo = {
        {"1","Admin","Sistema","admin@inmovista.com","true","admin"},
        {"2","Agente","InmoVista","inmobiliaria@test.com","true","inmobiliaria"},
        {"3","Juan","Torres","cliente@test.com","true","cliente"},
        {"4","Maria","García","usuario@test.com","true","usuario"}
    };
    for (String[] d : demo) {
        java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
        m.put("id", d[0]); m.put("nombre", d[1]); m.put("apellido", d[2]);
        m.put("email", d[3]); m.put("activo", "true".equals(d[4])); m.put("rol", d[5]);
        ultimosUsuarios.add(m);
    }
    totalUsuarios = 4; totalAdmins = 1; totalInmobiliarias = 1;
    totalClientes = 1; totalUsuariosBasicos = 1; totalPropiedades = 12;
}

request.setAttribute("ultimosUsuarios",    ultimosUsuarios);
request.setAttribute("todasCitas",         todasCitas);
request.setAttribute("todasSolicitudes",   todasSolicitudes);
request.setAttribute("ultimasPropiedades", ultimasPropiedades);
request.setAttribute("totalUsuarios",      totalUsuarios);
request.setAttribute("totalPropiedades",   totalPropiedades);
request.setAttribute("totalCitas",         totalCitas);
request.setAttribute("totalSolicitudes",   totalSolicitudes);
request.setAttribute("totalAdmins",        totalAdmins);
request.setAttribute("totalInmobiliarias", totalInmobiliarias);
request.setAttribute("totalClientes",      totalClientes);
request.setAttribute("totalUsuariosBasicos", totalUsuariosBasicos);
%>
<c:set var="pageTitle" value="Panel Admin — InmoVista" scope="request"/>
<%@ include file="header.jsp" %>

<style>
:root{--cg:#c9a84c;--cd:#0d0d0d;--cb:#e8e5df;--cs:#f8f7f5;--cm:#9a9590;}
.ad-layout{display:grid;grid-template-columns:240px 1fr;min-height:calc(100vh - 72px);background:var(--cs);}
@media(max-width:900px){.ad-layout{grid-template-columns:1fr;}}
.ad-sidebar{background:var(--cd);padding:20px 0;position:sticky;top:72px;height:calc(100vh - 72px);overflow-y:auto;display:flex;flex-direction:column;}
@media(max-width:900px){.ad-sidebar{display:none;}}
.ad-sb-user{padding:0 16px 20px;border-bottom:1px solid rgba(255,255,255,0.07);margin-bottom:10px;}
.ad-av{width:48px;height:48px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.2rem;font-weight:900;color:#fff;margin-bottom:8px;}
.ad-name{font-weight:700;color:#fff;font-size:0.9rem;}
.ad-role{font-size:0.62rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#3498db;}
.ad-sec{font-size:0.58rem;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,0.2);padding:10px 16px 4px;}
.ad-lnk{display:flex;align-items:center;gap:10px;padding:10px 16px;font-size:0.84rem;font-weight:500;color:rgba(255,255,255,0.4);text-decoration:none;border-left:3px solid transparent;transition:all .2s;cursor:pointer;background:none;border-top:none;border-right:none;border-bottom:none;width:100%;text-align:left;font-family:inherit;}
.ad-lnk:hover,.ad-lnk.active{color:#fff;background:rgba(255,255,255,0.04);}
.ad-lnk.active{color:#3498db;background:rgba(52,152,219,0.08);border-left-color:#3498db;}
.ad-lnk i{width:16px;text-align:center;font-size:0.82rem;}
.ad-bot{margin-top:auto;padding:14px 0;border-top:1px solid rgba(255,255,255,0.07);}
.ad-main{padding:28px;}
@media(max-width:768px){.ad-main{padding:16px;}}
.ad-pane{display:none;} .ad-pane.active{display:block;}
.ad-title{font-family:'Playfair Display',serif;font-size:1.7rem;font-weight:900;color:var(--cd);}
.ad-sub{font-size:0.82rem;color:var(--cm);margin-top:2px;}
.kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
@media(max-width:900px){.kpis{grid-template-columns:repeat(2,1fr);}}
.kpi{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:18px;display:flex;align-items:center;gap:14px;box-shadow:0 2px 8px rgba(0,0,0,0.04);}
.kpi-ic{width:44px;height:44px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.kpi-n{font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;color:var(--cd);line-height:1;}
.kpi-l{font-size:0.72rem;color:var(--cm);margin-top:1px;}
.card{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:22px;box-shadow:0 2px 8px rgba(0,0,0,0.04);margin-bottom:20px;}
.ct{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;}
.ct-t{display:flex;align-items:center;gap:9px;font-family:'Playfair Display',serif;font-size:1.05rem;font-weight:700;color:var(--cd);}
.ct-t i{color:var(--cg);}
.tbl{width:100%;border-collapse:collapse;}
.tbl th{text-align:left;font-size:0.7rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:var(--cm);padding:8px 10px;border-bottom:2px solid var(--cb);}
.tbl td{padding:11px 10px;border-bottom:1px solid var(--cb);font-size:0.84rem;vertical-align:middle;}
.tbl tr:last-child td{border-bottom:none;}
.tbl tr:hover td{background:var(--cs);}
.btn-g{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;background:linear-gradient(135deg,#c9a84c,#e8c96b);color:#000;font-weight:700;font-size:0.78rem;border:none;border-radius:8px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-g:hover{transform:translateY(-1px);box-shadow:0 6px 16px rgba(201,168,76,0.3);color:#000;}
.btn-o{display:inline-flex;align-items:center;gap:6px;padding:6px 12px;background:transparent;color:var(--cd);font-weight:600;font-size:0.76rem;border:1.5px solid var(--cb);border-radius:8px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-o:hover{border-color:var(--cg);color:var(--cg);}
.btn-d{display:inline-flex;align-items:center;gap:5px;padding:5px 10px;background:transparent;color:#e74c3c;font-size:0.74rem;border:1.5px solid rgba(231,76,60,0.3);border-radius:7px;cursor:pointer;transition:all .2s;}
.btn-b{display:inline-flex;align-items:center;gap:5px;padding:5px 10px;background:transparent;color:#3498db;font-size:0.74rem;border:1.5px solid rgba(52,152,219,0.3);border-radius:7px;cursor:pointer;text-decoration:none;transition:all .2s;}
.st{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;border-radius:100px;font-size:0.7rem;font-weight:700;}
.st-admin{background:rgba(52,152,219,0.12);color:#1a6c9f;}
.st-inmobiliaria{background:rgba(155,89,182,0.12);color:#6c3483;}
.st-cliente{background:rgba(39,174,96,0.12);color:#0f5132;}
.st-usuario{background:rgba(149,165,166,0.15);color:#555;}
.st-activo{background:#d1e7dd;color:#0f5132;}
.st-inactivo{background:#f8d7da;color:#842029;}
.st-disponible{background:#d1e7dd;color:#0f5132;}
.st-vendido{background:rgba(201,168,76,0.12);color:#7a5d0f;}
.st-arrendado{background:rgba(41,182,246,0.12);color:#055a7a;}
.st-pendiente{background:#fff3cd;color:#856404;}
.bar-wrap{height:6px;background:var(--cb);border-radius:4px;overflow:hidden;margin-top:5px;}
.bar{height:100%;border-radius:4px;transition:width .8s ease;}
.flash-ok{background:#d1e7dd;color:#0f5132;border:1px solid #a3cfbb;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;}
.flash-er{background:#f8d7da;color:#842029;border:1px solid #f1aeb5;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;}
.empty{text-align:center;padding:40px 20px;color:var(--cm);}
.empty i{font-size:2rem;color:var(--cb);display:block;margin-bottom:12px;}
.mnav{display:none;background:var(--cd);padding:10px 14px;gap:6px;overflow-x:auto;border-bottom:1px solid rgba(255,255,255,.07);}
@media(max-width:900px){.mnav{display:flex;}}
.mb{display:flex;align-items:center;gap:5px;padding:7px 12px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.08);border-radius:100px;color:rgba(255,255,255,.4);font-size:0.72rem;font-weight:600;white-space:nowrap;cursor:pointer;text-decoration:none;transition:all .2s;}
.mb.active,.mb:hover{background:rgba(52,152,219,.12);border-color:rgba(52,152,219,.3);color:#3498db;}
</style>

<div class="ad-layout">
<%-- ── SIDEBAR ── --%>
<aside class="ad-sidebar">
  <div class="ad-sb-user">
    <div class="ad-av">${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}</div>
    <div class="ad-name">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</div>
    <div class="ad-role"><i class="fas fa-shield-alt me-1"></i> Administrador</div>
  </div>
  <div class="ad-sec">Principal</div>
  <button class="ad-lnk" onclick="gt('dashboard')" id="sl-dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</button>
  <div class="ad-sec">Gestión</div>
  <button class="ad-lnk" onclick="gt('aprobaciones')" id="sl-aprobaciones"><i class="fas fa-user-check"></i> Aprobaciones <c:if test="${not empty pendientes}"><span style="background:#e74c3c;color:#fff;font-size:0.6rem;padding:1px 6px;border-radius:100px;margin-left:4px;">${fn:length(pendientes)}</span></c:if></button>
  <button class="ad-lnk" onclick="gt('usuarios')" id="sl-usuarios"><i class="fas fa-users"></i> Usuarios</button>
  <a class="ad-lnk" href="${pageContext.request.contextPath}/lista.jsp"><i class="fas fa-home"></i> Propiedades</a>
  <button class="ad-lnk" onclick="gt('solicitudes')" id="sl-solicitudes"><i class="fas fa-file-signature"></i> Solicitudes</button>
  <button class="ad-lnk" onclick="gt('citas')" id="sl-citas"><i class="fas fa-calendar-check"></i> Citas</button>
  <div class="ad-sec">Sistema</div>
  <a class="ad-lnk" href="${pageContext.request.contextPath}/reportes.jsp"><i class="fas fa-chart-bar"></i> Reportes</a>
  <button class="ad-lnk" onclick="gt('config')" id="sl-config"><i class="fas fa-cog"></i> Configuración</button>
  <div class="ad-bot">
    <a href="${pageContext.request.contextPath}/logout.jsp" class="ad-lnk" style="color:rgba(231,76,60,0.7);"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
  </div>
</aside>

<div>
  <%-- Mobile nav --%>
  <div class="mnav">
    <button class="mb active" id="mb-dashboard" onclick="gt('dashboard')"><i class="fas fa-th-large"></i> Panel</button>
    <button class="mb" id="mb-aprobaciones" onclick="gt('aprobaciones')"><i class="fas fa-user-check"></i> Aprob.</button>
    <button class="mb" id="mb-usuarios"    onclick="gt('usuarios')"><i class="fas fa-users"></i> Usuarios</button>
    <button class="mb" id="mb-solicitudes" onclick="gt('solicitudes')"><i class="fas fa-file-alt"></i> Solicitudes</button>
    <button class="mb" id="mb-citas"       onclick="gt('citas')"><i class="fas fa-calendar"></i> Citas</button>
    <button class="mb" id="mb-config"      onclick="gt('config')"><i class="fas fa-cog"></i> Config</button>
  </div>

  <main class="ad-main">
    <%-- Flash --%>
    <c:if test="${not empty param.msg}"><div class="flash-ok"><i class="fas fa-check-circle"></i> ${param.msg}</div></c:if>
    <c:if test="${not empty param.err}"><div class="flash-er"><i class="fas fa-exclamation-circle"></i> ${param.err}</div></c:if>

    <%-- ══ DASHBOARD ══ --%>
    <div class="ad-pane" id="pane-dashboard">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="ad-title">Panel de Administración</div><div class="ad-sub">Resumen general del sistema InmoVista</div></div>
        <a href="${pageContext.request.contextPath}/reportes.jsp" class="btn-g"><i class="fas fa-chart-bar"></i> Ver Reportes</a>
      </div>
      <c:if test="${not empty pendientes}">
        <div style="background:linear-gradient(135deg,rgba(201,168,76,0.12),rgba(201,168,76,0.2));border:1px solid rgba(201,168,76,0.3);border-radius:12px;padding:14px 20px;margin-bottom:20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;">
          <div style="display:flex;align-items:center;gap:12px;">
            <div style="width:36px;height:36px;background:#c9a84c;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#000;font-weight:700;">${fn:length(pendientes)}</div>
            <div><strong style="font-size:0.9rem;">Solicitudes pendientes de aprobación</strong><div style="font-size:0.78rem;color:var(--cm);">Nuevas cuentas de agentes esperan tu revisión</div></div>
          </div>
          <button onclick="gt('aprobaciones')" class="btn-g" style="padding:8px 16px;font-size:0.82rem;"><i class="fas fa-user-check me-1"></i> Revisar ahora</button>
        </div>
      </c:if>
      <div class="kpis">
        <div class="kpi"><div class="kpi-ic" style="background:rgba(52,152,219,0.12);color:#3498db;"><i class="fas fa-users"></i></div><div><div class="kpi-n">${totalUsuarios}</div><div class="kpi-l">Usuarios Activos</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(39,174,96,0.12);color:#27ae60;"><i class="fas fa-home"></i></div><div><div class="kpi-n">${totalPropiedades}</div><div class="kpi-l">Propiedades</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(201,168,76,0.12);color:var(--cg);"><i class="fas fa-calendar-check"></i></div><div><div class="kpi-n">${totalCitas}</div><div class="kpi-l">Citas Pendientes</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(231,76,60,0.12);color:#e74c3c;"><i class="fas fa-file-signature"></i></div><div><div class="kpi-n">${totalSolicitudes}</div><div class="kpi-l">Solicitudes</div></div></div>
      </div>
      <div class="row g-4">
        <div class="col-lg-8">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-users"></i> Últimos Usuarios</div><button class="btn-o" onclick="gt('usuarios')">Ver todos <i class="fas fa-arrow-right ms-1"></i></button></div>
            <div class="table-responsive">
              <table class="tbl"><thead><tr><th>Usuario</th><th>Email</th><th>Rol</th><th>Estado</th><th></th></tr></thead><tbody>
              <c:forEach var="u" items="${ultimosUsuarios}" begin="0" end="5">
                <tr>
                  <td><strong>${u.nombre} ${u.apellido}</strong></td>
                  <td style="font-size:0.8rem;color:var(--cm);">${u.email}</td>
                  <td><span class="st st-${u.rol}">${u.rol}</span></td>
                  <td><span class="st ${u.activo?'st-activo':'st-inactivo'}">${u.activo?'Activo':'Inactivo'}</span></td>
                  <td>
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="display:inline;">
                      <input type="hidden" name="action" value="toggleActivo">
                      <input type="hidden" name="id" value="${u.id}">
                      <input type="hidden" name="tab" value="usuarios">
                      <button type="submit" class="btn-o" style="padding:4px 9px;font-size:0.72rem;" title="Activar/Desactivar"><i class="fas fa-toggle-on"></i></button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="display:inline;" onsubmit="return confirm('¿Eliminar usuario?')">
                      <input type="hidden" name="action" value="eliminarUsuario">
                      <input type="hidden" name="id" value="${u.id}">
                      <input type="hidden" name="tab" value="usuarios">
                      <button type="submit" class="btn-d" style="padding:4px 9px;font-size:0.72rem;"><i class="fas fa-trash"></i></button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </div>
        </div>
        <div class="col-lg-4">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-chart-pie"></i> Distribución de Roles</div></div>
            <div class="mb-3"><div style="display:flex;justify-content:space-between;font-size:0.82rem;margin-bottom:4px;"><span class="st st-admin">Admin</span><strong>${totalAdmins}</strong></div><div class="bar-wrap"><div class="bar" style="background:#3498db;width:${totalUsuarios>0?(totalAdmins*100/totalUsuarios):0}%;"></div></div></div>
            <div class="mb-3"><div style="display:flex;justify-content:space-between;font-size:0.82rem;margin-bottom:4px;"><span class="st st-inmobiliaria">Inmobiliaria</span><strong>${totalInmobiliarias}</strong></div><div class="bar-wrap"><div class="bar" style="background:#9b59b6;width:${totalUsuarios>0?(totalInmobiliarias*100/totalUsuarios):0}%;"></div></div></div>
            <div class="mb-3"><div style="display:flex;justify-content:space-between;font-size:0.82rem;margin-bottom:4px;"><span class="st st-cliente">Cliente</span><strong>${totalClientes}</strong></div><div class="bar-wrap"><div class="bar" style="background:#27ae60;width:${totalUsuarios>0?(totalClientes*100/totalUsuarios):0}%;"></div></div></div>
            <div class="mb-3"><div style="display:flex;justify-content:space-between;font-size:0.82rem;margin-bottom:4px;"><span class="st st-usuario">Usuario</span><strong>${totalUsuariosBasicos}</strong></div><div class="bar-wrap"><div class="bar" style="background:#95a5a6;width:${totalUsuarios>0?(totalUsuariosBasicos*100/totalUsuarios):0}%;"></div></div></div>
            <hr style="border-color:var(--cb);margin:18px 0 14px;">
            <div class="d-grid gap-2">
              <button onclick="gt('usuarios')" class="btn-o w-100 justify-content-start"><i class="fas fa-user-plus me-2" style="color:var(--cg);"></i> Gestionar Usuarios</button>
              <a href="${pageContext.request.contextPath}/reportes.jsp" class="btn-o w-100 justify-content-start"><i class="fas fa-chart-bar me-2" style="color:var(--cg);"></i> Generar Reporte</a>
            </div>
          </div>
        </div>
        <div class="col-12">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-home"></i> Propiedades Recientes</div><a href="${pageContext.request.contextPath}/lista.jsp" class="btn-g"><i class="fas fa-external-link-alt"></i> Ver todas</a></div>
            <c:choose>
              <c:when test="${not empty ultimasPropiedades}">
                <div class="table-responsive"><table class="tbl"><thead><tr><th>Propiedad</th><th>Tipo</th><th>Operación</th><th>Ciudad</th><th>Precio</th><th>Estado</th></tr></thead><tbody>
                <c:forEach var="p" items="${ultimasPropiedades}">
                  <tr>
                    <td><strong>${p.titulo}</strong></td>
                    <td style="font-size:0.8rem;">${p.tipo}</td>
                    <td><span class="st st-${p.operacion}">${p.operacion}</span></td>
                    <td style="font-size:0.8rem;">${p.ciudad}</td>
                    <td style="font-weight:700;">$<fmt:formatNumber value="${p.precio}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td><span class="st st-${p.estado}">${p.estado}</span></td>
                  </tr>
                </c:forEach>
                </tbody></table></div>
              </c:when>
              <c:otherwise><div class="empty"><i class="fas fa-home"></i>No hay propiedades aún</div></c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>

    <%-- ══ APROBACIONES ══ --%>
    <div class="ad-pane" id="pane-aprobaciones">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="ad-title">Aprobaciones Pendientes</div><div class="ad-sub">Solicitudes de nuevas cuentas que requieren tu revisión</div></div>
      </div>
      <c:choose>
        <c:when test="${not empty pendientes}">
          <div class="row g-3">
            <c:forEach var="p" items="${pendientes}">
              <div class="col-md-6 col-lg-4">
                <div class="card" style="border-left:3px solid #c9a84c;padding:20px;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:14px;">
                    <div style="width:48px;height:48px;background:linear-gradient(135deg,#9b59b6,#8e44ad);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.1rem;font-weight:900;color:#fff;flex-shrink:0;">
                      ${fn:substring(p.nombre,0,1)}${fn:substring(p.apellido,0,1)}
                    </div>
                    <div>
                      <div style="font-weight:700;font-size:0.9rem;">${p.nombre} ${p.apellido}</div>
                      <span class="st st-inmobiliaria" style="font-size:0.65rem;">${p.rol}</span>
                    </div>
                  </div>
                  <div style="font-size:0.8rem;color:var(--cm);margin-bottom:4px;"><i class="fas fa-envelope me-1" style="color:var(--cg);"></i>${p.email}</div>
                  <c:if test="${not empty p.telefono}"><div style="font-size:0.8rem;color:var(--cm);margin-bottom:4px;"><i class="fas fa-phone me-1" style="color:var(--cg);"></i>${p.telefono}</div></c:if>
                  <div style="font-size:0.75rem;color:var(--cm);margin-bottom:16px;"><i class="fas fa-clock me-1"></i>Solicitó: ${p.fecha}</div>
                  <div style="display:flex;gap:8px;">
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="flex:1;">
                      <input type="hidden" name="action" value="aprobarCuenta">
                      <input type="hidden" name="id" value="${p.id}">
                      <input type="hidden" name="tab" value="aprobaciones">
                      <button type="submit" class="btn-g w-100 justify-content-center" style="padding:9px;">
                        <i class="fas fa-check"></i> Aprobar
                      </button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="flex:1;" onsubmit="return confirm('¿Rechazar y eliminar la solicitud de ${p.nombre}?')">
                      <input type="hidden" name="action" value="rechazarCuenta">
                      <input type="hidden" name="id" value="${p.id}">
                      <input type="hidden" name="tab" value="aprobaciones">
                      <button type="submit" class="btn-d w-100 justify-content-center" style="padding:9px;border-radius:8px;">
                        <i class="fas fa-times"></i> Rechazar
                      </button>
                    </form>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="card">
            <div class="empty" style="padding:60px 20px;">
              <i class="fas fa-user-check" style="font-size:2.5rem;color:var(--cb);display:block;margin-bottom:16px;"></i>
              <h6 style="font-family:'Playfair Display',serif;font-size:1rem;color:var(--cm);margin-bottom:6px;">Todo al día</h6>
              <p style="font-size:0.82rem;color:var(--cm);">No hay solicitudes pendientes de aprobación.</p>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ══ USUARIOS ══ --%>
    <div class="ad-pane" id="pane-usuarios">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="ad-title">Gestión de Usuarios</div><div class="ad-sub">Administra roles, acceso y estado de cada usuario</div></div>
        <a href="${pageContext.request.contextPath}/usuarios.jsp" class="btn-g"><i class="fas fa-external-link-alt"></i> Módulo completo</a>
      </div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty ultimosUsuarios}">
            <div class="table-responsive"><table class="tbl"><thead><tr><th>#</th><th>Nombre</th><th>Email</th><th>Rol</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
            <c:forEach var="u" items="${ultimosUsuarios}">
              <tr>
                <td style="color:var(--cm);font-size:0.78rem;">#${u.id}</td>
                <td><strong>${u.nombre} ${u.apellido}</strong></td>
                <td style="font-size:0.8rem;color:var(--cm);">${u.email}</td>
                <td>
                  <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="display:inline-flex;gap:4px;align-items:center;">
                    <input type="hidden" name="action" value="cambiarRol">
                    <input type="hidden" name="id" value="${u.id}">
                    <input type="hidden" name="tab" value="usuarios">
                    <select name="rolId" onchange="this.form.submit()" style="font-size:0.76rem;padding:3px 6px;border:1.5px solid var(--cb);border-radius:7px;background:var(--cs);">
                      <option value="1" ${u.rol=='admin'?'selected':''}>Admin</option>
                      <option value="2" ${u.rol=='inmobiliaria'?'selected':''}>Inmobiliaria</option>
                      <option value="3" ${u.rol=='cliente'?'selected':''}>Cliente</option>
                      <option value="4" ${u.rol=='usuario'?'selected':''}>Usuario</option>
                    </select>
                  </form>
                </td>
                <td><span class="st ${u.activo?'st-activo':'st-inactivo'}">${u.activo?'Activo':'Inactivo'}</span></td>
                <td>
                  <div style="display:flex;gap:5px;">
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="display:contents;">
                      <input type="hidden" name="action" value="toggleActivo">
                      <input type="hidden" name="id" value="${u.id}">
                      <input type="hidden" name="tab" value="usuarios">
                      <button type="submit" class="btn-o" style="padding:4px 9px;font-size:0.72rem;" title="${u.activo?'Desactivar':'Activar'}">
                        <i class="fas ${u.activo?'fa-user-slash':'fa-user-check'}"></i>
                      </button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin.jsp" method="post" style="display:contents;" onsubmit="return confirm('¿Eliminar a ${u.nombre}? Esta acción no se puede deshacer.')">
                      <input type="hidden" name="action" value="eliminarUsuario">
                      <input type="hidden" name="id" value="${u.id}">
                      <input type="hidden" name="tab" value="usuarios">
                      <button type="submit" class="btn-d" style="padding:4px 9px;font-size:0.72rem;"><i class="fas fa-trash"></i></button>
                    </form>
                  </div>
                </td>
              </tr>
            </c:forEach>
            </tbody></table></div>
          </c:when>
          <c:otherwise><div class="empty"><i class="fas fa-users"></i>No hay usuarios registrados</div></c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ SOLICITUDES ══ --%>
    <div class="ad-pane" id="pane-solicitudes">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="ad-title">Solicitudes</div><div class="ad-sub">Solicitudes de compra y arriendo de clientes</div></div>
        <span style="background:rgba(231,76,60,0.1);color:#e74c3c;padding:6px 14px;border-radius:8px;font-size:0.82rem;font-weight:700;">
          <i class="fas fa-exclamation-circle me-1"></i> ${totalSolicitudes} pendientes
        </span>
      </div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty todasSolicitudes}">
            <div class="table-responsive">
              <table class="tbl">
                <thead><tr><th>#</th><th>Propiedad</th><th>Cliente</th><th>Tipo</th><th>Fecha</th><th>Estado</th></tr></thead>
                <tbody>
                <c:forEach var="s" items="${todasSolicitudes}">
                  <tr>
                    <td style="color:var(--cm);font-size:0.76rem;">#${s.id}</td>
                    <td><strong style="font-size:0.86rem;">${s.propTitulo}</strong></td>
                    <td style="font-size:0.84rem;font-weight:600;">${s.clienteNombre}</td>
                    <td><span class="st st-${s.tipo}">${s.tipo}</span></td>
                    <td style="font-size:0.78rem;color:var(--cm);">${s.fecha}</td>
                    <td><span class="st st-${s.estado}">${s.estado}</span></td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </c:when>
          <c:otherwise>
            <div class="empty">
              <i class="fas fa-file-signature"></i>
              <p style="margin-top:10px;">No hay solicitudes registradas.<br>
              <small style="font-size:0.78rem;">Aparecen aquí cuando los clientes solicitan compra o arriendo desde una propiedad.</small></p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ CITAS ══ --%>
    <div class="ad-pane" id="pane-citas">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="ad-title">Citas y Visitas</div><div class="ad-sub">Todas las visitas agendadas por clientes</div></div>
        <span style="background:rgba(201,168,76,0.12);color:var(--cg);padding:6px 14px;border-radius:8px;font-size:0.82rem;font-weight:700;">
          <i class="fas fa-clock me-1"></i> ${totalCitas} pendientes
        </span>
      </div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty todasCitas}">
            <div class="table-responsive">
              <table class="tbl">
                <thead><tr><th>#</th><th>Propiedad</th><th>Cliente</th><th>Fecha</th><th>Notas</th><th>Estado</th></tr></thead>
                <tbody>
                <c:forEach var="c" items="${todasCitas}">
                  <tr>
                    <td style="color:var(--cm);font-size:0.76rem;">#${c.id}</td>
                    <td><strong style="font-size:0.86rem;">${c.propTitulo}</strong></td>
                    <td>
                      <div style="font-size:0.84rem;font-weight:600;">${c.clienteNombre}</div>
                      <div style="font-size:0.74rem;color:var(--cm);">${c.clienteEmail}</div>
                    </td>
                    <td style="font-size:0.8rem;">${c.fechaCita}</td>
                    <td style="font-size:0.78rem;color:var(--cm);max-width:140px;">${not empty c.notas ? c.notas : '—'}</td>
                    <td><span class="st st-${c.estado}">${c.estado}</span></td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </c:when>
          <c:otherwise>
            <div class="empty">
              <i class="fas fa-calendar-times"></i>
              <p style="margin-top:10px;">No hay citas registradas en la base de datos.<br>
              <small style="font-size:0.78rem;">Las citas aparecen aquí cuando los clientes agendan visitas desde el detalle de una propiedad.</small></p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ CONFIGURACIÓN ══ --%>
    <div class="ad-pane" id="pane-config">
      <div style="margin-bottom:24px;"><div class="ad-title">Configuración del Sistema</div><div class="ad-sub">Parámetros generales de InmoVista</div></div>
      <div class="row g-4">
        <div class="col-md-6">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-info-circle"></i> Información del Sistema</div></div>
            <table class="tbl">
              <tr><td style="color:var(--cm);">Versión</td><td><strong>InmoVista 1.0</strong></td></tr>
              <tr><td style="color:var(--cm);">Servidor</td><td><strong>Apache Tomcat 8.5.96</strong></td></tr>
              <tr><td style="color:var(--cm);">Base de datos</td><td><strong>MySQL — inmobiliaria_db</strong></td></tr>
              <tr><td style="color:var(--cm);">Usuarios activos</td><td><strong>${totalUsuarios}</strong></td></tr>
              <tr><td style="color:var(--cm);">Propiedades</td><td><strong>${totalPropiedades}</strong></td></tr>
            </table>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-user-shield"></i> Mi Cuenta Admin</div></div>
            <div style="text-align:center;padding:10px 0 20px;">
              <div style="width:64px;height:64px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.4rem;font-weight:900;color:#fff;margin:0 auto 12px;">
                ${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}
              </div>
              <strong>${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</strong><br>
              <span style="font-size:0.8rem;color:var(--cm);">${sessionScope.usuario.email}</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout.jsp" class="btn-d w-100 justify-content-center" style="padding:10px;"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
          </div>
        </div>
      </div>
    </div>

  </main>
</div>
</div>

<%@ include file="footer.jsp" %>

<script>
const INIT_TAB_AD = '<%= tab %>';
function gt(name) {
  document.querySelectorAll('.ad-pane').forEach(p=>p.classList.remove('active'));
  const el = document.getElementById('pane-'+name);
  if(el) el.classList.add('active');
  document.querySelectorAll('.ad-lnk[id]').forEach(l=>l.classList.remove('active'));
  const sl = document.getElementById('sl-'+name);
  if(sl) sl.classList.add('active');
  document.querySelectorAll('.mb').forEach(b=>b.classList.remove('active'));
  const mb = document.getElementById('mb-'+name);
  if(mb) mb.classList.add('active');
  const u = new URL(window.location.href);
  u.searchParams.set('tab',name);
  window.history.replaceState({},'',u);
  window.scrollTo({top:0,behavior:'smooth'});
}
gt(INIT_TAB_AD);
</script>
