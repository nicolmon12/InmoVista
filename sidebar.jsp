<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- SIDEBAR DASHBOARD -->
<aside class="dashboard-sidebar">
  <!-- Info usuario -->
  <div class="sidebar-user-info">
    <div class="sidebar-avatar">
      ${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}
    </div>
    <div class="sidebar-username">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</div>
    <div class="sidebar-role">${sessionScope.rolNombre}</div>
  </div>

  <!-- Nav según rol -->
  <c:choose>

    <%-- ===== ADMIN ===== --%>
    <c:when test="${sessionScope.rolNombre == 'admin'}">
      <div class="sidebar-nav-section">Principal</div>
      <a class="sidebar-nav-link ${pageTitle == 'Dashboard Admin' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/admin.jsp">
        <i class="fas fa-tachometer-alt"></i> Dashboard
      </a>
      <div class="sidebar-nav-section">Gestión</div>
      <a class="sidebar-nav-link ${pageTitle == 'Usuarios' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/usuarios.jsp">
        <i class="fas fa-users"></i> Usuarios
      </a>
      <a class="sidebar-nav-link ${pageTitle == 'Propiedades' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/lista.jsp">
        <i class="fas fa-home"></i> Propiedades
      </a>
      <a class="sidebar-nav-link ${pageTitle == 'Citas' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/admin.jsp">
        <i class="fas fa-calendar-alt"></i> Todas las Citas
      </a>
      <a class="sidebar-nav-link"
         href="${pageContext.request.contextPath}/admin.jsp">
        <i class="fas fa-file-signature"></i> Solicitudes
      </a>
      <div class="sidebar-nav-section">Reportes</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/reportes.jsp">
        <i class="fas fa-chart-bar"></i> Reportes
      </a>
    </c:when>

    <%-- ===== INMOBILIARIA ===== --%>
    <c:when test="${sessionScope.rolNombre == 'inmobiliaria'}">
      <div class="sidebar-nav-section">Principal</div>
      <a class="sidebar-nav-link ${pageTitle == 'Dashboard Inmobiliaria' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/inmobiliaria.jsp">
        <i class="fas fa-tachometer-alt"></i> Dashboard
      </a>
      <div class="sidebar-nav-section">Mis Propiedades</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/formulario.jsp">
        <i class="fas fa-plus-circle"></i> Publicar Propiedad
      </a>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/inmobiliaria.jsp">
        <i class="fas fa-building"></i> Mis Propiedades
      </a>
      <div class="sidebar-nav-section">Clientes</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/inmobiliaria.jsp?tab=citas">
        <i class="fas fa-calendar-alt"></i> Visitas Agendadas
      </a>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/inmobiliaria.jsp?tab=solicitudes">
        <i class="fas fa-file-signature"></i> Solicitudes
      </a>
      <div class="sidebar-nav-section">Análisis</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/reportes.jsp">
        <i class="fas fa-chart-pie"></i> Mis Reportes
      </a>
    </c:when>

    <%-- ===== CLIENTE ===== --%>
    <c:when test="${sessionScope.rolNombre == 'cliente'}">
      <div class="sidebar-nav-section">Principal</div>
      <a class="sidebar-nav-link ${pageTitle == 'Dashboard Cliente' ? 'active' : ''}"
         href="${pageContext.request.contextPath}/cliente.jsp">
        <i class="fas fa-tachometer-alt"></i> Mi Dashboard
      </a>
      <div class="sidebar-nav-section">Búsqueda</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/lista.jsp">
        <i class="fas fa-search"></i> Buscar Propiedades
      </a>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/cliente.jsp">
        <i class="fas fa-heart"></i> Mis Favoritos
      </a>
      <div class="sidebar-nav-section">Mis Gestiones</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/cliente.jsp">
        <i class="fas fa-calendar-check"></i> Mis Citas
      </a>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/cliente.jsp">
        <i class="fas fa-file-alt"></i> Mis Solicitudes
      </a>
    </c:when>

    <%-- ===== USUARIO ===== --%>
    <c:otherwise>
      <div class="sidebar-nav-section">Navegación</div>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/index.jsp">
        <i class="fas fa-home"></i> Inicio
      </a>
      <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/lista.jsp">
        <i class="fas fa-search"></i> Ver Propiedades
      </a>
    </c:otherwise>
  </c:choose>

  <!-- Perfil y Logout -->
  <div style="position:absolute;bottom:0;left:0;right:0;padding:16px 8px;border-top:1px solid rgba(255,255,255,0.08);">
    <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/perfil.jsp">
      <i class="fas fa-user-cog"></i> Mi Perfil
    </a>
    <a class="sidebar-nav-link" href="${pageContext.request.contextPath}/logout.jsp"
       style="color:rgba(231,76,60,0.8)!important;"
       onmouseover="this.style.background='rgba(231,76,60,0.1)'"
       onmouseout="this.style.background='none'">
      <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
    </a>
  </div>
</aside>
