<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════
   DOCUMENTOS.JSP — InmoVista
   Permite al cliente subir papeles de compra/arriendo.
   Solo accesible para rol 'cliente'.
═══════════════════════════════════════════════════ */
String rolSesion = (String) session.getAttribute("rolNombre");
if (!"cliente".equals(rolSesion)) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

Integer userId = (Integer) session.getAttribute("userId");
String flashMsg = null;
String flashType = "success";
java.util.List<java.util.Map<String, Object>> misDocumentos = new java.util.ArrayList<>();

// ── Cargar documentos existentes del cliente ──────────
java.sql.Connection db = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
        "root", "");

    java.sql.PreparedStatement ps = db.prepareStatement(
        "SELECT d.id, d.nombre_archivo, d.tipo_doc, d.fecha_subida, " +
        "COALESCE(p.titulo,'General') AS propiedad " +
        "FROM documentos d " +
        "LEFT JOIN propiedades p ON d.propiedad_id = p.id " +
        "WHERE d.cliente_id = ? ORDER BY d.fecha_subida DESC");
    ps.setInt(1, userId);
    java.sql.ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        java.util.Map<String, Object> doc = new java.util.LinkedHashMap<>();
        doc.put("id",            rs.getInt("id"));
        doc.put("nombre",        rs.getString("nombre_archivo"));
        doc.put("tipo",          rs.getString("tipo_doc") != null ? rs.getString("tipo_doc") : "Otro");
        doc.put("fecha",         rs.getString("fecha_subida"));
        doc.put("propiedad",     rs.getString("propiedad"));
        misDocumentos.add(doc);
    }
    rs.close(); ps.close();
} catch (Exception e) {
    flashMsg  = "No se pudo conectar a la base de datos: " + e.getMessage();
    flashType = "danger";
} finally {
    if (db != null) try { db.close(); } catch (Exception ignored) {}
}

request.setAttribute("misDocumentos", misDocumentos);
request.setAttribute("flashMsg",      flashMsg);
request.setAttribute("flashType",     flashType);
%>
<c:set var="pageTitle" value="Mis Documentos" scope="request"/>
<%@ include file="header.jsp" %>

<style>
.doc-layout { display: grid; grid-template-columns: 280px 1fr; gap: 0; min-height: calc(100vh - 70px); }
.doc-sidebar { background: #111118; border-right: 1px solid rgba(201,168,76,.15); padding: 28px 20px; }
.doc-main { background: #0d0d14; padding: 36px; }
.doc-title { font-family: 'Playfair Display', serif; font-size: 1.6rem; font-weight: 700; color: #c9a84c; margin-bottom: 4px; }
.doc-subtitle { font-family: 'DM Sans', sans-serif; font-size: .85rem; color: rgba(255,255,255,.4); margin-bottom: 28px; }

/* Upload card */
.upload-card { background: rgba(255,255,255,.03); border: 1px solid rgba(201,168,76,.2); border-radius: 16px; padding: 28px; margin-bottom: 28px; }
.upload-card h5 { font-family: 'Playfair Display', serif; color: #c9a84c; font-size: 1.1rem; margin-bottom: 20px; }
.form-label-gold { font-family: 'DM Sans', sans-serif; font-size: .8rem; font-weight: 600; color: rgba(255,255,255,.6); letter-spacing: 1px; text-transform: uppercase; margin-bottom: 6px; }
.form-control-dark, .form-select-dark {
  background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.1);
  border-radius: 10px; color: #fff; padding: 10px 14px;
  font-family: 'DM Sans', sans-serif; font-size: .88rem; width: 100%;
  transition: border-color .2s;
}
.form-control-dark:focus, .form-select-dark:focus {
  outline: none; border-color: rgba(201,168,76,.6);
  background: rgba(255,255,255,.08); color: #fff;
}
.form-select-dark option { background: #111118; color: #fff; }

/* Drop zone */
.drop-zone {
  border: 2px dashed rgba(201,168,76,.3); border-radius: 12px;
  padding: 36px; text-align: center; cursor: pointer;
  transition: all .3s; background: rgba(201,168,76,.03);
  position: relative;
}
.drop-zone:hover, .drop-zone.dragover { border-color: #c9a84c; background: rgba(201,168,76,.08); }
.drop-zone input[type=file] { position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; }
.drop-zone i { font-size: 2rem; color: rgba(201,168,76,.5); margin-bottom: 10px; display: block; }
.drop-zone p { font-family: 'DM Sans', sans-serif; font-size: .85rem; color: rgba(255,255,255,.4); margin: 0; }
.drop-zone .file-name { color: #c9a84c; font-weight: 600; margin-top: 8px; font-size: .88rem; }

.btn-gold { background: linear-gradient(135deg,#c9a84c,#b8962a); color: #0d0d0d; border: none; border-radius: 10px; padding: 11px 28px; font-family: 'DM Sans', sans-serif; font-weight: 700; font-size: .88rem; cursor: pointer; transition: all .3s; }
.btn-gold:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(201,168,76,.4); }

/* Tabla de documentos */
.docs-table { width: 100%; border-collapse: collapse; }
.docs-table th { font-family: 'DM Sans', sans-serif; font-size: .72rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: rgba(255,255,255,.3); padding: 10px 14px; border-bottom: 1px solid rgba(255,255,255,.06); text-align: left; }
.docs-table td { font-family: 'DM Sans', sans-serif; font-size: .85rem; color: rgba(255,255,255,.75); padding: 14px; border-bottom: 1px solid rgba(255,255,255,.04); vertical-align: middle; }
.docs-table tr:hover td { background: rgba(255,255,255,.02); }
.badge-tipo { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: .7rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; background: rgba(201,168,76,.12); color: #c9a84c; border: 1px solid rgba(201,168,76,.25); }
.empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,.25); }
.empty-state i { font-size: 3rem; margin-bottom: 14px; display: block; color: rgba(201,168,76,.2); }
.alert-flash { border-radius: 12px; padding: 14px 18px; font-family: 'DM Sans', sans-serif; font-size: .88rem; margin-bottom: 20px; }
@media (max-width: 768px) { .doc-layout { grid-template-columns: 1fr; } .doc-sidebar { display: none; } }
</style>

<div class="doc-layout">
  <%@ include file="sidebar.jsp" %>

  <main class="doc-main">
    <div class="doc-title"><i class="fas fa-folder-open me-2"></i>Mis Documentos</div>
    <div class="doc-subtitle">Sube tus papeles de compra o arriendo de forma segura</div>

    <c:if test="${not empty flashMsg}">
      <div class="alert-flash alert-${flashType}">${flashMsg}</div>
    </c:if>

    <!-- Formulario de subida -->
    <div class="upload-card">
      <h5><i class="fas fa-cloud-upload-alt me-2"></i>Subir Nuevo Documento</h5>
      <form action="${ctx}/SubirDocumentoServlet" method="post" enctype="multipart/form-data" id="uploadForm">

        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label-gold">Tipo de Documento</label>
            <select name="tipoDoc" class="form-select-dark" required>
              <option value="">Selecciona el tipo...</option>
              <option value="cedula">Cédula de Ciudadanía</option>
              <option value="comprobante_ingresos">Comprobante de Ingresos</option>
              <option value="desprendible_pago">Desprendible de Pago</option>
              <option value="extracto_bancario">Extracto Bancario</option>
              <option value="declaracion_renta">Declaración de Renta</option>
              <option value="carta_laboral">Carta Laboral</option>
              <option value="contrato">Contrato / Promesa</option>
              <option value="otro">Otro</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label-gold">Propiedad Relacionada (opcional)</label>
            <input type="text" name="propiedadTitulo" class="form-control-dark" placeholder="Ej: Casa en Cabecera (opcional)">
            <input type="hidden" name="propiedadId" id="propiedadId" value="">
          </div>
          <div class="col-12">
            <label class="form-label-gold">Archivo</label>
            <div class="drop-zone" id="dropZone">
              <input type="file" name="archivo" id="archivoInput" accept=".pdf,.jpg,.jpeg,.png,.doc,.docx" required>
              <i class="fas fa-file-upload"></i>
              <p>Arrastra tu archivo aquí o <strong style="color:#c9a84c;">haz clic para seleccionar</strong></p>
              <p style="font-size:.75rem;margin-top:4px;">PDF, JPG, PNG, DOC — máximo 5MB</p>
              <div class="file-name" id="fileName"></div>
            </div>
          </div>
          <div class="col-12">
            <button type="submit" class="btn-gold" id="btnSubir">
              <i class="fas fa-upload me-2"></i>Subir Documento
            </button>
          </div>
        </div>

      </form>
    </div>

    <!-- Lista de documentos -->
    <div class="upload-card">
      <h5><i class="fas fa-archive me-2"></i>Documentos Subidos (${fn:length(misDocumentos)})</h5>

      <c:choose>
        <c:when test="${not empty misDocumentos}">
          <div style="overflow-x:auto;">
            <table class="docs-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Archivo</th>
                  <th>Tipo</th>
                  <th>Propiedad</th>
                  <th>Fecha</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="doc" items="${misDocumentos}" varStatus="st">
                  <tr>
                    <td style="color:rgba(255,255,255,.3);">${st.index + 1}</td>
                    <td>
                      <i class="fas fa-file-alt me-2" style="color:#c9a84c;"></i>
                      ${doc.nombre}
                    </td>
                    <td><span class="badge-tipo">${doc.tipo}</span></td>
                    <td>${doc.propiedad}</td>
                    <td style="font-size:.78rem;color:rgba(255,255,255,.4);">${doc.fecha}</td>
                    <td>
                      <a href="${ctx}/SubirDocumentoServlet?action=descargar&id=${doc.id}"
                         style="color:#c9a84c;font-size:.82rem;text-decoration:none;">
                        <i class="fas fa-download me-1"></i>Ver
                      </a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:when>
        <c:otherwise>
          <div class="empty-state">
            <i class="fas fa-folder-open"></i>
            <p>Aún no has subido ningún documento.</p>
            <p style="font-size:.8rem;">Usa el formulario de arriba para subir tus papeles.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </main>
</div>

<script>
// Drop zone visual
const dz = document.getElementById('dropZone');
const fi = document.getElementById('archivoInput');
const fn = document.getElementById('fileName');

fi.addEventListener('change', function() {
  if (this.files[0]) {
    fn.textContent = '📎 ' + this.files[0].name;
    dz.style.borderColor = '#c9a84c';
  }
});
['dragover','dragenter'].forEach(ev => dz.addEventListener(ev, e => { e.preventDefault(); dz.classList.add('dragover'); }));
['dragleave','drop'].forEach(ev => dz.addEventListener(ev, () => dz.classList.remove('dragover')));

// Validar tamaño antes de enviar
document.getElementById('uploadForm').addEventListener('submit', function(e) {
  const file = fi.files[0];
  if (!file) { e.preventDefault(); alert('Debes seleccionar un archivo.'); return; }
  if (file.size > 5 * 1024 * 1024) { e.preventDefault(); alert('El archivo supera el límite de 5MB.'); return; }
  document.getElementById('btnSubir').disabled = true;
  document.getElementById('btnSubir').innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Subiendo...';
});
</script>

<%@ include file="footer.jsp" %>
