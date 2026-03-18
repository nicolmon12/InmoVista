<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Tomcat 8.5: configurar Java 1.8 en conf/web.xml si hay lambdas --%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════════
   CLIENTE.JSP  ·  InmoVista
   Maneja GET (mostrar dashboard) y POST (acciones del cliente).
   En producción las acciones POST van a cliente.jsp con JDBC.
   En modo demo se guardan en la sesión HTTP.
═══════════════════════════════════════════════════════ */

// ── Protección de sesión ──────────────────────────────
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolActual = (String) session.getAttribute("rolNombre");
if (!"cliente".equals(rolActual)) {
    response.sendRedirect(request.getContextPath() + "/" + rolActual + ".jsp");
    return;
}

// ── Obtener userId de la sesión ───────────────────────
int userId = 0;
Object _uidObj = session.getAttribute("userId");
if (_uidObj instanceof Integer) {
    userId = (Integer) _uidObj;
} else if (session.getAttribute("usuario") instanceof java.util.Map) {
    Object _idO = ((java.util.Map<?,?>)session.getAttribute("usuario")).get("id");
    if (_idO instanceof Integer) userId = (Integer) _idO;
}

// ── Inicializar listas en sesión si no existen ─────────
if (session.getAttribute("misCitas") == null) {
    session.setAttribute("misCitas", new java.util.ArrayList<java.util.Map<String,Object>>());
}
if (session.getAttribute("misSolicitudes") == null) {
    session.setAttribute("misSolicitudes", new java.util.ArrayList<java.util.Map<String,Object>>());
}
if (session.getAttribute("misFavoritos") == null) {
    session.setAttribute("misFavoritos", new java.util.ArrayList<java.util.Map<String,Object>>());
}

// ── Listado de 12 propiedades demo para mostrar en el select ──
String[] propIds    = {"1","2","3","4","5","6","7","8","9","10","11","12"};
String[] propTitles = {
    "Casa Moderna en Cabecera","Apto Exclusivo Lagos del Cacique",
    "Oficina Centro Empresarial","Casa Campestre Floridablanca",
    "Apartamento Amoblado Sotomayor","Penthouse Vista Panorámica BGA",
    "Casa Conjunto Cerrado Girón","Apartamento Nuevo El Jardín",
    "Terreno Urbanizable Piedecuesta","Local Comercial Cabecera",
    "Apartamento VIS Morrorico","Mansión Exclusiva Lagos del Cacique"
};
String[] propOps    = {
    "venta","venta","arriendo","venta","arriendo","venta",
    "venta","arriendo","venta","arriendo","venta","venta"
};
String[] propPrecios = {
    "$420.000.000","$280.000.000","$2.800.000/mes","$950.000.000",
    "$1.500.000/mes","$680.000.000","$380.000.000","$3.500.000/mes",
    "$550.000.000","$4.200.000/mes","$195.000.000","$1.200.000.000"
};
String[] propCiudades = {
    "Bucaramanga","Bucaramanga","Bucaramanga","Floridablanca",
    "Bucaramanga","Bucaramanga","Girón","Bucaramanga",
    "Piedecuesta","Bucaramanga","Bucaramanga","Bucaramanga"
};
String[] propFotos = {
    "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=300&q=60",
    "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=300&q=60",
    "https://images.unsplash.com/photo-1497366216548-37526070297c?w=300&q=60",
    "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&q=60",
    "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=300&q=60",
    "https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=300&q=60",
    "https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=300&q=60",
    "https://images.unsplash.com/photo-1554995207-c18c203602cb?w=300&q=60",
    "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=300&q=60",
    "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=300&q=60",
    "https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=300&q=60",
    "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=300&q=60"
};

// ── Helper: buscar título de propiedad por ID ──────────
java.util.Map<String,String[]> propMap = new java.util.LinkedHashMap<String,String[]>();
for (int pi = 0; pi < propIds.length; pi++) {
    propMap.put(propIds[pi], new String[]{propTitles[pi], propOps[pi], propPrecios[pi], propCiudades[pi], propFotos[pi]});
}
request.setAttribute("propMap", propMap);

// Pasar listas de propiedades al request para el select de agendar
java.util.List<java.util.Map<String,Object>> listaPropDemo = new java.util.ArrayList<java.util.Map<String,Object>>();
for (int pi2 = 0; pi2 < propIds.length; pi2++) {
    java.util.Map<String,Object> pm = new java.util.LinkedHashMap<String,Object>();
    pm.put("id",        propIds[pi2]);
    pm.put("titulo",    propTitles[pi2]);
    pm.put("operacion", propOps[pi2]);
    pm.put("precio",    propPrecios[pi2]);
    listaPropDemo.add(pm);
}
request.setAttribute("propiedades", listaPropDemo);

// ── JDBC helper: obtener conexion ──────────────────────
java.sql.Connection _dbCon = null;
final String _JDBC_URL = "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    _dbCon = java.sql.DriverManager.getConnection(_JDBC_URL, "root", "");
} catch (Exception _dbErr) {
    _dbCon = null; // BD no disponible - modo sesion
}

// ── HANDLER POST ───────────────────────────────────────
String flashMsg = null;
String flashErr = null;
String redirectTab = "dashboard";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    if (action == null) action = "";

    // ── AGENDAR CITA ───────────────────────────────────
    if ("agendarCita".equals(action)) {
        String propId   = request.getParameter("propiedadId");
        String fecha    = request.getParameter("fechaCita");
        String hora     = request.getParameter("horaCita");
        String notas    = request.getParameter("notas");
        String tipoSol  = request.getParameter("tipoSolicitud");

        if (propId == null || propId.trim().isEmpty() || fecha == null || fecha.trim().isEmpty()) {
            flashErr    = "Por favor selecciona una propiedad y una fecha.";
            redirectTab = "agendar";
        } else {
            String fechaCompleta = fecha;
            if (hora != null && !hora.isEmpty()) fechaCompleta = fecha + " " + hora + ":00";

            String[] pd = propMap.get(propId.trim());
            String propTitulo = (pd != null) ? pd[0] : "Propiedad #" + propId;
            String propCiud   = (pd != null) ? pd[3] : "Bucaramanga";

            // ── Guardar en BD ──
            int citaDbId = 0;
            if (_dbCon != null) {
                try {
                    java.sql.PreparedStatement ps = _dbCon.prepareStatement(
                        "INSERT INTO citas (cliente_id, propiedad_id, agente_id, fecha_cita, notas, estado, fecha_solicitud) VALUES (?,?,NULL,?,?,'pendiente',NOW())",
                        java.sql.Statement.RETURN_GENERATED_KEYS);
                    ps.setInt(1, userId);
                    try { ps.setInt(2, Integer.parseInt(propId.trim())); } catch(Exception e){ ps.setInt(2,0); }
                    ps.setString(3, fechaCompleta);
                    ps.setString(4, notas != null ? notas.trim() : "");
                    ps.executeUpdate();
                    java.sql.ResultSet gk = ps.getGeneratedKeys();
                    if (gk.next()) citaDbId = gk.getInt(1);
                    gk.close(); ps.close();
                } catch (Exception dbEx) { citaDbId = 0; }
            }

            // ── Guardar en sesion (siempre) ──
            java.util.Map<String,Object> cita = new java.util.LinkedHashMap<String,Object>();
            cita.put("id",              citaDbId > 0 ? String.valueOf(citaDbId) : "C" + System.currentTimeMillis());
            cita.put("propiedadId",     propId);
            cita.put("propiedadTitulo", propTitulo);
            cita.put("propiedadCiudad", propCiud);
            cita.put("fechaCita",       fechaCompleta);
            cita.put("notas",           notas != null ? notas : "");
            cita.put("estado",          "pendiente");

            @SuppressWarnings("unchecked")
            java.util.List<java.util.Map<String,Object>> citas =
                (java.util.List<java.util.Map<String,Object>>) session.getAttribute("misCitas");
            citas.add(0, cita);
            session.setAttribute("misCitas", citas);

            flashMsg    = "Visita agendada para " + propTitulo + " el " + fechaCompleta + ". La inmobiliaria confirmara pronto.";
            redirectTab = "citas";
        }
    }

    // ── SOLICITAR COMPRA / ARRIENDO ────────────────────
    else if ("solicitarOperacion".equals(action)) {
        String propId = request.getParameter("propiedadId");
        String tipo   = request.getParameter("tipo");

        if (propId == null || propId.trim().isEmpty()) {
            flashErr    = "No se pudo identificar la propiedad.";
            redirectTab = "solicitudes";
        } else {
            String[] pd2 = propMap.get(propId.trim());
            String propTitulo2 = (pd2 != null) ? pd2[0] : "Propiedad #" + propId;

            // ── Guardar en BD ──
            if (_dbCon != null) {
                try {
                    java.sql.PreparedStatement ps2 = _dbCon.prepareStatement(
                        "INSERT INTO solicitudes (cliente_id, propiedad_id, agente_id, tipo, estado, fecha_solicitud) VALUES (?,?,NULL,?,'pendiente',NOW())");
                    ps2.setInt(1, userId);
                    try { ps2.setInt(2, Integer.parseInt(propId.trim())); } catch(Exception e){ ps2.setInt(2,0); }
                    ps2.setString(3, tipo != null ? tipo : "venta");
                    ps2.executeUpdate(); ps2.close();
                } catch (Exception dbEx) {}
            }

            // ── Guardar en sesion ──
            java.util.Map<String,Object> sol = new java.util.LinkedHashMap<String,Object>();
            sol.put("id",              "S" + System.currentTimeMillis());
            sol.put("propiedadId",     propId);
            sol.put("propiedadTitulo", propTitulo2);
            sol.put("tipo",            tipo != null ? tipo : "venta");
            sol.put("estado",          "pendiente");
            sol.put("fechaSolicitud",  new java.util.Date());

            @SuppressWarnings("unchecked")
            java.util.List<java.util.Map<String,Object>> sols =
                (java.util.List<java.util.Map<String,Object>>) session.getAttribute("misSolicitudes");
            sols.add(0, sol);
            session.setAttribute("misSolicitudes", sols);

            String tipoStr = "venta".equals(tipo) ? "Compra" : "Arriendo";
            flashMsg    = "Solicitud de " + tipoStr + " enviada para " + propTitulo2 + ". El agente se pondra en contacto.";
            redirectTab = "solicitudes";
        }
    }

    // ── CANCELAR CITA ──────────────────────────────────
    else if ("cancelarCita".equals(action)) {
        String citaId = request.getParameter("citaId");
        @SuppressWarnings("unchecked")
        java.util.List<java.util.Map<String,Object>> citas2 =
            (java.util.List<java.util.Map<String,Object>>) session.getAttribute("misCitas");
        for (java.util.Map<String,Object> c : citas2) {
            if (citaId != null && citaId.equals(c.get("id"))) {
                c.put("estado", "cancelada");
                break;
            }
        }
        flashMsg    = "Cita cancelada correctamente.";
        redirectTab = "citas";
    }

    // ── AGREGAR FAVORITO ───────────────────────────────
    else if ("agregarFavorito".equals(action)) {
        String propId = request.getParameter("propiedadId");
        if (propId != null && !propId.trim().isEmpty()) {
            String[] pd3 = propMap.get(propId.trim());
            if (pd3 != null) {
                // Verificar que no esté ya en favoritos
                @SuppressWarnings("unchecked")
                java.util.List<java.util.Map<String,Object>> favs =
                    (java.util.List<java.util.Map<String,Object>>) session.getAttribute("misFavoritos");
                boolean yaExiste = false;
                for (java.util.Map<String,Object> fv : favs) {
                    if (propId.equals(fv.get("id"))) { yaExiste = true; break; }
                }
                if (!yaExiste) {
                    java.util.Map<String,Object> fav = new java.util.LinkedHashMap<String,Object>();
                    fav.put("id",           propId);
                    fav.put("titulo",       pd3[0]);
                    fav.put("operacion",    pd3[1]);
                    fav.put("precio",       pd3[2]);
                    fav.put("ciudad",       pd3[3]);
                    fav.put("fotoPrincipal",pd3[4]);
                    favs.add(0, fav);
                    session.setAttribute("misFavoritos", favs);
                    flashMsg = "✓ " + pd3[0] + " guardada en tus favoritos.";
                } else {
                    flashMsg = "Esta propiedad ya está en tus favoritos.";
                }
            }
        }
        redirectTab = "favoritos";
    }

    // ── QUITAR FAVORITO ────────────────────────────────
    else if ("quitarFavorito".equals(action)) {
        String propId = request.getParameter("propiedadId");
        @SuppressWarnings("unchecked")
        java.util.List<java.util.Map<String,Object>> favs2 =
            (java.util.List<java.util.Map<String,Object>>) session.getAttribute("misFavoritos");
        java.util.Iterator<java.util.Map<String,Object>> it = favs2.iterator();
        while (it.hasNext()) {
            java.util.Map<String,Object> fItem = it.next();
            if (propId != null && propId.equals(fItem.get("id"))) { it.remove(); }
        }
        session.setAttribute("misFavoritos", favs2);
        flashMsg    = "Propiedad eliminada de favoritos.";
        redirectTab = "favoritos";
    }

    // ── ACTUALIZAR PERFIL ──────────────────────────────
    else if ("actualizarPerfil".equals(action)) {
        String nombre2   = request.getParameter("nombre");
        String apellido2 = request.getParameter("apellido");
        String email2    = request.getParameter("email");
        String tel2      = request.getParameter("telefono");

        @SuppressWarnings("unchecked")
        java.util.Map<String,Object> user =
            (java.util.Map<String,Object>) session.getAttribute("usuario");
        if (nombre2 != null && !nombre2.trim().isEmpty()) user.put("nombre",   nombre2.trim());
        if (apellido2 != null && !apellido2.trim().isEmpty()) user.put("apellido", apellido2.trim());
        if (email2 != null && !email2.trim().isEmpty()) user.put("email",    email2.trim());
        if (tel2 != null) user.put("telefono", tel2.trim());
        session.setAttribute("usuario", user);

        flashMsg    = "✓ Perfil actualizado correctamente.";
        redirectTab = "perfil";
    }

    // ── POST-REDIRECT-GET ──
    if (_dbCon != null) { try { _dbCon.close(); } catch(Exception e){} }
    String redirectUrl = request.getContextPath() + "/cliente.jsp?tab=" + redirectTab;
    if (flashMsg != null) redirectUrl += "&msg=" + java.net.URLEncoder.encode(flashMsg, "UTF-8");
    if (flashErr != null) redirectUrl += "&err=" + java.net.URLEncoder.encode(flashErr, "UTF-8");
    response.sendRedirect(redirectUrl);
    return;
}

// ── GET: cargar datos desde BD (si disponible) o sesion ─
if (_dbCon != null && userId > 0) {
    try {
        // Cargar citas del usuario desde BD
        java.sql.PreparedStatement psCitas = _dbCon.prepareStatement(
            "SELECT c.id, c.propiedad_id, p.titulo AS prop_titulo, p.ciudad AS prop_ciudad, " +
            "c.fecha_cita, c.notas, c.estado " +
            "FROM citas c LEFT JOIN propiedades p ON c.propiedad_id=p.id " +
            "WHERE c.cliente_id=? ORDER BY c.fecha_cita DESC");
        psCitas.setInt(1, userId);
        java.sql.ResultSet rsCitas = psCitas.executeQuery();
        java.util.List<java.util.Map<String,Object>> citasDB = new java.util.ArrayList<java.util.Map<String,Object>>();
        while (rsCitas.next()) {
            java.util.Map<String,Object> cm = new java.util.LinkedHashMap<String,Object>();
            cm.put("id",              String.valueOf(rsCitas.getInt("id")));
            cm.put("propiedadId",     String.valueOf(rsCitas.getInt("propiedad_id")));
            cm.put("propiedadTitulo", rsCitas.getString("prop_titulo") != null ? rsCitas.getString("prop_titulo") : "Propiedad #"+rsCitas.getInt("propiedad_id"));
            cm.put("propiedadCiudad", rsCitas.getString("prop_ciudad") != null ? rsCitas.getString("prop_ciudad") : "");
            cm.put("fechaCita",       rsCitas.getString("fecha_cita") != null ? rsCitas.getString("fecha_cita") : "");
            cm.put("notas",           rsCitas.getString("notas") != null ? rsCitas.getString("notas") : "");
            cm.put("estado",          rsCitas.getString("estado") != null ? rsCitas.getString("estado") : "pendiente");
            citasDB.add(cm);
        }
        rsCitas.close(); psCitas.close();
        // Solo reemplazar sesion si BD devolvio resultados
        // Si esta vacio puede ser que el INSERT fallo - conservar sesion
        if (!citasDB.isEmpty()) {
            session.setAttribute("misCitas", citasDB);
        }

        // Cargar solicitudes desde BD
        java.sql.PreparedStatement psSols = _dbCon.prepareStatement(
            "SELECT s.id, s.propiedad_id, p.titulo AS prop_titulo, s.tipo, s.estado, s.fecha_solicitud " +
            "FROM solicitudes s LEFT JOIN propiedades p ON s.propiedad_id=p.id " +
            "WHERE s.cliente_id=? ORDER BY s.fecha_solicitud DESC");
        psSols.setInt(1, userId);
        java.sql.ResultSet rsSols = psSols.executeQuery();
        java.util.List<java.util.Map<String,Object>> solsDB = new java.util.ArrayList<java.util.Map<String,Object>>();
        while (rsSols.next()) {
            java.util.Map<String,Object> sm = new java.util.LinkedHashMap<String,Object>();
            sm.put("id",              String.valueOf(rsSols.getInt("id")));
            sm.put("propiedadId",     String.valueOf(rsSols.getInt("propiedad_id")));
            sm.put("propiedadTitulo", rsSols.getString("prop_titulo") != null ? rsSols.getString("prop_titulo") : "Propiedad #"+rsSols.getInt("propiedad_id"));
            sm.put("tipo",            rsSols.getString("tipo") != null ? rsSols.getString("tipo") : "venta");
            sm.put("estado",          rsSols.getString("estado") != null ? rsSols.getString("estado") : "pendiente");
            sm.put("fechaSolicitud",  rsSols.getString("fecha_solicitud") != null ? rsSols.getString("fecha_solicitud") : "");
            solsDB.add(sm);
        }
        rsSols.close(); psSols.close();
        if (!solsDB.isEmpty()) {
            session.setAttribute("misSolicitudes", solsDB);
        }

        // Cargar favoritos desde BD
        java.sql.PreparedStatement psFavs = _dbCon.prepareStatement(
            "SELECT f.propiedad_id, p.titulo, p.operacion, p.precio, p.ciudad " +
            "FROM favoritos f LEFT JOIN propiedades p ON f.propiedad_id=p.id " +
            "WHERE f.cliente_id=? ORDER BY f.fecha_guardado DESC");
        psFavs.setInt(1, userId);
        java.sql.ResultSet rsFavs = psFavs.executeQuery();
        java.util.List<java.util.Map<String,Object>> favsDB = new java.util.ArrayList<java.util.Map<String,Object>>();
        while (rsFavs.next()) {
            java.util.Map<String,Object> fm = new java.util.LinkedHashMap<String,Object>();
            fm.put("id",           String.valueOf(rsFavs.getInt("propiedad_id")));
            fm.put("titulo",       rsFavs.getString("titulo") != null ? rsFavs.getString("titulo") : "Propiedad");
            fm.put("operacion",    rsFavs.getString("operacion") != null ? rsFavs.getString("operacion") : "venta");
            fm.put("precio",       rsFavs.getString("precio") != null ? "$"+rsFavs.getString("precio") : "");
            fm.put("ciudad",       rsFavs.getString("ciudad") != null ? rsFavs.getString("ciudad") : "");
            fm.put("fotoPrincipal","https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=300&q=60");
            favsDB.add(fm);
        }
        rsFavs.close(); psFavs.close();
        session.setAttribute("misFavoritos", favsDB);

        _dbCon.close();
    } catch (Exception dbLoadEx) {
        if (_dbCon != null) { try { _dbCon.close(); } catch(Exception e){} }
    }
}

request.setAttribute("misCitas",        session.getAttribute("misCitas"));
request.setAttribute("misSolicitudes",  session.getAttribute("misSolicitudes"));
request.setAttribute("misFavoritos",    session.getAttribute("misFavoritos"));

String tab = request.getParameter("tab");
if (tab == null || tab.isEmpty()) tab = "dashboard";
%>
<c:set var="pageTitle" value="Dashboard Cliente" scope="request"/>
<c:set var="u" value="${sessionScope.usuario}" scope="page"/>
<%@ include file="header.jsp" %>

<style>
:root{--cg:#c9a84c;--cd:#0d0d0d;--cb:#e8e5df;--cs:#f8f7f5;--cm:#9a9590;}
.cl-layout{display:grid;grid-template-columns:240px 1fr;min-height:calc(100vh - 72px);background:var(--cs);}
@media(max-width:900px){.cl-layout{grid-template-columns:1fr;}}
.cl-sidebar{background:var(--cd);padding:20px 0;position:sticky;top:72px;height:calc(100vh - 72px);overflow-y:auto;display:flex;flex-direction:column;}
@media(max-width:900px){.cl-sidebar{display:none;}}
.cl-sb-user{padding:0 16px 20px;border-bottom:1px solid rgba(255,255,255,0.07);margin-bottom:10px;}
.cl-sb-av{width:48px;height:48px;background:linear-gradient(135deg,#c9a84c,#e8c96b);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.2rem;font-weight:900;color:#000;margin-bottom:8px;}
.cl-sb-name{font-weight:700;color:#fff;font-size:0.9rem;}
.cl-sb-role{font-size:0.62rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:var(--cg);}
.cl-sb-sec{font-size:0.58rem;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,0.2);padding:10px 16px 4px;}
.cl-sb-lnk{display:flex;align-items:center;gap:10px;padding:10px 16px;font-size:0.84rem;font-weight:500;color:rgba(255,255,255,0.4);text-decoration:none;border-left:3px solid transparent;transition:all .2s;cursor:pointer;background:none;border-top:none;border-right:none;border-bottom:none;width:100%;text-align:left;font-family:inherit;}
.cl-sb-lnk:hover{color:#fff;background:rgba(255,255,255,0.04);}
.cl-sb-lnk.active{color:var(--cg);background:rgba(201,168,76,0.08);border-left-color:var(--cg);}
.cl-sb-lnk i{width:16px;text-align:center;font-size:0.82rem;}
.cl-sb-bot{margin-top:auto;padding:14px 0;border-top:1px solid rgba(255,255,255,0.07);}
.cl-mnav{display:none;background:var(--cd);padding:10px 14px;gap:6px;overflow-x:auto;border-bottom:1px solid rgba(255,255,255,0.07);}
@media(max-width:900px){.cl-mnav{display:flex;}}
.cl-mb{display:flex;align-items:center;gap:5px;padding:7px 12px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.08);border-radius:100px;color:rgba(255,255,255,0.4);font-size:0.72rem;font-weight:600;white-space:nowrap;cursor:pointer;text-decoration:none;transition:all .2s;border-top:none;}
.cl-mb.active,.cl-mb:hover{background:rgba(201,168,76,0.12);border:1px solid rgba(201,168,76,0.3);color:var(--cg);}
.cl-main{padding:28px;}
@media(max-width:768px){.cl-main{padding:16px;}}
.cl-pane{display:none;} .cl-pane.active{display:block;}
.cl-phdr{display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;margin-bottom:24px;}
.cl-ptitle{font-family:'Playfair Display',serif;font-size:1.7rem;font-weight:900;color:var(--cd);}
.cl-psub{font-size:0.82rem;color:var(--cm);margin-top:2px;}
.cl-kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
@media(max-width:900px){.cl-kpis{grid-template-columns:repeat(2,1fr);}}
.cl-kpi{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:18px;display:flex;align-items:center;gap:14px;box-shadow:0 2px 8px rgba(0,0,0,0.04);}
.cl-kpi-ic{width:44px;height:44px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.cl-kpi-n{font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;color:var(--cd);line-height:1;}
.cl-kpi-l{font-size:0.72rem;color:var(--cm);margin-top:1px;}
.cl-card{background:#fff;border:1px solid var(--cb);border-radius:14px;padding:22px;box-shadow:0 2px 8px rgba(0,0,0,0.04);}
.cl-ct{display:flex;align-items:center;gap:9px;font-family:'Playfair Display',serif;font-size:1.05rem;font-weight:700;color:var(--cd);margin-bottom:3px;}
.cl-ct i{color:var(--cg);}
.cl-cs{font-size:0.76rem;color:var(--cm);margin-bottom:18px;}
.cl-bg{display:inline-flex;align-items:center;gap:7px;padding:9px 18px;background:linear-gradient(135deg,#c9a84c,#e8c96b);color:#000;font-weight:700;font-size:0.82rem;border:none;border-radius:9px;cursor:pointer;text-decoration:none;transition:all .25s;}
.cl-bg:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(201,168,76,0.35);color:#000;}
.cl-bo{display:inline-flex;align-items:center;gap:7px;padding:8px 16px;background:transparent;color:var(--cd);font-weight:600;font-size:0.8rem;border:1.5px solid var(--cb);border-radius:9px;cursor:pointer;text-decoration:none;transition:all .25s;}
.cl-bo:hover{border-color:var(--cg);color:var(--cg);}
.cl-bd{display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:transparent;color:#e74c3c;font-weight:600;font-size:0.76rem;border:1.5px solid rgba(231,76,60,0.3);border-radius:8px;cursor:pointer;text-decoration:none;transition:all .2s;}
.cl-bd:hover{background:rgba(231,76,60,0.08);}
.st{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;border-radius:100px;font-size:0.7rem;font-weight:700;}
.st-pendiente{background:#fff3cd;color:#856404;} .st-confirmada{background:#d1e7dd;color:#0f5132;}
.st-cancelada{background:#f8d7da;color:#842029;} .st-venta{background:rgba(201,168,76,0.12);color:#7a5d0f;}
.st-arriendo{background:rgba(41,182,246,0.12);color:#055a7a;} .st-disponible{background:#d1e7dd;color:#0f5132;}
.cl-tbl{width:100%;border-collapse:collapse;}
.cl-tbl th{text-align:left;font-size:0.7rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:var(--cm);padding:8px 10px;border-bottom:2px solid var(--cb);}
.cl-tbl td{padding:12px 10px;border-bottom:1px solid var(--cb);font-size:0.84rem;}
.cl-tbl tr:last-child td{border-bottom:none;}
.cl-tbl tr:hover td{background:var(--cs);}
.cl-empty{text-align:center;padding:48px 20px;}
.cl-empty i{font-size:2.2rem;color:var(--cb);margin-bottom:14px;display:block;}
.cl-empty h6{font-family:'Playfair Display',serif;font-size:1rem;color:var(--cm);margin-bottom:5px;}
.cl-empty p{font-size:0.8rem;color:var(--cm);margin-bottom:18px;}
.cl-fc{width:100%;padding:10px 13px;border:1.5px solid var(--cb);border-radius:9px;font-family:inherit;font-size:0.86rem;color:var(--cd);background:var(--cs);outline:none;transition:border-color .2s;}
.cl-fc:focus{border-color:var(--cg);background:#fff;}
.cl-fl{font-size:0.72rem;font-weight:700;color:var(--cm);margin-bottom:5px;display:block;}
.cl-wiz{display:flex;gap:12px;align-items:flex-start;padding:12px 0;border-bottom:1px solid var(--cb);}
.cl-wiz:last-child{border:none;}
.cl-wn{width:32px;height:32px;border-radius:50%;background:var(--cd);color:var(--cg);display:flex;align-items:center;justify-content:center;font-weight:900;font-size:0.86rem;flex-shrink:0;}
.cl-wn.done{background:#0f5132;color:#fff;}
</style>

<%-- Sidebar --%>
<div class="cl-layout">
<aside class="cl-sidebar">
  <div class="cl-sb-user">
    <div class="cl-sb-av">${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}</div>
    <div class="cl-sb-name">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</div>
    <div class="cl-sb-role"><i class="fas fa-user me-1"></i> Cliente</div>
  </div>
  <div class="cl-sb-sec">Principal</div>
  <button class="cl-sb-lnk" onclick="gt('dashboard')" id="sl-dashboard"><i class="fas fa-th-large"></i> Mi Dashboard</button>
  <div class="cl-sb-sec">Propiedades</div>
  <a class="cl-sb-lnk" href="${ctx}/lista.jsp"><i class="fas fa-search"></i> Buscar Propiedades</a>
  <button class="cl-sb-lnk" onclick="gt('favoritos')" id="sl-favoritos"><i class="fas fa-heart"></i> Mis Favoritos</button>
  <div class="cl-sb-sec">Mis Gestiones</div>
  <button class="cl-sb-lnk" onclick="gt('citas')" id="sl-citas"><i class="fas fa-calendar-check"></i> Mis Citas</button>
  <button class="cl-sb-lnk" onclick="gt('solicitudes')" id="sl-solicitudes"><i class="fas fa-file-alt"></i> Mis Solicitudes</button>
  <button class="cl-sb-lnk" onclick="gt('agendar')" id="sl-agendar"><i class="fas fa-calendar-plus"></i> Agendar Visita</button>
  <div class="cl-sb-sec">Cuenta</div>
  <button class="cl-sb-lnk" onclick="gt('documentos')" id="sl-documentos"><i class="fas fa-folder-open"></i> Mis Documentos</button>
  <button class="cl-sb-lnk" onclick="gt('perfil')" id="sl-perfil"><i class="fas fa-user-cog"></i> Mi Perfil</button>
  <div class="cl-sb-bot">
    <a href="${ctx}/logout.jsp" class="cl-sb-lnk" style="color:rgba(231,76,60,0.7);"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
  </div>
</aside>

<div>
  <%-- Mobile nav --%>
  <div class="cl-mnav">
    <button class="cl-mb" id="mb-dashboard" onclick="gt('dashboard')"><i class="fas fa-th-large"></i> Panel</button>
    <button class="cl-mb" id="mb-citas"      onclick="gt('citas')"><i class="fas fa-calendar-check"></i> Citas</button>
    <button class="cl-mb" id="mb-solicitudes" onclick="gt('solicitudes')"><i class="fas fa-file-alt"></i> Solicitudes</button>
    <button class="cl-mb" id="mb-favoritos"  onclick="gt('favoritos')"><i class="fas fa-heart"></i> Favoritos</button>
    <button class="cl-mb" id="mb-agendar"    onclick="gt('agendar')"><i class="fas fa-plus"></i> Agendar</button>
    <button class="cl-mb" id="mb-documentos" onclick="gt('documentos')"><i class="fas fa-folder"></i> Docs</button>
    <button class="cl-mb" id="mb-perfil"     onclick="gt('perfil')"><i class="fas fa-user"></i> Perfil</button>
  </div>

  <main class="cl-main">
    <%-- Flash messages --%>
    <c:if test="${not empty param.msg}">
      <div style="background:#d1e7dd;color:#0f5132;border:1px solid #a3cfbb;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;">
        <i class="fas fa-check-circle"></i> ${param.msg}
      </div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div style="background:#f8d7da;color:#842029;border:1px solid #f1aeb5;border-radius:10px;padding:11px 16px;margin-bottom:18px;font-size:0.86rem;display:flex;align-items:center;gap:8px;">
        <i class="fas fa-exclamation-circle"></i> ${param.err}
      </div>
    </c:if>

    <%-- ══ DASHBOARD ══ --%>
    <div class="cl-pane" id="pane-dashboard">
      <div class="cl-phdr">
        <div>
          <div class="cl-ptitle">Hola, ${sessionScope.usuario.nombre} 👋</div>
          <div class="cl-psub">Resumen de tu actividad en InmoVista</div>
        </div>
        <a href="${ctx}/lista.jsp" class="cl-bg"><i class="fas fa-search"></i> Explorar</a>
      </div>
      <div class="cl-kpis">
        <div class="cl-kpi"><div class="cl-kpi-ic" style="background:rgba(201,168,76,0.12);color:var(--cg);"><i class="fas fa-calendar-check"></i></div><div><div class="cl-kpi-n">${not empty misCitas?fn:length(misCitas):'0'}</div><div class="cl-kpi-l">Citas</div></div></div>
        <div class="cl-kpi"><div class="cl-kpi-ic" style="background:rgba(52,152,219,0.12);color:#3498db;"><i class="fas fa-file-signature"></i></div><div><div class="cl-kpi-n">${not empty misSolicitudes?fn:length(misSolicitudes):'0'}</div><div class="cl-kpi-l">Solicitudes</div></div></div>
        <div class="cl-kpi"><div class="cl-kpi-ic" style="background:rgba(231,76,60,0.12);color:#e74c3c;"><i class="fas fa-heart"></i></div><div><div class="cl-kpi-n">${not empty misFavoritos?fn:length(misFavoritos):'0'}</div><div class="cl-kpi-l">Favoritos</div></div></div>
        <div class="cl-kpi"><div class="cl-kpi-ic" style="background:rgba(39,174,96,0.12);color:#27ae60;"><i class="fas fa-home"></i></div><div><div class="cl-kpi-n">${not empty totalPropDisp?totalPropDisp:'60'}</div><div class="cl-kpi-l">Disponibles</div></div></div>
      </div>
      <div class="row g-4">
        <div class="col-lg-6">
          <div class="cl-card">
            <div class="cl-ct"><i class="fas fa-calendar-alt"></i> Próximas Citas</div>
            <div class="cl-cs">Tus visitas recientes</div>
            <c:choose>
              <c:when test="${not empty misCitas}">
                <table class="cl-tbl"><thead><tr><th>Propiedad</th><th>Fecha</th><th>Estado</th></tr></thead><tbody>
                <c:forEach var="c" items="${misCitas}" begin="0" end="3">
                  <tr><td><strong>${c.propiedadTitulo}</strong></td><td style="font-size:0.8rem;">${c.fechaCita}</td><td><span class="st st-${c.estado}">${c.estado}</span></td></tr>
                </c:forEach></tbody></table>
                <div class="mt-3"><button class="cl-bo" onclick="gt('citas')" style="font-size:0.76rem;">Ver todas <i class="fas fa-arrow-right ms-1"></i></button></div>
              </c:when>
              <c:otherwise>
                <div class="cl-empty"><i class="fas fa-calendar"></i><h6>Sin citas</h6><p>Explora y agenda una visita</p>
                  <button class="cl-bg" onclick="gt('agendar')"><i class="fas fa-calendar-plus"></i> Agendar</button>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
        <div class="col-lg-6">
          <div class="cl-card">
            <div class="cl-ct"><i class="fas fa-bolt"></i> Acciones Rápidas</div>
            <div class="cl-cs">¿Qué quieres hacer hoy?</div>
            <div class="d-flex flex-column gap-3 mt-2">
              <a href="${ctx}/lista.jsp" class="cl-bg" style="padding:13px 18px;justify-content:flex-start;">
                <i class="fas fa-search fa-fw"></i><div><div>Buscar Propiedades</div><div style="font-size:0.72rem;opacity:.7;">Explora el catálogo</div></div>
              </a>
              <button class="cl-bo" style="padding:13px 18px;justify-content:flex-start;" onclick="gt('agendar')">
                <i class="fas fa-calendar-plus fa-fw"></i><div><div>Agendar Visita</div><div style="font-size:0.72rem;opacity:.7;">Coordina una inspección</div></div>
              </button>
              <button class="cl-bo" style="padding:13px 18px;justify-content:flex-start;" onclick="gt('solicitudes')">
                <i class="fas fa-file-signature fa-fw"></i><div><div>Mis Solicitudes</div><div style="font-size:0.72rem;opacity:.7;">Compra o arriendo</div></div>
              </button>
              <button class="cl-bo" style="padding:13px 18px;justify-content:flex-start;" onclick="gt('favoritos')">
                <i class="fas fa-heart fa-fw" style="color:#e74c3c;"></i><div><div>Mis Favoritos</div><div style="font-size:0.72rem;opacity:.7;">Propiedades guardadas</div></div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <%-- ══ CITAS ══ --%>
    <div class="cl-pane" id="pane-citas">
      <div class="cl-phdr">
        <div><div class="cl-ptitle">Mis Citas</div><div class="cl-psub">Historial de visitas</div></div>
        <button class="cl-bg" onclick="gt('agendar')"><i class="fas fa-plus"></i> Nueva visita</button>
      </div>
      <div class="cl-card">
        <c:choose>
          <c:when test="${not empty misCitas}">
            <div class="table-responsive">
              <table class="cl-tbl"><thead><tr><th>Propiedad</th><th>Fecha</th><th>Notas</th><th>Estado</th><th>Acción</th></tr></thead><tbody>
              <c:forEach var="cita" items="${misCitas}">
                <tr>
                  <td><strong>${cita.propiedadTitulo}</strong><br><small style="color:var(--cm);">${cita.propiedadCiudad}</small></td>
                  <td style="font-size:0.8rem;">${cita.fechaCita}</td>
                  <td style="font-size:0.8rem;max-width:160px;">${not empty cita.notas?cita.notas:'N/A'}</td>
                  <td><span class="st st-${cita.estado}">${cita.estado}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${cita.estado=='pendiente'}">
                        <form action="${ctx}/cliente.jsp" method="post" style="display:inline;">
                          <input type="hidden" name="action" value="cancelarCita">
                          <input type="hidden" name="citaId" value="${cita.id}">
                          <input type="hidden" name="tab"    value="citas">
                          <button type="submit" class="cl-bd" onclick="return confirm('¿Cancelar cita?')"><i class="fas fa-times"></i> Cancelar</button>
                        </form>
                      </c:when>
                      <c:otherwise>
                        <a href="${ctx}/detalle.jsp?id=${cita.propiedadId}" class="cl-bo" style="padding:5px 10px;font-size:0.74rem;"><i class="fas fa-eye"></i></a>
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </c:when>
          <c:otherwise>
            <div class="cl-empty"><i class="fas fa-calendar-times"></i><h6>Sin citas agendadas</h6><p>Agenda una visita a cualquier propiedad.</p>
              <button class="cl-bg" onclick="gt('agendar')"><i class="fas fa-calendar-plus"></i> Agendar</button>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ SOLICITUDES ══ --%>
    <div class="cl-pane" id="pane-solicitudes">
      <div class="cl-phdr">
        <div><div class="cl-ptitle">Mis Solicitudes</div><div class="cl-psub">Compra o arriendo en proceso</div></div>
      </div>
      <div class="cl-card">
        <c:choose>
          <c:when test="${not empty misSolicitudes}">
            <div class="table-responsive">
              <table class="cl-tbl"><thead><tr><th>Propiedad</th><th>Tipo</th><th>Estado</th><th>Fecha</th><th></th></tr></thead><tbody>
              <c:forEach var="sol" items="${misSolicitudes}">
                <tr>
                  <td><strong>${sol.propiedadTitulo}</strong></td>
                  <td><span class="st st-${sol.tipo}">${sol.tipo}</span></td>
                  <td><span class="st st-${sol.estado}">${sol.estado}</span></td>
                  <td style="font-size:0.78rem;color:var(--cm);">${sol.fechaSolicitud}</td>
                  <td><a href="${ctx}/detalle.jsp?id=${sol.propiedadId}" class="cl-bo" style="padding:5px 10px;font-size:0.74rem;"><i class="fas fa-eye"></i></a></td>
                </tr>
              </c:forEach>
              </tbody></table>
            </div>
          </c:when>
          <c:otherwise>
            <div class="cl-empty"><i class="fas fa-file-signature"></i><h6>Sin solicitudes activas</h6>
              <p>Cuando solicites comprar o arrendar, aparecerá aquí.</p>
              <a href="${ctx}/lista.jsp" class="cl-bg"><i class="fas fa-search"></i> Ver propiedades</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- ══ FAVORITOS ══ --%>
    <div class="cl-pane" id="pane-favoritos">
      <div class="cl-phdr">
        <div><div class="cl-ptitle">Mis Favoritos</div><div class="cl-psub">Propiedades guardadas</div></div>
        <a href="${ctx}/lista.jsp" class="cl-bo"><i class="fas fa-plus"></i> Agregar</a>
      </div>
      <c:choose>
        <c:when test="${not empty misFavoritos}">
          <div class="row g-3">
            <c:forEach var="fav" items="${misFavoritos}">
              <div class="col-md-6 col-lg-4">
                <div class="cl-card" style="padding:0;overflow:hidden;">
                  <div style="aspect-ratio:16/9;overflow:hidden;position:relative;">
                    <img src="${not empty fav.fotoPrincipal?fav.fotoPrincipal:'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=500&q=70'}"
                         style="width:100%;height:100%;object-fit:cover;" alt="${fav.titulo}">
                    <span class="st st-${fav.operacion}" style="position:absolute;top:8px;left:8px;">${fav.operacion}</span>
                  </div>
                  <div style="padding:14px;">
                    <div style="font-weight:700;font-size:0.88rem;margin-bottom:3px;">${fav.titulo}</div>
                    <div style="font-size:0.76rem;color:var(--cm);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1" style="color:var(--cg);"></i>${fav.ciudad}</div>
                    <div style="font-size:1.05rem;font-weight:900;margin-bottom:10px;">$${fav.precio}</div>
                    <div class="d-flex gap-2">
                      <a href="${ctx}/detalle.jsp?id=${fav.id}" class="cl-bg flex-fill justify-content-center" style="font-size:0.76rem;">Ver</a>
                      <form action="${ctx}/cliente.jsp" method="post" style="display:contents;">
                        <input type="hidden" name="action" value="quitarFavorito">
                        <input type="hidden" name="propiedadId" value="${fav.id}">
                        <input type="hidden" name="tab" value="favoritos">
                        <button type="submit" class="cl-bd" style="padding:8px 11px;"><i class="fas fa-heart-broken"></i></button>
                      </form>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="cl-card"><div class="cl-empty"><i class="fas fa-heart"></i><h6>Sin favoritos</h6>
            <p>Guarda propiedades que te interesen desde el listado.</p>
            <a href="${ctx}/lista.jsp" class="cl-bg"><i class="fas fa-search"></i> Explorar</a>
          </div></div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ══ AGENDAR ══ --%>
    <div class="cl-pane" id="pane-agendar">
      <div class="cl-phdr">
        <div><div class="cl-ptitle">Agendar Visita</div><div class="cl-psub">Solicita ver una propiedad</div></div>
      </div>
      <div class="row g-4">
        <div class="col-lg-7">
          <div class="cl-card">
            <div class="cl-ct"><i class="fas fa-calendar-plus"></i> Nueva Solicitud de Visita</div>
            <div class="cl-cs">Completa los datos — la inmobiliaria confirmará disponibilidad</div>
            <form action="${ctx}/cliente.jsp" method="post">
              <input type="hidden" name="action" value="agendarCita">
              <input type="hidden" name="tab"    value="citas">
              <div class="mb-3">
                <label class="cl-fl">Propiedad de interés *</label>
                <c:choose>
                  <c:when test="${not empty propiedades}">
                    <select name="propiedadId" class="cl-fc" required>
                      <option value="">-- Selecciona --</option>
                      <c:forEach var="p" items="${propiedades}">
                        <option value="${p.id}" ${not empty param.propId and param.propId==p.id?'selected':''}>
                          ${p.titulo} — ${p.operacion}
                        </option>
                      </c:forEach>
                    </select>
                  </c:when>
                  <c:otherwise>
                    <input type="text" name="propiedadId" class="cl-fc" required
                           placeholder="ID de la propiedad (ej: 1, 2, 3…)"
                           value="${param.propId}">
                    <small style="font-size:0.73rem;color:var(--cm);">
                      <i class="fas fa-info-circle me-1"></i>Copia el ID desde la URL de la propiedad.
                      <a href="${ctx}/lista.jsp" style="color:var(--cg);">Ver propiedades →</a>
                    </small>
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="mb-3">
                <label class="cl-fl">Tipo de solicitud</label>
                <div class="d-flex gap-3 flex-wrap">
                  <label style="font-size:0.83rem;display:flex;align-items:center;gap:6px;cursor:pointer;"><input type="radio" name="tipoSolicitud" value="visita" checked style="accent-color:var(--cg);"> Visita presencial</label>
                  <label style="font-size:0.83rem;display:flex;align-items:center;gap:6px;cursor:pointer;"><input type="radio" name="tipoSolicitud" value="informacion" style="accent-color:var(--cg);"> Solo información</label>
                  <label style="font-size:0.83rem;display:flex;align-items:center;gap:6px;cursor:pointer;"><input type="radio" name="tipoSolicitud" value="oferta" style="accent-color:var(--cg);"> Hacer una oferta</label>
                </div>
              </div>
              <div class="row g-3 mb-3">
                <div class="col-md-6">
                  <label class="cl-fl">Fecha deseada *</label>
                  <input type="date" name="fechaCita" class="cl-fc" required id="fci">
                </div>
                <div class="col-md-6">
                  <label class="cl-fl">Hora preferida</label>
                  <select name="horaCita" class="cl-fc">
                    <option value="08:00">8:00 am</option><option value="09:00">9:00 am</option>
                    <option value="10:00" selected>10:00 am</option><option value="11:00">11:00 am</option>
                    <option value="14:00">2:00 pm</option><option value="15:00">3:00 pm</option>
                    <option value="16:00">4:00 pm</option><option value="17:00">5:00 pm</option>
                  </select>
                </div>
              </div>
              <div class="mb-4">
                <label class="cl-fl">Comentarios (opcional)</label>
                <textarea name="notas" class="cl-fc" rows="3" placeholder="¿Alguna pregunta? ¿Vas con familia?"></textarea>
              </div>
              <button type="submit" class="cl-bg w-100 justify-content-center py-3" style="font-size:0.93rem;">
                <i class="fas fa-calendar-check me-1"></i> Enviar Solicitud
              </button>
            </form>
          </div>
        </div>
        <div class="col-lg-5">
          <div class="cl-card">
            <div class="cl-ct"><i class="fas fa-info-circle"></i> ¿Cómo funciona?</div>
            <div class="cl-wiz"><div class="cl-wn done"><i class="fas fa-check"></i></div><div><strong style="font-size:0.87rem;">1. Selecciona la propiedad</strong><p style="font-size:0.78rem;color:var(--cm);margin:2px 0 0;">Elige la que quieres visitar.</p></div></div>
            <div class="cl-wiz"><div class="cl-wn done"><i class="fas fa-check"></i></div><div><strong style="font-size:0.87rem;">2. Indica fecha y hora</strong><p style="font-size:0.78rem;color:var(--cm);margin:2px 0 0;">Cuándo prefieres la visita.</p></div></div>
            <div class="cl-wiz"><div class="cl-wn">3</div><div><strong style="font-size:0.87rem;">3. La inmobiliaria confirma</strong><p style="font-size:0.78rem;color:var(--cm);margin:2px 0 0;">Recibirás notificación de confirmación.</p></div></div>
            <div class="cl-wiz" style="border:none;"><div class="cl-wn">4</div><div><strong style="font-size:0.87rem;">4. ¡Visita la propiedad!</strong><p style="font-size:0.78rem;color:var(--cm);margin:2px 0 0;">Ve el día acordado y conoce tu futuro hogar.</p></div></div>
          </div>
        </div>
      </div>
    </div>

    <%-- ══ PERFIL ══ --%>
    <div class="cl-pane" id="pane-perfil">
      <div class="cl-phdr">
        <div><div class="cl-ptitle">Mi Perfil</div><div class="cl-psub">Actualiza tu información</div></div>
      </div>
      <div class="row g-4">
        <div class="col-lg-4">
          <div class="cl-card text-center">
            <div style="width:72px;height:72px;background:linear-gradient(135deg,#c9a84c,#e8c96b);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.6rem;font-weight:900;color:#000;margin:0 auto 14px;">
              ${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}
            </div>
            <h6 style="font-family:'Playfair Display',serif;font-weight:900;margin-bottom:4px;">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</h6>
            <span style="background:rgba(52,152,219,0.12);color:#1a6c9f;padding:3px 10px;border-radius:100px;font-size:0.68rem;font-weight:700;letter-spacing:1px;"><i class="fas fa-user me-1"></i>CLIENTE</span>
            <div style="margin-top:18px;text-align:left;">
              <div style="display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid var(--cb);font-size:0.84rem;"><span style="color:var(--cm);">Correo</span><span style="font-weight:600;">${sessionScope.usuario.email}</span></div>
              <div style="display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid var(--cb);font-size:0.84rem;"><span style="color:var(--cm);">Teléfono</span><span style="font-weight:600;">${not empty sessionScope.usuario.telefono?sessionScope.usuario.telefono:'N/A'}</span></div>
              <div style="display:flex;justify-content:space-between;padding:9px 0;font-size:0.84rem;"><span style="color:var(--cm);">Miembro desde</span><span style="font-weight:600;"><c:choose><c:when test="${sessionScope.usuario.fechaRegistro != null}"><fmt:formatDate value="${sessionScope.usuario.fechaRegistro}" pattern="MMM yyyy"/></c:when><c:otherwise>—</c:otherwise></c:choose></span></div>
            </div>
          </div>
        </div>
        <div class="col-lg-8">
          <div class="cl-card">
            <div class="cl-ct"><i class="fas fa-edit"></i> Editar Datos</div>
            <div class="cl-cs">Los cambios se guardan en la base de datos</div>
            <form action="${ctx}/cliente.jsp" method="post">
              <input type="hidden" name="action" value="actualizarPerfil">
              <input type="hidden" name="tab"    value="perfil">
              <div class="row g-3">
                <div class="col-md-6"><label class="cl-fl">Nombre</label><input type="text" name="nombre" class="cl-fc" value="${sessionScope.usuario.nombre}" required></div>
                <div class="col-md-6"><label class="cl-fl">Apellido</label><input type="text" name="apellido" class="cl-fc" value="${sessionScope.usuario.apellido}" required></div>
                <div class="col-md-6"><label class="cl-fl">Correo</label><input type="email" name="email" class="cl-fc" value="${sessionScope.usuario.email}" required></div>
                <div class="col-md-6"><label class="cl-fl">Teléfono</label><input type="tel" name="telefono" class="cl-fc" value="${sessionScope.usuario.telefono}" placeholder="+57 300 000 0000"></div>
                <div class="col-12"><label class="cl-fl">Nueva contraseña <small style="color:var(--cm);font-weight:400;">(vacío = no cambiar)</small></label><input type="password" name="nuevaPassword" class="cl-fc" placeholder="Mínimo 8 caracteres"></div>
                <div class="col-12 mt-2"><button type="submit" class="cl-bg"><i class="fas fa-save"></i> Guardar</button></div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>


    <!-- ══ PANEL DOCUMENTOS ══ -->
    <div class="cl-pane" id="pane-documentos">
      <div class="cl-phdr">
        <div>
          <div class="cl-ptitle"><i class="fas fa-folder-open me-2" style="color:var(--gold,#c9a84c);"></i>Mis Documentos</div>
          <div class="cl-psub">Sube tus papeles de compra o arriendo</div>
        </div>
      </div>

      <div class="cl-card mb-4">
        <div class="cl-ct"><i class="fas fa-cloud-upload-alt me-2"></i>Subir Nuevo Documento</div>
        <div id="docAlerta" style="display:none;margin:12px 0;padding:12px 16px;border-radius:10px;font-size:.88rem;"></div>
        <div class="row g-3 mt-1">
          <div class="col-md-6">
            <label class="cl-fl">Tipo de Documento</label>
            <select id="docTipo" class="cl-fc">
              <option value="">Selecciona...</option>
              <option value="cedula">Cédula de Ciudadanía</option>
              <option value="comprobante">Comprobante de Ingresos</option>
              <option value="desprendible">Desprendible de Pago</option>
              <option value="extracto">Extracto Bancario</option>
              <option value="declaracion_renta">Declaración de Renta</option>
              <option value="carta_laboral">Carta Laboral</option>
              <option value="contrato">Contrato / Promesa</option>
              <option value="otro">Otro</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="cl-fl">Propiedad (opcional)</label>
            <input type="text" id="docPropiedad" class="cl-fc" placeholder="Ej: Casa en Cabecera">
          </div>
          <div class="col-12">
            <label class="cl-fl">Archivo (PDF, JPG, PNG — máx 5MB)</label>
            <div id="docDropZone" style="border:2px dashed rgba(201,168,76,.4);border-radius:12px;padding:28px;text-align:center;cursor:pointer;background:rgba(201,168,76,.02);transition:all .3s;position:relative;">
              <input type="file" id="docArchivo" accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                     style="position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;">
              <i class="fas fa-file-upload" style="font-size:1.8rem;color:rgba(201,168,76,.5);display:block;margin-bottom:8px;"></i>
              <p style="margin:0;font-size:.84rem;color:#888;">Arrastra aquí o <strong style="color:var(--gold,#c9a84c);">haz clic para seleccionar</strong></p>
              <div id="docFileName" style="margin-top:6px;color:var(--gold,#c9a84c);font-size:.83rem;font-weight:600;"></div>
            </div>
          </div>
          <div class="col-12">
            <button class="cl-bg" id="docBtnSubir" onclick="subirDocumento()">
              <i class="fas fa-upload me-2"></i>Subir Documento
            </button>
          </div>
        </div>
      </div>

      <div class="cl-card">
        <div class="cl-ct"><i class="fas fa-archive me-2"></i>Documentos Subidos</div>
        <div id="docLista" style="margin-top:12px;min-height:80px;display:flex;align-items:center;justify-content:center;">
          <span style="color:#aaa;font-size:.88rem;">Haz clic en "Mis Documentos" para cargar.</span>
        </div>
      </div>
    </div>

  </main>
</div>
</div>

<%@ include file="footer.jsp" %>

<script>
const INIT_TAB = '<%= tab %>';

function gt(name) {
  document.querySelectorAll('.cl-pane').forEach(p=>p.classList.remove('active'));
  const el = document.getElementById('pane-'+name);
  if(el) el.classList.add('active');
  document.querySelectorAll('.cl-sb-lnk[id]').forEach(l=>l.classList.remove('active'));
  const sl = document.getElementById('sl-'+name);
  if(sl) sl.classList.add('active');
  document.querySelectorAll('.cl-mb').forEach(b=>b.classList.remove('active'));
  const mb = document.getElementById('mb-'+name);
  if(mb) mb.classList.add('active');
  const u = new URL(window.location.href);
  u.searchParams.set('tab',name);
  window.history.replaceState({},'',u);
  window.scrollTo({top:0,behavior:'smooth'});
}

// Init
gt(INIT_TAB);

// Min date on cita form
const fci = document.getElementById('fci');
if(fci) fci.min = new Date().toISOString().split('T')[0];

// Auto-open agendar if propId in URL
const up = new URLSearchParams(window.location.search);
if(up.get('propId') && INIT_TAB !== 'agendar') gt('agendar');

// ═══ DOCUMENTOS JS ═══
document.getElementById('docArchivo') && document.getElementById('docArchivo').addEventListener('change', function() {
  if(this.files[0]) {
    document.getElementById('docFileName').textContent = '📎 ' + this.files[0].name;
    document.getElementById('docDropZone').style.borderColor = '#c9a84c';
  }
});

function docAlerta(msg, ok) {
  var el = document.getElementById('docAlerta');
  el.style.display = 'block';
  el.style.background = ok ? '#e8f5e9' : '#ffebee';
  el.style.color = ok ? '#2e7d32' : '#c62828';
  el.style.border = '1px solid ' + (ok ? '#a5d6a7' : '#ef9a9a');
  el.innerHTML = (ok ? '<i class="fas fa-check-circle me-2"></i>' : '<i class="fas fa-exclamation-circle me-2"></i>') + msg;
}

function subirDocumento() {
  var archivo = document.getElementById('docArchivo').files[0];
  var tipo    = document.getElementById('docTipo').value;
  if (!archivo) { docAlerta('Selecciona un archivo.', false); return; }
  if (!tipo)    { docAlerta('Selecciona el tipo de documento.', false); return; }
  if (archivo.size > 5*1024*1024) { docAlerta('El archivo supera 5MB.', false); return; }

  var btn = document.getElementById('docBtnSubir');
  btn.disabled = true;
  btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Subiendo...';

  // Enviar datos sin multipart (nombre del archivo + tipo)
  var params = new URLSearchParams();
  params.append('tipoDoc', tipo);
  params.append('nombreArchivo', archivo.name);
  params.append('propiedadTitulo', document.getElementById('docPropiedad').value);

  fetch('guardar-documento.jsp', { method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: params.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if(d.ok) {
        docAlerta('Documento subido correctamente.', true);
        document.getElementById('docArchivo').value = '';
        document.getElementById('docFileName').textContent = '';
        document.getElementById('docDropZone').style.borderColor = 'rgba(201,168,76,.4)';
        document.getElementById('docTipo').value = '';
        cargarMisDocumentos();
      } else {
        docAlerta('Error: ' + (d.error || 'desconocido'), false);
      }
      btn.disabled = false;
      btn.innerHTML = '<i class="fas fa-upload me-2"></i>Subir Documento';
    })
    .catch(function(){
      docAlerta('No se pudo conectar con el servidor.', false);
      btn.disabled = false;
      btn.innerHTML = '<i class="fas fa-upload me-2"></i>Subir Documento';
    });
}

function cargarMisDocumentos() {
  var lista = document.getElementById('docLista');
  if (!lista) return;
  lista.innerHTML = '<span style="color:#aaa;font-size:.88rem;"><i class="fas fa-spinner fa-spin me-2"></i>Cargando...</span>';
  fetch('listar-documentos.jsp')
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d.docs || d.docs.length === 0) {
        lista.innerHTML = '<div style="text-align:center;padding:30px;color:#bbb;"><i class="fas fa-folder-open" style="font-size:2rem;display:block;margin-bottom:8px;"></i><p style="margin:0;font-size:.86rem;">Aún no has subido documentos.</p></div>';
        return;
      }
      var html = '<div style="overflow-x:auto;"><table style="width:100%;border-collapse:collapse;">'
        + '<thead><tr style="border-bottom:2px solid #f0f0f0;">'
        + '<th style="padding:10px;text-align:left;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;">Archivo</th>'
        + '<th style="padding:10px;text-align:left;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;">Tipo</th>'
        + '<th style="padding:10px;text-align:left;font-size:.72rem;color:#aaa;text-transform:uppercase;letter-spacing:1px;">Fecha</th>'
        + '</tr></thead><tbody>';
      d.docs.forEach(function(doc){
        html += '<tr style="border-bottom:1px solid #f5f5f5;">'
          + '<td style="padding:11px 10px;font-size:.86rem;"><i class="fas fa-file-alt me-2" style="color:#c9a84c;"></i>' + doc.nombre + '</td>'
          + '<td style="padding:11px 10px;"><span style="background:rgba(201,168,76,.1);color:#c9a84c;padding:3px 10px;border-radius:20px;font-size:.7rem;font-weight:700;">' + doc.tipo + '</span></td>'
          + '<td style="padding:11px 10px;font-size:.78rem;color:#aaa;">' + doc.fecha + '</td>'
          + '</tr>';
      });
      html += '</tbody></table></div>';
      lista.innerHTML = html;
    })
    .catch(function(){
      lista.innerHTML = '<p style="color:#aaa;text-align:center;padding:20px;font-size:.86rem;">No se pudieron cargar los documentos.</p>';
    });
}

// Interceptar click en Mis Documentos para cargar lista
(function(){
  var btnDoc = document.getElementById('sl-documentos');
  var btnDocMb = document.getElementById('mb-documentos');
  if(btnDoc) btnDoc.addEventListener('click', function(){ setTimeout(cargarMisDocumentos, 150); });
  if(btnDocMb) btnDocMb.addEventListener('click', function(){ setTimeout(cargarMisDocumentos, 150); });
})();
</script>
