<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${not empty pageTitle ? pageTitle : 'InmoVista'} — Sistema Inmobiliario</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link href="${ctx}/estilos.css" rel="stylesheet">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-inmovista">
  <div class="container">
    <a class="navbar-brand-logo" href="${ctx}/index.jsp">
      <i class="fas fa-building me-2"></i>Inmo<span>Vista</span>
    </a>

    <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navPrincipal">
      <i class="fas fa-bars text-white"></i>
    </button>

    <div class="collapse navbar-collapse" id="navPrincipal">
      <ul class="navbar-nav mx-auto">
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/lista.jsp">
            <i class="fas fa-home me-1"></i> Propiedades
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/lista.jsp?operacion=venta">
            <i class="fas fa-tag me-1"></i> En Venta
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/lista.jsp?operacion=arriendo">
            <i class="fas fa-key me-1"></i> En Arriendo
          </a>
        </li>
      </ul>

      <ul class="navbar-nav align-items-center gap-2">
        <c:choose>
          <c:when test="${not empty sessionScope.usuario}">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle d-flex align-items-center gap-2" href="#"
                 data-bs-toggle="dropdown">
                <div style="width:32px;height:32px;background:var(--gold);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-weight:700;color:#0d0d0d;font-size:0.9rem;">
                  ${fn:substring(sessionScope.usuario.nombre,0,1)}${fn:substring(sessionScope.usuario.apellido,0,1)}
                </div>
                <span style="color:rgba(255,255,255,0.85);font-size:0.88rem;">${sessionScope.usuario.nombre}</span>
                <span class="badge-rol badge-${sessionScope.rolNombre}">${sessionScope.rolNombre}</span>
              </a>
              <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0" style="border-radius:12px;min-width:220px;padding:8px;">
                <li>
                  <a class="dropdown-item rounded-2 py-2" href="${ctx}/${sessionScope.rolNombre}.jsp">
                    <i class="fas fa-tachometer-alt me-2 text-warning"></i> Mi Dashboard
                  </a>
                </li>
                <li>
                  <a class="dropdown-item rounded-2 py-2"
                     href="${ctx}/${sessionScope.rolNombre}.jsp?tab=perfil">
                    <i class="fas fa-user me-2 text-muted"></i> Mi Perfil
                  </a>
                </li>
                <c:if test="${sessionScope.rolNombre == 'cliente'}">
                  <li>
                    <a class="dropdown-item rounded-2 py-2" href="${ctx}/cliente.jsp?tab=citas">
                      <i class="fas fa-calendar me-2 text-muted"></i> Mis Citas
                    </a>
                  </li>
                </c:if>
                <c:if test="${sessionScope.rolNombre == 'admin'}">
                  <li>
                    <a class="dropdown-item rounded-2 py-2" href="${ctx}/usuarios.jsp">
                      <i class="fas fa-users me-2 text-muted"></i> Gestión Usuarios
                    </a>
                  </li>
                </c:if>
                <li><hr class="dropdown-divider my-1"></li>
                <li>
                  <a class="dropdown-item rounded-2 py-2 text-danger" href="${ctx}/logout.jsp">
                    <i class="fas fa-sign-out-alt me-2"></i> Cerrar Sesión
                  </a>
                </li>
              </ul>
            </li>
          </c:when>
          <c:otherwise>
            <li class="nav-item">
              <a class="btn-dark-outline" href="${ctx}/login.jsp">
                Iniciar Sesión
              </a>
            </li>
            <li class="nav-item">
              <a class="btn-gold" href="${ctx}/registro.jsp">
                Registrarse
              </a>
            </li>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
</nav>
