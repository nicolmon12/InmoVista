<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════
   INMOBILIARIA.JSP · InmoVista
   Dashboard del agente inmobiliario.
   Protección de sesión + CRUD propiedades + gestión
   de citas y solicitudes de clientes.
═══════════════════════════════════════════════════ */

// ── Protección de sesión ──────────────────────────
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolActual = (String) session.getAttribute("rolNombre");
if (!"inmobiliaria".equals(rolActual)) {
    response.sendRedirect(request.getContextPath() + "/" + rolActual + ".jsp");
    return;
}

int agentId = 0;
Object uidObj = session.getAttribute("userId");
if (uidObj instanceof Integer) agentId = (Integer) uidObj;
else {
    Object idO = ((java.util.Map<?,?>)session.getAttribute("usuario")).get("id");
    if (idO instanceof Integer) agentId = (Integer) idO;
}

// ── Conexión BD ───────────────────────────────────
java.sql.Connection db = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");
} catch (Exception e) { db = null; }

String tab = request.getParameter("tab");
if (tab == null || tab.isEmpty()) tab = "dashboard";
String flashMsg = null, flashErr = null;

// ── HANDLE POST ───────────────────────────────────
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    if (action == null) action = "";

    // Confirmar / Cancelar cita
    if (("confirmarCita".equals(action) || "cancelarCita".equals(action)) && db != null) {
        try {
            String nuevoEstado = "confirmarCita".equals(action) ? "confirmada" : "cancelada";
            java.sql.PreparedStatement ps = db.prepareStatement(
                "UPDATE citas SET estado=? WHERE id=?");
            ps.setString(1, nuevoEstado);
            ps.setInt(2, Integer.parseInt(request.getParameter("citaId")));
            ps.executeUpdate(); ps.close();
            flashMsg = "Cita " + nuevoEstado + " correctamente.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    }

    // Aprobar / Rechazar solicitud
    else if (("aprobarSolicitud".equals(action) || "rechazarSolicitud".equals(action)) && db != null) {
        try {
            String nuevoEstado = "aprobarSolicitud".equals(action) ? "aprobada" : "rechazada";
            java.sql.PreparedStatement ps = db.prepareStatement(
                "UPDATE solicitudes SET estado=? WHERE id=?");
            ps.setString(1, nuevoEstado);
            ps.setInt(2, Integer.parseInt(request.getParameter("solId")));
            ps.executeUpdate(); ps.close();
            // Si aprobada, marcar propiedad como vendida/arrendada
            if ("aprobada".equals(nuevoEstado)) {
                java.sql.PreparedStatement ps2 = db.prepareStatement(
                    "UPDATE propiedades p JOIN solicitudes s ON p.id=s.propiedad_id " +
                    "SET p.estado = IF(s.tipo='venta','vendido','arrendado') WHERE s.id=?");
                ps2.setInt(1, Integer.parseInt(request.getParameter("solId")));
                ps2.executeUpdate(); ps2.close();
            }
            flashMsg = "Solicitud " + nuevoEstado + " correctamente.";
        } catch (Exception ex) { flashErr = "Error: " + ex.getMessage(); }
    }

    // Actualizar perfil
    else if ("actualizarPerfil".equals(action)) {
        String nombre2   = request.getParameter("nombre");
        String apellido2 = request.getParameter("apellido");
        String email2    = request.getParameter("email");
        String tel2      = request.getParameter("telefono");
        if (db != null) {
            try {
                java.sql.PreparedStatement ps = db.prepareStatement(
                    "UPDATE usuarios SET nombre=?, apellido=?, email=?, telefono=? WHERE id=?");
                ps.setString(1, nombre2 != null ? nombre2.trim() : "");
                ps.setString(2, apellido2 != null ? apellido2.trim() : "");
                ps.setString(3, email2 != null ? email2.trim() : "");
                ps.setString(4, tel2 != null ? tel2.trim() : "");
                ps.setInt(5, agentId);
                ps.executeUpdate(); ps.close();
            } catch (Exception ex) {}
        }
        @SuppressWarnings("unchecked")
        java.util.Map<String,Object> uMap = (java.util.Map<String,Object>)session.getAttribute("usuario");
        if (nombre2 != null && !nombre2.trim().isEmpty()) uMap.put("nombre", nombre2.trim());
        if (apellido2 != null) uMap.put("apellido", apellido2.trim());
        if (email2 != null) uMap.put("email", email2.trim());
        if (tel2 != null) uMap.put("telefono", tel2.trim());
        session.setAttribute("usuario", uMap);
        flashMsg = "✓ Perfil actualizado.";
        tab = "perfil";
    }

    if (db != null) { try { db.close(); } catch(Exception e){} }
    String redir = request.getContextPath() + "/inmobiliaria.jsp?tab=" + tab;
    if (flashMsg != null) redir += "&msg=" + java.net.URLEncoder.encode(flashMsg,"UTF-8");
    if (flashErr != null) redir += "&err=" + java.net.URLEncoder.encode(flashErr,"UTF-8");
    response.sendRedirect(redir);
    return;
}

// ── GET: cargar datos ─────────────────────────────
java.util.List<java.util.Map<String,Object>> misPropiedades   = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> citasPendientes  = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> todasCitas       = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> solicitudes      = new java.util.ArrayList<>();
int cntProp=0, cntCitasPend=0, cntSolPend=0, cntVentas=0;

if (db != null) {
    try {
        java.sql.ResultSet rs;

        // Mis propiedades
        java.sql.PreparedStatement ps1 = db.prepareStatement(
            "SELECT id,titulo,tipo,operacion,ciudad,precio,estado,foto_principal FROM propiedades ORDER BY id DESC");
        rs = ps1.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",       rs.getInt("id"));
            m.put("titulo",   rs.getString("titulo"));
            m.put("tipo",     rs.getString("tipo"));
            m.put("operacion",rs.getString("operacion"));
            m.put("ciudad",   rs.getString("ciudad"));
            m.put("precio",   rs.getDouble("precio"));
            m.put("estado",   rs.getString("estado"));
            m.put("foto",     rs.getString("foto_principal") != null ? rs.getString("foto_principal") :
                              "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=300&q=60");
            misPropiedades.add(m);
        } rs.close(); ps1.close();
        cntProp = misPropiedades.size();

        // Citas
        java.sql.PreparedStatement ps2 = db.prepareStatement(
            "SELECT c.id, c.fecha_cita, c.notas, c.estado, " +
            "p.titulo AS prop_titulo, u.nombre AS cli_nombre, u.apellido AS cli_apellido " +
            "FROM citas c JOIN propiedades p ON c.propiedad_id=p.id " +
            "JOIN usuarios u ON c.cliente_id=u.id ORDER BY c.fecha_cita ASC");
        rs = ps2.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",           rs.getInt("id"));
            m.put("fechaCita",    rs.getString("fecha_cita") != null ? rs.getString("fecha_cita") : "");
            m.put("notas",        rs.getString("notas") != null ? rs.getString("notas") : "");
            m.put("estado",       rs.getString("estado"));
            m.put("propTitulo",   rs.getString("prop_titulo"));
            m.put("clienteNombre",rs.getString("cli_nombre") + " " + rs.getString("cli_apellido"));
            todasCitas.add(m);
            if ("pendiente".equals(rs.getString("estado"))) {
                citasPendientes.add(m);
                cntCitasPend++;
            }
        } rs.close(); ps2.close();

        // Solicitudes
        java.sql.PreparedStatement ps3 = db.prepareStatement(
            "SELECT s.id, s.tipo, s.estado, s.fecha_solicitud, " +
            "p.titulo AS prop_titulo, u.nombre AS cli_nombre, u.apellido AS cli_apellido " +
            "FROM solicitudes s JOIN propiedades p ON s.propiedad_id=p.id " +
            "JOIN usuarios u ON s.cliente_id=u.id ORDER BY s.fecha_solicitud DESC");
        rs = ps3.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",           rs.getInt("id"));
            m.put("tipo",         rs.getString("tipo"));
            m.put("estado",       rs.getString("estado"));
            m.put("fecha",        rs.getString("fecha_solicitud") != null ? rs.getString("fecha_solicitud") : "");
            m.put("propTitulo",   rs.getString("prop_titulo"));
            m.put("clienteNombre",rs.getString("cli_nombre") + " " + rs.getString("cli_apellido"));
            solicitudes.add(m);
            if ("pendiente".equals(rs.getString("estado"))) cntSolPend++;
            if ("aprobada".equals(rs.getString("estado")))  cntVentas++;
        } rs.close(); ps3.close();

        db.close();
    } catch (Exception ex) {
        if (db != null) { try { db.close(); } catch(Exception e){} }
    }
}

// ── Demo fallback ─────────────────────────────────
if (misPropiedades.isEmpty()) {
    String[][] demoProps = {
        {"1","Casa Moderna en Cabecera","casa","venta","Bucaramanga","420000000","disponible"},
        {"2","Apto Exclusivo Lagos","apartamento","venta","Bucaramanga","280000000","disponible"},
        {"3","Oficina Centro Empresarial","oficina","arriendo","Bucaramanga","2800000","disponible"}
    };
    for (String[] d : demoProps) {
        java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
        m.put("id",d[0]); m.put("titulo",d[1]); m.put("tipo",d[2]);
        m.put("operacion",d[3]); m.put("ciudad",d[4]); m.put("precio",Double.parseDouble(d[5]));
        m.put("estado",d[6]); m.put("foto","https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=300&q=60");
        misPropiedades.add(m);
    }
    cntProp = 3;
}

request.setAttribute("misPropiedades",  misPropiedades);
request.setAttribute("citasPendientes", citasPendientes);
request.setAttribute("todasCitas",      todasCitas);
request.setAttribute("solicitudes",     solicitudes);
request.setAttribute("cntProp",         cntProp);
request.setAttribute("cntCitasPend",    cntCitasPend);
request.setAttribute("cntSolPend",      cntSolPend);
request.setAttribute("cntVentas",       cntVentas);
%>
<c:set var="pageTitle" value="Panel Inmobiliaria — InmoVista" scope="request"/>
<%@ include file="header.jsp" %>

<style>
:root{--cg:#c9a84c;--cd:#0d0d0d;--cb:#e8e5df;--cs:#f8f7f5;--cm:#9a9590;}
.im-layout{display:grid;grid-template-columns:240px 1fr;min-height:calc(100vh - 72px);background:var(--cs);}
@media(max-width:900px){.im-layout{grid-template-columns:1fr;}}
.im-sidebar{background:var(--cd);padding:20px 0;position:sticky;top:72px;height:calc(100vh - 72px);overflow-y:auto;display:flex;flex-direction:column;}
@media(max-width:900px){.im-sidebar{display:none;}}
.im-av{width:48px;height:48px;background:linear-gradient(135deg,#9b59b6,#8e44ad);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.2rem;font-weight:900;color:#fff;margin-bottom:8px;}
.im-role{font-size:0.62rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#9b59b6;}
.im-sec{font-size:0.58rem;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,.2);padding:10px 16px 4px;}
.im-lnk{display:flex;align-items:center;gap:10px;padding:10px 16px;font-size:0.84rem;font-weight:500;color:rgba(255,255,255,.4);text-decoration:none;border-left:3px solid transparent;transition:all .2s;cursor:pointer;background:none;border-top:none;border-right:none;border-bottom:none;width:100%;text-align:left;font-family:inherit;}
.im-lnk:hover,.im-lnk.active{color:#fff;background:rgba(255,255,255,.04);}
.im-lnk.active{color:var(--cg);background:rgba(201,168,76,.08);border-left-color:var(--cg);}
.im-lnk i{width:16px;text-align:center;font-size:0.82rem;}
.im-bot{margin-top:auto;padding:14px 0;border-top:1px solid rgba(255,255,255,.07);}
.im-main{padding:28px;}
@media(max-width:768px){.im-main{padding:16px;}}
.im-pane{display:none;} .im-pane.active{display:block;}
.im-title{font-family:'Playfair Display',serif;font-size:1.7rem;font-weight:900;color:var(--cd);}
.im-sub{font-size:0.82rem;color:var(--cm);margin-top:2px;}
.kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
@media(max-width:900px){.kpis{grid-template-columns:repeat(2,1fr);}}
.kpi{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:18px;display:flex;align-items:center;gap:14px;box-shadow:0 2px 8px rgba(0,0,0,.04);}
.kpi-ic{width:44px;height:44px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.kpi-n{font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;color:var(--cd);line-height:1;}
.kpi-l{font-size:0.72rem;color:var(--cm);margin-top:1px;}
.card{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:22px;box-shadow:0 2px 8px rgba(0,0,0,.04);margin-bottom:20px;}
.ct{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;}
.ct-t{display:flex;align-items:center;gap:9px;font-family:'Playfair Display',serif;font-size:1.05rem;font-weight:700;color:var(--cd);}
.ct-t i{color:var(--cg);}
.tbl{width:100%;border-collapse:collapse;}
.tbl th{text-align:left;font-size:0.7rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:var(--cm);padding:8px 10px;border-bottom:2px solid var(--cb);}
.tbl td{padding:11px 10px;border-bottom:1px solid var(--cb);font-size:0.84rem;vertical-align:middle;}
.tbl tr:last-child td{border-bottom:none;}
.tbl tr:hover td{background:var(--cs);}
.btn-g{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;background:linear-gradient(135deg,#c9a84c,#e8c96b);color:#000;font-weight:700;font-size:0.78rem;border:none;border-radius:8px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-g:hover{transform:translateY(-1px);box-shadow:0 6px 16px rgba(201,168,76,.3);color:#000;}
.btn-o{display:inline-flex;align-items:center;gap:6px;padding:6px 12px;background:transparent;color:var(--cd);font-weight:600;font-size:0.76rem;border:1.5px solid var(--cb);border-radius:8px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-o:hover{border-color:var(--cg);color:var(--cg);}
.btn-ok{display:inline-flex;align-items:center;gap:5px;padding:5px 10px;background:rgba(39,174,96,.1);color:#0f5132;font-size:0.73rem;border:1.5px solid rgba(39,174,96,.3);border-radius:7px;cursor:pointer;transition:all .2s;}
.btn-ok:hover{background:rgba(39,174,96,.2);}
.btn-d{display:inline-flex;align-items:center;gap:5px;padding:5px 10px;background:transparent;color:#e74c3c;font-size:0.73rem;border:1.5px solid rgba(231,76,60,.3);border-radius:7px;cursor:pointer;transition:all .2s;}
.btn-d:hover{background:rgba(231,76,60,.08);}
.st{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;border-radius:100px;font-size:0.7rem;font-weight:700;}
.st-pendiente{background:#fff3cd;color:#856404;}
.st-confirmada,.st-aprobada,.st-disponible{background:#d1e7dd;color:#0f5132;}
.st-cancelada,.st-rechazada{background:#f8d7da;color:#842029;}
.st-vendido{background:rgba(201,168,76,.12);color:#7a5d0f;}
.st-arrendado{background:rgba(41,182,246,.12);color:#055a7a;}
.st-venta{background:rgba(201,168,76,.12);color:#7a5d0f;}
.st-arriendo{background:rgba(41,182,246,.12);color:#055a7a;}
.prop-img{width:48px;height:40px;border-radius:7px;object-fit:cover;flex-shrink:0;}
.flash-ok{background:#d1e7dd;color:#0f5132;border:1px solid #a3cfbb;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;}
.flash-er{background:#f8d7da;color:#842029;border:1px solid #f1aeb5;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;}
.empty{text-align:center;padding:40px 20px;color:var(--cm);}
.empty i{font-size:2rem;color:var(--cb);display:block;margin-bottom:12px;}
.cl-fc{width:100%;padding:10px 13px;border:1.5px solid var(--cb);border-radius:9px;font-family:inherit;font-size:0.86rem;color:var(--cd);background:var(--cs);outline:none;transition:border-color .2s;}
.cl-fc:focus{border-color:var(--cg);background:#fff;}
.cl-fl{font-size:0.72rem;font-weight:700;color:var(--cm);margin-bottom:5px;display:block;}
.mnav{display:none;background:var(--cd);padding:10px 14px;gap:6px;overflow-x:auto;border-bottom:1px solid rgba(255,255,255,.07);}
@media(max-width:900px){.mnav{display:flex;}}
.mb{display:flex;align-items:center;gap:5px;padding:7px 12px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.08);border-radius:100px;color:rgba(255,255,255,.4);font-size:0.72rem;font-weight:600;white-space:nowrap;cursor:pointer;text-decoration:none;transition:all .2s;}
.mb.active,.mb:hover{background:rgba(201,168,76,.12);border-color:rgba(201,168,76,.3);color:var(--cg);}
</style>

<div class="im-layout">
<%-- ── SIDEBAR ── --%>
<aside class="im-sidebar">
  <div style="padding:0 16px 20px;border-bottom:1px solid rgba(255,255,255,.07);margin-bottom:10px;">
    <div class="im-av">${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}</div>
    <div style="font-weight:700;color:#fff;font-size:0.9rem;">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</div>
    <div class="im-role"><i class="fas fa-building me-1"></i> Inmobiliaria</div>
  </div>
  <div class="im-sec">Principal</div>
  <button class="im-lnk" onclick="gt('dashboard')" id="sl-dashboard"><i class="fas fa-tachometer-alt"></i> Mi Panel</button>
  <div class="im-sec">Propiedades</div>
  <button class="im-lnk" onclick="gt('propiedades')" id="sl-propiedades"><i class="fas fa-home"></i> Mis Propiedades</button>
  <a class="im-lnk" href="${pageContext.request.contextPath}/formulario.jsp"><i class="fas fa-plus-circle"></i> Publicar Nueva</a>
  <div class="im-sec">Clientes</div>
  <button class="im-lnk" onclick="gt('citas')" id="sl-citas"><i class="fas fa-calendar-check"></i> Visitas Agendadas</button>
  <button class="im-lnk" onclick="gt('solicitudes')" id="sl-solicitudes"><i class="fas fa-file-signature"></i> Solicitudes</button>
  <div class="im-sec">Cuenta</div>
  <button class="im-lnk" onclick="gt('reportes')" id="sl-reportes"><i class="fas fa-chart-bar"></i> Mis Reportes</button>
  <button class="im-lnk" onclick="gt('perfil')" id="sl-perfil"><i class="fas fa-user-cog"></i> Mi Perfil</button>
  <div class="im-bot">
    <a href="${pageContext.request.contextPath}/logout.jsp" class="im-lnk" style="color:rgba(231,76,60,.7);"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
  </div>
</aside>

<div>
  <div class="mnav">
    <button class="mb" id="mb-dashboard"    onclick="gt('dashboard')"><i class="fas fa-th-large"></i> Panel</button>
    <button class="mb" id="mb-propiedades"  onclick="gt('propiedades')"><i class="fas fa-home"></i> Props</button>
    <button class="mb" id="mb-citas"        onclick="gt('citas')"><i class="fas fa-calendar"></i> Citas</button>
    <button class="mb" id="mb-solicitudes"  onclick="gt('solicitudes')"><i class="fas fa-file-alt"></i> Solic.</button>
    <button class="mb" id="mb-reportes"     onclick="gt('reportes')"><i class="fas fa-chart-bar"></i> Reportes</button>
    <button class="mb" id="mb-perfil"       onclick="gt('perfil')"><i class="fas fa-user"></i> Perfil</button>
  </div>

  <main class="im-main">
    <c:if test="${not empty param.msg}"><div class="flash-ok"><i class="fas fa-check-circle"></i> ${param.msg}</div></c:if>
    <c:if test="${not empty param.err}"><div class="flash-er"><i class="fas fa-exclamation-circle"></i> ${param.err}</div></c:if>

    <%-- ══ DASHBOARD ══ --%>
    <div class="im-pane" id="pane-dashboard">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="im-title">Hola, ${sessionScope.usuario.nombre} 👋</div><div class="im-sub">Resumen de tu actividad inmobiliaria</div></div>
        <a href="${pageContext.request.contextPath}/formulario.jsp" class="btn-g"><i class="fas fa-plus"></i> Publicar Propiedad</a>
      </div>
      <div class="kpis">
        <div class="kpi"><div class="kpi-ic" style="background:rgba(39,174,96,.12);color:#27ae60;"><i class="fas fa-home"></i></div><div><div class="kpi-n">${cntProp}</div><div class="kpi-l">Mis Propiedades</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(201,168,76,.12);color:var(--cg);"><i class="fas fa-calendar-alt"></i></div><div><div class="kpi-n">${cntCitasPend}</div><div class="kpi-l">Visitas Pendientes</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(52,152,219,.12);color:#3498db;"><i class="fas fa-file-signature"></i></div><div><div class="kpi-n">${cntSolPend}</div><div class="kpi-l">Solicitudes Nuevas</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(155,89,182,.12);color:#9b59b6;"><i class="fas fa-handshake"></i></div><div><div class="kpi-n">${cntVentas}</div><div class="kpi-l">Ventas/Arriendos</div></div></div>
      </div>
      <div class="row g-4">
        <div class="col-lg-7">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-home"></i> Mis Propiedades</div><button class="btn-o" onclick="gt('propiedades')">Ver todas <i class="fas fa-arrow-right ms-1"></i></button></div>
            <c:choose>
              <c:when test="${not empty misPropiedades}">
                <table class="tbl"><thead><tr><th>Propiedad</th><th>Operación</th><th>Precio</th><th>Estado</th></tr></thead><tbody>
                <c:forEach var="p" items="${misPropiedades}" begin="0" end="4">
                  <tr>
                    <td><strong style="font-size:0.86rem;">${p.titulo}</strong><br><small style="color:var(--cm);">${p.ciudad}</small></td>
                    <td><span class="st st-${p.operacion}">${p.operacion}</span></td>
                    <td style="font-weight:700;font-size:0.84rem;">$<fmt:formatNumber value="${p.precio}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td><span class="st st-${p.estado}">${p.estado}</span></td>
                  </tr>
                </c:forEach>
                </tbody></table>
              </c:when>
              <c:otherwise><div class="empty"><i class="fas fa-home"></i>Aún no has publicado propiedades<br><a href="${pageContext.request.contextPath}/formulario.jsp" class="btn-g mt-3 d-inline-flex"><i class="fas fa-plus"></i> Publicar</a></div></c:otherwise>
            </c:choose>
          </div>
        </div>
        <div class="col-lg-5">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-calendar-alt"></i> Visitas Pendientes</div></div>
            <c:choose>
              <c:when test="${not empty citasPendientes}">
                <c:forEach var="c" items="${citasPendientes}" begin="0" end="3">
                  <div style="padding:12px 0;border-bottom:1px solid var(--cb);">
                    <div style="font-weight:600;font-size:0.86rem;">${c.propTitulo}</div>
                    <div style="font-size:0.78rem;color:var(--cm);margin:3px 0;"><i class="fas fa-user me-1"></i>${c.clienteNombre}</div>
                    <div style="font-size:0.78rem;"><i class="fas fa-clock me-1" style="color:var(--cg);"></i>${c.fechaCita}</div>
                    <div style="display:flex;gap:6px;margin-top:8px;">
                      <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="flex:1;">
                        <input type="hidden" name="action" value="confirmarCita">
                        <input type="hidden" name="citaId" value="${c.id}">
                        <input type="hidden" name="tab" value="citas">
                        <button type="submit" class="btn-ok w-100 justify-content-center"><i class="fas fa-check"></i> Confirmar</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="flex:1;">
                        <input type="hidden" name="action" value="cancelarCita">
                        <input type="hidden" name="citaId" value="${c.id}">
                        <input type="hidden" name="tab" value="citas">
                        <button type="submit" class="btn-d w-100 justify-content-center"><i class="fas fa-times"></i> Cancelar</button>
                      </form>
                    </div>
                  </div>
                </c:forEach>
                <c:if test="${fn:length(citasPendientes)>4}"><button class="btn-o w-100 mt-2 justify-content-center" onclick="gt('citas')">Ver todas (${fn:length(citasPendientes)})</button></c:if>
              </c:when>
              <c:otherwise><div class="empty" style="padding:24px;"><i class="fas fa-calendar-check"></i>Sin visitas pendientes</div></c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>

    <%-- ══ PROPIEDADES ══ --%>
    <div class="im-pane" id="pane-propiedades">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;">
        <div><div class="im-title">Mis Propiedades</div><div class="im-sub">Administra tu catálogo completo</div></div>
        <a href="${pageContext.request.contextPath}/formulario.jsp" class="btn-g"><i class="fas fa-plus"></i> Nueva Propiedad</a>
      </div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty misPropiedades}">
            <div class="table-responsive">
              <table class="tbl"><thead><tr><th>Foto</th><th>Propiedad</th><th>Tipo</th><th>Operación</th><th>Ciudad</th><th>Precio</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
              <c:forEach var="p" items="${misPropiedades}">
                <tr>
                  <td><img src="${p.foto}" class="prop-img" alt="${p.titulo}"></td>
                  <td><strong style="font-size:0.86rem;">${p.titulo}</strong></td>
                  <td style="font-size:0.8rem;">${p.tipo}</td>
                  <td><span class="st st-${p.operacion}">${p.operacion}</span></td>
                  <td style="font-size:0.8rem;">${p.ciudad}</td>
                  <td style="font-weight:700;font-size:0.84rem;">$<fmt:formatNumber value="${p.precio}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                  <td><span class="st st-${p.estado}">${p.estado}</span></td>
                  <td>
                    <div style="display:flex;gap:5px;">
                      <a href="${pageContext.request.contextPath}/detalle.jsp?id=${p.id}" class="btn-o" style="padding:5px 9px;"><i class="fas fa-eye"></i></a>
                      <a href="${pageContext.request.contextPath}/formulario.jsp?id=${p.id}" class="btn-g" style="padding:5px 9px;"><i class="fas fa-edit"></i></a>
                      <form action="${pageContext.request.contextPath}/lista.jsp" method="post" style="display:contents;" onsubmit="return confirm('¿Eliminar ${p.titulo}?')">
                        <input type="hidden" name="action" value="eliminar">
                        <input type="hidden" name="id" value="${p.id}">
                        <button type="submit" class="btn-d" style="padding:5px 9px;"><i class="fas fa-trash"></i></button>
                      </form>
                    </div>
                  </td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </c:when>
          <c:otherwise><div class="empty"><i class="fas fa-building"></i>No tienes propiedades publicadas aún<br><a href="${pageContext.request.contextPath}/formulario.jsp" class="btn-g mt-3 d-inline-flex"><i class="fas fa-plus"></i> Publicar primera</a></div></c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ CITAS ══ --%>
    <div class="im-pane" id="pane-citas">
      <div style="margin-bottom:24px;"><div class="im-title">Visitas Agendadas</div><div class="im-sub">Gestiona las visitas de tus clientes</div></div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty todasCitas}">
            <div class="table-responsive">
              <table class="tbl"><thead><tr><th>Propiedad</th><th>Cliente</th><th>Fecha</th><th>Notas</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
              <c:forEach var="c" items="${todasCitas}">
                <tr>
                  <td><strong style="font-size:0.86rem;">${c.propTitulo}</strong></td>
                  <td style="font-size:0.82rem;">${c.clienteNombre}</td>
                  <td style="font-size:0.8rem;">${c.fechaCita}</td>
                  <td style="font-size:0.8rem;max-width:130px;color:var(--cm);">${not empty c.notas ? c.notas : '—'}</td>
                  <td><span class="st st-${c.estado}">${c.estado}</span></td>
                  <td>
                    <c:if test="${c.estado=='pendiente'}">
                      <div style="display:flex;gap:5px;">
                        <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="display:contents;">
                          <input type="hidden" name="action" value="confirmarCita">
                          <input type="hidden" name="citaId" value="${c.id}">
                          <input type="hidden" name="tab" value="citas">
                          <button type="submit" class="btn-ok"><i class="fas fa-check"></i></button>
                        </form>
                        <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="display:contents;">
                          <input type="hidden" name="action" value="cancelarCita">
                          <input type="hidden" name="citaId" value="${c.id}">
                          <input type="hidden" name="tab" value="citas">
                          <button type="submit" class="btn-d"><i class="fas fa-times"></i></button>
                        </form>
                      </div>
                    </c:if>
                    <c:if test="${c.estado!='pendiente'}"><span style="font-size:0.75rem;color:var(--cm);">—</span></c:if>
                  </td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </c:when>
          <c:otherwise><div class="empty"><i class="fas fa-calendar-times"></i>No hay visitas agendadas</div></c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ SOLICITUDES ══ --%>
    <div class="im-pane" id="pane-solicitudes">
      <div style="margin-bottom:24px;"><div class="im-title">Solicitudes de Clientes</div><div class="im-sub">Aprueba o rechaza solicitudes de compra y arriendo</div></div>
      <div class="card">
        <c:choose>
          <c:when test="${not empty solicitudes}">
            <div class="table-responsive">
              <table class="tbl"><thead><tr><th>Propiedad</th><th>Cliente</th><th>Tipo</th><th>Fecha</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
              <c:forEach var="s" items="${solicitudes}">
                <tr>
                  <td><strong style="font-size:0.86rem;">${s.propTitulo}</strong></td>
                  <td style="font-size:0.82rem;">${s.clienteNombre}</td>
                  <td><span class="st st-${s.tipo}">${s.tipo}</span></td>
                  <td style="font-size:0.78rem;color:var(--cm);">${s.fecha}</td>
                  <td><span class="st st-${s.estado}">${s.estado}</span></td>
                  <td>
                    <c:if test="${s.estado=='pendiente'}">
                      <div style="display:flex;gap:5px;">
                        <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="display:contents;">
                          <input type="hidden" name="action" value="aprobarSolicitud">
                          <input type="hidden" name="solId" value="${s.id}">
                          <input type="hidden" name="tab" value="solicitudes">
                          <button type="submit" class="btn-ok"><i class="fas fa-check me-1"></i>Aprobar</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post" style="display:contents;" onsubmit="return confirm('¿Rechazar esta solicitud?')">
                          <input type="hidden" name="action" value="rechazarSolicitud">
                          <input type="hidden" name="solId" value="${s.id}">
                          <input type="hidden" name="tab" value="solicitudes">
                          <button type="submit" class="btn-d"><i class="fas fa-times me-1"></i>Rechazar</button>
                        </form>
                      </div>
                    </c:if>
                    <c:if test="${s.estado!='pendiente'}"><span style="font-size:0.75rem;color:var(--cm);">Procesada</span></c:if>
                  </td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </c:when>
          <c:otherwise><div class="empty"><i class="fas fa-file-signature"></i>No hay solicitudes aún</div></c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ REPORTES ══ --%>
    <div class="im-pane" id="pane-reportes">
      <div style="margin-bottom:24px;"><div class="im-title">Mis Reportes</div><div class="im-sub">Estadísticas de ventas y arriendos</div></div>
      <div class="kpis">
        <div class="kpi"><div class="kpi-ic" style="background:rgba(39,174,96,.12);color:#27ae60;"><i class="fas fa-home"></i></div><div><div class="kpi-n">${cntProp}</div><div class="kpi-l">Total Propiedades</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(201,168,76,.12);color:var(--cg);"><i class="fas fa-handshake"></i></div><div><div class="kpi-n">${cntVentas}</div><div class="kpi-l">Ventas/Arriendos</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(52,152,219,.12);color:#3498db;"><i class="fas fa-calendar"></i></div><div><div class="kpi-n">${fn:length(todasCitas)}</div><div class="kpi-l">Total Citas</div></div></div>
        <div class="kpi"><div class="kpi-ic" style="background:rgba(231,76,60,.12);color:#e74c3c;"><i class="fas fa-file-alt"></i></div><div><div class="kpi-n">${fn:length(solicitudes)}</div><div class="kpi-l">Total Solicitudes</div></div></div>
      </div>
      <div class="card">
        <div class="ct"><div class="ct-t"><i class="fas fa-chart-bar"></i> Reporte Completo del Sistema</div></div>
        <p style="font-size:0.87rem;color:var(--cm);margin-bottom:18px;">Para reportes detallados con gráficos y exportación, accede al módulo de reportes.</p>
        <a href="${pageContext.request.contextPath}/reportes.jsp" class="btn-g"><i class="fas fa-external-link-alt me-1"></i> Abrir módulo de reportes</a>
      </div>
    </div>

    <%-- ══ PERFIL ══ --%>
    <div class="im-pane" id="pane-perfil">
      <div style="margin-bottom:24px;"><div class="im-title">Mi Perfil</div><div class="im-sub">Actualiza tu información de agente</div></div>
      <div class="row g-4">
        <div class="col-lg-4">
          <div class="card text-center">
            <div style="width:72px;height:72px;background:linear-gradient(135deg,#9b59b6,#8e44ad);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.6rem;font-weight:900;color:#fff;margin:0 auto 14px;">
              ${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}
            </div>
            <h6 style="font-family:'Playfair Display',serif;font-weight:900;margin-bottom:4px;">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</h6>
            <span style="background:rgba(155,89,182,.12);color:#6c3483;padding:3px 10px;border-radius:100px;font-size:0.68rem;font-weight:700;letter-spacing:1px;"><i class="fas fa-building me-1"></i>INMOBILIARIA</span>
            <div style="margin-top:18px;text-align:left;">
              <div style="display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid var(--cb);font-size:0.84rem;"><span style="color:var(--cm);">Correo</span><span style="font-weight:600;">${sessionScope.usuario.email}</span></div>
              <div style="display:flex;justify-content:space-between;padding:9px 0;font-size:0.84rem;"><span style="color:var(--cm);">Teléfono</span><span style="font-weight:600;">${not empty sessionScope.usuario.telefono?sessionScope.usuario.telefono:'N/A'}</span></div>
            </div>
          </div>
        </div>
        <div class="col-lg-8">
          <div class="card">
            <div class="ct"><div class="ct-t"><i class="fas fa-edit"></i> Editar Datos</div></div>
            <form action="${pageContext.request.contextPath}/inmobiliaria.jsp" method="post">
              <input type="hidden" name="action" value="actualizarPerfil">
              <input type="hidden" name="tab" value="perfil">
              <div class="row g-3">
                <div class="col-md-6"><label class="cl-fl">Nombre</label><input type="text" name="nombre" class="cl-fc" value="${sessionScope.usuario.nombre}" required></div>
                <div class="col-md-6"><label class="cl-fl">Apellido</label><input type="text" name="apellido" class="cl-fc" value="${sessionScope.usuario.apellido}" required></div>
                <div class="col-md-6"><label class="cl-fl">Correo</label><input type="email" name="email" class="cl-fc" value="${sessionScope.usuario.email}" required></div>
                <div class="col-md-6"><label class="cl-fl">Teléfono</label><input type="tel" name="telefono" class="cl-fc" value="${sessionScope.usuario.telefono}" placeholder="+57 300 000 0000"></div>
                <div class="col-12 mt-2"><button type="submit" class="btn-g"><i class="fas fa-save"></i> Guardar Cambios</button></div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

  </main>
</div>
</div>

<%@ include file="footer.jsp" %>

<script>
const INIT_TAB_IM = '<%= tab %>';
function gt(name) {
  document.querySelectorAll('.im-pane').forEach(p=>p.classList.remove('active'));
  const el = document.getElementById('pane-'+name);
  if(el) el.classList.add('active');
  document.querySelectorAll('.im-lnk[id]').forEach(l=>l.classList.remove('active'));
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
gt(INIT_TAB_IM);
</script>
