<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
/* ══ HANDLER POST: registro demo ══
   En producción esto lo hace RegisterServlet con JDBC + validación BD.
   Para demo, creamos sesión de cliente directamente con los datos del form.
*/
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre    = request.getParameter("nombre");
    String apellido  = request.getParameter("apellido");
    String email     = request.getParameter("email");
    String password  = request.getParameter("password");
    String confirm   = request.getParameter("passwordConfirm");
    String telefono  = request.getParameter("telefono");
    String rolParam  = request.getParameter("rol"); // "3"=cliente, "4"=inmobiliaria

    if (nombre == null)   nombre = "";
    if (apellido == null) apellido = "Usuario";
    if (email == null)    email = "";
    if (password == null) password = "";
    if (confirm == null)  confirm = "";
    if (telefono == null) telefono = "";

    // Determinar rol segun seleccion del usuario
    // BD: 1=admin, 2=inmobiliaria, 3=cliente, 4=usuario
    int rolId = 3; // cliente por defecto
    String rolNombreReg = "cliente";
    if ("inmobiliaria".equals(rolParam) || "2".equals(rolParam) || "4".equals(rolParam)) {
        rolId = 2;
        rolNombreReg = "inmobiliaria";
    }

    nombre  = nombre.trim();
    email   = email.trim().toLowerCase();

    // Validaciones básicas
    String regError = null;
    if (nombre.isEmpty() || email.isEmpty() || password.isEmpty()) {
        regError = "Por favor completa todos los campos obligatorios.";
    } else if (!email.contains("@")) {
        regError = "El correo electrónico no es válido.";
    } else if (password.length() < 8) {
        regError = "La contraseña debe tener al menos 8 caracteres.";
    } else if (!password.equals(confirm) && !confirm.isEmpty()) {
        regError = "Las contraseñas no coinciden.";
    }

    if (regError != null) {
        request.setAttribute("error", regError);
    } else {
        int nuevoId = 0;
        java.sql.Connection con = null;
        boolean savedToDB = false;
        String dbErrorMsg  = null;

        // ── Hash SHA-256 de la contrasena ──────────────────
        String passwordHash = password;
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes("UTF-8"));
            StringBuilder sbH = new StringBuilder();
            for (byte b : hashBytes) sbH.append(String.format("%02x", b));
            passwordHash = sbH.toString();
        } catch (Exception hashEx) { /* usar password plano si falla el hash */ }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8",
                "root", "");

            // Verificar si el correo ya existe
            java.sql.PreparedStatement chk = con.prepareStatement(
                "SELECT id FROM usuarios WHERE email = ?");
            chk.setString(1, email);
            java.sql.ResultSet chkRs = chk.executeQuery();
            boolean existe = chkRs.next();
            chkRs.close(); chk.close();

            if (existe) {
                request.setAttribute("error",
                    "El correo " + email + " ya esta registrado. Inicia sesion.");
            } else {
                // Insertar con el rol seleccionado por el usuario
                // inmobiliaria entra con activo=0 hasta que el admin apruebe
                int activoVal = (rolId == 2) ? 0 : 1;
                java.sql.PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO usuarios (nombre, apellido, email, password, telefono, rol_id, activo, fecha_registro) VALUES (?,?,?,?,?,?,?,NOW())",
                    java.sql.Statement.RETURN_GENERATED_KEYS);
                ins.setString(1, nombre);
                ins.setString(2, apellido.isEmpty() ? "" : apellido);
                ins.setString(3, email);
                ins.setString(4, passwordHash);
                ins.setString(5, telefono);
                ins.setInt(6, rolId);
                ins.setInt(7, activoVal);
                ins.executeUpdate();
                java.sql.ResultSet keys = ins.getGeneratedKeys();
                if (keys.next()) nuevoId = keys.getInt(1);
                keys.close(); ins.close();
                savedToDB = true;
            }
        } catch (Exception dbEx) {
            dbErrorMsg = dbEx.getMessage();
            savedToDB  = false;
        } finally {
            if (con != null) { try { con.close(); } catch(Exception e){} }
        }

        if (request.getAttribute("error") == null) {
            if (!savedToDB) {
                // Mostrar error real para que el admin sepa que fallo la BD
                request.setAttribute("error",
                    "No se pudo guardar en la base de datos. Verifica que MySQL este activo." +
                    (dbErrorMsg != null ? " Detalle: " + dbErrorMsg : ""));
            } else {
                // Registro exitoso en BD — crear sesion
                java.util.Map<String,Object> usr = new java.util.LinkedHashMap<String,Object>();
                usr.put("id",            nuevoId);
                usr.put("nombre",        nombre);
                usr.put("apellido",      apellido);
                usr.put("email",         email);
                usr.put("telefono",      telefono);
                usr.put("fechaRegistro", new java.util.Date());
                session.setAttribute("usuario",   usr);
                session.setAttribute("rolNombre", rolNombreReg);
                session.setAttribute("userId",    nuevoId);

                if (rolId == 2) {
                    // inmobiliaria: mostrar pagina de espera de aprobacion
                    session.invalidate(); // no crear sesion hasta aprobacion
                    response.sendRedirect(request.getContextPath() + "/pendiente-aprobacion.jsp");
                    return;
                } else {
                    String msg = java.net.URLEncoder.encode(
                        "Bienvenido/a a InmoVista, " + nombre + "! Tu cuenta fue creada correctamente.", "UTF-8");
                    response.sendRedirect(request.getContextPath() + "/" + rolNombreReg + ".jsp?tab=dashboard&msg=" + msg);
                    return;
                }
            }
        }
    }
}

/* ══ Si ya hay sesión, redirigir ══ */
if (session.getAttribute("usuario") != null) {
    String rol = (String) session.getAttribute("rolNombre");
    response.sendRedirect(request.getContextPath() + "/" + rol + ".jsp");
    return;
}
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Crear Cuenta — InmoVista</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,700;1,300;1,400&family=Outfit:wght@200;300;400;500;600;700&display=swap" rel="stylesheet">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html, body {
  width: 100%; height: 100%;
  font-family: 'Outfit', sans-serif;
  background: #06060e;
  color: #fff;
  overflow: hidden;
}

#cv {
  position: fixed; top: 0; left: 0;
  width: 100%; height: 100%;
  z-index: 0; pointer-events: none;
}

/* ── GRAIN ── */
body::after {
  content: '';
  position: fixed; inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.035'/%3E%3C/svg%3E");
  pointer-events: none; z-index: 1; opacity: .55;
}

/* ── LAYOUT ── */
.wrap {
  position: relative; z-index: 2;
  display: flex; width: 100vw; height: 100vh;
}

/* ════════════════════════
   COLUMNA IZQUIERDA
════════════════════════ */
.col-l {
  flex: 1; position: relative;
  overflow: hidden;
  display: flex; align-items: center; justify-content: center;
}
@media (max-width: 900px) { .col-l { display: none; } }

.bg-img {
  position: absolute; inset: -12%;
  background: url('https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1400&q=85') center/cover no-repeat;
  filter: brightness(.28) saturate(.6);
  transform: scale(1.1);
  animation: bgZoom 24s ease-in-out infinite alternate;
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
.l-vline {
  position: absolute; left: 13%; top: 12%; bottom: 12%;
  width: 1px;
  background: linear-gradient(180deg, transparent, #c9a84c, transparent);
  opacity: 0;
  animation: vIn 1.8s .5s ease forwards;
}
@keyframes vIn { to { opacity: .4; } }

.l-wm {
  position: absolute; right: -2%; bottom: -10%;
  font-family: 'Cormorant Garamond', serif;
  font-size: 32rem; font-weight: 700;
  color: transparent;
  -webkit-text-stroke: 1px rgba(201,168,76,.055);
  line-height: 1; user-select: none; pointer-events: none;
}

.l-body {
  position: relative; z-index: 3;
  padding: 64px; max-width: 500px;
}
.l-tag {
  display: inline-flex; align-items: center; gap: 12px;
  font-size: .68rem; font-weight: 600; letter-spacing: 4px;
  text-transform: uppercase; color: #c9a84c;
  margin-bottom: 28px;
  opacity: 0; transform: translateY(18px);
  animation: sUp .9s .7s ease forwards;
}
.l-tag::before { content: ''; width: 38px; height: 1px; background: #c9a84c; }

.l-quote {
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(2rem, 3.2vw, 3rem);
  font-weight: 300; line-height: 1.2; color: #fff;
  margin-bottom: 20px;
  opacity: 0; transform: translateY(22px);
  animation: sUp 1s .9s ease forwards;
}
.l-quote em { color: #c9a84c; font-style: italic; }
.l-attr {
  font-size: .8rem; color: rgba(255,255,255,.3); letter-spacing: 1px;
  opacity: 0; animation: sUp .8s 1.1s ease forwards;
}

/* Stats izquierda */
.l-stats {
  display: flex; gap: 36px; margin-top: 48px;
  opacity: 0; animation: sUp .8s 1.2s ease forwards;
}
.lstat-num {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2.4rem; font-weight: 700;
  color: #c9a84c; line-height: 1;
}
.lstat-lbl {
  font-size: .7rem; font-weight: 600;
  letter-spacing: 2px; text-transform: uppercase;
  color: rgba(255,255,255,.28); margin-top: 4px;
}
.l-sep { width: 1px; background: rgba(201,168,76,.2); align-self: stretch; }

.l-chips {
  display: flex; gap: 10px; flex-wrap: wrap; margin-top: 36px;
  opacity: 0; animation: sUp .8s 1.3s ease forwards;
}
.l-chip {
  display: flex; align-items: center; gap: 7px;
  padding: 9px 16px;
  background: rgba(255,255,255,.04);
  border: 1px solid rgba(201,168,76,.2);
  border-radius: 100px;
  font-size: .73rem; font-weight: 500;
  color: rgba(255,255,255,.5);
  backdrop-filter: blur(10px);
}
.l-chip i { color: #c9a84c; font-size: .68rem; }

/* ════════════════════════
   COLUMNA DERECHA (scroll)
════════════════════════ */
.col-r {
  width: 520px; flex-shrink: 0;
  display: flex; align-items: flex-start; justify-content: center;
  padding: 0; overflow-y: auto;
  position: relative;
  scrollbar-width: thin;
  scrollbar-color: rgba(201,168,76,.2) transparent;
}
@media (max-width: 900px) { .col-r { width: 100%; } }

/* Halo */
.col-r::before {
  content: ''; position: fixed;
  width: 500px; height: 500px; border-radius: 50%;
  background: radial-gradient(circle, rgba(201,168,76,.065) 0%, transparent 70%);
  top: 50%; right: 100px;
  transform: translateY(-50%);
  pointer-events: none;
  animation: halo 5s ease-in-out infinite;
}
@keyframes halo {
  0%,100% { opacity: .6; transform: translateY(-50%) scale(1); }
  50%      { opacity: 1;  transform: translateY(-50%) scale(1.18); }
}

.form-box {
  width: 100%; max-width: 440px;
  padding: 48px 0 60px;
  opacity: 0; transform: translateY(30px);
  animation: sUp 1s .2s ease forwards;
}

/* Logo */
.logo {
  display: flex; align-items: center; gap: 10px;
  text-decoration: none; margin-bottom: 8px;
}
.logo-icon {
  width: 40px; height: 40px;
  background: rgba(201,168,76,.12);
  border: 1px solid rgba(201,168,76,.22);
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  color: #c9a84c; font-size: 1rem;
}
.logo-txt {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.9rem; font-weight: 600; color: #fff;
}
.logo-txt span { color: #c9a84c; }
.logo-sub {
  font-size: .76rem; color: rgba(255,255,255,.24);
  letter-spacing: .5px; margin-bottom: 40px;
}

.form-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2.5rem; font-weight: 300;
  line-height: 1.1; margin-bottom: 6px;
}
.form-title em { color: #c9a84c; font-style: italic; }
.form-lead { font-size: .84rem; color: rgba(255,255,255,.3); margin-bottom: 32px; }

/* Error */
.msg {
  display: flex; align-items: center; gap: 10px;
  padding: 13px 16px; border-radius: 10px;
  font-size: .82rem; margin-bottom: 22px; border: 1px solid;
}
.msg-err { background: rgba(231,76,60,.1); border-color: rgba(231,76,60,.25); color: #e74c3c; }

/* ── SELECTOR TIPO CUENTA ── */
.type-grid {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 10px; margin-bottom: 24px;
}
.type-opt { position: relative; }
.type-opt input { position: absolute; opacity: 0; width: 0; height: 0; }
.type-lbl {
  display: flex; align-items: flex-start; gap: 12px;
  padding: 16px;
  background: rgba(255,255,255,.04);
  border: 1px solid rgba(255,255,255,.08);
  border-radius: 14px;
  cursor: pointer;
  transition: all .3s;
}
.type-lbl:hover {
  background: rgba(201,168,76,.06);
  border-color: rgba(201,168,76,.25);
}
.type-opt input:checked + .type-lbl {
  background: rgba(201,168,76,.1);
  border-color: #c9a84c;
  box-shadow: 0 0 0 3px rgba(201,168,76,.09);
}
.type-ico {
  width: 36px; height: 36px; flex-shrink: 0;
  background: rgba(201,168,76,.12);
  border: 1px solid rgba(201,168,76,.2);
  border-radius: 9px;
  display: flex; align-items: center; justify-content: center;
  color: #c9a84c; font-size: .9rem;
  transition: background .3s;
}
.type-opt input:checked + .type-lbl .type-ico {
  background: rgba(201,168,76,.25);
}
.type-name {
  font-size: .88rem; font-weight: 600; color: #fff; margin-bottom: 2px;
}
.type-desc { font-size: .73rem; color: rgba(255,255,255,.3); }

/* ── CAMPOS ── */
.field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { margin-bottom: 16px; }
.fl {
  display: block;
  font-size: .68rem; font-weight: 600; letter-spacing: 2px;
  text-transform: uppercase; color: rgba(255,255,255,.28);
  margin-bottom: 7px; transition: color .3s;
}
.fg:focus-within .fl { color: #c9a84c; }

.fw {
  display: flex; align-items: center;
  background: rgba(255,255,255,.04);
  border: 1px solid rgba(255,255,255,.08);
  border-radius: 12px; overflow: hidden;
  position: relative;
  transition: all .35s cubic-bezier(.16,1,.3,1);
}
.fw:focus-within {
  border-color: #c9a84c;
  background: rgba(201,168,76,.05);
  box-shadow: 0 0 0 3px rgba(201,168,76,.09), 0 8px 28px rgba(0,0,0,.3);
}
.fw::after {
  content: ''; position: absolute;
  bottom: 0; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg, #c9a84c, #e8c96b);
  transform: scaleX(0); transform-origin: left;
  border-radius: 0 0 12px 12px;
  transition: transform .45s cubic-bezier(.16,1,.3,1);
}
.fw:focus-within::after { transform: scaleX(1); }

.fi {
  width: 44px; height: 50px;
  display: flex; align-items: center; justify-content: center;
  color: rgba(255,255,255,.18); font-size: .82rem; flex-shrink: 0;
  transition: color .3s;
}
.fw:focus-within .fi { color: #c9a84c; }

.finp {
  flex: 1; height: 50px;
  background: transparent; border: none; outline: none;
  font-family: 'Outfit', sans-serif;
  font-size: .88rem; color: #fff; padding-right: 14px;
}
.finp::placeholder { color: rgba(255,255,255,.14); }
.finp:-webkit-autofill {
  -webkit-box-shadow: 0 0 0 50px rgba(10,10,20,.98) inset !important;
  -webkit-text-fill-color: #fff !important;
}

.feye {
  width: 42px; height: 50px;
  display: flex; align-items: center; justify-content: center;
  color: rgba(255,255,255,.18); font-size: .82rem;
  cursor: pointer; flex-shrink: 0; transition: color .25s;
}
.feye:hover { color: #c9a84c; }

/* Barra de fuerza */
.strength-bars {
  display: flex; gap: 4px; margin-top: 7px;
}
.sb {
  flex: 1; height: 3px; border-radius: 3px;
  background: rgba(255,255,255,.08);
  transition: background .35s;
}
.strength-txt {
  font-size: .68rem; margin-top: 4px; height: 14px;
  transition: color .3s;
}

/* Match msg */
.match-msg { font-size: .7rem; margin-top: 5px; height: 14px; }

/* Términos */
.terms-row {
  display: flex; gap: 10px; align-items: flex-start;
  margin-bottom: 26px;
}
.terms-row input { accent-color: #c9a84c; width: 15px; height: 15px; margin-top: 2px; cursor: pointer; flex-shrink: 0; }
.terms-row label {
  font-size: .82rem; color: rgba(255,255,255,.32); cursor: pointer; line-height: 1.5;
}
.terms-row a { color: rgba(255,255,255,.65); font-weight: 600; text-decoration: none; transition: color .25s; }
.terms-row a:hover { color: #c9a84c; }

/* Botón */
.btn-sub {
  width: 100%; height: 56px;
  background: #c9a84c; border: none; border-radius: 14px;
  font-family: 'Outfit', sans-serif;
  font-size: .92rem; font-weight: 700; letter-spacing: .5px;
  color: #06060e; cursor: pointer;
  position: relative; overflow: hidden;
  display: flex; align-items: center; justify-content: center; gap: 10px;
  margin-bottom: 26px;
  transition: background .3s, transform .3s, box-shadow .3s;
}
.btn-sub::before {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,.22), transparent);
  opacity: 0; transition: opacity .3s;
}
.btn-sub:hover {
  background: #e8c96b; transform: translateY(-2px);
  box-shadow: 0 18px 50px rgba(201,168,76,.45), 0 4px 16px rgba(0,0,0,.4);
}
.btn-sub:hover::before { opacity: 1; }
.btn-sub:active { transform: translateY(0); }

/* Ripple */
.rip {
  position: absolute; border-radius: 50%;
  background: rgba(255,255,255,.28);
  transform: scale(0); animation: ripA .65s linear;
  pointer-events: none;
}
@keyframes ripA { to { transform: scale(4.5); opacity: 0; } }

/* Foot */
.form-foot {
  text-align: center; font-size: .82rem; color: rgba(255,255,255,.22);
}
.form-foot a {
  color: rgba(255,255,255,.6); font-weight: 600;
  text-decoration: none; transition: color .25s;
}
.form-foot a:hover { color: #c9a84c; }

/* Cursor */
#cdot, #cring {
  position: fixed; border-radius: 50%;
  pointer-events: none; z-index: 9999;
}
#cdot {
  width: 7px; height: 7px; background: #c9a84c;
  transform: translate(-50%,-50%); mix-blend-mode: difference;
  transition: transform .15s;
}
#cring {
  width: 34px; height: 34px;
  border: 1.5px solid rgba(201,168,76,.6);
  transform: translate(-50%,-50%);
  transition: all .35s cubic-bezier(.16,1,.3,1); opacity: .7;
}

@keyframes sUp { to { opacity: 1; transform: translateY(0); } }
</style>
</head>
<body>

<div id="cdot"></div>
<div id="cring"></div>
<canvas id="cv">

<!-- Botón volver al inicio -->
<a href="${pageContext.request.contextPath}/index.jsp"
   style="position:fixed;top:20px;left:20px;z-index:1000;display:inline-flex;align-items:center;gap:8px;color:rgba(255,255,255,0.4);font-size:0.78rem;font-family:'Outfit',sans-serif;text-decoration:none;padding:8px 16px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.1);border-radius:100px;backdrop-filter:blur(12px);transition:all 0.25s;"
   onmouseover="this.style.color='#c9a84c';this.style.borderColor='rgba(201,168,76,0.35)';this.style.background='rgba(201,168,76,0.07)'"
   onmouseout="this.style.color='rgba(255,255,255,0.4)';this.style.borderColor='rgba(255,255,255,0.1)';this.style.background='rgba(255,255,255,0.04)'">
  <i class="fas fa-arrow-left"></i> Inicio
</a></canvas>

<div class="wrap">

  <!-- ══ IZQUIERDA ══ -->
  <div class="col-l">
    <div class="bg-img"></div>
    <div class="bg-grad"></div>
    <div class="l-vline"></div>
    <div class="l-wm">IV</div>
    <div class="l-body">
      <div class="l-tag"><i class="fas fa-key"></i> Únete Hoy</div>
      <div class="l-quote">
        Cada gran sueño<br>comienza con un<br><em>primer paso.</em>
      </div>
      <div class="l-attr">— InmoVista, 2026</div>
      <div class="l-stats">
        <div>
          <div class="lstat-num">500<span style="font-size:1.4rem">+</span></div>
          <div class="lstat-lbl">Propiedades</div>
        </div>
        <div class="l-sep"></div>
        <div>
          <div class="lstat-num">200<span style="font-size:1.4rem">+</span></div>
          <div class="lstat-lbl">Clientes felices</div>
        </div>
        <div class="l-sep"></div>
        <div>
          <div class="lstat-num">8<span style="font-size:1.4rem"> años</span></div>
          <div class="lstat-lbl">Experiencia</div>
        </div>
      </div>
      <div class="l-chips">
        <div class="l-chip"><i class="fas fa-shield-alt"></i> Seguro</div>
        <div class="l-chip"><i class="fas fa-bolt"></i> Gratis</div>
        <div class="l-chip"><i class="fas fa-star"></i> Premium</div>
      </div>
    </div>
  </div>

  <!-- ══ DERECHA (scroll) ══ -->
  <div class="col-r">
    <div class="form-box">

      <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
        <div class="logo-icon"><i class="fas fa-building"></i></div>
        <div class="logo-txt">Inmo<span>Vista</span></div>
      </a>
      <div class="logo-sub">Tu hogar comienza aquí</div>

      <div class="form-title">Crea tu<br><em>cuenta.</em></div>
      <div class="form-lead">Accede a todas las funcionalidades de InmoVista</div>

      <c:if test="${not empty error}">
        <div class="msg msg-err"><i class="fas fa-exclamation-circle"></i> ${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/registro.jsp" method="post" id="rf" novalidate>

        <!-- Tipo de cuenta -->
        <div class="type-grid" style="margin-bottom:24px;">
          <div class="type-opt">
            <input type="radio" name="rol" id="rCli" value="3" checked>
            <label class="type-lbl" for="rCli">
              <div class="type-ico"><i class="fas fa-user"></i></div>
              <div>
                <div class="type-name">Cliente</div>
                <div class="type-desc">Busca y solicita propiedades</div>
              </div>
            </label>
          </div>
          <div class="type-opt">
            <input type="radio" name="rol" id="rInm" value="inmobiliaria">
            <label class="type-lbl" for="rInm">
              <div class="type-ico"><i class="fas fa-building"></i></div>
              <div>
                <div class="type-name">Inmobiliaria</div>
                <div class="type-desc">Publica y gestiona propiedades</div>
              </div>
            </label>
          </div>
        </div>

        <!-- Nombre + Apellido -->
        <div class="field-row">
          <div class="fg">
            <label class="fl">Nombre</label>
            <div class="fw">
              <div class="fi"><i class="fas fa-user"></i></div>
              <input class="finp" type="text" name="nombre" placeholder="Tu nombre" value="${param.nombre}" required>
            </div>
          </div>
          <div class="fg">
            <label class="fl">Apellido</label>
            <div class="fw">
              <div class="fi"><i class="fas fa-user"></i></div>
              <input class="finp" type="text" name="apellido" placeholder="Tu apellido" value="${param.apellido}" required>
            </div>
          </div>
        </div>

        <!-- Email -->
        <div class="fg">
          <label class="fl">Correo electrónico</label>
          <div class="fw">
            <div class="fi"><i class="fas fa-envelope"></i></div>
            <input class="finp" type="email" name="email" placeholder="tu@correo.com" value="${param.email}" required>
          </div>
        </div>

        <!-- Teléfono -->
        <div class="fg">
          <label class="fl">Teléfono <span style="color:rgba(255,255,255,.2);font-size:.65rem;letter-spacing:1px;">(opcional)</span></label>
          <div class="fw">
            <div class="fi"><i class="fas fa-phone"></i></div>
            <input class="finp" type="tel" name="telefono" placeholder="+57 300 000 0000" value="${param.telefono}">
          </div>
        </div>

        <!-- Contraseñas -->
        <div class="field-row">
          <div class="fg">
            <label class="fl">Contraseña</label>
            <div class="fw">
              <div class="fi"><i class="fas fa-lock"></i></div>
              <input class="finp" type="password" name="password" id="pwd1"
                     placeholder="Mín. 8 caracteres" required minlength="8"
                     oninput="chkStr(this.value)">
              <div class="feye" onclick="tglP('pwd1','ei1')"><i class="fas fa-eye" id="ei1"></i></div>
            </div>
            <div class="strength-bars">
              <div class="sb" id="s1"></div>
              <div class="sb" id="s2"></div>
              <div class="sb" id="s3"></div>
              <div class="sb" id="s4"></div>
            </div>
            <div class="strength-txt" id="stxt"></div>
          </div>
          <div class="fg">
            <label class="fl">Confirmar</label>
            <div class="fw">
              <div class="fi"><i class="fas fa-lock"></i></div>
              <input class="finp" type="password" name="confirm" id="pwd2"
                     placeholder="Repite la contraseña" required
                     oninput="chkMatch()">
              <div class="feye" onclick="tglP('pwd2','ei2')"><i class="fas fa-eye" id="ei2"></i></div>
            </div>
            <div class="match-msg" id="mmsg"></div>
          </div>
        </div>

        <!-- Términos -->
        <div class="terms-row">
          <input type="checkbox" id="terms" required>
          <label for="terms">
            Acepto los <a href="#">Términos de Servicio</a>
            y la <a href="#">Política de Privacidad</a> de InmoVista
          </label>
        </div>

        <button type="submit" class="btn-sub" id="subBtn" onclick="doRip(event,this)">
          <i class="fas fa-user-plus"></i>
          <span id="btnLbl">Crear cuenta gratuita</span>
        </button>

      </form>

      <div class="form-foot">
        ¿Ya tienes cuenta?
        <a href="${pageContext.request.contextPath}/login.jsp">Iniciar sesión &rarr;</a>
      </div>

    </div>
  </div>
</div>

<script>
/* ══ CANVAS — mismo universo que login ══ */
const canvas = document.getElementById('cv');
const ctx    = canvas.getContext('2d');
let W, H;
const mouse = { x: innerWidth / 2, y: innerHeight / 2 };

function resize() { W = canvas.width = innerWidth; H = canvas.height = innerHeight; }
resize();
window.addEventListener('resize', resize);
window.addEventListener('mousemove', e => { mouse.x = e.clientX; mouse.y = e.clientY; });

class Dot {
  constructor() { this.init(); }
  init() {
    this.x  = Math.random() * W;
    this.y  = Math.random() * H;
    this.vx = (Math.random() - .5) * .52;
    this.vy = (Math.random() - .5) * .52;
    this.sz = Math.random() * 1.7 + .35;
    this.gold = Math.random() > .62;
    this.a  = Math.random() * .48 + .12;
    this.ph = Math.random() * Math.PI * 2;
  }
  step() {
    const dx = this.x - mouse.x, dy = this.y - mouse.y;
    const d  = Math.sqrt(dx*dx + dy*dy);
    if (d < 140) { const f = (140-d)/140*.85; this.vx += dx/d*f; this.vy += dy/d*f; }
    this.vx *= .977; this.vy *= .977;
    this.x += this.vx; this.y += this.vy;
    if (this.x < -8) this.x = W+8; if (this.x > W+8) this.x = -8;
    if (this.y < -8) this.y = H+8; if (this.y > H+8) this.y = -8;
    this.ph += .018;
  }
  draw() {
    const a = this.a + Math.sin(this.ph) * .1;
    const r = this.sz + Math.sin(this.ph) * .3;
    ctx.beginPath(); ctx.arc(this.x, this.y, r, 0, Math.PI*2);
    ctx.fillStyle = this.gold ? `rgba(201,168,76,${a})` : `rgba(255,255,255,${a*.5})`;
    ctx.fill();
  }
}

function drawEdges(dots) {
  const MAX = 128;
  for (let i = 0; i < dots.length-1; i++) {
    for (let j = i+1; j < dots.length; j++) {
      const dx = dots[i].x-dots[j].x, dy = dots[i].y-dots[j].y;
      const d  = Math.sqrt(dx*dx+dy*dy);
      if (d < MAX) {
        const bg = dots[i].gold && dots[j].gold;
        const a  = (1-d/MAX) * (bg ? .24 : .09);
        ctx.beginPath(); ctx.moveTo(dots[i].x,dots[i].y); ctx.lineTo(dots[j].x,dots[j].y);
        ctx.strokeStyle = bg ? `rgba(201,168,76,${a})` : `rgba(255,255,255,${a})`;
        ctx.lineWidth = bg ? .8 : .38; ctx.stroke();
      }
    }
  }
}

const ORBITS = [{r:170,s:.00034,a:.042},{r:300,s:.00021,a:.028},{r:450,s:.00011,a:.017}];
let tick = 0;
function drawOrbits() {
  const cx2 = W*.5, cy2 = H*.5;
  ORBITS.forEach(o => {
    ctx.beginPath(); ctx.arc(cx2,cy2,o.r,0,Math.PI*2);
    ctx.strokeStyle=`rgba(201,168,76,${o.a})`; ctx.lineWidth=.48; ctx.stroke();
    const ang=tick*o.s;
    const px=cx2+Math.cos(ang)*o.r, py=cy2+Math.sin(ang)*o.r;
    ctx.beginPath(); ctx.arc(px,py,2.6,0,Math.PI*2);
    ctx.fillStyle=`rgba(201,168,76,${o.a*6})`; ctx.fill();
  });
}

const meteors = [];
setInterval(() => {
  if (Math.random()>.5) meteors.push({
    x:Math.random()*W, y:-30,
    vx:(Math.random()-.5)*2.4, vy:Math.random()*4.5+3,
    life:1, len:Math.random()*85+45
  });
}, 2400);
function drawMeteors() {
  for (let i=meteors.length-1; i>=0; i--) {
    const m=meteors[i];
    m.x+=m.vx; m.y+=m.vy; m.life-=.015;
    if (m.life<=0||m.y>H+30) { meteors.splice(i,1); continue; }
    const g=ctx.createLinearGradient(m.x,m.y,m.x-m.vx*m.len*.5,m.y-m.vy*m.len*.5);
    g.addColorStop(0,`rgba(201,168,76,${m.life*.78})`);
    g.addColorStop(1,'rgba(201,168,76,0)');
    ctx.beginPath(); ctx.moveTo(m.x,m.y);
    ctx.lineTo(m.x-m.vx*m.len*.5,m.y-m.vy*m.len*.5);
    ctx.strokeStyle=g; ctx.lineWidth=1.7; ctx.stroke();
  }
}

const dots = Array.from({length:92}, () => new Dot());
(function loop() {
  ctx.clearRect(0,0,W,H); tick++;
  drawOrbits(); drawEdges(dots);
  dots.forEach(d => { d.step(); d.draw(); });
  drawMeteors(); requestAnimationFrame(loop);
})();

/* ══ CURSOR ══ */
const $d=document.getElementById('cdot'), $r=document.getElementById('cring');
let mx=0,my=0,rx=0,ry=0;
window.addEventListener('mousemove',e=>{mx=e.clientX;my=e.clientY;$d.style.left=mx+'px';$d.style.top=my+'px';});
(function cl(){rx+=(mx-rx)*.13;ry+=(my-ry)*.13;$r.style.left=rx+'px';$r.style.top=ry+'px';requestAnimationFrame(cl);})();
document.querySelectorAll('a,button,input,label,.type-lbl,.feye').forEach(el=>{
  el.addEventListener('mouseenter',()=>{$r.style.transform='translate(-50%,-50%) scale(2.2)';$r.style.borderColor='#c9a84c';$d.style.transform='translate(-50%,-50%) scale(0)';});
  el.addEventListener('mouseleave',()=>{$r.style.transform='translate(-50%,-50%) scale(1)';$d.style.transform='translate(-50%,-50%) scale(1)';});
});

/* ══ BOTÓN MAGNÉTICO ══ */
const subBtn = document.getElementById('subBtn');
subBtn.addEventListener('mousemove', e => {
  const r=subBtn.getBoundingClientRect();
  const ox=(e.clientX-r.left-r.width/2)*.26, oy=(e.clientY-r.top-r.height/2)*.26;
  subBtn.style.transform=`translate(${ox}px,${oy-2}px)`;
});
subBtn.addEventListener('mouseleave', () => subBtn.style.transform='');

/* ══ RIPPLE ══ */
function doRip(e, el) {
  const r=document.createElement('span'), rc=el.getBoundingClientRect();
  const sz=Math.max(rc.width,rc.height);
  r.className='rip';
  r.style.cssText=`width:${sz}px;height:${sz}px;left:${e.clientX-rc.left-sz/2}px;top:${e.clientY-rc.top-sz/2}px;`;
  el.appendChild(r); setTimeout(()=>r.remove(),700);
}

/* ══ TOGGLE CONTRASEÑA ══ */
function tglP(fid, iid) {
  const f=document.getElementById(fid), i=document.getElementById(iid);
  if(f.type==='password'){f.type='text';i.classList.replace('fa-eye','fa-eye-slash');i.parentElement.style.color='#c9a84c';}
  else{f.type='password';i.classList.replace('fa-eye-slash','fa-eye');i.parentElement.style.color='';}
}

/* ══ FUERZA CONTRASEÑA ══ */
function chkStr(val) {
  let sc=0;
  if(val.length>=8)sc++;
  if(/[A-Z]/.test(val))sc++;
  if(/[0-9]/.test(val))sc++;
  if(/[^A-Za-z0-9]/.test(val))sc++;
  const cols=['','#e74c3c','#e67e22','#3498db','#2ecc71'];
  const lbls=['','Muy débil','Débil','Buena','Fuerte ✓'];
  [1,2,3,4].forEach(i=>{
    const el=document.getElementById('s'+i);
    el.style.background=i<=sc?cols[sc]:'rgba(255,255,255,.08)';
  });
  const t=document.getElementById('stxt');
  t.textContent=sc>0?lbls[sc]:'';
  t.style.color=cols[sc]||'';
}

/* ══ VERIFICAR MATCH ══ */
function chkMatch() {
  const p1=document.getElementById('pwd1').value;
  const p2=document.getElementById('pwd2').value;
  const m=document.getElementById('mmsg');
  if(!p2){m.textContent='';return;}
  if(p1===p2){m.textContent='✓ Contraseñas coinciden';m.style.color='#2ecc71';}
  else{m.textContent='✗ No coinciden';m.style.color='#e74c3c';}
}

/* ══ SUBMIT FEEDBACK ══ */
document.getElementById('rf').addEventListener('submit', function(e) {
  const p1=document.getElementById('pwd1').value;
  const p2=document.getElementById('pwd2').value;
  if(p1!==p2){e.preventDefault();chkMatch();document.getElementById('pwd2').focus();return;}
  const b=document.getElementById('subBtn'), l=document.getElementById('btnLbl');
  b.disabled=true; l.textContent='Creando cuenta...'; b.style.opacity='.82';
});
</script>
</body>
</html>
