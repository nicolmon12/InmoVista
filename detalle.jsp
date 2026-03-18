<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════
   DETALLE.JSP · InmoVista
   Página de detalle de una propiedad individual.
   Accesible para todos (incluyendo visitantes).
   Si el usuario está logueado como cliente puede
   solicitar cita directamente desde esta página.
═══════════════════════════════════════════════════ */

String idParam = request.getParameter("id");
if (idParam == null || idParam.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/lista.jsp");
    return;
}

java.sql.Connection db = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");
} catch (Exception e) { db = null; }

java.util.Map<String,Object> prop = null;
java.util.List<String> fotos = new java.util.ArrayList<>();
String errorMsg = null;

// ── Manejar POST: solicitar cita ─────────────────
if ("POST".equalsIgnoreCase(request.getMethod()) && db != null) {
    String rolSesion = (String) session.getAttribute("rolNombre");
    if (!"cliente".equals(rolSesion)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    try {
        Object uidObj = session.getAttribute("userId");
        int clienteId = 0;
        if (uidObj instanceof Integer) clienteId = (Integer) uidObj;
        else {
            Object idO = ((java.util.Map<?,?>)session.getAttribute("usuario")).get("id");
            if (idO instanceof Integer) clienteId = (Integer) idO;
        }
        String fecha   = request.getParameter("fecha");
        String hora    = request.getParameter("hora");
        String mensaje = request.getParameter("mensaje");
        java.sql.PreparedStatement ps = db.prepareStatement(
            "INSERT INTO citas (cliente_id, propiedad_id, fecha, hora, estado, notas) VALUES (?,?,?,?,?,?)");
        ps.setInt(1,    clienteId);
        ps.setInt(2,    Integer.parseInt(idParam.trim()));
        ps.setString(3, fecha);
        ps.setString(4, hora);
        ps.setString(5, "pendiente");
        ps.setString(6, mensaje != null ? mensaje.trim() : "");
        ps.executeUpdate(); ps.close();
        if (db != null) { try { db.close(); } catch(Exception e){} }
        response.sendRedirect(request.getContextPath() + "/detalle.jsp?id=" + idParam +
            "&msg=" + java.net.URLEncoder.encode("✓ Cita solicitada correctamente. El agente la confirmará pronto.", "UTF-8"));
        return;
    } catch (Exception ex) {
        errorMsg = "Error al solicitar la cita: " + ex.getMessage();
    }
}

// ── GET: cargar propiedad ────────────────────────
if (db != null) {
    try {
        java.sql.PreparedStatement ps = db.prepareStatement(
            "SELECT p.*, u.nombre AS agente_nombre, u.apellido AS agente_apellido, " +
            "u.email AS agente_email, u.telefono AS agente_tel " +
            "FROM propiedades p " +
            "LEFT JOIN usuarios u ON u.id = p.agente_id " +
            "WHERE p.id = ?");
        ps.setInt(1, Integer.parseInt(idParam.trim()));
        java.sql.ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            prop = new java.util.LinkedHashMap<>();
            prop.put("id",           rs.getInt("id"));
            prop.put("titulo",       rs.getString("titulo") != null ? rs.getString("titulo") : "");
            prop.put("descripcion",  rs.getString("descripcion") != null ? rs.getString("descripcion") : "");
            prop.put("tipo",         rs.getString("tipo") != null ? rs.getString("tipo") : "");
            prop.put("operacion",    rs.getString("operacion") != null ? rs.getString("operacion") : "");
            prop.put("precio",       rs.getDouble("precio"));
            prop.put("area",         rs.getDouble("area"));
            prop.put("habitaciones", rs.getInt("habitaciones"));
            prop.put("banos",        rs.getInt("banos"));
            prop.put("garaje",       rs.getInt("garaje") == 1);
            prop.put("estado",       rs.getString("estado") != null ? rs.getString("estado") : "disponible");
            prop.put("direccion",    rs.getString("direccion") != null ? rs.getString("direccion") : "");
            prop.put("ciudad",       rs.getString("ciudad") != null ? rs.getString("ciudad") : "");
            prop.put("barrio",       rs.getString("barrio") != null ? rs.getString("barrio") : "");
            prop.put("foto",         rs.getString("foto_principal") != null ? rs.getString("foto_principal") :
                                     "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70");
            prop.put("fecha",        rs.getString("fecha_publicacion") != null ? rs.getString("fecha_publicacion") : "");
            prop.put("agenteNombre", rs.getString("agente_nombre") != null ? rs.getString("agente_nombre") + " " + (rs.getString("agente_apellido") != null ? rs.getString("agente_apellido") : "") : "InmoVista");
            prop.put("agenteEmail",  rs.getString("agente_email") != null ? rs.getString("agente_email") : "");
            prop.put("agenteTel",    rs.getString("agente_tel") != null ? rs.getString("agente_tel") : "");
            fotos.add((String)prop.get("foto"));
        }
        rs.close(); ps.close();

        // Cargar fotos adicionales de fotos_propiedades si existe
        try {
            java.sql.PreparedStatement ps2 = db.prepareStatement(
                "SELECT url FROM fotos_propiedades WHERE propiedad_id = ? ORDER BY id ASC LIMIT 6");
            ps2.setInt(1, Integer.parseInt(idParam.trim()));
            java.sql.ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                String url = rs2.getString("url");
                if (url != null && !url.isEmpty() && !fotos.contains(url)) fotos.add(url);
            }
            rs2.close(); ps2.close();
        } catch (Exception ex2) { /* tabla no existe, ignorar */ }

        db.close();
    } catch (Exception ex) {
        if (db != null) { try { db.close(); } catch(Exception e){} }
    }
}

if (prop == null) {
    response.sendRedirect(request.getContextPath() + "/lista.jsp");
    return;
}

request.setAttribute("prop",  prop);
request.setAttribute("fotos", fotos);
request.setAttribute("pageTitle", prop.get("titulo"));
if (errorMsg != null) request.setAttribute("error", errorMsg);
String flashMsg = request.getParameter("msg");
if (flashMsg != null) request.setAttribute("flash", flashMsg);
%>
<%@ include file="header.jsp" %>

<style>
/* ═══════════════════ DETALLE PAGE ═══════════════════ */
.detalle-hero {
  position: relative;
  height: 460px;
  overflow: hidden;
  background: var(--dark);
}
.detalle-hero img {
  width: 100%; height: 100%;
  object-fit: cover;
  opacity: 0.75;
  transition: opacity 0.4s;
}
.detalle-hero__overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to bottom, rgba(13,13,13,0.3) 0%, rgba(13,13,13,0.7) 100%);
}
.detalle-hero__badges {
  position: absolute;
  top: 24px; left: 32px;
  display: flex; gap: 8px;
}
.detalle-hero__title {
  position: absolute;
  bottom: 32px; left: 32px; right: 32px;
}
.badge-tipo {
  background: var(--gold);
  color: #0d0d0d;
  font-size: 0.72rem;
  font-weight: 700;
  padding: 5px 14px;
  border-radius: 30px;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.badge-operacion {
  background: rgba(255,255,255,0.15);
  backdrop-filter: blur(8px);
  color: #fff;
  font-size: 0.72rem;
  font-weight: 600;
  padding: 5px 14px;
  border-radius: 30px;
  border: 1px solid rgba(255,255,255,0.25);
  text-transform: uppercase;
  letter-spacing: 1px;
}
.badge-estado {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 5px 14px;
  border-radius: 30px;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.badge-estado.disponible { background: #1a7a4a; color: #fff; }
.badge-estado.reservada  { background: #b85c00; color: #fff; }
.badge-estado.vendida    { background: #7a1a1a; color: #fff; }
.badge-estado.arrendada  { background: #1a4a7a; color: #fff; }

.detalle-body { background: var(--background); min-height: 60vh; padding: 48px 0 80px; }

.detalle-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 28px 32px;
  margin-bottom: 24px;
}
.detalle-card__title {
  font-family: 'Playfair Display', serif;
  font-size: 1rem;
  font-weight: 700;
  color: var(--gold);
  text-transform: uppercase;
  letter-spacing: 2px;
  margin-bottom: 18px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 8px;
}
.precio-grande {
  font-family: 'Playfair Display', serif;
  font-size: 2.2rem;
  font-weight: 900;
  color: var(--gold);
  line-height: 1;
}
.precio-op {
  font-size: 0.8rem;
  color: var(--gray-3);
  margin-top: 4px;
}

.caract-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
}
.caract-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: var(--background);
  border-radius: 10px;
  border: 1px solid var(--border);
}
.caract-icon {
  width: 36px; height: 36px;
  background: rgba(201,168,76,0.12);
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  color: var(--gold);
  font-size: 1rem;
  flex-shrink: 0;
}
.caract-label { font-size: 0.72rem; color: var(--gray-3); margin-bottom: 1px; }
.caract-value { font-size: 0.95rem; font-weight: 600; color: var(--dark); }

/* Galería miniaturas */
.galeria-thumbs {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin-top: 12px;
}
.galeria-thumb {
  height: 70px;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.2s;
}
.galeria-thumb.active { border-color: var(--gold); }
.galeria-thumb img { width: 100%; height: 100%; object-fit: cover; }

/* Agente card */
.agente-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: var(--background);
  border-radius: 12px;
  border: 1px solid var(--border);
  margin-bottom: 16px;
}
.agente-avatar {
  width: 52px; height: 52px;
  background: var(--gold);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-family: 'Playfair Display', serif;
  font-size: 1.3rem;
  font-weight: 700;
  color: #0d0d0d;
  flex-shrink: 0;
}
.agente-info { flex: 1; }
.agente-nombre { font-weight: 700; color: var(--dark); margin-bottom: 2px; }
.agente-cargo  { font-size: 0.75rem; color: var(--gold); }

/* Formulario cita */
.cita-form .form-control, .cita-form .form-select {
  background: var(--background);
  border: 1px solid var(--border);
  color: var(--dark);
  border-radius: 8px;
  padding: 10px 14px;
}
.cita-form .form-control:focus, .cita-form .form-select:focus {
  border-color: var(--gold);
  box-shadow: 0 0 0 3px rgba(201,168,76,0.15);
}
.cita-form label { font-size: 0.82rem; font-weight: 600; color: var(--gray-2); margin-bottom: 5px; }

/* Map placeholder */
.map-placeholder {
  width: 100%; height: 200px;
  background: var(--background);
  border-radius: 10px;
  border: 1px solid var(--border);
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  color: var(--gray-3);
  gap: 8px;
}

/* breadcrumb */
.bcrumb a { color: var(--gray-3); font-size: 0.82rem; text-decoration: none; }
.bcrumb a:hover { color: var(--gold); }
.bcrumb span { color: var(--gray-3); font-size: 0.82rem; margin: 0 6px; }
</style>

<%
java.util.Map<String,Object> p = (java.util.Map<String,Object>) request.getAttribute("prop");
java.util.List<String> fotoList = (java.util.List<String>) request.getAttribute("fotos");
String fotoMain = (String) p.get("foto");
double precio = (double) p.get("precio");
String precioFmt = String.format("%,.0f", precio);
%>

<!-- HERO -->
<div class="detalle-hero">
  <img id="heroImg" src="${prop.foto}" alt="${prop.titulo}">
  <div class="detalle-hero__overlay"></div>
  <div class="detalle-hero__badges">
    <span class="badge-tipo">${prop.tipo}</span>
    <span class="badge-operacion">En ${prop.operacion}</span>
    <span class="badge-estado ${prop.estado}">${prop.estado}</span>
  </div>
  <div class="detalle-hero__title">
    <h1 style="font-family:'Playfair Display',serif;font-size:clamp(1.4rem,3vw,2.2rem);font-weight:900;color:#fff;margin-bottom:8px;line-height:1.2;">${prop.titulo}</h1>
    <div style="color:rgba(255,255,255,0.7);font-size:0.88rem;">
      <i class="fas fa-map-marker-alt me-1" style="color:var(--gold);"></i>
      ${not empty prop.barrio ? prop.barrio.concat(', ') : ''}${prop.ciudad}
      <c:if test="${not empty prop.direccion}"> — ${prop.direccion}</c:if>
    </div>
  </div>
</div>

<!-- BODY -->
<div class="detalle-body">
  <div class="container">

    <!-- Breadcrumb + flash -->
    <div class="bcrumb mb-3">
      <a href="${ctx}/index.jsp"><i class="fas fa-home me-1"></i>Inicio</a>
      <span>›</span>
      <a href="${ctx}/lista.jsp">Propiedades</a>
      <span>›</span>
      <span style="color:var(--dark);">${prop.titulo}</span>
    </div>

    <c:if test="${not empty flash}">
      <div class="alert-inmovista alert-success-custom mb-4">
        <i class="fas fa-check-circle"></i> ${flash}
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert-inmovista alert-error-custom mb-4">
        <i class="fas fa-exclamation-circle"></i> ${error}
      </div>
    </c:if>

    <div class="row g-4">
      <!-- ═══ COLUMNA PRINCIPAL ═══ -->
      <div class="col-lg-8">

        <!-- Precio + galería -->
        <div class="detalle-card">
          <div class="d-flex justify-content-between align-items-start flex-wrap gap-3 mb-4">
            <div>
              <div class="precio-grande">$<%= precioFmt %> COP</div>
              <div class="precio-op">${prop.operacion == 'arriendo' ? 'Mensual' : 'Precio de venta'}</div>
            </div>
            <div class="d-flex gap-2">
              <a href="${ctx}/lista.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                <i class="fas fa-arrow-left me-1"></i> Volver
              </a>
              <c:if test="${sessionScope.rolNombre == 'inmobiliaria' || sessionScope.rolNombre == 'admin'}">
                <a href="${ctx}/formulario.jsp?id=${prop.id}" class="btn btn-sm rounded-pill px-3" style="background:var(--gold);color:#0d0d0d;font-weight:700;">
                  <i class="fas fa-edit me-1"></i> Editar
                </a>
              </c:if>
            </div>
          </div>

          <!-- Galería miniaturas -->
          <c:if test="${fotos.size() > 1}">
            <div class="galeria-thumbs">
              <c:forEach var="f" items="${fotos}" varStatus="st">
                <div class="galeria-thumb ${st.index == 0 ? 'active' : ''}"
                     onclick="cambiarFoto(this, '${f}')">
                  <img src="${f}" alt="Foto ${st.index + 1}">
                </div>
              </c:forEach>
            </div>
          </c:if>
        </div>

        <!-- Descripción -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-align-left"></i> Descripción
          </div>
          <p style="color:var(--gray-2);line-height:1.8;font-size:0.95rem;margin:0;">
            <c:choose>
              <c:when test="${not empty prop.descripcion}">${prop.descripcion}</c:when>
              <c:otherwise>Esta propiedad no tiene descripción disponible aún.</c:otherwise>
            </c:choose>
          </p>
        </div>

        <!-- Características -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-list-ul"></i> Características
          </div>
          <div class="caract-grid">
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-home"></i></div>
              <div>
                <div class="caract-label">Tipo</div>
                <div class="caract-value" style="text-transform:capitalize;">${prop.tipo}</div>
              </div>
            </div>
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-ruler-combined"></i></div>
              <div>
                <div class="caract-label">Área</div>
                <div class="caract-value">${prop.area > 0 ? prop.area.intValue().concat(' m²') : 'No especificada'}</div>
              </div>
            </div>
            <c:if test="${prop.habitaciones > 0}">
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-bed"></i></div>
              <div>
                <div class="caract-label">Habitaciones</div>
                <div class="caract-value">${prop.habitaciones}</div>
              </div>
            </div>
            </c:if>
            <c:if test="${prop.banos > 0}">
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-bath"></i></div>
              <div>
                <div class="caract-label">Baños</div>
                <div class="caract-value">${prop.banos}</div>
              </div>
            </div>
            </c:if>
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-car"></i></div>
              <div>
                <div class="caract-label">Garaje</div>
                <div class="caract-value">${prop.garaje ? 'Sí incluye' : 'No incluye'}</div>
              </div>
            </div>
            <div class="caract-item">
              <div class="caract-icon"><i class="fas fa-tag"></i></div>
              <div>
                <div class="caract-label">Operación</div>
                <div class="caract-value" style="text-transform:capitalize;">${prop.operacion}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Ubicación + mapa -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-map-marker-alt"></i> Ubicación
          </div>
          <p style="color:var(--gray-2);font-size:0.92rem;margin-bottom:16px;">
            <i class="fas fa-map-pin me-2" style="color:var(--gold);"></i>
            ${not empty prop.direccion ? prop.direccion.concat(', ') : ''}
            ${not empty prop.barrio ? prop.barrio.concat(', ') : ''}
            ${prop.ciudad}
          </p>
          <div class="map-placeholder">
            <i class="fas fa-map-marked-alt" style="font-size:2rem;color:var(--gold);"></i>
            <span style="font-size:0.85rem;">Mapa disponible próximamente</span>
            <span style="font-size:0.75rem;">${prop.ciudad}</span>
          </div>
        </div>

      </div>

      <!-- ═══ COLUMNA LATERAL ═══ -->
      <div class="col-lg-4">

        <!-- Agente -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-user-tie"></i> Agente
          </div>
          <div class="agente-card">
            <div class="agente-avatar">
              ${fn:substring(prop.agenteNombre, 0, 1)}
            </div>
            <div class="agente-info">
              <div class="agente-nombre">${prop.agenteNombre}</div>
              <div class="agente-cargo">Agente InmoVista</div>
            </div>
          </div>
          <c:if test="${not empty prop.agenteTel}">
            <a href="tel:${prop.agenteTel}" class="d-flex align-items-center gap-2 mb-2"
               style="color:var(--gray-2);font-size:0.85rem;text-decoration:none;">
              <i class="fas fa-phone" style="color:var(--gold);"></i> ${prop.agenteTel}
            </a>
          </c:if>
          <c:if test="${not empty prop.agenteEmail}">
            <a href="mailto:${prop.agenteEmail}" class="d-flex align-items-center gap-2"
               style="color:var(--gray-2);font-size:0.85rem;text-decoration:none;">
              <i class="fas fa-envelope" style="color:var(--gold);"></i> ${prop.agenteEmail}
            </a>
          </c:if>
        </div>

        <!-- Solicitar cita -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-calendar-plus"></i> Solicitar Visita
          </div>

          <c:choose>
            <c:when test="${sessionScope.rolNombre == 'cliente'}">
              <c:if test="${prop.estado != 'vendida' && prop.estado != 'arrendada'}">
                <form action="${ctx}/detalle.jsp?id=${prop.id}" method="post" class="cita-form">
                  <div class="mb-3">
                    <label>Fecha de visita <span class="text-danger">*</span></label>
                    <input type="date" name="fecha" class="form-control" required
                           min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                  </div>
                  <div class="mb-3">
                    <label>Hora preferida <span class="text-danger">*</span></label>
                    <select name="hora" class="form-select" required>
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
                    <label>Mensaje opcional</label>
                    <textarea name="mensaje" class="form-control" rows="3"
                              placeholder="Ej: Me interesa conocer el estado de los acabados..."></textarea>
                  </div>
                  <button type="submit" class="btn-gold w-100 py-2"
                          style="border:none;border-radius:10px;font-weight:700;font-size:0.92rem;">
                    <i class="fas fa-calendar-check me-2"></i> Agendar Visita
                  </button>
                </form>
              </c:if>
              <c:if test="${prop.estado == 'vendida' || prop.estado == 'arrendada'}">
                <div style="text-align:center;padding:20px;color:var(--gray-3);">
                  <i class="fas fa-lock" style="font-size:2rem;margin-bottom:8px;display:block;"></i>
                  Esta propiedad ya no está disponible.
                </div>
              </c:if>
            </c:when>
            <c:when test="${empty sessionScope.usuario}">
              <div style="text-align:center;padding:16px;">
                <p style="color:var(--gray-3);font-size:0.88rem;margin-bottom:16px;">
                  Inicia sesión como cliente para solicitar una visita.
                </p>
                <a href="${ctx}/login.jsp" class="btn-gold px-4 py-2"
                   style="border:none;border-radius:10px;font-weight:700;font-size:0.88rem;text-decoration:none;">
                  <i class="fas fa-sign-in-alt me-2"></i> Iniciar Sesión
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div style="text-align:center;padding:16px;color:var(--gray-3);font-size:0.88rem;">
                <i class="fas fa-info-circle me-1"></i>
                Solo los clientes pueden solicitar visitas.
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Compartir -->
        <div class="detalle-card">
          <div class="detalle-card__title">
            <i class="fas fa-share-alt"></i> Compartir
          </div>
          <div class="d-flex gap-2 flex-wrap">
            <a href="https://wa.me/?text=${prop.titulo}%20-%20${ctx}/detalle.jsp?id=${prop.id}"
               target="_blank" class="btn btn-sm rounded-pill px-3"
               style="background:#25d366;color:#fff;font-size:0.8rem;">
              <i class="fab fa-whatsapp me-1"></i> WhatsApp
            </a>
            <button onclick="navigator.clipboard.writeText(window.location.href);this.textContent='¡Copiado!';"
                    class="btn btn-sm btn-outline-secondary rounded-pill px-3" style="font-size:0.8rem;">
              <i class="fas fa-link me-1"></i> Copiar enlace
            </button>
          </div>
        </div>

      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jsp" %>
<script>
function cambiarFoto(thumb, url) {
  document.getElementById('heroImg').src = url;
  document.querySelectorAll('.galeria-thumb').forEach(t => t.classList.remove('active'));
  thumb.classList.add('active');
}
</script>
