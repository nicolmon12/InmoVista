<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%
/* ═══════════════════════════════════════════════════
   SUPERADMIN.JSP · InmoVista
   Panel exclusivo de la creadora. Acceso solo desde
   el trigger oculto del footer con clave maestra.
   Establece sesión automática como admin1.
═══════════════════════════════════════════════════ */

// ── Acceso: token sv=1 O sesión admin activa ─────
String svToken = request.getParameter("sv");
boolean hasAdminSession = "admin".equals(session.getAttribute("rolNombre")) && session.getAttribute("usuario") != null;
if (!"1".equals(svToken) && !hasAdminSession) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// ── Crear sesión si viene por sv=1 y no hay sesión ─
if ("1".equals(svToken) && session.getAttribute("usuario") == null) {
    java.util.Map<String,Object> sAdmin = new java.util.LinkedHashMap<String,Object>();
    sAdmin.put("id",            1);
    sAdmin.put("nombre",        "Creadora");
    sAdmin.put("apellido",      "InmoVista");
    sAdmin.put("email",         "admin@inmovista.com");
    sAdmin.put("telefono",      "");
    sAdmin.put("fechaRegistro", new java.util.Date());
    session.setAttribute("usuario",   sAdmin);
    session.setAttribute("rolNombre", "admin");
    session.setAttribute("userId",    1);
    session.setAttribute("isSuperAdmin", true);
}

// ── Cargar stats desde BD ─────────────────────────
java.sql.Connection db = null;
int totalUsuarios=0, totalPropiedades=0, totalCitas=0, totalSolicitudes=0;
java.util.List<java.util.Map<String,Object>> pendientes  = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> usuarios    = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> propiedades = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> citas       = new java.util.ArrayList<>();
java.util.List<java.util.Map<String,Object>> solicitudes = new java.util.ArrayList<>();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");

    java.sql.ResultSet rs;
    rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios"); if(rs.next()) totalUsuarios=rs.getInt(1); rs.close();
    rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM propiedades"); if(rs.next()) totalPropiedades=rs.getInt(1); rs.close();
    rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM citas WHERE estado='pendiente'"); if(rs.next()) totalCitas=rs.getInt(1); rs.close();
    rs = db.createStatement().executeQuery("SELECT COUNT(*) FROM solicitudes WHERE estado='pendiente'"); if(rs.next()) totalSolicitudes=rs.getInt(1); rs.close();

    // Pendientes de aprobacion
    rs = db.createStatement().executeQuery(
        "SELECT u.id,u.nombre,u.apellido,u.email,r.nombre AS rol,u.fecha_registro FROM usuarios u JOIN roles r ON u.rol_id=r.id WHERE u.activo=0 ORDER BY u.fecha_registro DESC");
    while(rs.next()){
        java.util.Map<String,Object> m=new java.util.LinkedHashMap<>();
        m.put("id",rs.getInt("id")); m.put("nombre",rs.getString("nombre")); m.put("apellido",rs.getString("apellido"));
        m.put("email",rs.getString("email")); m.put("rol",rs.getString("rol")); m.put("fecha",rs.getString("fecha_registro")!=null?rs.getString("fecha_registro"):"");
        pendientes.add(m);
    } rs.close();

    // Todos los usuarios
    rs = db.createStatement().executeQuery(
        "SELECT u.id,u.nombre,u.apellido,u.email,u.activo,r.nombre AS rol FROM usuarios u JOIN roles r ON u.rol_id=r.id ORDER BY u.fecha_registro DESC LIMIT 20");
    while(rs.next()){
        java.util.Map<String,Object> m=new java.util.LinkedHashMap<>();
        m.put("id",rs.getInt("id")); m.put("nombre",rs.getString("nombre")); m.put("apellido",rs.getString("apellido"));
        m.put("email",rs.getString("email")); m.put("activo",rs.getInt("activo")==1); m.put("rol",rs.getString("rol"));
        usuarios.add(m);
    } rs.close();

    // Propiedades
    rs = db.createStatement().executeQuery(
        "SELECT id,titulo,tipo,operacion,ciudad,precio,estado FROM propiedades ORDER BY id DESC LIMIT 15");
    while(rs.next()){
        java.util.Map<String,Object> m=new java.util.LinkedHashMap<>();
        m.put("id",rs.getInt("id")); m.put("titulo",rs.getString("titulo")); m.put("tipo",rs.getString("tipo"));
        m.put("operacion",rs.getString("operacion")); m.put("ciudad",rs.getString("ciudad"));
        m.put("precio",rs.getDouble("precio")); m.put("estado",rs.getString("estado"));
        propiedades.add(m);
    } rs.close();

    // Citas
    rs = db.createStatement().executeQuery(
        "SELECT c.id,c.fecha_cita,c.notas,c.estado,COALESCE(p.titulo,'Propiedad eliminada') AS prop,u.nombre AS cli,u.apellido AS cli_ap,u.email AS cli_email FROM citas c LEFT JOIN propiedades p ON c.propiedad_id=p.id LEFT JOIN usuarios u ON c.cliente_id=u.id WHERE u.id IS NOT NULL ORDER BY c.fecha_cita DESC LIMIT 50");
    while(rs.next()){
        java.util.Map<String,Object> m=new java.util.LinkedHashMap<>();
        m.put("id",rs.getInt("id")); m.put("fecha",rs.getString("fecha_cita")!=null?rs.getString("fecha_cita"):"");
        m.put("notas",rs.getString("notas")!=null?rs.getString("notas"):"");
        m.put("estado",rs.getString("estado")); m.put("prop",rs.getString("prop"));
        m.put("cliente",rs.getString("cli")+" "+rs.getString("cli_ap"));
        m.put("email",rs.getString("cli_email")!=null?rs.getString("cli_email"):"");
        citas.add(m);
    } rs.close();

    // Solicitudes
    rs = db.createStatement().executeQuery(
        "SELECT s.id,s.tipo,s.estado,s.fecha_solicitud,COALESCE(p.titulo,'Propiedad eliminada') AS prop,u.nombre AS cli,u.apellido AS cli_ap,u.email AS cli_email FROM solicitudes s LEFT JOIN propiedades p ON s.propiedad_id=p.id LEFT JOIN usuarios u ON s.cliente_id=u.id WHERE u.id IS NOT NULL ORDER BY s.fecha_solicitud DESC LIMIT 50");
    while(rs.next()){
        java.util.Map<String,Object> m=new java.util.LinkedHashMap<>();
        m.put("id",rs.getInt("id")); m.put("tipo",rs.getString("tipo")); m.put("estado",rs.getString("estado"));
        m.put("fecha",rs.getString("fecha_solicitud")!=null?rs.getString("fecha_solicitud"):"");
        m.put("prop",rs.getString("prop"));
        m.put("cliente",rs.getString("cli")+" "+rs.getString("cli_ap"));
        m.put("email",rs.getString("cli_email")!=null?rs.getString("cli_email"):"");
        solicitudes.add(m);
    } rs.close();

    db.close();
} catch(Exception ex){
    request.setAttribute("dbError", "Error BD: " + ex.getMessage());
    if(db!=null){try{db.close();}catch(Exception e){}}
}

// Handle POST actions
String flashMsg=null;
if("POST".equalsIgnoreCase(request.getMethod())){
    String action=request.getParameter("action");
    java.sql.Connection db2=null;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        db2=java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8","root","");
        if("aprobar".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE usuarios SET activo=1 WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="✓ Cuenta aprobada.";
        } else if("rechazar".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("DELETE FROM usuarios WHERE id=? AND activo=0");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="Solicitud rechazada.";
        } else if("confirmarCita".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE citas SET estado='confirmada' WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="✓ Cita confirmada.";
        } else if("cancelarCita".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE citas SET estado='cancelada' WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="Cita cancelada.";
        } else if("aprobarSolicitud".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE solicitudes SET estado='aprobada' WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            // Marcar propiedad como vendida/arrendada
            try {
                java.sql.PreparedStatement ps2=db2.prepareStatement(
                    "UPDATE propiedades p JOIN solicitudes s ON p.id=s.propiedad_id SET p.estado=IF(s.tipo='venta','vendido','arrendado') WHERE s.id=?");
                ps2.setInt(1,Integer.parseInt(request.getParameter("id"))); ps2.executeUpdate(); ps2.close();
            } catch(Exception ex2){}
            flashMsg="✓ Solicitud aprobada. Propiedad actualizada.";
        } else if("rechazarSolicitud".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE solicitudes SET estado='rechazada' WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="Solicitud rechazada.";
        } else if("eliminarUsuario".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("DELETE FROM usuarios WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="Usuario eliminado.";
        } else if("toggleActivo".equals(action)){
            java.sql.PreparedStatement ps=db2.prepareStatement("UPDATE usuarios SET activo=1-activo WHERE id=?");
            ps.setInt(1,Integer.parseInt(request.getParameter("id"))); ps.executeUpdate(); ps.close();
            flashMsg="Estado actualizado.";
        }
        db2.close();
    }catch(Exception ex){if(db2!=null){try{db2.close();}catch(Exception e){}}}
    String redir=request.getContextPath()+"/superadmin.jsp?sv=1&tab="+(request.getParameter("tab")!=null?request.getParameter("tab"):"dashboard");
    if(flashMsg!=null) redir+="&msg="+java.net.URLEncoder.encode(flashMsg,"UTF-8");
    response.sendRedirect(redir); return;
}

String tab=request.getParameter("tab"); if(tab==null||tab.isEmpty()) tab="dashboard";

request.setAttribute("pendientes",pendientes);
request.setAttribute("usuarios",usuarios);
request.setAttribute("propiedades",propiedades);
request.setAttribute("citas",citas);
request.setAttribute("solicitudes",solicitudes);
request.setAttribute("totalUsuarios",totalUsuarios);
request.setAttribute("totalPropiedades",totalPropiedades);
request.setAttribute("totalCitas",totalCitas);
request.setAttribute("totalSolicitudes",totalSolicitudes);
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>// SUPERADMIN — InmoVista</title>
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
:root{
  --g:#00ff41; --gd:#00c032; --gdd:#007a1f;
  --bg:#020c02; --bg2:#041004; --bg3:#071807;
  --border:rgba(0,255,65,0.15); --border2:rgba(0,255,65,0.3);
  --cm:rgba(0,255,65,0.45); --cd:rgba(0,255,65,0.08);
}
html,body{min-height:100vh;background:var(--bg);color:var(--g);font-family:'Share Tech Mono',monospace;overflow-x:hidden;}

/* ── Scanlines overlay ── */
body::before{content:'';position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,0,0,0.08) 2px,rgba(0,0,0,0.08) 4px);pointer-events:none;z-index:0;}
body::after{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at center,rgba(0,255,65,0.04) 0%,transparent 70%);pointer-events:none;z-index:0;}

/* ── Glitch title ── */
@keyframes glitch1{0%,100%{clip-path:inset(0 0 95% 0)}20%{clip-path:inset(33% 0 60% 0)}40%{clip-path:inset(70% 0 10% 0)}60%{clip-path:inset(5% 0 80% 0)}80%{clip-path:inset(50% 0 30% 0)}}
@keyframes glitch2{0%,100%{clip-path:inset(0 0 95% 0);transform:translate(-3px,0)}20%{clip-path:inset(40% 0 50% 0);transform:translate(3px,0)}40%{clip-path:inset(80% 0 5% 0);transform:translate(-2px,0)}60%{clip-path:inset(10% 0 75% 0);transform:translate(2px,0)}80%{clip-path:inset(55% 0 25% 0);transform:translate(-1px,0)}}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
@keyframes scanline{0%{transform:translateY(-100%)}100%{transform:translateY(100vh)}}
@keyframes fadeIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
@keyframes pulse-border{0%,100%{box-shadow:0 0 0 0 rgba(0,255,65,0.2)}50%{box-shadow:0 0 0 4px rgba(0,255,65,0.05)}}

/* ── Scanline sweep ── */
.scanline-sweep{position:fixed;top:0;left:0;width:100%;height:3px;background:linear-gradient(90deg,transparent,rgba(0,255,65,0.4),transparent);animation:scanline 4s linear infinite;pointer-events:none;z-index:1;}

/* ── Layout ── */
.sa-layout{display:grid;grid-template-columns:220px 1fr;min-height:100vh;position:relative;z-index:2;}
@media(max-width:900px){.sa-layout{grid-template-columns:1fr;}}

/* ── Sidebar ── */
.sa-sidebar{background:var(--bg2);border-right:1px solid var(--border);padding:0;display:flex;flex-direction:column;position:sticky;top:0;height:100vh;overflow-y:auto;}
@media(max-width:900px){.sa-sidebar{display:none;}}
.sa-brand{padding:24px 20px 20px;border-bottom:1px solid var(--border);margin-bottom:8px;}
.sa-brand-title{font-size:0.65rem;letter-spacing:3px;color:var(--cm);margin-bottom:6px;}
.sa-brand-name{font-size:1.1rem;color:var(--g);font-weight:700;}
.sa-brand-name span{color:var(--gdd);font-size:0.7rem;display:block;margin-top:2px;}
.sa-cursor{animation:blink 1s step-end infinite;color:var(--g);}
.sa-sec{font-size:0.58rem;letter-spacing:3px;color:var(--gdd);padding:12px 20px 4px;}
.sa-lnk{display:flex;align-items:center;gap:10px;padding:10px 20px;font-size:0.8rem;color:var(--cm);text-decoration:none;border-left:2px solid transparent;transition:all .15s;cursor:pointer;background:none;border-top:none;border-right:none;border-bottom:none;width:100%;text-align:left;font-family:'Share Tech Mono',monospace;}
.sa-lnk:hover{color:var(--g);background:var(--cd);border-left-color:var(--gdd);}
.sa-lnk.active{color:var(--g);background:rgba(0,255,65,0.06);border-left-color:var(--g);text-shadow:0 0 8px rgba(0,255,65,0.5);}
.sa-lnk i{width:14px;text-align:center;font-size:0.75rem;}
.sa-bot{margin-top:auto;padding:16px 0;border-top:1px solid var(--border);}
.sa-badge{display:inline-flex;align-items:center;gap:5px;background:rgba(0,255,65,0.08);border:1px solid var(--border2);color:var(--g);padding:2px 8px;border-radius:3px;font-size:0.62rem;letter-spacing:1px;}

/* ── Main ── */
.sa-main{padding:28px;background:var(--bg);}
@media(max-width:768px){.sa-main{padding:16px;}}
.sa-pane{display:none;animation:fadeIn .3s ease;}
.sa-pane.active{display:block;}

/* ── Header bar ── */
.sa-topbar{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px;margin-bottom:28px;padding-bottom:16px;border-bottom:1px solid var(--border);}
.sa-title{font-size:1.4rem;color:var(--g);text-shadow:0 0 12px rgba(0,255,65,0.4);}
.sa-title span{color:var(--cm);font-size:0.7rem;display:block;margin-bottom:2px;letter-spacing:2px;}
.sa-time{font-size:0.72rem;color:var(--cm);}

/* ── KPIs ── */
.sa-kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:24px;}
@media(max-width:900px){.sa-kpis{grid-template-columns:repeat(2,1fr);}}
.sa-kpi{background:var(--bg2);border:1px solid var(--border);border-radius:6px;padding:16px;position:relative;overflow:hidden;animation:pulse-border 3s infinite;}
.sa-kpi::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(0,255,65,0.03),transparent);pointer-events:none;}
.sa-kpi-n{font-size:2rem;font-weight:700;color:var(--g);line-height:1;text-shadow:0 0 16px rgba(0,255,65,0.6);}
.sa-kpi-l{font-size:0.68rem;color:var(--cm);letter-spacing:1px;margin-top:4px;}
.sa-kpi-ic{position:absolute;right:14px;top:14px;font-size:1.3rem;color:rgba(0,255,65,0.1);}

/* ── Cards ── */
.sa-card{background:var(--bg2);border:1px solid var(--border);border-radius:6px;padding:20px;margin-bottom:18px;}
.sa-card-title{font-size:0.72rem;letter-spacing:2px;color:var(--cm);margin-bottom:14px;display:flex;align-items:center;gap:8px;}
.sa-card-title::before{content:'//';color:var(--gdd);}

/* ── Table ── */
.sa-tbl{width:100%;border-collapse:collapse;font-size:0.8rem;}
.sa-tbl th{text-align:left;font-size:0.62rem;letter-spacing:2px;color:var(--gdd);padding:7px 10px;border-bottom:1px solid var(--border);}
.sa-tbl td{padding:10px 10px;border-bottom:1px solid rgba(0,255,65,0.05);vertical-align:middle;}
.sa-tbl tr:hover td{background:rgba(0,255,65,0.03);}
.sa-tbl tr:last-child td{border-bottom:none;}

/* ── Buttons ── */
.btn-g{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;background:rgba(0,255,65,0.08);border:1px solid var(--border2);color:var(--g);font-size:0.75rem;font-family:'Share Tech Mono',monospace;border-radius:4px;cursor:pointer;text-decoration:none;transition:all .15s;}
.btn-g:hover{background:rgba(0,255,65,0.15);color:var(--g);text-shadow:0 0 8px rgba(0,255,65,0.5);box-shadow:0 0 12px rgba(0,255,65,0.15);}
.btn-ok{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;background:rgba(0,255,65,0.08);border:1px solid rgba(0,255,65,0.3);color:var(--g);font-size:0.72rem;font-family:'Share Tech Mono',monospace;border-radius:4px;cursor:pointer;transition:all .15s;}
.btn-ok:hover{background:rgba(0,255,65,0.15);box-shadow:0 0 8px rgba(0,255,65,0.2);}
.btn-d{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;background:rgba(255,0,60,0.08);border:1px solid rgba(255,0,60,0.3);color:#ff003c;font-size:0.72rem;font-family:'Share Tech Mono',monospace;border-radius:4px;cursor:pointer;transition:all .15s;}
.btn-d:hover{background:rgba(255,0,60,0.15);box-shadow:0 0 8px rgba(255,0,60,0.2);}

/* ── Badges ── */
.st{display:inline-flex;align-items:center;padding:2px 8px;border-radius:3px;font-size:0.65rem;letter-spacing:1px;font-family:'Share Tech Mono',monospace;}
.st-ok{background:rgba(0,255,65,0.1);border:1px solid rgba(0,255,65,0.2);color:var(--g);}
.st-warn{background:rgba(255,200,0,0.1);border:1px solid rgba(255,200,0,0.2);color:#ffc800;}
.st-err{background:rgba(255,0,60,0.1);border:1px solid rgba(255,0,60,0.2);color:#ff003c;}
.st-info{background:rgba(0,180,255,0.1);border:1px solid rgba(0,180,255,0.2);color:#00b4ff;}

/* ── Flash ── */
.flash{background:rgba(0,255,65,0.08);border:1px solid var(--border2);color:var(--g);border-radius:4px;padding:10px 16px;margin-bottom:16px;font-size:0.82rem;}

/* ── Pending alert ── */
.pend-alert{background:rgba(255,200,0,0.05);border:1px solid rgba(255,200,0,0.2);border-radius:6px;padding:14px 20px;margin-bottom:20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.pend-alert-txt{font-size:0.8rem;color:#ffc800;}

/* ── Terminal log ── */
.terminal{background:#000;border:1px solid var(--border);border-radius:6px;padding:16px;font-size:0.78rem;line-height:1.8;max-height:220px;overflow-y:auto;}
.terminal .line-ok{color:var(--g);}
.terminal .line-info{color:#00b4ff;}
.terminal .line-warn{color:#ffc800;}
.terminal .prompt{color:var(--gdd);}

/* ── Mobile nav ── */
.sa-mnav{display:none;background:var(--bg2);padding:10px 14px;gap:6px;overflow-x:auto;border-bottom:1px solid var(--border);}
@media(max-width:900px){.sa-mnav{display:flex;}}
.sa-mb{display:flex;align-items:center;gap:5px;padding:6px 12px;background:rgba(0,255,65,0.05);border:1px solid var(--border);border-radius:3px;color:var(--cm);font-size:0.68rem;white-space:nowrap;cursor:pointer;font-family:'Share Tech Mono',monospace;transition:all .15s;}
.sa-mb.active,.sa-mb:hover{background:rgba(0,255,65,0.1);color:var(--g);border-color:var(--border2);}
</style>
</head>
<body>
<div class="scanline-sweep"></div>

<div class="sa-layout">
<%-- ── SIDEBAR ── --%>
<aside class="sa-sidebar">
  <div class="sa-brand">
    <div class="sa-brand-title">> SISTEMA ACTIVO</div>
    <div class="sa-brand-name">
      SUPERADMIN<span>InmoVista v1.0 <span class="sa-cursor">_</span></span>
    </div>
    <div class="mt-2"><span class="sa-badge"><i class="fas fa-circle" style="font-size:0.4rem;color:#00ff41;"></i> ROOT ACCESS</span></div>
  </div>

  <div class="sa-sec">// SISTEMA</div>
  <button class="sa-lnk" onclick="gt('dashboard')" id="sl-dashboard"><i class="fas fa-terminal"></i> Dashboard</button>
  <button class="sa-lnk" onclick="gt('aprobaciones')" id="sl-aprobaciones">
    <i class="fas fa-user-check"></i> Aprobaciones
    <c:if test="${not empty pendientes}"><span style="background:#ffc800;color:#000;font-size:0.58rem;padding:1px 5px;border-radius:2px;margin-left:auto;">${fn:length(pendientes)}</span></c:if>
  </button>

  <div class="sa-sec">// DATOS</div>
  <button class="sa-lnk" onclick="gt('usuarios')" id="sl-usuarios"><i class="fas fa-users"></i> Usuarios</button>
  <button class="sa-lnk" onclick="gt('propiedades')" id="sl-propiedades"><i class="fas fa-home"></i> Propiedades</button>
  <button class="sa-lnk" onclick="gt('citas')" id="sl-citas"><i class="fas fa-calendar"></i> Citas</button>
  <button class="sa-lnk" onclick="gt('solicitudes')" id="sl-solicitudes"><i class="fas fa-file-alt"></i> Solicitudes</button>

  <div class="sa-sec">// ACCESOS</div>
  <a class="sa-lnk" href="${pageContext.request.contextPath}/admin.jsp"><i class="fas fa-shield-alt"></i> Panel Admin</a>
  <a class="sa-lnk" href="${pageContext.request.contextPath}/lista.jsp"><i class="fas fa-eye"></i> Ver Sitio</a>
  <a class="sa-lnk" href="${pageContext.request.contextPath}/reportes.jsp"><i class="fas fa-chart-bar"></i> Reportes</a>

  <div class="sa-bot">
    <a href="${pageContext.request.contextPath}/logout.jsp" class="sa-lnk" style="color:rgba(255,0,60,0.6);"><i class="fas fa-power-off"></i> Terminar sesión</a>
  </div>
</aside>

<div>
  <div class="sa-mnav">
    <button class="sa-mb" id="mb-dashboard"    onclick="gt('dashboard')"><i class="fas fa-terminal"></i> Panel</button>
    <button class="sa-mb" id="mb-aprobaciones" onclick="gt('aprobaciones')"><i class="fas fa-user-check"></i> Aprob.</button>
    <button class="sa-mb" id="mb-usuarios"     onclick="gt('usuarios')"><i class="fas fa-users"></i> Users</button>
    <button class="sa-mb" id="mb-propiedades"  onclick="gt('propiedades')"><i class="fas fa-home"></i> Props</button>
    <button class="sa-mb" id="mb-citas"        onclick="gt('citas')"><i class="fas fa-calendar"></i> Citas</button>
  </div>

  <main class="sa-main">
    <c:if test="${not empty param.msg}"><div class="flash"><i class="fas fa-check me-2"></i>${param.msg}</div></c:if>

    <%-- ══ DASHBOARD ══ --%>
    <div class="sa-pane" id="pane-dashboard">
      <div class="sa-topbar">
        <div>
          <div class="sa-title"><span>> ACCESO RAÍZ</span>PANEL MAESTRO</div>
        </div>
        <div class="sa-time" id="sa-clock"></div>
      </div>

      <c:if test="${not empty pendientes}">
        <div class="pend-alert">
          <div class="pend-alert-txt"><i class="fas fa-exclamation-triangle me-2"></i>${fn:length(pendientes)} cuenta(s) pendientes de aprobación</div>
          <button onclick="gt('aprobaciones')" class="btn-g" style="border-color:rgba(255,200,0,0.3);color:#ffc800;">[ REVISAR ]</button>
        </div>
      </c:if>

      <div class="sa-kpis">
        <div class="sa-kpi"><i class="fas fa-users sa-kpi-ic"></i><div class="sa-kpi-n">${totalUsuarios}</div><div class="sa-kpi-l">USUARIOS</div></div>
        <div class="sa-kpi"><i class="fas fa-home sa-kpi-ic"></i><div class="sa-kpi-n">${totalPropiedades}</div><div class="sa-kpi-l">PROPIEDADES</div></div>
        <div class="sa-kpi"><i class="fas fa-calendar sa-kpi-ic"></i><div class="sa-kpi-n">${totalCitas}</div><div class="sa-kpi-l">CITAS PEND.</div></div>
        <div class="sa-kpi"><i class="fas fa-file-alt sa-kpi-ic"></i><div class="sa-kpi-n">${totalSolicitudes}</div><div class="sa-kpi-l">SOLICITUDES</div></div>
      </div>

      <div class="row g-3">
        <div class="col-lg-6">
          <div class="sa-card">
            <div class="sa-card-title">ACTIVIDAD RECIENTE — CITAS</div>
            <table class="sa-tbl"><thead><tr><th>PROPIEDAD</th><th>CLIENTE</th><th>ESTADO</th></tr></thead><tbody>
            <c:choose>
              <c:when test="${not empty citas}">
                <c:forEach var="c" items="${citas}" begin="0" end="4">
                  <tr>
                    <td style="color:var(--g);">${fn:substring(c.prop,0,22)}${fn:length(c.prop)>22?'...':''}</td>
                    <td style="color:var(--cm);">${c.cliente}</td>
                    <td>
                      <span class="st ${c.estado=='pendiente'?'st-warn':c.estado=='confirmada'?'st-ok':'st-err'}">${c.estado}</span>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise><tr><td colspan="3" style="color:var(--gdd);padding:20px;text-align:center;">// sin datos</td></tr></c:otherwise>
            </c:choose>
            </tbody></table>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="sa-card">
            <div class="sa-card-title">LOG DEL SISTEMA</div>
            <div class="terminal" id="sa-log"></div>
          </div>
        </div>
        <div class="col-12">
          <div class="sa-card">
            <div class="sa-card-title">ÚLTIMOS USUARIOS REGISTRADOS</div>
            <table class="sa-tbl"><thead><tr><th>#ID</th><th>NOMBRE</th><th>EMAIL</th><th>ROL</th><th>ESTADO</th></tr></thead><tbody>
            <c:forEach var="u" items="${usuarios}" begin="0" end="5">
              <tr>
                <td style="color:var(--gdd);">#${u.id}</td>
                <td style="color:var(--g);">${u.nombre} ${u.apellido}</td>
                <td style="color:var(--cm);font-size:0.75rem;">${u.email}</td>
                <td><span class="st st-info">${u.rol}</span></td>
                <td><span class="st ${u.activo?'st-ok':'st-warn'}">${u.activo?'ACTIVO':'PENDIENTE'}</span></td>
              </tr>
            </c:forEach>
            </tbody></table>
          </div>
        </div>
      </div>
    </div>

    <%-- ══ APROBACIONES ══ --%>
    <div class="sa-pane" id="pane-aprobaciones">
      <div class="sa-topbar">
        <div class="sa-title"><span>> CONTROL DE ACCESO</span>APROBACIONES PENDIENTES</div>
      </div>
      <c:choose>
        <c:when test="${not empty pendientes}">
          <div class="row g-3">
            <c:forEach var="p" items="${pendientes}">
              <div class="col-md-6 col-lg-4">
                <div class="sa-card" style="border-color:rgba(255,200,0,0.2);">
                  <div style="font-size:0.65rem;color:var(--gdd);letter-spacing:2px;margin-bottom:10px;">// SOLICITUD #${p.id}</div>
                  <div style="font-size:0.95rem;color:var(--g);margin-bottom:4px;">${p.nombre} ${p.apellido}</div>
                  <div style="font-size:0.75rem;color:var(--cm);margin-bottom:3px;"><i class="fas fa-envelope me-1"></i>${p.email}</div>
                  <div style="font-size:0.72rem;color:var(--gdd);margin-bottom:14px;"><i class="fas fa-clock me-1"></i>${p.fecha}</div>
                  <span class="st st-info" style="margin-bottom:14px;display:inline-block;">${p.rol}</span>
                  <div style="display:flex;gap:8px;margin-top:10px;">
                    <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;">
                      <input type="hidden" name="action" value="aprobar">
                      <input type="hidden" name="id" value="${p.id}">
                      <input type="hidden" name="tab" value="aprobaciones">
                      <button type="submit" class="btn-ok w-100 justify-content-center">[ APROBAR ]</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;" onsubmit="return confirm('Rechazar y eliminar?')">
                      <input type="hidden" name="action" value="rechazar">
                      <input type="hidden" name="id" value="${p.id}">
                      <input type="hidden" name="tab" value="aprobaciones">
                      <button type="submit" class="btn-d w-100 justify-content-center">[ RECHAZAR ]</button>
                    </form>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="sa-card" style="text-align:center;padding:60px 20px;">
            <i class="fas fa-check-circle" style="font-size:2rem;color:var(--g);display:block;margin-bottom:14px;"></i>
            <div style="color:var(--g);font-size:0.9rem;">// SISTEMA LIMPIO</div>
            <div style="color:var(--cm);font-size:0.78rem;margin-top:6px;">No hay solicitudes pendientes.</div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ══ USUARIOS ══ --%>
    <div class="sa-pane" id="pane-usuarios">
      <div class="sa-topbar">
        <div class="sa-title"><span>> BASE DE DATOS</span>TABLA USUARIOS</div>
        <a href="${pageContext.request.contextPath}/usuarios.jsp" class="btn-g"><i class="fas fa-external-link-alt"></i> Módulo completo</a>
      </div>
      <div class="sa-card">
        <table class="sa-tbl"><thead><tr><th>#ID</th><th>NOMBRE</th><th>EMAIL</th><th>ROL</th><th>ESTADO</th><th>OPS</th></tr></thead><tbody>
        <c:forEach var="u" items="${usuarios}">
          <tr>
            <td style="color:var(--gdd);">${u.id}</td>
            <td style="color:var(--g);">${u.nombre} ${u.apellido}</td>
            <td style="color:var(--cm);font-size:0.75rem;">${u.email}</td>
            <td><span class="st st-info">${u.rol}</span></td>
            <td><span class="st ${u.activo?'st-ok':'st-warn'}">${u.activo?'ON':'OFF'}</span></td>
            <td>
              <div style="display:flex;gap:4px;">
                <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="display:contents;">
                  <input type="hidden" name="action" value="toggleActivo">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="tab" value="usuarios">
                  <button type="submit" class="btn-ok" style="padding:3px 8px;font-size:0.65rem;" title="Toggle activo"><i class="fas fa-toggle-on"></i></button>
                </form>
                <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="display:contents;" onsubmit="return confirm('DELETE usuario '+${u.id}+'?')">
                  <input type="hidden" name="action" value="eliminarUsuario">
                  <input type="hidden" name="id" value="${u.id}">
                  <input type="hidden" name="tab" value="usuarios">
                  <button type="submit" class="btn-d" style="padding:3px 8px;font-size:0.65rem;"><i class="fas fa-trash"></i></button>
                </form>
              </div>
            </td>
          </tr>
        </c:forEach>
        </tbody></table>
      </div>
    </div>

    <%-- ══ PROPIEDADES ══ --%>
    <div class="sa-pane" id="pane-propiedades">
      <div class="sa-topbar">
        <div class="sa-title"><span>> BASE DE DATOS</span>TABLA PROPIEDADES</div>
        <a href="${pageContext.request.contextPath}/lista.jsp" class="btn-g"><i class="fas fa-external-link-alt"></i> Ver catálogo</a>
      </div>
      <div class="sa-card">
        <table class="sa-tbl"><thead><tr><th>#ID</th><th>TÍTULO</th><th>TIPO</th><th>OP</th><th>CIUDAD</th><th>ESTADO</th></tr></thead><tbody>
        <c:forEach var="p" items="${propiedades}">
          <tr>
            <td style="color:var(--gdd);">${p.id}</td>
            <td style="color:var(--g);">${fn:substring(p.titulo,0,28)}${fn:length(p.titulo)>28?'...':''}</td>
            <td style="color:var(--cm);font-size:0.75rem;">${p.tipo}</td>
            <td><span class="st st-info">${p.operacion}</span></td>
            <td style="color:var(--cm);font-size:0.75rem;">${p.ciudad}</td>
            <td><span class="st ${p.estado=='disponible'?'st-ok':p.estado=='vendido'?'st-warn':'st-info'}">${p.estado}</span></td>
          </tr>
        </c:forEach>
        </tbody></table>
      </div>
    </div>

    <%-- ══ CITAS ══ --%>
    <div class="sa-pane" id="pane-citas">
      <div class="sa-topbar">
        <div class="sa-title"><span>> GESTIÓN DE VISITAS</span>CITAS AGENDADAS</div>
        <div style="display:flex;gap:8px;font-size:0.72rem;color:var(--cm);">
          <span>TOTAL: ${fn:length(citas)}</span>
          <span style="color:var(--gdd);">|</span>
          <span style="color:#ffc800;">PEND: ${totalCitas}</span>
        </div>
      </div>
      <c:choose>
        <c:when test="${not empty citas}">
          <div class="row g-3">
            <c:forEach var="c" items="${citas}">
              <div class="col-lg-6">
                <div class="sa-card" style="padding:16px;border-color:${c.estado=='pendiente'?'rgba(255,200,0,0.25)':c.estado=='confirmada'?'rgba(0,255,65,0.2)':'rgba(255,0,60,0.15)'};">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                    <div style="font-size:0.62rem;color:var(--gdd);letter-spacing:2px;">// CITA #${c.id}</div>
                    <span class="st ${c.estado=='pendiente'?'st-warn':c.estado=='confirmada'?'st-ok':'st-err'}">${c.estado}</span>
                  </div>
                  <div style="font-size:0.88rem;color:var(--g);margin-bottom:4px;">${c.prop}</div>
                  <div style="font-size:0.75rem;color:var(--cm);margin-bottom:2px;"><i class="fas fa-user me-1"></i>${c.cliente}</div>
                  <div style="font-size:0.72rem;color:var(--cm);margin-bottom:2px;"><i class="fas fa-envelope me-1"></i>${c.email}</div>
                  <div style="font-size:0.72rem;color:var(--gdd);margin-bottom:10px;"><i class="fas fa-clock me-1"></i>${c.fecha}</div>
                  <c:if test="${not empty c.notas}">
                    <div style="font-size:0.72rem;background:rgba(0,255,65,0.04);border:1px solid var(--border);border-radius:3px;padding:6px 10px;color:var(--cm);margin-bottom:10px;">&gt; ${c.notas}</div>
                  </c:if>
                  <c:if test="${c.estado=='pendiente'}">
                    <div style="display:flex;gap:8px;margin-top:8px;">
                      <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;">
                        <input type="hidden" name="action" value="confirmarCita">
                        <input type="hidden" name="id" value="${c.id}">
                        <input type="hidden" name="tab" value="citas">
                        <button type="submit" class="btn-ok w-100 justify-content-center">[ CONFIRMAR ]</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;">
                        <input type="hidden" name="action" value="cancelarCita">
                        <input type="hidden" name="id" value="${c.id}">
                        <input type="hidden" name="tab" value="citas">
                        <button type="submit" class="btn-d w-100 justify-content-center">[ CANCELAR ]</button>
                      </form>
                    </div>
                  </c:if>
                  <c:if test="${c.estado!='pendiente'}">
                    <div style="font-size:0.68rem;color:var(--gdd);margin-top:8px;letter-spacing:1px;">// Procesada — sin acciones disponibles</div>
                  </c:if>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="sa-card" style="text-align:center;padding:60px 20px;">
            <div style="color:var(--gdd);font-size:0.9rem;">// NULL — sin registros</div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ══ SOLICITUDES ══ --%>
    <div class="sa-pane" id="pane-solicitudes">
      <div class="sa-topbar">
        <div class="sa-title"><span>> GESTIÓN DE SOLICITUDES</span>COMPRAS Y ARRIENDOS</div>
        <div style="display:flex;gap:8px;font-size:0.72rem;color:var(--cm);">
          <span>TOTAL: ${fn:length(solicitudes)}</span>
          <span style="color:var(--gdd);">|</span>
          <span style="color:#ffc800;">PEND: ${totalSolicitudes}</span>
        </div>
      </div>
      <c:choose>
        <c:when test="${not empty solicitudes}">
          <div class="row g-3">
            <c:forEach var="s" items="${solicitudes}">
              <div class="col-lg-6">
                <div class="sa-card" style="padding:16px;border-color:${s.estado=='pendiente'?'rgba(255,200,0,0.25)':s.estado=='aprobada'?'rgba(0,255,65,0.2)':'rgba(255,0,60,0.15)'};">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                    <div style="font-size:0.62rem;color:var(--gdd);letter-spacing:2px;">// SOLICITUD #${s.id}</div>
                    <div style="display:flex;gap:5px;align-items:center;">
                      <span class="st st-info">${s.tipo}</span>
                      <span class="st ${s.estado=='pendiente'?'st-warn':s.estado=='aprobada'?'st-ok':'st-err'}">${s.estado}</span>
                    </div>
                  </div>
                  <div style="font-size:0.88rem;color:var(--g);margin-bottom:4px;">${s.prop}</div>
                  <div style="font-size:0.75rem;color:var(--cm);margin-bottom:2px;"><i class="fas fa-user me-1"></i>${s.cliente}</div>
                  <div style="font-size:0.72rem;color:var(--cm);margin-bottom:2px;"><i class="fas fa-envelope me-1"></i>${s.email}</div>
                  <div style="font-size:0.72rem;color:var(--gdd);margin-bottom:10px;"><i class="fas fa-clock me-1"></i>${s.fecha}</div>
                  <c:if test="${s.estado=='pendiente'}">
                    <div style="background:rgba(255,200,0,0.04);border:1px solid rgba(255,200,0,0.15);border-radius:3px;padding:8px 10px;font-size:0.7rem;color:rgba(255,200,0,0.6);margin-bottom:10px;">
                      &gt; Solicitud de <strong style="color:#ffc800;">${s.tipo=='venta'?'COMPRA':'ARRIENDO'}</strong> — pendiente de revisión
                    </div>
                    <div style="display:flex;gap:8px;">
                      <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;">
                        <input type="hidden" name="action" value="aprobarSolicitud">
                        <input type="hidden" name="id" value="${s.id}">
                        <input type="hidden" name="tab" value="solicitudes">
                        <button type="submit" class="btn-ok w-100 justify-content-center">[ APROBAR ]</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/superadmin.jsp?sv=1" method="post" style="flex:1;" onsubmit="return confirm('Rechazar solicitud #${s.id}?')">
                        <input type="hidden" name="action" value="rechazarSolicitud">
                        <input type="hidden" name="id" value="${s.id}">
                        <input type="hidden" name="tab" value="solicitudes">
                        <button type="submit" class="btn-d w-100 justify-content-center">[ RECHAZAR ]</button>
                      </form>
                    </div>
                  </c:if>
                  <c:if test="${s.estado!='pendiente'}">
                    <div style="font-size:0.68rem;color:var(--gdd);margin-top:8px;letter-spacing:1px;">// Procesada — sin acciones disponibles</div>
                  </c:if>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="sa-card" style="text-align:center;padding:60px 20px;">
            <div style="color:var(--gdd);font-size:0.9rem;">// NULL — sin registros</div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </main>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Tab navigation ──
const INIT_TAB = '<%= tab %>';
function gt(name) {
  document.querySelectorAll('.sa-pane').forEach(p=>p.classList.remove('active'));
  const el = document.getElementById('pane-'+name);
  if(el) el.classList.add('active');
  document.querySelectorAll('.sa-lnk[id],  .sa-mb').forEach(l=>l.classList.remove('active'));
  ['sl-','mb-'].forEach(pre=>{ const e=document.getElementById(pre+name); if(e) e.classList.add('active'); });
  const u=new URL(window.location.href); u.searchParams.set('tab',name);
  window.history.replaceState({},'',u);
}
gt(INIT_TAB);

// ── Live clock ──
function updateClock(){
  const now=new Date();
  const pad=n=>String(n).padStart(2,'0');
  document.getElementById('sa-clock').textContent=
    '> '+now.getFullYear()+'/'+pad(now.getMonth()+1)+'/'+pad(now.getDate())+
    ' '+pad(now.getHours())+':'+pad(now.getMinutes())+':'+pad(now.getSeconds());
}
setInterval(updateClock,1000); updateClock();

// ── Terminal log ──
const logs=[
  {t:'info', m:'Sistema InmoVista iniciado'},
  {t:'ok',   m:'Conexion BD establecida'},
  {t:'info', m:'Sesion SUPERADMIN activa'},
  {t:'ok',   m:'${totalUsuarios} usuarios cargados'},
  {t:'ok',   m:'${totalPropiedades} propiedades en BD'},
  {t:'warn', m:'${totalCitas} citas pendientes'},
  {t:'warn', m:'${totalSolicitudes} solicitudes pendientes'},
  {t:'info', m:'Esperando instrucciones...'},
];
const logEl=document.getElementById('sa-log');
function addLog(log,delay){
  setTimeout(()=>{
    const div=document.createElement('div');
    const cls=log.t==='ok'?'line-ok':log.t==='warn'?'line-warn':'line-info';
    const prefix=log.t==='ok'?'[OK]  ':log.t==='warn'?'[WARN]':'[INFO]';
    div.innerHTML='<span class="prompt">root@inmovista:~$ </span><span class="'+cls+'">'+prefix+' '+log.m+'</span>';
    logEl.appendChild(div);
    logEl.scrollTop=logEl.scrollHeight;
  },delay);
}
logs.forEach((l,i)=>addLog(l, i*280));
</script>
</body>
</html>
