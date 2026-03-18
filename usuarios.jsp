<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
/* ═══════════════════════════════════════════════════
   USUARIOS.JSP · InmoVista — Gestión de usuarios
   Solo accesible para admin.
   Maneja: crear, actualizar, eliminar, activar/desactivar
═══════════════════════════════════════════════════ */

// ── Protección: solo admin ────────────────────────
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolSesion = (String) session.getAttribute("rolNombre");
if (!"admin".equals(rolSesion)) {
    response.sendRedirect(request.getContextPath() + "/" + rolSesion + ".jsp");
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

String msgExito = null, msgError = null;

// ════════════════════════════════════════════════════
// HANDLE POST
// ════════════════════════════════════════════════════
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    if (action == null) action = "";

    if (db == null) {
        msgError = "No hay conexión con la base de datos. Verifica que MySQL esté activo.";
    } else {

        // ── CREAR USUARIO ─────────────────────────
        if ("crear".equals(action)) {
            String nombre   = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String email    = request.getParameter("email");
            String password = request.getParameter("password");
            String telefono = request.getParameter("telefono");
            String rolId    = request.getParameter("rolId");

            if (nombre==null||nombre.trim().isEmpty()||email==null||email.trim().isEmpty()||password==null||password.trim().isEmpty()) {
                msgError = "Nombre, email y contraseña son obligatorios.";
            } else {
                try {
                    // Verificar email duplicado
                    java.sql.PreparedStatement chk = db.prepareStatement("SELECT id FROM usuarios WHERE email=?");
                    chk.setString(1, email.trim().toLowerCase());
                    boolean existe = chk.executeQuery().next();
                    chk.close();

                    if (existe) {
                        msgError = "Ya existe un usuario con el correo " + email;
                    } else {
                        // Hash SHA-256 contraseña
                        String passHash = password;
                        try {
                            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
                            byte[] hb = md.digest(password.getBytes("UTF-8"));
                            StringBuilder sb = new StringBuilder();
                            for (byte b : hb) sb.append(String.format("%02x", b));
                            passHash = sb.toString();
                        } catch (Exception he) {}

                        java.sql.PreparedStatement ins = db.prepareStatement(
                            "INSERT INTO usuarios (nombre, apellido, email, password, telefono, rol_id, activo, fecha_registro) VALUES (?,?,?,?,?,?,1,NOW())");
                        ins.setString(1, nombre.trim());
                        ins.setString(2, apellido != null ? apellido.trim() : "");
                        ins.setString(3, email.trim().toLowerCase());
                        ins.setString(4, passHash);
                        ins.setString(5, telefono != null ? telefono.trim() : "");
                        ins.setInt(6,    rolId != null ? Integer.parseInt(rolId) : 3);
                        ins.executeUpdate();
                        ins.close();
                        msgExito = "✓ Usuario " + nombre.trim() + " creado correctamente.";
                    }
                } catch (Exception ex) {
                    msgError = "Error al crear usuario: " + ex.getMessage();
                }
            }
        }

        // ── ACTUALIZAR USUARIO ────────────────────
        else if ("actualizar".equals(action)) {
            String uid      = request.getParameter("id");
            String nombre   = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String telefono = request.getParameter("telefono");
            String rolId    = request.getParameter("rolId");
            String activo   = request.getParameter("activo");
            try {
                java.sql.PreparedStatement ps = db.prepareStatement(
                    "UPDATE usuarios SET nombre=?, apellido=?, telefono=?, rol_id=?, activo=? WHERE id=?");
                ps.setString(1, nombre != null ? nombre.trim() : "");
                ps.setString(2, apellido != null ? apellido.trim() : "");
                ps.setString(3, telefono != null ? telefono.trim() : "");
                ps.setInt(4,    rolId != null ? Integer.parseInt(rolId) : 3);
                ps.setInt(5,    "true".equals(activo) ? 1 : 0);
                ps.setInt(6,    Integer.parseInt(uid));
                ps.executeUpdate(); ps.close();
                msgExito = "✓ Usuario actualizado correctamente.";
            } catch (Exception ex) {
                msgError = "Error al actualizar: " + ex.getMessage();
            }
        }

        // ── ELIMINAR ──────────────────────────────
        else if ("eliminar".equals(action)) {
            String uid = request.getParameter("id");
            try {
                java.sql.PreparedStatement ps = db.prepareStatement("DELETE FROM usuarios WHERE id=?");
                ps.setInt(1, Integer.parseInt(uid));
                ps.executeUpdate(); ps.close();
                msgExito = "✓ Usuario eliminado.";
            } catch (Exception ex) {
                msgError = "Error al eliminar: " + ex.getMessage();
            }
        }

        // ── ACTIVAR / DESACTIVAR ──────────────────
        else if ("activar".equals(action) || "desactivar".equals(action)) {
            String uid = request.getParameter("id");
            int nuevoEstado = "activar".equals(action) ? 1 : 0;
            try {
                java.sql.PreparedStatement ps = db.prepareStatement("UPDATE usuarios SET activo=? WHERE id=?");
                ps.setInt(1, nuevoEstado);
                ps.setInt(2, Integer.parseInt(uid));
                ps.executeUpdate(); ps.close();
                msgExito = "✓ Usuario " + ("activar".equals(action) ? "activado" : "desactivado") + ".";
            } catch (Exception ex) {
                msgError = "Error: " + ex.getMessage();
            }
        }
    }

    // POST → Redirect → GET (evitar reenvío)
    if (db != null) { try { db.close(); } catch(Exception e){} }
    String redir = request.getContextPath() + "/usuarios.jsp";
    if (msgExito != null) redir += "?ok=" + java.net.URLEncoder.encode(msgExito, "UTF-8");
    if (msgError != null) redir += "?err=" + java.net.URLEncoder.encode(msgError, "UTF-8");
    // Conservar filtros si venían
    String buscar = request.getParameter("buscarActual");
    if (buscar != null && !buscar.isEmpty()) redir += "&buscar=" + java.net.URLEncoder.encode(buscar,"UTF-8");
    response.sendRedirect(redir);
    return;
}

// ════════════════════════════════════════════════════
// GET: cargar lista de usuarios desde BD
// ════════════════════════════════════════════════════
// Leer mensajes flash de la URL
if (request.getParameter("ok")  != null) msgExito = request.getParameter("ok");
if (request.getParameter("err") != null) msgError = request.getParameter("err");

java.util.List<java.util.Map<String,Object>> usuarios = new java.util.ArrayList<>();

// Filtros opcionales
String filtBuscar = request.getParameter("buscar");
String filtRol    = request.getParameter("rol");
String filtActivo = request.getParameter("activo");

if (db != null) {
    try {
        StringBuilder sql = new StringBuilder(
            "SELECT u.id, u.nombre, u.apellido, u.email, u.telefono, " +
            "u.activo, u.fecha_registro, r.id AS rol_id, r.nombre AS rol_nombre " +
            "FROM usuarios u JOIN roles r ON u.rol_id = r.id WHERE 1=1");

        java.util.List<Object> params = new java.util.ArrayList<>();

        if (filtBuscar != null && !filtBuscar.trim().isEmpty()) {
            sql.append(" AND (u.nombre LIKE ? OR u.apellido LIKE ? OR u.email LIKE ?)");
            String like = "%" + filtBuscar.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (filtRol != null && !filtRol.trim().isEmpty()) {
            sql.append(" AND u.rol_id = ?");
            params.add(Integer.parseInt(filtRol));
        }
        if (filtActivo != null && !filtActivo.trim().isEmpty()) {
            sql.append(" AND u.activo = ?");
            params.add(Integer.parseInt(filtActivo));
        }
        sql.append(" ORDER BY u.fecha_registro DESC");

        java.sql.PreparedStatement ps = db.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) ps.setInt(i+1, (Integer)p);
            else ps.setString(i+1, (String)p);
        }

        java.sql.ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
            m.put("id",           rs.getInt("id"));
            m.put("nombre",       rs.getString("nombre"));
            m.put("apellido",     rs.getString("apellido") != null ? rs.getString("apellido") : "");
            m.put("email",        rs.getString("email"));
            m.put("telefono",     rs.getString("telefono") != null ? rs.getString("telefono") : "");
            m.put("activo",       rs.getInt("activo") == 1);
            m.put("fechaRegistro",rs.getTimestamp("fecha_registro") != null ? new java.util.Date(rs.getTimestamp("fecha_registro").getTime()) : new java.util.Date());
            m.put("rolId",        rs.getInt("rol_id"));
            m.put("rolNombre",    rs.getString("rol_nombre"));
            usuarios.add(m);
        }
        rs.close(); ps.close();
        db.close();
    } catch (Exception ex) {
        msgError = (msgError != null ? msgError + " | " : "") + "Error BD: " + ex.getMessage();
        if (db != null) { try { db.close(); } catch(Exception e){} }
    }
} else {
    // Demo fallback
    Object[][] demo = {
        {1,"Admin","Sistema","admin@inmovista.com","",true,1,"admin"},
        {2,"Agente","InmoVista","inmobiliaria@test.com","",true,2,"inmobiliaria"},
        {3,"Juan","Torres","cliente@test.com","3001234567",true,3,"cliente"},
        {4,"Maria","García","usuario@test.com","",true,4,"usuario"}
    };
    for (Object[] d : demo) {
        java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
        m.put("id",d[0]); m.put("nombre",d[1]); m.put("apellido",d[2]);
        m.put("email",d[3]); m.put("telefono",d[4]); m.put("activo",d[5]);
        m.put("fechaRegistro", new java.util.Date());
        m.put("rolId",d[6]); m.put("rolNombre",d[7]);
        usuarios.add(m);
    }
    msgError = "⚠ Mostrando datos de demostración — BD no disponible.";
}

request.setAttribute("usuarios", usuarios);
request.setAttribute("msgExito", msgExito);
request.setAttribute("msgError", msgError);
%>
<c:set var="pageTitle" value="Usuarios" scope="request"/>
<%@ include file="header.jsp" %>

<div class="dashboard-layout">
  <%@ include file="sidebar.jsp" %>

  <main class="dashboard-main">
    <div class="dashboard-header d-flex justify-content-between align-items-start flex-wrap gap-3">
      <div>
        <div class="dashboard-title"><i class="fas fa-users me-2" style="color:var(--gold);"></i>Gestión de Usuarios</div>
        <div class="dashboard-subtitle">Administra todos los usuarios del sistema</div>
      </div>
      <!-- Botón crear usuario -->
      <button onclick="document.getElementById('modalCrearUsuario').style.display='flex'"
              class="btn-gold" style="border:none;border-radius:10px;padding:10px 20px;font-weight:700;">
        <i class="fas fa-user-plus me-2"></i> Nuevo Usuario
      </button>
    </div>

    <!-- Mensajes -->
    <c:if test="${not empty msgExito}">
      <div class="alert-inmovista alert-success-custom mb-4">
        <i class="fas fa-check-circle"></i> ${msgExito}
      </div>
    </c:if>
    <c:if test="${not empty msgError}">
      <div class="alert-inmovista alert-error-custom mb-4">
        <i class="fas fa-exclamation-circle"></i> ${msgError}
      </div>
    </c:if>

    <!-- Filtros -->
    <div class="table-card mb-4">
      <div style="padding:16px 22px;">
        <form action="${pageContext.request.contextPath}/usuarios.jsp" method="get"
              class="row g-2 align-items-center">
          <div class="col-md-4">
            <input type="text" name="buscar" class="form-control form-control-sm"
                   placeholder="Buscar por nombre o email..." value="${param.buscar}">
          </div>
          <div class="col-md-3">
            <select name="rol" class="form-select form-select-sm">
              <option value="">Todos los roles</option>
              <option value="1" ${param.rol == '1' ? 'selected' : ''}>Administrador</option>
              <option value="2" ${param.rol == '2' ? 'selected' : ''}>Usuario</option>
              <option value="3" ${param.rol == '3' ? 'selected' : ''}>Cliente</option>
              <option value="4" ${param.rol == '4' ? 'selected' : ''}>Inmobiliaria</option>
            </select>
          </div>
          <div class="col-md-2">
            <select name="activo" class="form-select form-select-sm">
              <option value="">Todos</option>
              <option value="1" ${param.activo == '1' ? 'selected' : ''}>Activos</option>
              <option value="0" ${param.activo == '0' ? 'selected' : ''}>Inactivos</option>
            </select>
          </div>
          <div class="col-md-2">
            <button type="submit" class="btn btn-sm w-100"
                    style="background:var(--dark);color:var(--gold);border:none;border-radius:6px;">
              <i class="fas fa-search me-1"></i>Filtrar
            </button>
          </div>
          <div class="col-md-1">
            <a href="${pageContext.request.contextPath}/usuarios.jsp"
               class="btn btn-sm w-100"
               style="background:var(--gray-1);border:1.5px solid var(--gray-2);border-radius:6px;">
              <i class="fas fa-times"></i>
            </a>
          </div>
        </form>
      </div>
    </div>

    <!-- Tabla usuarios -->
    <div class="table-card">
      <div class="table-card-header">
        <h5><i class="fas fa-table me-2" style="color:var(--gold);"></i>
          Lista de Usuarios
          <span style="font-size:0.8rem;font-weight:400;color:var(--gray-3);margin-left:8px;">
            (${not empty usuarios ? fn:length(usuarios) : '0'} registros)
          </span>
        </h5>
      </div>
      <div class="table-responsive">
        <table class="table mb-0" id="tablaUsuarios">
          <thead>
            <tr>
              <th>#</th>
              <th>Usuario</th>
              <th>Email</th>
              <th>Teléfono</th>
              <th>Rol</th>
              <th>Registro</th>
              <th>Estado</th>
              <th style="text-align:center;">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty usuarios}">
                <c:forEach var="u" items="${usuarios}" varStatus="loop">
                <tr>
                  <td style="color:var(--gray-3);font-size:0.82rem;">${loop.index + 1}</td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div style="width:36px;height:36px;background:var(--gold);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-weight:700;font-size:0.85rem;color:var(--dark);flex-shrink:0;">
                        ${fn:substring(u.nombre,0,1)}${fn:substring(u.apellido,0,1)}
                      </div>
                      <div>
                        <div style="font-weight:600;font-size:0.88rem;">${u.nombre} ${u.apellido}</div>
                      </div>
                    </div>
                  </td>
                  <td style="font-size:0.85rem;">${u.email}</td>
                  <td style="font-size:0.85rem;">${not empty u.telefono ? u.telefono : '—'}</td>
                  <td><span class="badge-rol badge-${u.rolNombre}">${u.rolNombre}</span></td>
                  <td style="font-size:0.82rem;">
                    <fmt:formatDate value="${u.fechaRegistro}" pattern="dd/MM/yyyy"/>
                  </td>
                  <td>
                    <span class="status-badge ${u.activo ? 'status-disponible' : 'status-cancelada'}">
                      ${u.activo ? 'Activo' : 'Inactivo'}
                    </span>
                  </td>
                  <td style="text-align:center;">
                    <div class="d-flex gap-1 justify-content-center">
                      <!-- Editar -->
                      <button onclick="abrirEditar(${u.id},'${u.nombre}','${u.apellido}','${u.email}','${u.telefono}',${u.rolId},${u.activo})"
                              class="btn btn-sm" title="Editar"
                              style="background:var(--dark);color:var(--gold);border:none;border-radius:6px;padding:4px 8px;">
                        <i class="fas fa-edit"></i>
                      </button>
                      <!-- Activar/Desactivar -->
                      <form action="${pageContext.request.contextPath}/usuarios.jsp" method="post">
                        <input type="hidden" name="action" value="${u.activo ? 'desactivar' : 'activar'}">
                        <input type="hidden" name="id" value="${u.id}">
                        <button type="submit" class="btn btn-sm" title="${u.activo ? 'Desactivar' : 'Activar'}"
                                style="background:${u.activo ? '#f39c12' : '#27ae60'};color:#fff;border:none;border-radius:6px;padding:4px 8px;">
                          <i class="fas fa-${u.activo ? 'ban' : 'check'}"></i>
                        </button>
                      </form>
                      <!-- Eliminar -->
                      <c:if test="${u.id != sessionScope.usuario.id}">
                        <form action="${pageContext.request.contextPath}/usuarios.jsp" method="post"
                              onsubmit="return confirm('¿Eliminar usuario ${u.nombre}?')">
                          <input type="hidden" name="action" value="eliminar">
                          <input type="hidden" name="id" value="${u.id}">
                          <button type="submit" class="btn btn-sm" title="Eliminar"
                                  style="background:#e74c3c;color:#fff;border:none;border-radius:6px;padding:4px 8px;">
                            <i class="fas fa-trash"></i>
                          </button>
                        </form>
                      </c:if>
                    </div>
                  </td>
                </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr>
                  <td colspan="8">
                    <div class="empty-state py-4">
                      <i class="fas fa-users"></i>
                      <h5>No se encontraron usuarios</h5>
                    </div>
                  </td>
                </tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </main>
</div>

<!-- ===== MODAL CREAR USUARIO ===== -->
<div id="modalCrearUsuario"
     style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:#fff;border-radius:16px;padding:32px;width:500px;max-width:95vw;max-height:90vh;overflow-y:auto;">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h5 style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;">Nuevo Usuario</h5>
      <button onclick="document.getElementById('modalCrearUsuario').style.display='none'"
              style="background:none;border:none;font-size:1.5rem;cursor:pointer;color:var(--gray-3);">×</button>
    </div>
    <form action="${pageContext.request.contextPath}/usuarios.jsp" method="post">
      <input type="hidden" name="action" value="crear">
      <input type="hidden" name="buscarActual" value="${param.buscar}">
      <div class="row g-3">
        <div class="col-6">
          <label class="form-label">Nombre <span class="text-danger">*</span></label>
          <input type="text" name="nombre" class="form-control" required>
        </div>
        <div class="col-6">
          <label class="form-label">Apellido <span class="text-danger">*</span></label>
          <input type="text" name="apellido" class="form-control" required>
        </div>
        <div class="col-12">
          <label class="form-label">Email <span class="text-danger">*</span></label>
          <input type="email" name="email" class="form-control" required>
        </div>
        <div class="col-6">
          <label class="form-label">Contraseña <span class="text-danger">*</span></label>
          <input type="password" name="password" class="form-control" required minlength="8">
        </div>
        <div class="col-6">
          <label class="form-label">Teléfono</label>
          <input type="tel" name="telefono" class="form-control">
        </div>
        <div class="col-6">
          <label class="form-label">Rol <span class="text-danger">*</span></label>
          <select name="rolId" class="form-select" required>
            <option value="1">Administrador</option>
            <option value="2">Usuario</option>
            <option value="3" selected>Cliente</option>
            <option value="4">Inmobiliaria</option>
          </select>
        </div>
        <div class="col-12">
          <button type="submit" class="btn-gold w-100 py-2" style="border:none;border-radius:10px;font-weight:700;">
            <i class="fas fa-user-plus me-2"></i>Crear Usuario
          </button>
        </div>
      </div>
    </form>
  </div>
</div>

<!-- ===== MODAL EDITAR USUARIO ===== -->
<div id="modalEditarUsuario"
     style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:#fff;border-radius:16px;padding:32px;width:500px;max-width:95vw;max-height:90vh;overflow-y:auto;">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h5 style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;">Editar Usuario</h5>
      <button onclick="document.getElementById('modalEditarUsuario').style.display='none'"
              style="background:none;border:none;font-size:1.5rem;cursor:pointer;color:var(--gray-3);">×</button>
    </div>
    <form action="${pageContext.request.contextPath}/usuarios.jsp" method="post">
      <input type="hidden" name="action" value="actualizar">
      <input type="hidden" name="id" id="editId">
      <div class="row g-3">
        <div class="col-6">
          <label class="form-label">Nombre</label>
          <input type="text" name="nombre" id="editNombre" class="form-control" required>
        </div>
        <div class="col-6">
          <label class="form-label">Apellido</label>
          <input type="text" name="apellido" id="editApellido" class="form-control" required>
        </div>
        <div class="col-12">
          <label class="form-label">Email</label>
          <input type="email" name="email" id="editEmail" class="form-control" required readonly
                 style="background:var(--gray-1);">
        </div>
        <div class="col-6">
          <label class="form-label">Teléfono</label>
          <input type="tel" name="telefono" id="editTelefono" class="form-control">
        </div>
        <div class="col-6">
          <label class="form-label">Rol</label>
          <select name="rolId" id="editRolId" class="form-select">
            <option value="1">Administrador</option>
            <option value="2">Usuario</option>
            <option value="3">Cliente</option>
            <option value="4">Inmobiliaria</option>
          </select>
        </div>
        <div class="col-6">
          <label class="form-label">Estado</label>
          <select name="activo" id="editActivo" class="form-select">
            <option value="true">Activo</option>
            <option value="false">Inactivo</option>
          </select>
        </div>
        <div class="col-12">
          <button type="submit" class="btn-gold w-100 py-2" style="border:none;border-radius:10px;font-weight:700;">
            <i class="fas fa-save me-2"></i>Guardar Cambios
          </button>
        </div>
      </div>
    </form>
  </div>
</div>

<%@ include file="footer.jsp" %>
<script>
  function abrirEditar(id, nombre, apellido, email, telefono, rolId, activo) {
    document.getElementById('editId').value = id;
    document.getElementById('editNombre').value = nombre;
    document.getElementById('editApellido').value = apellido;
    document.getElementById('editEmail').value = email;
    document.getElementById('editTelefono').value = telefono || '';
    document.getElementById('editRolId').value = rolId;
    document.getElementById('editActivo').value = activo ? 'true' : 'false';
    document.getElementById('modalEditarUsuario').style.display = 'flex';
  }
  // Cerrar modal al hacer click fuera
  ['modalCrearUsuario','modalEditarUsuario'].forEach(id => {
    document.getElementById(id).addEventListener('click', function(e) {
      if (e.target === this) this.style.display = 'none';
    });
  });
</script>
