<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
/* ═══════════════════════════════════════════════════
   USUARIO.JSP · InmoVista
   Dashboard del usuario visitante (solo lectura).
   Puede explorar propiedades pero no hacer solicitudes.
═══════════════════════════════════════════════════ */
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rolActual = (String) session.getAttribute("rolNombre");
if (!"usuario".equals(rolActual)) {
    response.sendRedirect(request.getContextPath() + "/" + rolActual + ".jsp");
    return;
}
%>
<c:set var="pageTitle" value="Mi Cuenta — InmoVista" scope="request"/>
<%@ include file="header.jsp" %>

<style>
:root{--cg:#c9a84c;--cd:#0d0d0d;--cb:#e8e5df;--cs:#f8f7f5;--cm:#9a9590;}
.us-wrap{max-width:700px;margin:60px auto;padding:0 24px 60px;}
.us-card{background:#fff;border:1px solid var(--cb);border-radius:18px;padding:44px;box-shadow:0 4px 24px rgba(0,0,0,.06);text-align:center;}
.us-av{width:80px;height:80px;background:linear-gradient(135deg,#7f8c8d,#95a5a6);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;color:#fff;margin:0 auto 20px;}
.us-name{font-family:'Playfair Display',serif;font-size:1.6rem;font-weight:900;color:var(--cd);margin-bottom:6px;}
.us-badge{background:rgba(149,165,166,.15);color:#555;padding:4px 14px;border-radius:100px;font-size:0.72rem;font-weight:700;letter-spacing:1px;display:inline-block;margin-bottom:28px;}
.us-info{background:var(--cs);border-radius:12px;padding:20px;margin-bottom:28px;text-align:left;}
.us-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--cb);font-size:0.86rem;}
.us-row:last-child{border:none;}
.us-row span:first-child{color:var(--cm);}
.us-row span:last-child{font-weight:600;}
.us-actions{display:grid;gap:12px;}
.btn-g{display:flex;align-items:center;justify-content:center;gap:8px;padding:14px 20px;background:linear-gradient(135deg,#c9a84c,#e8c96b);color:#000;font-weight:700;font-size:0.9rem;border:none;border-radius:10px;cursor:pointer;text-decoration:none;transition:all .25s;}
.btn-g:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(201,168,76,.35);color:#000;}
.btn-o{display:flex;align-items:center;justify-content:center;gap:8px;padding:13px 20px;background:transparent;color:var(--cd);font-weight:600;font-size:0.88rem;border:1.5px solid var(--cb);border-radius:10px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-o:hover{border-color:var(--cg);color:var(--cg);}
.btn-red{display:flex;align-items:center;justify-content:center;gap:8px;padding:12px 20px;background:transparent;color:#e74c3c;font-size:0.86rem;font-weight:600;border:1.5px solid rgba(231,76,60,.3);border-radius:10px;cursor:pointer;text-decoration:none;transition:all .2s;}
.btn-red:hover{background:rgba(231,76,60,.06);}
.upgrade-box{background:linear-gradient(135deg,rgba(201,168,76,.08),rgba(201,168,76,.15));border:1px solid rgba(201,168,76,.25);border-radius:14px;padding:24px;margin-bottom:24px;}
.upgrade-box h6{font-family:'Playfair Display',serif;font-weight:700;font-size:1rem;margin-bottom:6px;}
.upgrade-box p{font-size:0.84rem;color:var(--cm);margin-bottom:0;}
</style>

<div class="us-wrap">
  <div class="us-card">
    <div class="us-av">${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}</div>
    <div class="us-name">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</div>
    <span class="us-badge"><i class="fas fa-user me-1"></i> USUARIO VISITANTE</span>

    <div class="upgrade-box">
      <h6><i class="fas fa-star me-2" style="color:var(--cg);"></i>¿Quieres hacer más?</h6>
      <p>Como usuario visitante puedes explorar propiedades. Para agendar visitas, solicitar compras o arriendos, necesitas una cuenta <strong>Cliente</strong>. Habla con el administrador para actualizar tu cuenta.</p>
    </div>

    <div class="us-info">
      <div class="us-row"><span>Correo</span><span>${sessionScope.usuario.email}</span></div>
      <div class="us-row"><span>Teléfono</span><span>${not empty sessionScope.usuario.telefono ? sessionScope.usuario.telefono : 'No registrado'}</span></div>
      <div class="us-row"><span>Tipo de cuenta</span><span>Visitante</span></div>
    </div>

    <div class="us-actions">
      <a href="${pageContext.request.contextPath}/lista.jsp" class="btn-g">
        <i class="fas fa-search"></i> Explorar Propiedades
      </a>
      <a href="${pageContext.request.contextPath}/lista.jsp?operacion=venta" class="btn-o">
        <i class="fas fa-tag"></i> Ver propiedades en venta
      </a>
      <a href="${pageContext.request.contextPath}/lista.jsp?operacion=arriendo" class="btn-o">
        <i class="fas fa-key"></i> Ver propiedades en arriendo
      </a>
      <a href="${pageContext.request.contextPath}/logout.jsp" class="btn-red">
        <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
      </a>
    </div>
  </div>
</div>

<%@ include file="footer.jsp" %>
