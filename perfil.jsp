<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
/*
 * perfil.jsp — Redirige al tab de perfil del dashboard correspondiente al rol.
 * Así funciona tanto desde el header antiguo como desde cualquier enlace directo.
 */
if (session.getAttribute("usuario") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String rol = (String) session.getAttribute("rolNombre");
if (rol == null || rol.isEmpty()) rol = "cliente";

response.sendRedirect(request.getContextPath() + "/" + rol + ".jsp?tab=perfil");
%>
