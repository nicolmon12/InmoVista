<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
/* ══ LOGOUT.JSP — InmoVista ══
   Invalida la sesión y muestra pantalla de despedida.
*/
String nombre = "";
if (session.getAttribute("usuario") != null) {
    Object u = session.getAttribute("usuario");
    if (u instanceof java.util.Map) {
        Object n = ((java.util.Map<?,?>)u).get("nombre");
        if (n != null) nombre = n.toString();
    }
}
session.invalidate();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sesión cerrada — InmoVista</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Outfit:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      min-height: 100vh;
      background: #0d0d0d;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-family: 'Outfit', sans-serif;
      color: #fff;
      padding: 24px;
    }

    .card {
      background: #161616;
      border: 1px solid rgba(201,168,76,0.15);
      border-radius: 20px;
      padding: 52px 48px;
      text-align: center;
      max-width: 420px;
      width: 100%;
      box-shadow: 0 24px 60px rgba(0,0,0,0.5);
      animation: fadeUp .45s ease both;
    }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(24px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .icon-wrap {
      width: 72px;
      height: 72px;
      background: rgba(201,168,76,0.1);
      border: 1px solid rgba(201,168,76,0.25);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 24px;
      font-size: 1.8rem;
      color: #c9a84c;
    }

    h1 {
      font-family: 'Playfair Display', serif;
      font-size: 1.9rem;
      font-weight: 900;
      margin-bottom: 10px;
      color: #fff;
    }

    .sub {
      font-size: 0.92rem;
      color: rgba(255,255,255,0.45);
      line-height: 1.6;
      margin-bottom: 36px;
    }

    .sub strong { color: rgba(255,255,255,0.75); }

    .btn-gold {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 13px 28px;
      background: linear-gradient(135deg, #c9a84c, #e8c96b);
      color: #000;
      font-weight: 700;
      font-size: 0.9rem;
      border: none;
      border-radius: 10px;
      cursor: pointer;
      text-decoration: none;
      transition: all .25s;
      width: 100%;
      justify-content: center;
      margin-bottom: 12px;
    }

    .btn-gold:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 24px rgba(201,168,76,0.35);
    }

    .btn-outline {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 12px 28px;
      background: transparent;
      color: rgba(255,255,255,0.55);
      font-size: 0.88rem;
      font-weight: 500;
      border: 1.5px solid rgba(255,255,255,0.1);
      border-radius: 10px;
      text-decoration: none;
      transition: all .2s;
      width: 100%;
      justify-content: center;
    }

    .btn-outline:hover {
      border-color: rgba(255,255,255,0.25);
      color: #fff;
    }

    .divider {
      width: 40px;
      height: 2px;
      background: linear-gradient(90deg, #c9a84c, #e8c96b);
      border-radius: 2px;
      margin: 0 auto 28px;
    }

    .brand {
      font-family: 'Playfair Display', serif;
      font-size: 1.1rem;
      font-weight: 900;
      color: rgba(255,255,255,0.2);
      margin-top: 36px;
      letter-spacing: 1px;
    }

    .brand span { color: #c9a84c; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon-wrap">
      <i class="fas fa-check"></i>
    </div>

    <h1>Sesión cerrada</h1>
    <div class="divider"></div>

    <p class="sub">
      <% if (!nombre.isEmpty()) { %>
        Hasta pronto, <strong><%= nombre %></strong>.<br>
      <% } %>
      Tu sesión fue cerrada de forma segura.<br>
      ¿Vuelves pronto? Te esperamos.
    </p>

    <a href="<%= request.getContextPath() %>/login.jsp" class="btn-gold">
      <i class="fas fa-sign-in-alt"></i> Iniciar sesión de nuevo
    </a>

    <a href="<%= request.getContextPath() %>/index.jsp" class="btn-outline">
      <i class="fas fa-home"></i> Ir al inicio
    </a>
  </div>

  <div class="brand">Inmo<span>Vista</span></div>
</body>
</html>
