<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%
/* ═══════════════════════════════════════════════════
   DETALLE.JSP — InmoVista
   Columnas reales de la BD:
   id, titulo, descripcion, tipo, operacion, precio,
   area, habitaciones, banos, garaje, direccion,
   ciudad, barrio, latitud, longitud, estado,
   propietario_id, fecha_publicacion,
   fecha_actualizacion, usuario_id, foto_principal
═══════════════════════════════════════════════════ */

// ── Verificar parámetro id ────────────────────────
String idParam = request.getParameter("id");
if (idParam == null || idParam.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/lista.jsp");
    return;
}
int propId = 0;
try { propId = Integer.parseInt(idParam.trim()); }
catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/lista.jsp");
    return;
}

// ── Conexión BD ───────────────────────────────────
java.sql.Connection db = null;
String dbError = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db" +
        "?useSSL=false&serverTimezone=America/Bogota" +
        "&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");
} catch (Exception e) {
    dbError = e.getMessage();
}

// ── Variables ─────────────────────────────────────
String titulo = "", descripcion = "", tipo = "", operacion = "";
String direccion = "", ciudad = "", barrio = "", estado = "disponible";
String foto = "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70";
String fecha = "";
double precio = 0, area = 0;
int habitaciones = 0, banos = 0, garaje = 0;
boolean encontrada = false;
String flashMsg = request.getParameter("msg");
String errorCita = null;

// ── POST: agendar cita ────────────────────────────
if ("POST".equalsIgnoreCase(request.getMethod()) && db != null) {
    String rol = (String) session.getAttribute("rolNombre");
    if (!"cliente".equals(rol)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    try {
        int clienteId = 0;
        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) clienteId = (Integer) uid;
        else if (uid != null) clienteId = Integer.parseInt(uid.toString());

        String fechaCita = request.getParameter("fecha");
        String horaCita  = request.getParameter("hora");
        String notas     = request.getParameter("mensaje");
        String fechaHora = fechaCita + " " + (horaCita != null ? horaCita : "09:00") + ":00";

        java.sql.PreparedStatement ps = db.prepareStatement(
            "INSERT INTO citas (cliente_id, propiedad_id, fecha_cita, estado, notas) VALUES (?,?,?,?,?)");
        ps.setInt(1, clienteId);
        ps.setInt(2, propId);
        ps.setString(3, fechaHora);
        ps.setString(4, "pendiente");
        ps.setString(5, notas != null ? notas.trim() : "");
        ps.executeUpdate();
        ps.close();
        if (db != null) try { db.close(); } catch(Exception ex){}
        response.sendRedirect(request.getContextPath() + "/detalle.jsp?id=" + propId +
            "&msg=" + java.net.URLEncoder.encode("Cita solicitada correctamente. El agente la confirmara pronto.", "UTF-8"));
        return;
    } catch (Exception ex) {
        errorCita = "Error al agendar: " + ex.getMessage();
        ex.printStackTrace();
    }
}

// ── GET: cargar propiedad ─────────────────────────
if (db != null) {
    try {
        java.sql.PreparedStatement ps = db.prepareStatement(
            "SELECT * FROM propiedades WHERE id = ? LIMIT 1");
        ps.setInt(1, propId);
        java.sql.ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            encontrada    = true;
            titulo        = rs.getString("titulo")      != null ? rs.getString("titulo")      : "";
            descripcion   = rs.getString("descripcion") != null ? rs.getString("descripcion") : "";
            tipo          = rs.getString("tipo")        != null ? rs.getString("tipo")        : "";
            operacion     = rs.getString("operacion")   != null ? rs.getString("operacion")   : "";
            precio        = rs.getDouble("precio");
            area          = rs.getDouble("area");
            habitaciones  = rs.getInt("habitaciones");
            banos         = rs.getInt("banos");
            garaje        = rs.getInt("garaje");
            estado        = rs.getString("estado")      != null ? rs.getString("estado")      : "disponible";
            direccion     = rs.getString("direccion")   != null ? rs.getString("direccion")   : "";
            ciudad        = rs.getString("ciudad")      != null ? rs.getString("ciudad")      : "";
            barrio        = rs.getString("barrio")      != null ? rs.getString("barrio")      : "";
            String fotoDb = rs.getString("foto_principal");
            if (fotoDb != null && !fotoDb.trim().isEmpty()) foto = fotoDb;
            try { fecha = rs.getString("fecha_publicacion") != null ? rs.getString("fecha_publicacion") : ""; }
            catch(Exception ef) { fecha = ""; }
        }
        rs.close(); ps.close();
    } catch (Exception ex) {
        ex.printStackTrace();
        dbError = ex.getMessage();
    } finally {
        try { db.close(); } catch(Exception ex) {}
    }
}

// Si no se encontró la propiedad, volver a lista
if (!encontrada) {
    response.sendRedirect(request.getContextPath() + "/lista.jsp");
    return;
}

// Formatear precio
String precioFmt = String.format("%,.0f", precio);

// Exponer en request para JSTL
request.setAttribute("titulo",       titulo);
request.setAttribute("descripcion",  descripcion);
request.setAttribute("tipo",         tipo);
request.setAttribute("operacion",    operacion);
request.setAttribute("precioFmt",    precioFmt);
request.setAttribute("area",         area);
request.setAttribute("habitaciones", habitaciones);
request.setAttribute("banos",        banos);
request.setAttribute("garaje",       garaje == 1);
request.setAttribute("estado",       estado);
request.setAttribute("direccion",    direccion);
request.setAttribute("ciudad",       ciudad);
request.setAttribute("barrio",       barrio);
request.setAttribute("foto",         foto);
request.setAttribute("fecha",        fecha);
request.setAttribute("propId",       propId);
request.setAttribute("flash",        flashMsg);
request.setAttribute("errorCita",    errorCita);
request.setAttribute("pageTitle",    titulo);
%>
<%@ include file="header.jsp" %>

<style>
.det-hero { position:relative; height:420px; overflow:hidden; background:#0d0d0d; }
.det-hero img { width:100%; height:100%; object-fit:cover; opacity:.78; }
.det-hero__ov { position:absolute; inset:0; background:linear-gradient(to bottom,rgba(13,13,13,.25),rgba(13,13,13,.75)); }
.det-hero__top { position:absolute; top:20px; left:24px; display:flex; gap:8px; flex-wrap:wrap; }
.det-hero__bot { position:absolute; bottom:24px; left:24px; right:24px; }
.tag-tipo { background:var(--gold); color:#0d0d0d; font-size:.7rem; font-weight:700; padding:4px 14px; border-radius:20px; text-transform:uppercase; letter-spacing:1px; }
.tag-op   { background:rgba(255,255,255,.15); backdrop-filter:blur(8px); color:#fff; font-size:.7rem; font-weight:600; padding:4px 14px; border-radius:20px; border:1px solid rgba(255,255,255,.3); text-transform:uppercase; }
.tag-est  { font-size:.7rem; font-weight:700; padding:4px 14px; border-radius:20px; text-transform:uppercase; }
.tag-est.disponible  { background:#1a7a4a; color:#fff; }
.tag-est.reservada   { background:#b85c00; color:#fff; }
.tag-est.vendida     { background:#7a1a1a; color:#fff; }
.tag-est.arrendada   { background:#1a4a7a; color:#fff; }

.det-body { background:var(--background,#f8f8f8); padding:40px 0 80px; }
.det-card { background:#fff; border:1px solid #e8e8e8; border-radius:14px; padding:24px 28px; margin-bottom:20px; box-shadow:0 2px 12px rgba(0,0,0,.06); }
.det-card__h { font-family:'Playfair Display',serif; font-size:.88rem; font-weight:700; color:var(--gold,#c9a84c); text-transform:uppercase; letter-spacing:2px; margin-bottom:16px; padding-bottom:10px; border-bottom:1px solid #f0f0f0; display:flex; align-items:center; gap:8px; }
.precio-big { font-family:'Playfair Display',serif; font-size:2rem; font-weight:900; color:var(--gold,#c9a84c); }
.precio-lbl { font-size:.78rem; color:#888; margin-top:2px; }
.feat-grid { display:grid; grid-template-columns:repeat(2,1fr); gap:12px; }
.feat-item { display:flex; align-items:center; gap:10px; padding:12px 14px; background:#fafafa; border-radius:10px; border:1px solid #eee; }
.feat-ico { width:34px; height:34px; background:rgba(201,168,76,.1); border-radius:8px; display:flex; align-items:center; justify-content:center; color:var(--gold,#c9a84c); font-size:.95rem; flex-shrink:0; }
.feat-lbl { font-size:.7rem; color:#999; margin-bottom:1px; }
.feat-val { font-size:.9rem; font-weight:600; color:#222; }
.map-ph { height:180px; background:#f5f5f5; border-radius:10px; border:1px solid #eee; display:flex; flex-direction:column; align-items:center; justify-content:center; color:#bbb; gap:6px; }
.cita-lbl { font-size:.8rem; font-weight:600; color:#555; margin-bottom:5px; display:block; }
.cita-ctrl { width:100%; padding:9px 13px; border:1px solid #ddd; border-radius:8px; font-size:.88rem; background:#fafafa; outline:none; transition:border-color .2s; }
.cita-ctrl:focus { border-color:var(--gold,#c9a84c); }
.btn-agendar { width:100%; padding:11px; background:var(--gold,#c9a84c); color:#0d0d0d; font-weight:700; font-size:.9rem; border:none; border-radius:10px; cursor:pointer; transition:all .3s; }
.btn-agendar:hover { background:#b8962a; transform:translateY(-1px); }
.alert-ok  { background:#e8f5e9; border:1px solid #a5d6a7; color:#2e7d32; padding:12px 16px; border-radius:10px; margin-bottom:16px; font-size:.88rem; }
.alert-err { background:#ffebee; border:1px solid #ef9a9a; color:#c62828; padding:12px 16px; border-radius:10px; margin-bottom:16px; font-size:.88rem; }
.bcrumb { font-size:.82rem; margin-bottom:20px; }
.bcrumb a { color:#888; text-decoration:none; } .bcrumb a:hover { color:var(--gold,#c9a84c); }
.bcrumb span { color:#ccc; margin:0 5px; }
</style>

<!-- HERO -->
<div class="det-hero">
  <img src="${foto}" alt="${titulo}">
  <div class="det-hero__ov"></div>
  <div class="det-hero__top">
    <span class="tag-tipo">${tipo}</span>
    <span class="tag-op">En ${operacion}</span>
    <span class="tag-est ${estado}">${estado}</span>
  </div>
  <div class="det-hero__bot">
    <h1 style="font-family:'Playfair Display',serif;font-size:clamp(1.4rem,3vw,2rem);font-weight:900;color:#fff;margin-bottom:6px;line-height:1.2;">${titulo}</h1>
    <div style="color:rgba(255,255,255,.7);font-size:.86rem;">
      <i class="fas fa-map-marker-alt me-1" style="color:var(--gold,#c9a84c);"></i>
      ${not empty barrio ? barrio : ''}${not empty barrio && not empty ciudad ? ', ' : ''}${ciudad}
    </div>
  </div>
</div>

<!-- BODY -->
<div class="det-body">
  <div class="container">

    <!-- Breadcrumb -->
    <div class="bcrumb">
      <a href="${ctx}/index.jsp"><i class="fas fa-home me-1"></i>Inicio</a>
      <span>›</span>
      <a href="${ctx}/lista.jsp">Propiedades</a>
      <span>›</span>
      <span style="color:#444;">${titulo}</span>
    </div>

    <!-- Alertas -->
    <c:if test="${not empty flash}">
      <div class="alert-ok"><i class="fas fa-check-circle me-2"></i>${flash}</div>
    </c:if>
    <c:if test="${not empty errorCita}">
      <div class="alert-err"><i class="fas fa-exclamation-circle me-2"></i>${errorCita}</div>
    </c:if>

    <div class="row g-4">

      <!-- ═══ COLUMNA PRINCIPAL ═══ -->
      <div class="col-lg-8">

        <!-- Precio -->
        <div class="det-card">
          <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
            <div>
              <div class="precio-big">$${precioFmt} COP</div>
              <div class="precio-lbl">${operacion == 'arriendo' ? 'Mensual' : 'Precio de venta'}</div>
            </div>
            <a href="${ctx}/lista.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
              <i class="fas fa-arrow-left me-1"></i> Volver
            </a>
          </div>
        </div>

        <!-- Descripción -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-align-left"></i> Descripción</div>
          <p style="color:#555;line-height:1.8;font-size:.93rem;margin:0;">
            <c:choose>
              <c:when test="${not empty descripcion}">${descripcion}</c:when>
              <c:otherwise>Esta propiedad no tiene descripción disponible aún.</c:otherwise>
            </c:choose>
          </p>
        </div>

        <!-- Características -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-list-ul"></i> Características</div>
          <div class="feat-grid">
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-home"></i></div>
              <div><div class="feat-lbl">Tipo</div><div class="feat-val" style="text-transform:capitalize;">${tipo}</div></div>
            </div>
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-ruler-combined"></i></div>
              <div><div class="feat-lbl">Área</div><div class="feat-val">${area > 0 ? area : 'N/A'} m²</div></div>
            </div>
            <c:if test="${habitaciones > 0}">
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-bed"></i></div>
              <div><div class="feat-lbl">Habitaciones</div><div class="feat-val">${habitaciones}</div></div>
            </div>
            </c:if>
            <c:if test="${banos > 0}">
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-bath"></i></div>
              <div><div class="feat-lbl">Baños</div><div class="feat-val">${banos}</div></div>
            </div>
            </c:if>
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-car"></i></div>
              <div><div class="feat-lbl">Garaje</div><div class="feat-val">${garaje ? 'Sí incluye' : 'No incluye'}</div></div>
            </div>
            <div class="feat-item">
              <div class="feat-ico"><i class="fas fa-tag"></i></div>
              <div><div class="feat-lbl">Operación</div><div class="feat-val" style="text-transform:capitalize;">${operacion}</div></div>
            </div>
          </div>
        </div>

        <!-- Ubicación -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-map-marker-alt"></i> Ubicación</div>
          <p style="color:#555;font-size:.9rem;margin-bottom:14px;">
            <i class="fas fa-map-pin me-2" style="color:var(--gold,#c9a84c);"></i>
            ${not empty direccion ? direccion : ''}${not empty direccion ? ', ' : ''}${not empty barrio ? barrio : ''}${not empty barrio ? ', ' : ''}${ciudad}
          </p>
          <div class="map-ph">
            <i class="fas fa-map-marked-alt" style="font-size:1.8rem;color:#c9a84c;"></i>
            <span style="font-size:.82rem;">Mapa disponible próximamente</span>
            <span style="font-size:.75rem;color:#ccc;">${ciudad}</span>
          </div>
        </div>

      </div>

      <!-- ═══ COLUMNA LATERAL ═══ -->
      <div class="col-lg-4">

        <!-- Agente -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-user-tie"></i> Agente</div>
          <div style="display:flex;align-items:center;gap:14px;padding:14px;background:#fafafa;border-radius:10px;border:1px solid #eee;">
            <div style="width:48px;height:48px;background:var(--gold,#c9a84c);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.2rem;font-weight:700;color:#0d0d0d;flex-shrink:0;">I</div>
            <div>
              <div style="font-weight:700;color:#222;">InmoVista</div>
              <div style="font-size:.75rem;color:var(--gold,#c9a84c);">Agente Inmobiliario</div>
            </div>
          </div>
        </div>

        <!-- Formulario cita -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-calendar-plus"></i> Solicitar Visita</div>

          <c:choose>
            <c:when test="${sessionScope.rolNombre == 'cliente'}">
              <c:choose>
                <c:when test="${estado != 'vendida' && estado != 'arrendada'}">
                  <form action="${ctx}/detalle.jsp?id=${propId}" method="post">
                    <div class="mb-3">
                      <label class="cita-lbl">Fecha <span style="color:red;">*</span></label>
                      <input type="date" name="fecha" class="cita-ctrl" required>
                    </div>
                    <div class="mb-3">
                      <label class="cita-lbl">Hora preferida <span style="color:red;">*</span></label>
                      <select name="hora" class="cita-ctrl" required>
                        <option value="">Seleccionar hora</option>
                        <option value="09:00">9:00 AM</option>
                        <option value="10:00">10:00 AM</option>
                        <option value="11:00">11:00 AM</option>
                        <option value="14:00">2:00 PM</option>
                        <option value="15:00">3:00 PM</option>
                        <option value="16:00">4:00 PM</option>
                      </select>
                    </div>
                    <div class="mb-3">
                      <label class="cita-lbl">Mensaje (opcional)</label>
                      <textarea name="mensaje" class="cita-ctrl" rows="3" placeholder="¿Algo que quieras saber?"></textarea>
                    </div>
                    <button type="submit" class="btn-agendar">
                      <i class="fas fa-calendar-check me-2"></i>Agendar Visita
                    </button>
                  </form>
                </c:when>
                <c:otherwise>
                  <div style="text-align:center;padding:20px;color:#999;">
                    <i class="fas fa-lock" style="font-size:1.8rem;margin-bottom:8px;display:block;"></i>
                    Esta propiedad ya no está disponible.
                  </div>
                </c:otherwise>
              </c:choose>
            </c:when>
            <c:when test="${empty sessionScope.usuario}">
              <div style="text-align:center;padding:16px;">
                <p style="color:#888;font-size:.86rem;margin-bottom:14px;">Inicia sesión como cliente para solicitar una visita.</p>
                <a href="${ctx}/login.jsp" style="display:inline-block;padding:10px 24px;background:var(--gold,#c9a84c);color:#0d0d0d;font-weight:700;border-radius:10px;text-decoration:none;font-size:.88rem;">
                  <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div style="text-align:center;padding:14px;color:#888;font-size:.86rem;">
                <i class="fas fa-info-circle me-1"></i>Solo los clientes pueden solicitar visitas.
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Compartir -->
        <div class="det-card">
          <div class="det-card__h"><i class="fas fa-share-alt"></i> Compartir</div>
          <div class="d-flex gap-2 flex-wrap">
            <a href="https://wa.me/?text=${titulo}%20-%20localhost:8080${ctx}/detalle.jsp?id=${propId}"
               target="_blank" style="padding:7px 16px;background:#25d366;color:#fff;border-radius:20px;text-decoration:none;font-size:.8rem;">
              <i class="fab fa-whatsapp me-1"></i>WhatsApp
            </a>
            <button onclick="navigator.clipboard.writeText(window.location.href);this.innerHTML='<i class=\'fas fa-check me-1\'></i>Copiado';"
                    style="padding:7px 16px;background:#f0f0f0;color:#333;border:1px solid #ddd;border-radius:20px;font-size:.8rem;cursor:pointer;">
              <i class="fas fa-link me-1"></i>Copiar enlace
            </button>
          </div>
        </div>

      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jsp" %>
