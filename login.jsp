<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
/* ══ HANDLER POST: autenticación demo ══
   En producción esto lo hace LoginServlet con JDBC.
   Para demo, validamos contra usuarios hardcoded y creamos sesión.
*/
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email    = request.getParameter("email");
    String password = request.getParameter("password");
    if (email == null) email = "";
    if (password == null) password = "";
    email = email.trim().toLowerCase();

    boolean loginOk = false;

    // ── 1. Intentar autenticar contra MySQL ──────────
    java.sql.Connection con = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
            "root", "");

        // Hash SHA-256 de la contrasena ingresada
        String passwordHash = password;
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hb = md.digest(password.getBytes("UTF-8"));
            StringBuilder sbH = new StringBuilder();
            for (byte b : hb) sbH.append(String.format("%02x", b));
            passwordHash = sbH.toString();
        } catch (Exception he) {}

        // Buscar por email y verificar contrasena (SHA-256 o texto plano para compatibilidad)
        String sql = "SELECT u.id, u.nombre, u.apellido, u.email, u.telefono, " +
                     "r.nombre AS rol_nombre " +
                     "FROM usuarios u " +
                     "JOIN roles r ON u.rol_id = r.id " +
                     "WHERE u.email = ? AND u.activo = 1";
        java.sql.PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, email);
        java.sql.ResultSet rs = ps.executeQuery();
        // Verificar contrasena manualmente para soportar SHA-256 y texto plano
        boolean passwordOk = false;
        if (rs.next()) {
            // Obtener el hash guardado
            java.sql.PreparedStatement psPass = con.prepareStatement(
                "SELECT password FROM usuarios WHERE email=?");
            psPass.setString(1, email);
            java.sql.ResultSet rsPass = psPass.executeQuery();
            if (rsPass.next()) {
                String storedPass = rsPass.getString("password");
                if (storedPass != null) {
                    // Aceptar: SHA-256, texto plano, o BCrypt (solo verificacion simple)
                    passwordOk = passwordHash.equals(storedPass)   // SHA-256
                               || password.equals(storedPass);      // texto plano legacy
                }
            }
            rsPass.close(); psPass.close();
        }
        if (!passwordOk) { rs.close(); ps.close(); loginOk = false; }
        else if (rs.getString("email") != null) {
            java.util.Map<String,Object> usuario = new java.util.LinkedHashMap<String,Object>();
            usuario.put("id",           rs.getInt("id"));
            usuario.put("nombre",       rs.getString("nombre"));
            usuario.put("apellido",     rs.getString("apellido"));
            usuario.put("email",        rs.getString("email"));
            usuario.put("telefono",     rs.getString("telefono") != null ? rs.getString("telefono") : "");
            usuario.put("fechaRegistro", new java.util.Date());
            String rol = rs.getString("rol_nombre");
            session.setAttribute("usuario",   usuario);
            session.setAttribute("rolNombre", rol);
            session.setAttribute("userId",    rs.getInt("id"));
            rs.close(); ps.close(); con.close();
            String destino = "admin".equals(rol)
                ? request.getContextPath() + "/superadmin.jsp?sv=1"
                : request.getContextPath() + "/" + rol + ".jsp";
            response.sendRedirect(destino);
            return;
        }
        rs.close(); ps.close();
        loginOk = false;
    } catch (Exception dbEx) {
        loginOk = false; // BD no disponible, intentar demo
    } finally {
        if (con != null) { try { con.close(); } catch(Exception e){} }
    }

    // ── 2. Fallback: usuarios demo hardcoded ─────────
    java.util.Map<String,String[]> demoUsers = new java.util.LinkedHashMap<String,String[]>();
    demoUsers.put("admin@inmobiliaria.com",  new String[]{"Admin","Sistema","admin","1","Admin123!"});
    demoUsers.put("inmobiliaria@test.com",   new String[]{"Agente","InmoVista","inmobiliaria","2","Test123!"});
    demoUsers.put("cliente@test.com",        new String[]{"Juan","Torres","cliente","3","Test123!"});
    demoUsers.put("usuario@test.com",        new String[]{"Maria","Garcia","usuario","4","Test123!"});

    String[] userData = demoUsers.get(email);
    if (userData != null && userData[4].equals(password)) {
        java.util.Map<String,Object> usuario = new java.util.LinkedHashMap<String,Object>();
        usuario.put("id",           Integer.parseInt(userData[3]));
        usuario.put("nombre",       userData[0]);
        usuario.put("apellido",     userData[1]);
        usuario.put("email",        email);
        usuario.put("telefono",     "");
        usuario.put("fechaRegistro", new java.util.Date());
        session.setAttribute("usuario",   usuario);
        session.setAttribute("rolNombre", userData[2]);
        session.setAttribute("userId",    Integer.parseInt(userData[3]));
        String destDemo = "admin".equals(userData[2])
            ? request.getContextPath() + "/superadmin.jsp?sv=1"
            : request.getContextPath() + "/" + userData[2] + ".jsp";
        response.sendRedirect(destDemo);
        return;
    }

    // ── 3. Credenciales incorrectas ──────────────────
    request.setAttribute("error", "Correo o contrasena incorrectos.");
}

/* ══ Si ya hay sesión, redirigir ══ */
if (session.getAttribute("usuario") != null) {
    String rol = (String) session.getAttribute("rolNombre");
    String dest = "admin".equals(rol)
        ? request.getContextPath() + "/superadmin.jsp?sv=1"
        : request.getContextPath() + "/" + rol + ".jsp";
    response.sendRedirect(dest);
    return;
}
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Acceder — InmoVista</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,700;1,300;1,400&family=Outfit:wght@200;300;400;500;600;700&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html, body {
  width: 100%; height: 100%;
  overflow: hidden;
  font-family: 'Outfit', sans-serif;
  background: #06060e;
  color: #fff;
}

/* ── CANVAS FONDO ── */
#cv {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  z-index: 0;
  pointer-events: none;
}

/* ── LAYOUT DOS COLUMNAS ── */
.wrap {
  position: relative;
  z-index: 2;
  display: flex;
  width: 100vw;
  height: 100vh;
}

/* ══════════════════════════════
   COLUMNA IZQUIERDA
══════════════════════════════ */
.col-l {
  flex: 1;
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

@media (max-width: 820px) { .col-l { display: none; } }

.bg-img {
  position: absolute;
  inset: -12%;
  background: url('https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1400&q=85') center/cover no-repeat;
  filter: brightness(0.28) saturate(0.6);
  transform: scale(1.1);
  animation: bgZoom 22s ease-in-out infinite alternate;
}
@keyframes bgZoom {
  from { transform: scale(1.10) translate(0,0); }
  to   { transform: scale(1.18) translate(-2%,-2%); }
}

.bg-grad {
  position: absolute; inset: 0;
  background:
    linear-gradient(90deg, transparent 50%, #06060e 100%),
    linear-gradient(180deg, rgba(6,6,14,.6) 0%, transparent 40%, rgba(6,6,14,.8) 100%);
}

.left-vline {
  position: absolute;
  left: 13%; top: 12%; bottom: 12%;
  width: 1px;
  background: linear-gradient(180deg, transparent, #c9a84c, transparent);
  opacity: 0;
  animation: vlineIn 1.8s 0.5s ease forwards;
}
@keyframes vlineIn { to { opacity: 0.4; } }

.left-wm {
  position: absolute;
  right: -2%; bottom: -10%;
  font-family: 'Cormorant Garamond', serif;
  font-size: 32rem;
  font-weight: 700;
  color: transparent;
  -webkit-text-stroke: 1px rgba(201,168,76,0.06);
  line-height: 1;
  user-select: none;
  pointer-events: none;
}

.left-body {
  position: relative;
  z-index: 3;
  padding: 64px;
  max-width: 500px;
}

.l-tag {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  font-size: 0.68rem;
  font-weight: 600;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: #c9a84c;
  margin-bottom: 28px;
  opacity: 0;
  transform: translateY(18px);
  animation: slideUp 0.9s 0.7s ease forwards;
}
.l-tag::before {
  content: '';
  width: 38px; height: 1px;
  background: #c9a84c;
}

.l-quote {
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(2.2rem, 3.4vw, 3.2rem);
  font-weight: 300;
  line-height: 1.15;
  color: #fff;
  margin-bottom: 20px;
  opacity: 0;
  transform: translateY(22px);
  animation: slideUp 1s 0.9s ease forwards;
}
.l-quote em { color: #c9a84c; font-style: italic; }

.l-attr {
  font-size: 0.8rem;
  color: rgba(255,255,255,0.3);
  letter-spacing: 1px;
  opacity: 0;
  animation: slideUp 0.8s 1.1s ease forwards;
}

.l-chips {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 48px;
  opacity: 0;
  animation: slideUp 0.8s 1.2s ease forwards;
}
.l-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(201,168,76,0.2);
  border-radius: 100px;
  font-size: 0.74rem;
  font-weight: 500;
  color: rgba(255,255,255,0.55);
  backdrop-filter: blur(12px);
}
.l-chip i { color: #c9a84c; font-size: 0.68rem; }

/* ══════════════════════════════
   COLUMNA DERECHA
══════════════════════════════ */
.col-r {
  width: 480px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 50px;
  overflow-y: auto;
  position: relative;
  flex-shrink: 0;
}

@media (max-width: 820px) {
  .col-r { width: 100%; }
}

/* Halo pulsante detrás del form */
.col-r::before {
  content: '';
  position: absolute;
  width: 500px; height: 500px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(201,168,76,0.07) 0%, transparent 70%);
  top: 50%; left: 50%;
  transform: translate(-50%,-50%);
  pointer-events: none;
  animation: haloPulse 5s ease-in-out infinite;
}
@keyframes haloPulse {
  0%,100% { transform: translate(-50%,-50%) scale(1); opacity: 0.6; }
  50%      { transform: translate(-50%,-50%) scale(1.2); opacity: 1; }
}

.form-box {
  width: 100%;
  max-width: 380px;
  position: relative;
  opacity: 0;
  transform: translateY(30px);
  animation: slideUp 1s 0.2s ease forwards;
}

/* Logo */
.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  margin-bottom: 8px;
}
.logo-icon {
  width: 40px; height: 40px;
  background: rgba(201,168,76,0.12);
  border: 1px solid rgba(201,168,76,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #c9a84c;
  font-size: 1rem;
}
.logo-text {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.9rem;
  font-weight: 600;
  color: #fff;
}
.logo-text span { color: #c9a84c; }

.logo-sub {
  font-size: 0.76rem;
  color: rgba(255,255,255,0.25);
  letter-spacing: 0.5px;
  margin-bottom: 48px;
}

.form-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2.6rem;
  font-weight: 300;
  line-height: 1.1;
  margin-bottom: 8px;
}
.form-title em { color: #c9a84c; font-style: italic; }
.form-lead {
  font-size: 0.84rem;
  color: rgba(255,255,255,0.3);
  margin-bottom: 36px;
}

/* Alertas */
.msg {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 13px 16px;
  border-radius: 10px;
  font-size: 0.82rem;
  margin-bottom: 22px;
  border: 1px solid;
}
.msg-ok  { background: rgba(39,174,96,0.1);  border-color: rgba(39,174,96,0.25);  color: #2ecc71; }
.msg-err { background: rgba(231,76,60,0.1);  border-color: rgba(231,76,60,0.25);  color: #e74c3c; }
.msg-inf { background: rgba(41,182,246,0.1); border-color: rgba(41,182,246,0.25); color: #29b6f6; }

/* Campos */
.field-group { margin-bottom: 20px; }

.field-label {
  display: block;
  font-size: 0.68rem;
  font-weight: 600;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: rgba(255,255,255,0.3);
  margin-bottom: 8px;
  transition: color 0.3s;
}
.field-group:focus-within .field-label { color: #c9a84c; }

.field-wrap {
  display: flex;
  align-items: center;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 14px;
  overflow: hidden;
  position: relative;
  transition: border-color 0.35s, background 0.35s, box-shadow 0.35s;
}
.field-wrap:focus-within {
  border-color: #c9a84c;
  background: rgba(201,168,76,0.05);
  box-shadow: 0 0 0 3px rgba(201,168,76,0.09), 0 8px 28px rgba(0,0,0,0.35);
}
/* Barra animada inferior */
.field-wrap::after {
  content: '';
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 2px;
  background: linear-gradient(90deg, #c9a84c, #e8c96b);
  transform: scaleX(0);
  transform-origin: left;
  border-radius: 0 0 14px 14px;
  transition: transform 0.45s cubic-bezier(0.16,1,0.3,1);
}
.field-wrap:focus-within::after { transform: scaleX(1); }

.field-ico {
  width: 50px; height: 54px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255,255,255,0.18);
  font-size: 0.85rem;
  flex-shrink: 0;
  transition: color 0.3s;
}
.field-wrap:focus-within .field-ico { color: #c9a84c; }

.field-input {
  flex: 1;
  height: 54px;
  background: transparent;
  border: none;
  outline: none;
  font-family: 'Outfit', sans-serif;
  font-size: 0.9rem;
  color: #fff;
  padding-right: 16px;
}
.field-input::placeholder { color: rgba(255,255,255,0.15); }
.field-input:-webkit-autofill {
  -webkit-box-shadow: 0 0 0 50px rgba(10,10,20,0.98) inset !important;
  -webkit-text-fill-color: #fff !important;
}

.field-toggle {
  width: 46px; height: 54px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255,255,255,0.2);
  font-size: 0.85rem;
  cursor: pointer;
  flex-shrink: 0;
  transition: color 0.25s;
}
.field-toggle:hover { color: #c9a84c; }

/* Fila check + forgot */
.form-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
}
.chk-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 0.8rem;
  color: rgba(255,255,255,0.35);
}
.chk-label input { accent-color: #c9a84c; width: 15px; height: 15px; cursor: pointer; }
.forgot-link {
  font-size: 0.8rem;
  color: rgba(255,255,255,0.28);
  text-decoration: none;
  transition: color 0.25s;
}
.forgot-link:hover { color: #c9a84c; }

/* Botón principal */
.btn-submit {
  width: 100%;
  height: 56px;
  background: #c9a84c;
  border: none;
  border-radius: 14px;
  font-family: 'Outfit', sans-serif;
  font-size: 0.92rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  color: #06060e;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 28px;
  transition: background 0.3s, transform 0.3s, box-shadow 0.3s;
}
.btn-submit::before {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.22), transparent);
  opacity: 0;
  transition: opacity 0.3s;
}
.btn-submit:hover {
  background: #e8c96b;
  transform: translateY(-2px);
  box-shadow: 0 18px 50px rgba(201,168,76,0.45), 0 4px 16px rgba(0,0,0,0.4);
}
.btn-submit:hover::before { opacity: 1; }
.btn-submit:active { transform: translateY(0); }

/* Ripple */
.ripple-el {
  position: absolute;
  border-radius: 50%;
  background: rgba(255,255,255,0.3);
  transform: scale(0);
  animation: ripAnim 0.65s linear;
  pointer-events: none;
}
@keyframes ripAnim { to { transform: scale(4.5); opacity: 0; } }

/* Separador */
.sep {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 18px;
}
.sep-line { flex: 1; height: 1px; background: rgba(255,255,255,0.06); }
.sep-txt {
  font-size: 0.68rem;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: rgba(255,255,255,0.18);
}

/* Demo grid */
.demo-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-bottom: 30px;
}
.demo-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 11px 13px;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 10px;
  cursor: pointer;
  transition: background 0.25s, border-color 0.25s, transform 0.25s;
  text-align: left;
}
.demo-item:hover {
  background: rgba(201,168,76,0.1);
  border-color: rgba(201,168,76,0.25);
  transform: translateX(3px);
}
.demo-badge {
  font-size: 0.58rem;
  font-weight: 700;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  padding: 3px 8px;
  border-radius: 100px;
  flex-shrink: 0;
}
.db-a { background: rgba(231,76,60,0.2);  color: #e74c3c; }
.db-i { background: rgba(41,128,185,0.2); color: #3498db; }
.db-c { background: rgba(39,174,96,0.2);  color: #2ecc71; }
.db-u { background: rgba(127,140,141,0.2);color: #95a5a6; }
.demo-email {
  font-size: 0.7rem;
  color: rgba(255,255,255,0.38);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Pie */
.form-foot {
  text-align: center;
  font-size: 0.82rem;
  color: rgba(255,255,255,0.22);
}
.form-foot a {
  color: rgba(255,255,255,0.6);
  font-weight: 600;
  text-decoration: none;
  transition: color 0.25s;
}
.form-foot a:hover { color: #c9a84c; }

/* Cursor */
#cdot, #cring {
  position: fixed;
  border-radius: 50%;
  pointer-events: none;
  z-index: 9999;
}
#cdot {
  width: 7px; height: 7px;
  background: #c9a84c;
  transform: translate(-50%,-50%);
  mix-blend-mode: difference;
  transition: transform 0.15s;
}
#cring {
  width: 34px; height: 34px;
  border: 1.5px solid rgba(201,168,76,0.6);
  transform: translate(-50%,-50%);
  transition: all 0.35s cubic-bezier(0.16,1,0.3,1);
  opacity: 0.7;
}

@keyframes slideUp {
  to { opacity: 1; transform: translateY(0); }
}
</style>
</head>
<body>

<div id="cdot"></div>
<div id="cring"></div>
<canvas id="cv"></canvas>

<!-- Botón volver al inicio (fijo arriba a la izquierda) -->
<a href="${pageContext.request.contextPath}/index.jsp"
   style="position:fixed;top:20px;left:20px;z-index:1000;display:inline-flex;align-items:center;gap:8px;color:rgba(255,255,255,0.4);font-size:0.78rem;font-family:'Outfit',sans-serif;text-decoration:none;padding:8px 16px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.1);border-radius:100px;backdrop-filter:blur(12px);transition:all 0.25s;"
   onmouseover="this.style.color='#c9a84c';this.style.borderColor='rgba(201,168,76,0.35)';this.style.background='rgba(201,168,76,0.07)'"
   onmouseout="this.style.color='rgba(255,255,255,0.4)';this.style.borderColor='rgba(255,255,255,0.1)';this.style.background='rgba(255,255,255,0.04)'">
  <i class="fas fa-arrow-left"></i> Inicio
</a>

<div class="wrap">

  <!-- ═══ IZQUIERDA ═══ -->
  <div class="col-l">
    <div class="bg-img"></div>
    <div class="bg-grad"></div>
    <div class="left-vline"></div>
    <div class="left-wm">IV</div>
    <div class="left-body">
      <div class="l-tag"><i class="fas fa-gem"></i> Plataforma Premium</div>
      <div class="l-quote">
        El hogar no es<br>un lugar, es una<br><em>sensación.</em>
      </div>
      <div class="l-attr">— InmoVista, 2026</div>
      <div class="l-chips">
        <div class="l-chip"><i class="fas fa-shield-alt"></i> 100% Seguro</div>
        <div class="l-chip"><i class="fas fa-bolt"></i> Instantáneo</div>
        <div class="l-chip"><i class="fas fa-star"></i> Premium</div>
      </div>
    </div>
  </div>

  <!-- ═══ DERECHA ═══ -->
  <div class="col-r">
    <div class="form-box">

      <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
        <div class="logo-icon"><i class="fas fa-building"></i></div>
        <div class="logo-text">Inmo<span>Vista</span></div>
      </a>
      <div class="logo-sub">Tu plataforma inmobiliaria de confianza</div>

      <div class="form-title">Bienvenido<br>de <em>vuelta.</em></div>
      <div class="form-lead">Ingresa tus credenciales para continuar</div>

      <c:if test="${not empty param.registrado}">
        <div class="msg msg-ok"><i class="fas fa-check-circle"></i> ¡Registro exitoso! Ya puedes ingresar.</div>
      </c:if>
      <c:if test="${not empty param.logout}">
        <div class="msg msg-inf"><i class="fas fa-info-circle"></i> Sesión cerrada correctamente.</div>
      </c:if>
      <c:if test="${not empty error}">
        <div class="msg msg-err"><i class="fas fa-exclamation-circle"></i> ${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login.jsp" method="post" id="lform" novalidate>

        <div class="field-group">
          <label class="field-label">Correo electrónico</label>
          <div class="field-wrap">
            <div class="field-ico"><i class="fas fa-envelope"></i></div>
            <input class="field-input" type="email" name="email"
                   placeholder="tu@correo.com" value="${param.email}" required autofocus>
          </div>
        </div>

        <div class="field-group">
          <label class="field-label">Contraseña</label>
          <div class="field-wrap">
            <div class="field-ico"><i class="fas fa-lock"></i></div>
            <input class="field-input" type="password" name="password" id="pwd"
                   placeholder="••••••••" required>
            <div class="field-toggle" onclick="tglPwd(this)">
              <i class="fas fa-eye" id="eyeIco"></i>
            </div>
          </div>
        </div>

        <div class="form-row">
          <label class="chk-label">
            <input type="checkbox" name="recuerdame">
            Recordarme 30 días
          </label>
          <a href="#" class="forgot-link">¿Olvidaste tu contraseña?</a>
        </div>

        <button type="submit" class="btn-submit" id="subBtn" onclick="doRipple(event,this)">
          <i class="fas fa-arrow-right-to-bracket"></i>
          <span id="btnLabel">Iniciar Sesión</span>
        </button>

      </form>

      <div class="sep">
        <div class="sep-line"></div>
        <div class="sep-txt">Accesos Demo</div>
        <div class="sep-line"></div>
      </div>

      <div class="demo-grid">
        <button class="demo-item" onclick="autoFill('admin@inmobiliaria.com','Admin123!')">
          <span class="demo-badge db-a">Admin</span>
          <span class="demo-email">admin@inmobiliaria.com</span>
        </button>
        <button class="demo-item" onclick="autoFill('inmobiliaria@test.com','Test123!')">
          <span class="demo-badge db-i">Agente</span>
          <span class="demo-email">inmobiliaria@test.com</span>
        </button>
        <button class="demo-item" onclick="autoFill('cliente@test.com','Test123!')">
          <span class="demo-badge db-c">Cliente</span>
          <span class="demo-email">cliente@test.com</span>
        </button>
        <button class="demo-item" onclick="autoFill('usuario@test.com','Test123!')">
          <span class="demo-badge db-u">Usuario</span>
          <span class="demo-email">usuario@test.com</span>
        </button>
      </div>

      <div class="form-foot">
        ¿No tienes cuenta?
        <a href="${pageContext.request.contextPath}/registro.jsp">Regístrate gratis &rarr;</a>
      </div>

    </div>
  </div>
</div>

<script>
/* ═══════════════════════════════════
   CANVAS — Universo de partículas
═══════════════════════════════════ */
const canvas = document.getElementById('cv');
const ctx    = canvas.getContext('2d');
let W, H;
const mouse  = { x: window.innerWidth / 2, y: window.innerHeight / 2 };

function resize() {
  W = canvas.width  = window.innerWidth;
  H = canvas.height = window.innerHeight;
}
resize();
window.addEventListener('resize', resize);
window.addEventListener('mousemove', e => { mouse.x = e.clientX; mouse.y = e.clientY; });

/* Nodo */
class Dot {
  constructor() { this.init(); }
  init() {
    this.x  = Math.random() * W;
    this.y  = Math.random() * H;
    this.vx = (Math.random() - .5) * .55;
    this.vy = (Math.random() - .5) * .55;
    this.sz = Math.random() * 1.8 + .35;
    this.gold = Math.random() > .6;
    this.alpha = Math.random() * .5 + .12;
    this.phase = Math.random() * Math.PI * 2;
  }
  step() {
    /* repulsión del cursor */
    const dx = this.x - mouse.x;
    const dy = this.y - mouse.y;
    const d  = Math.sqrt(dx * dx + dy * dy);
    if (d < 140) {
      const f = (140 - d) / 140 * .9;
      this.vx += (dx / d) * f;
      this.vy += (dy / d) * f;
    }
    this.vx *= .977; this.vy *= .977;
    this.x  += this.vx; this.y  += this.vy;
    if (this.x < -8) this.x = W + 8;
    if (this.x > W+8) this.x = -8;
    if (this.y < -8) this.y = H + 8;
    if (this.y > H+8) this.y = -8;
    this.phase += .019;
  }
  draw() {
    const a = this.alpha + Math.sin(this.phase) * .11;
    const r = this.sz    + Math.sin(this.phase) * .3;
    ctx.beginPath();
    ctx.arc(this.x, this.y, r, 0, Math.PI * 2);
    ctx.fillStyle = this.gold
      ? `rgba(201,168,76,${a})`
      : `rgba(255,255,255,${a * .5})`;
    ctx.fill();
  }
}

/* Líneas entre nodos cercanos */
function drawEdges(dots) {
  const MAX = 130;
  for (let i = 0; i < dots.length - 1; i++) {
    for (let j = i + 1; j < dots.length; j++) {
      const dx = dots[i].x - dots[j].x;
      const dy = dots[i].y - dots[j].y;
      const d  = Math.sqrt(dx*dx + dy*dy);
      if (d < MAX) {
        const bothGold = dots[i].gold && dots[j].gold;
        const a = (1 - d / MAX) * (bothGold ? .25 : .1);
        ctx.beginPath();
        ctx.moveTo(dots[i].x, dots[i].y);
        ctx.lineTo(dots[j].x, dots[j].y);
        ctx.strokeStyle = bothGold
          ? `rgba(201,168,76,${a})`
          : `rgba(255,255,255,${a})`;
        ctx.lineWidth = bothGold ? .85 : .4;
        ctx.stroke();
      }
    }
  }
}

/* Órbitas */
const ORBITS = [
  { r: 170, spd: .00035, a: .045 },
  { r: 300, spd: .00022, a: .03  },
  { r: 450, spd: .00012, a: .018 },
];
let tick = 0;

function drawOrbits() {
  const cx2 = W * .5, cy2 = H * .5;
  ORBITS.forEach(o => {
    ctx.beginPath();
    ctx.arc(cx2, cy2, o.r, 0, Math.PI * 2);
    ctx.strokeStyle = `rgba(201,168,76,${o.a})`;
    ctx.lineWidth = .5;
    ctx.stroke();
    const ang = tick * o.spd;
    const px  = cx2 + Math.cos(ang) * o.r;
    const py  = cy2 + Math.sin(ang) * o.r;
    ctx.beginPath();
    ctx.arc(px, py, 2.8, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(201,168,76,${o.a * 6})`;
    ctx.fill();
  });
}

/* Meteoros */
const meteors = [];
function spawnMeteor() {
  if (Math.random() > .55) return;
  meteors.push({
    x: Math.random() * W, y: -30,
    vx: (Math.random() - .5) * 2.5,
    vy: Math.random() * 5 + 3,
    life: 1, len: Math.random() * 90 + 50,
  });
}
setInterval(spawnMeteor, 2200);

function drawMeteors() {
  for (let i = meteors.length - 1; i >= 0; i--) {
    const m = meteors[i];
    m.x += m.vx; m.y += m.vy; m.life -= .016;
    if (m.life <= 0 || m.y > H + 30) { meteors.splice(i, 1); continue; }
    const g = ctx.createLinearGradient(
      m.x, m.y,
      m.x - m.vx * m.len * .5, m.y - m.vy * m.len * .5
    );
    g.addColorStop(0, `rgba(201,168,76,${m.life * .75})`);
    g.addColorStop(1, 'rgba(201,168,76,0)');
    ctx.beginPath();
    ctx.moveTo(m.x, m.y);
    ctx.lineTo(m.x - m.vx * m.len * .5, m.y - m.vy * m.len * .5);
    ctx.strokeStyle = g;
    ctx.lineWidth = 1.8;
    ctx.stroke();
  }
}

const dots = Array.from({ length: 95 }, () => new Dot());

(function loop() {
  ctx.clearRect(0, 0, W, H);
  tick++;
  drawOrbits();
  drawEdges(dots);
  dots.forEach(d => { d.step(); d.draw(); });
  drawMeteors();
  requestAnimationFrame(loop);
})();

/* ═══════════════════════════════════
   CURSOR PERSONALIZADO
═══════════════════════════════════ */
const $dot  = document.getElementById('cdot');
const $ring = document.getElementById('cring');
let mx = 0, my = 0, rx = 0, ry = 0;

window.addEventListener('mousemove', e => {
  mx = e.clientX; my = e.clientY;
  $dot.style.left = mx + 'px';
  $dot.style.top  = my + 'px';
});
(function cursorLoop() {
  rx += (mx - rx) * .13;
  ry += (my - ry) * .13;
  $ring.style.left = rx + 'px';
  $ring.style.top  = ry + 'px';
  requestAnimationFrame(cursorLoop);
})();

document.querySelectorAll('a, button, input, .demo-item, .field-toggle, .chk-label').forEach(el => {
  el.addEventListener('mouseenter', () => {
    $ring.style.transform = 'translate(-50%,-50%) scale(2.2)';
    $ring.style.borderColor = '#c9a84c';
    $dot.style.transform = 'translate(-50%,-50%) scale(0)';
  });
  el.addEventListener('mouseleave', () => {
    $ring.style.transform = 'translate(-50%,-50%) scale(1)';
    $dot.style.transform  = 'translate(-50%,-50%) scale(1)';
  });
});

/* ═══════════════════════════════════
   BOTÓN MAGNÉTICO
═══════════════════════════════════ */
const btn = document.getElementById('subBtn');
btn.addEventListener('mousemove', e => {
  const r  = btn.getBoundingClientRect();
  const ox = (e.clientX - r.left - r.width  / 2) * .28;
  const oy = (e.clientY - r.top  - r.height / 2) * .28;
  btn.style.transform = `translate(${ox}px, ${oy - 2}px)`;
});
btn.addEventListener('mouseleave', () => { btn.style.transform = ''; });

/* ═══════════════════════════════════
   RIPPLE
═══════════════════════════════════ */
function doRipple(e, el) {
  const r  = document.createElement('span');
  const rc = el.getBoundingClientRect();
  const sz = Math.max(rc.width, rc.height);
  r.className = 'ripple-el';
  r.style.cssText = `width:${sz}px;height:${sz}px;`
    + `left:${e.clientX - rc.left - sz/2}px;`
    + `top:${e.clientY - rc.top  - sz/2}px;`;
  el.appendChild(r);
  setTimeout(() => r.remove(), 700);
}

/* ═══════════════════════════════════
   TOGGLE CONTRASEÑA
═══════════════════════════════════ */
function tglPwd(el) {
  const p = document.getElementById('pwd');
  const i = document.getElementById('eyeIco');
  if (p.type === 'password') {
    p.type = 'text';
    i.classList.replace('fa-eye', 'fa-eye-slash');
    el.style.color = '#c9a84c';
  } else {
    p.type = 'password';
    i.classList.replace('fa-eye-slash', 'fa-eye');
    el.style.color = '';
  }
}

/* ═══════════════════════════════════
   AUTOFILL CON EFECTO TYPEWRITER
═══════════════════════════════════ */
function autoFill(email, pass) {
  const eEl = document.querySelector('input[name="email"]');
  const pEl = document.getElementById('pwd');
  eEl.value = ''; pEl.value = '';
  let i = 0;
  const te = setInterval(() => {
    eEl.value += email[i++];
    if (i >= email.length) {
      clearInterval(te);
      let j = 0;
      const tp = setInterval(() => {
        pEl.value += pass[j++];
        if (j >= pass.length) clearInterval(tp);
      }, 40);
    }
  }, 28);
}

/* ═══════════════════════════════════
   SUBMIT FEEDBACK
═══════════════════════════════════ */
document.getElementById('lform').addEventListener('submit', () => {
  const b = document.getElementById('subBtn');
  const l = document.getElementById('btnLabel');
  b.disabled = true;
  l.textContent = 'Verificando...';
  b.style.opacity = '.8';
});
</script>
</body>
</html>
