<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
/* ═══════════════════════════════════════════════════
   FORMULARIO.JSP · InmoVista
   Crear y editar propiedades. Solo accesible para
   inmobiliaria y admin.
═══════════════════════════════════════════════════ */

// ── Protección de sesión ──────────────────────────
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolF = (String) session.getAttribute("rolNombre");
if (!"inmobiliaria".equals(rolF) && !"admin".equals(rolF)) {
    response.sendRedirect(request.getContextPath() + "/" + rolF + ".jsp");
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

String errorMsg = null;

// ════════════════════════════════════════════════════
// HANDLE POST — crear o editar
// ════════════════════════════════════════════════════
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action      = request.getParameter("action");
    String titulo      = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String tipo        = request.getParameter("tipo");
    String operacion   = request.getParameter("operacion");
    String precioStr   = request.getParameter("precio");
    String areaStr     = request.getParameter("area");
    String habitStr    = request.getParameter("habitaciones");
    String banosStr    = request.getParameter("banos");
    String garaje      = request.getParameter("garaje");
    String estado      = request.getParameter("estado");
    String direccion   = request.getParameter("direccion");
    String ciudad      = request.getParameter("ciudad");
    String barrio      = request.getParameter("barrio");
    String fotoPrincipal = request.getParameter("fotoPrincipal");

    // Validación básica
    if (titulo == null || titulo.trim().isEmpty() ||
        tipo == null || tipo.isEmpty() ||
        operacion == null || operacion.isEmpty() ||
        precioStr == null || precioStr.isEmpty() ||
        ciudad == null || ciudad.trim().isEmpty()) {
        errorMsg = "Por favor completa todos los campos obligatorios (título, tipo, operación, precio y ciudad).";
    } else if (db == null) {
        errorMsg = "No hay conexión con la base de datos. Verifica que MySQL esté activo.";
    } else {
        try {
            double precio = Double.parseDouble(precioStr.replace(",","").replace("$","").trim());
            double area   = (areaStr != null && !areaStr.isEmpty()) ? Double.parseDouble(areaStr) : 0;
            int habitaciones = (habitStr != null && !habitStr.isEmpty()) ? Integer.parseInt(habitStr) : 0;
            int banos    = (banosStr != null && !banosStr.isEmpty()) ? Integer.parseInt(banosStr) : 0;
            boolean tieneGaraje = "on".equals(garaje) || "true".equals(garaje) || "1".equals(garaje);
            if (estado == null || estado.isEmpty()) estado = "disponible";
            if (fotoPrincipal == null || fotoPrincipal.trim().isEmpty())
                fotoPrincipal = "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=70";

            if ("editar".equals(action)) {
                // ── UPDATE ───────────────────────────────────
                String idStr = request.getParameter("id");
                java.sql.PreparedStatement ps = db.prepareStatement(
                    "UPDATE propiedades SET titulo=?, descripcion=?, tipo=?, operacion=?, " +
                    "precio=?, area=?, habitaciones=?, banos=?, garaje=?, estado=?, " +
                    "direccion=?, ciudad=?, barrio=?, foto_principal=? WHERE id=?");
                ps.setString(1,  titulo.trim());
                ps.setString(2,  descripcion != null ? descripcion.trim() : "");
                ps.setString(3,  tipo);
                ps.setString(4,  operacion);
                ps.setDouble(5,  precio);
                ps.setDouble(6,  area);
                ps.setInt(7,     habitaciones);
                ps.setInt(8,     banos);
                ps.setInt(9,     tieneGaraje ? 1 : 0);
                ps.setString(10, estado);
                ps.setString(11, direccion != null ? direccion.trim() : "");
                ps.setString(12, ciudad.trim());
                ps.setString(13, barrio != null ? barrio.trim() : "");
                ps.setString(14, fotoPrincipal.trim());
                ps.setInt(15,    Integer.parseInt(idStr));
                ps.executeUpdate(); ps.close();
                if (db != null) { try { db.close(); } catch(Exception e){} }
                response.sendRedirect(request.getContextPath() + "/" + rolF + ".jsp?tab=propiedades&msg=" +
                    java.net.URLEncoder.encode("✓ Propiedad actualizada correctamente.", "UTF-8"));
                return;

            } else {
                // ── INSERT ───────────────────────────────────
                java.sql.PreparedStatement ps = db.prepareStatement(
                    "INSERT INTO propiedades (titulo, descripcion, tipo, operacion, precio, area, " +
                    "habitaciones, banos, garaje, estado, direccion, ciudad, barrio, foto_principal, fecha_publicacion) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW())");
                ps.setString(1,  titulo.trim());
                ps.setString(2,  descripcion != null ? descripcion.trim() : "");
                ps.setString(3,  tipo);
                ps.setString(4,  operacion);
                ps.setDouble(5,  precio);
                ps.setDouble(6,  area);
                ps.setInt(7,     habitaciones);
                ps.setInt(8,     banos);
                ps.setInt(9,     tieneGaraje ? 1 : 0);
                ps.setString(10, "disponible");
                ps.setString(11, direccion != null ? direccion.trim() : "");
                ps.setString(12, ciudad.trim());
                ps.setString(13, barrio != null ? barrio.trim() : "");
                ps.setString(14, fotoPrincipal.trim());
                ps.executeUpdate(); ps.close();
                if (db != null) { try { db.close(); } catch(Exception e){} }
                response.sendRedirect(request.getContextPath() + "/" + rolF + ".jsp?tab=propiedades&msg=" +
                    java.net.URLEncoder.encode("✓ Propiedad publicada correctamente.", "UTF-8"));
                return;
            }
        } catch (Exception ex) {
            errorMsg = "Error al guardar: " + ex.getMessage() + (ex.getCause() != null ? " — " + ex.getCause().getMessage() : "");
        }
    }
    if (db != null) { try { db.close(); } catch(Exception e){} }
    request.setAttribute("error", errorMsg);
    // Fall through to render form again with error
}

// ════════════════════════════════════════════════════
// GET — cargar propiedad existente si es edición
// ════════════════════════════════════════════════════
String idParam = request.getParameter("id");
java.util.Map<String,Object> propiedad = null;

if (idParam != null && !idParam.trim().isEmpty() && db != null) {
    try {
        java.sql.PreparedStatement ps = db.prepareStatement(
            "SELECT * FROM propiedades WHERE id=?");
        ps.setInt(1, Integer.parseInt(idParam.trim()));
        java.sql.ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            propiedad = new java.util.LinkedHashMap<>();
            propiedad.put("id",           rs.getInt("id"));
            propiedad.put("titulo",       rs.getString("titulo") != null ? rs.getString("titulo") : "");
            propiedad.put("descripcion",  rs.getString("descripcion") != null ? rs.getString("descripcion") : "");
            propiedad.put("tipo",         rs.getString("tipo") != null ? rs.getString("tipo") : "");
            propiedad.put("operacion",    rs.getString("operacion") != null ? rs.getString("operacion") : "");
            propiedad.put("precio",       rs.getDouble("precio"));
            propiedad.put("area",         rs.getDouble("area"));
            propiedad.put("habitaciones", rs.getInt("habitaciones"));
            propiedad.put("banos",        rs.getInt("banos"));
            propiedad.put("garaje",       rs.getInt("garaje") == 1);
            propiedad.put("estado",       rs.getString("estado") != null ? rs.getString("estado") : "disponible");
            propiedad.put("direccion",    rs.getString("direccion") != null ? rs.getString("direccion") : "");
            propiedad.put("ciudad",       rs.getString("ciudad") != null ? rs.getString("ciudad") : "");
            propiedad.put("barrio",       rs.getString("barrio") != null ? rs.getString("barrio") : "");
            propiedad.put("fotoPrincipal",rs.getString("foto_principal") != null ? rs.getString("foto_principal") : "");
        }
        rs.close(); ps.close();
        db.close();
    } catch (Exception ex) {
        if (db != null) { try { db.close(); } catch(Exception e){} }
    }
} else if (db != null) {
    try { db.close(); } catch(Exception e){}
}

request.setAttribute("propiedad", propiedad);
if (errorMsg != null) request.setAttribute("error", errorMsg);
%>
<c:set var="esEdicion" value="${not empty propiedad}"/>
<c:set var="pageTitle" value="${esEdicion ? 'Editar Propiedad' : 'Nueva Propiedad'}" scope="request"/>
<%@ include file="header.jsp" %>

<div class="dashboard-layout">
  <%@ include file="sidebar.jsp" %>

  <main class="dashboard-main">
    <div class="dashboard-header">
      <div class="d-flex align-items-center gap-3 mb-1">
        <a href="${pageContext.request.contextPath}/${sessionScope.rolNombre}.jsp"
           style="color:var(--gray-3);font-size:0.85rem;">Dashboard</a>
        <span style="color:var(--gray-3);">›</span>
        <span style="font-size:0.85rem;color:var(--dark);">
          ${esEdicion ? 'Editar Propiedad' : 'Nueva Propiedad'}
        </span>
      </div>
      <div class="dashboard-title">
        <i class="fas fa-${esEdicion ? 'edit' : 'plus-circle'} me-2" style="color:var(--gold);"></i>
        ${esEdicion ? 'Editar Propiedad' : 'Publicar Nueva Propiedad'}
      </div>
    </div>

    <!-- Mensajes -->
    <c:if test="${not empty error}">
      <div class="alert-inmovista alert-error-custom mb-4">
        <i class="fas fa-exclamation-circle"></i> ${error}
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/formulario.jsp" method="post"
          id="propForm" novalidate>
      <input type="hidden" name="action" value="${esEdicion ? 'editar' : 'agregar'}">
      <c:if test="${esEdicion}">
        <input type="hidden" name="id" value="${propiedad.id}">
      </c:if>

      <div class="row g-4">
        <!-- ===== COLUMNA PRINCIPAL ===== -->
        <div class="col-lg-8">

          <!-- Información básica -->
          <div class="form-section">
            <div class="form-section-title">
              <i class="fas fa-info-circle" style="color:var(--gold);"></i> Información Básica
            </div>
            <div class="mb-3">
              <label class="form-label">Título del anuncio <span class="text-danger">*</span></label>
              <input type="text" name="titulo" class="form-control"
                     placeholder="Ej: Hermosa casa en sector residencial..."
                     value="${propiedad.titulo}" required maxlength="200"
                     oninput="document.getElementById('tituloCount').textContent=this.value.length">
              <div style="font-size:0.75rem;color:var(--gray-3);text-align:right;margin-top:4px;">
                <span id="tituloCount">${not empty propiedad.titulo ? fn:length(propiedad.titulo) : 0}</span>/200
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label">Descripción completa <span class="text-danger">*</span></label>
              <textarea name="descripcion" class="form-control" rows="5"
                        placeholder="Describe detalladamente la propiedad: características, estado, acabados, entorno...">${propiedad.descripcion}</textarea>
            </div>
            <div class="row g-3">
              <div class="col-6">
                <label class="form-label">Tipo de inmueble <span class="text-danger">*</span></label>
                <select name="tipo" class="form-select" required>
                  <option value="">Seleccionar tipo</option>
                  <option value="casa"        ${propiedad.tipo == 'casa'        ? 'selected' : ''}>🏠 Casa</option>
                  <option value="apartamento" ${propiedad.tipo == 'apartamento' ? 'selected' : ''}>🏢 Apartamento</option>
                  <option value="terreno"     ${propiedad.tipo == 'terreno'     ? 'selected' : ''}>🌄 Terreno</option>
                  <option value="oficina"     ${propiedad.tipo == 'oficina'     ? 'selected' : ''}>💼 Oficina</option>
                  <option value="local"       ${propiedad.tipo == 'local'       ? 'selected' : ''}>🏪 Local Comercial</option>
                </select>
              </div>
              <div class="col-6">
                <label class="form-label">Operación <span class="text-danger">*</span></label>
                <select name="operacion" class="form-select" required>
                  <option value="">Seleccionar</option>
                  <option value="venta"    ${propiedad.operacion == 'venta'    ? 'selected' : ''}>💰 En Venta</option>
                  <option value="arriendo" ${propiedad.operacion == 'arriendo' ? 'selected' : ''}>🔑 En Arriendo</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Características -->
          <div class="form-section">
            <div class="form-section-title">
              <i class="fas fa-list" style="color:var(--gold);"></i> Características
            </div>
            <div class="row g-3">
              <div class="col-6 col-md-3">
                <label class="form-label">Precio (COP) <span class="text-danger">*</span></label>
                <input type="number" name="precio" class="form-control"
                       placeholder="0" value="${propiedad.precio}" required min="0">
              </div>
              <div class="col-6 col-md-3">
                <label class="form-label">Área (m²)</label>
                <input type="number" name="area" class="form-control"
                       placeholder="0" value="${propiedad.area}" min="0" step="0.01">
              </div>
              <div class="col-6 col-md-3">
                <label class="form-label">Habitaciones</label>
                <input type="number" name="habitaciones" class="form-control"
                       placeholder="0" value="${propiedad.habitaciones}" min="0" max="20">
              </div>
              <div class="col-6 col-md-3">
                <label class="form-label">Baños</label>
                <input type="number" name="banos" class="form-control"
                       placeholder="0" value="${propiedad.banos}" min="0" max="10">
              </div>
              <div class="col-6 col-md-3">
                <label class="form-label">¿Tiene garaje?</label>
                <div class="d-flex gap-3 mt-2">
                  <div class="form-check">
                    <input class="form-check-input" type="radio" name="garaje" value="on"
                           id="garajeSi" ${propiedad.garaje ? 'checked' : ''}>
                    <label class="form-check-label" for="garajeSi">Sí</label>
                  </div>
                  <div class="form-check">
                    <input class="form-check-input" type="radio" name="garaje" value="off"
                           id="garajeNo" ${!propiedad.garaje ? 'checked' : ''}>
                    <label class="form-check-label" for="garajeNo">No</label>
                  </div>
                </div>
              </div>
              <c:if test="${esEdicion}">
              <div class="col-6 col-md-3">
                <label class="form-label">Estado</label>
                <select name="estado" class="form-select">
                  <option value="disponible" ${propiedad.estado == 'disponible' ? 'selected' : ''}>Disponible</option>
                  <option value="reservada"  ${propiedad.estado == 'reservada'  ? 'selected' : ''}>Reservada</option>
                  <option value="vendida"    ${propiedad.estado == 'vendida'    ? 'selected' : ''}>Vendida</option>
                  <option value="arrendada"  ${propiedad.estado == 'arrendada'  ? 'selected' : ''}>Arrendada</option>
                </select>
              </div>
              </c:if>
            </div>
          </div>

          <!-- Ubicación -->
          <div class="form-section">
            <div class="form-section-title">
              <i class="fas fa-map-marker-alt" style="color:var(--gold);"></i> Ubicación
            </div>
            <div class="row g-3">
              <div class="col-12">
                <label class="form-label">Dirección completa <span class="text-danger">*</span></label>
                <input type="text" name="direccion" class="form-control"
                       placeholder="Calle, Carrera, Número..." value="${propiedad.direccion}">
              </div>
              <div class="col-6">
                <label class="form-label">Ciudad <span class="text-danger">*</span></label>
                <input type="text" name="ciudad" class="form-control"
                       placeholder="Bucaramanga" value="${propiedad.ciudad}" required>
              </div>
              <div class="col-6">
                <label class="form-label">Barrio / Sector</label>
                <input type="text" name="barrio" class="form-control"
                       placeholder="Nombre del barrio" value="${propiedad.barrio}">
              </div>
            </div>
          </div>

        </div>

        <!-- ===== COLUMNA LATERAL ===== -->
        <div class="col-lg-4">

          <!-- Upload de fotos -->
          <div class="form-section mb-4">
            <div class="form-section-title">
              <i class="fas fa-images" style="color:var(--gold);"></i> Fotos de la Propiedad
            </div>

            <!-- Fotos actuales (edición) -->
            <c:if test="${esEdicion and not empty propiedad.fotos}">
              <div class="mb-3">
                <div style="font-size:0.8rem;color:var(--gray-3);margin-bottom:8px;">Fotos actuales:</div>
                <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:6px;">
                  <c:forEach var="foto" items="${propiedad.fotos}">
                    <div style="position:relative;height:70px;border-radius:6px;overflow:hidden;">
                      <img src="${foto}" style="width:100%;height:100%;object-fit:cover;">
                    </div>
                  </c:forEach>
                </div>
              </div>
            </c:if>

            <!-- Drop zone -->
            <div class="upload-area" id="uploadArea"
                 onclick="document.getElementById('fotosInput').click()">
              <div class="upload-icon"><i class="fas fa-cloud-upload-alt"></i></div>
              <div style="font-weight:600;margin-bottom:4px;">Arrastra o haz click para subir</div>
              <div style="font-size:0.8rem;color:var(--gray-3);">JPG, PNG, WEBP — Máx 5MB c/u</div>
              <input type="file" id="fotosInput" name="fotos" multiple accept="image/*"
                     style="display:none;" onchange="previewFotos(this)">
            </div>
            <!-- Preview -->
            <div id="fotosPreview" class="mt-2"
                 style="display:grid;grid-template-columns:repeat(3,1fr);gap:6px;"></div>
          </div>

          <!-- Resumen precio -->
          <div class="form-section">
            <div class="form-section-title">
              <i class="fas fa-dollar-sign" style="color:var(--gold);"></i> Resumen
            </div>
            <div id="resumenPrecio" style="font-family:'Playfair Display',serif;font-size:1.6rem;font-weight:700;color:var(--dark);text-align:center;padding:16px 0;">
              $0 COP
            </div>
            <button type="submit" class="btn-gold w-100 py-3 mt-2"
                    style="border:none;border-radius:10px;font-size:1rem;font-weight:700;">
              <i class="fas fa-${esEdicion ? 'save' : 'paper-plane'} me-2"></i>
              ${esEdicion ? 'Guardar Cambios' : 'Publicar Propiedad'}
            </button>
            <a href="${pageContext.request.contextPath}/${sessionScope.rolNombre}.jsp"
               class="d-block text-center mt-2" style="font-size:0.88rem;color:var(--gray-3);">
              Cancelar
            </a>
          </div>

        </div>
      </div>
    </form>
  </main>
</div>

<%@ include file="footer.jsp" %>
<script>
  // Preview fotos
  function previewFotos(input) {
    const preview = document.getElementById('fotosPreview');
    preview.innerHTML = '';
    [...input.files].forEach(file => {
      const reader = new FileReader();
      reader.onload = e => {
        const div = document.createElement('div');
        div.style.cssText = 'height:70px;border-radius:6px;overflow:hidden;';
        div.innerHTML = `<img src="${e.target.result}" style="width:100%;height:100%;object-fit:cover;">`;
        preview.appendChild(div);
      };
      reader.readAsDataURL(file);
    });
  }

  // Drag & drop
  const area = document.getElementById('uploadArea');
  area.addEventListener('dragover', e => { e.preventDefault(); area.style.borderColor = 'var(--gold)'; });
  area.addEventListener('dragleave', () => area.style.borderColor = 'var(--gray-2)');
  area.addEventListener('drop', e => {
    e.preventDefault();
    area.style.borderColor = 'var(--gray-2)';
    const dt = new DataTransfer();
    [...document.getElementById('fotosInput').files, ...e.dataTransfer.files].forEach(f => dt.items.add(f));
    document.getElementById('fotosInput').files = dt.files;
    previewFotos(document.getElementById('fotosInput'));
  });

  // Actualizar resumen precio
  document.querySelector('input[name="precio"]').addEventListener('input', function() {
    const v = parseFloat(this.value) || 0;
    document.getElementById('resumenPrecio').textContent =
      '$' + v.toLocaleString('es-CO') + ' COP';
  });

  // Init precio si hay valor
  const precioInit = document.querySelector('input[name="precio"]').value;
  if (precioInit) {
    document.getElementById('resumenPrecio').textContent =
      '$' + parseFloat(precioInit).toLocaleString('es-CO') + ' COP';
  }
</script>
