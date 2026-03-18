<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cuenta en Revisión — InmoVista</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
  <style>
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
    body{min-height:100vh;background:#0d0d0d;display:flex;flex-direction:column;align-items:center;justify-content:center;font-family:'Outfit',sans-serif;color:#fff;padding:24px;}
    .card{background:#161616;border:1px solid rgba(201,168,76,0.15);border-radius:20px;padding:52px 48px;text-align:center;max-width:480px;width:100%;box-shadow:0 24px 60px rgba(0,0,0,0.5);animation:fadeUp .45s ease both;}
    @keyframes fadeUp{from{opacity:0;transform:translateY(24px)}to{opacity:1;transform:translateY(0)}}
    .icon-wrap{width:80px;height:80px;background:rgba(201,168,76,0.1);border:1px solid rgba(201,168,76,0.25);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 24px;font-size:2rem;color:#c9a84c;animation:pulse 2s infinite;}
    @keyframes pulse{0%,100%{box-shadow:0 0 0 0 rgba(201,168,76,0.3)}50%{box-shadow:0 0 0 12px rgba(201,168,76,0)}}
    h1{font-family:'Playfair Display',serif;font-size:1.8rem;font-weight:900;margin-bottom:8px;}
    .divider{width:40px;height:2px;background:linear-gradient(90deg,#c9a84c,#e8c96b);border-radius:2px;margin:16px auto 20px;}
    .sub{font-size:0.9rem;color:rgba(255,255,255,0.5);line-height:1.7;margin-bottom:32px;}
    .sub strong{color:rgba(255,255,255,0.8);}
    .steps{text-align:left;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;padding:20px 24px;margin-bottom:28px;}
    .step{display:flex;align-items:flex-start;gap:14px;padding:10px 0;border-bottom:1px solid rgba(255,255,255,0.05);}
    .step:last-child{border:none;padding-bottom:0;}
    .step-n{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:0.75rem;font-weight:700;flex-shrink:0;}
    .step-done{background:rgba(39,174,96,0.2);color:#27ae60;border:1px solid rgba(39,174,96,0.3);}
    .step-wait{background:rgba(201,168,76,0.1);color:#c9a84c;border:1px solid rgba(201,168,76,0.2);}
    .step-pend{background:rgba(255,255,255,0.05);color:rgba(255,255,255,0.3);border:1px solid rgba(255,255,255,0.08);}
    .step-txt strong{font-size:0.87rem;display:block;margin-bottom:2px;}
    .step-txt span{font-size:0.78rem;color:rgba(255,255,255,0.35);}
    .btn-outline{display:flex;align-items:center;justify-content:center;gap:8px;padding:13px 28px;background:transparent;color:rgba(255,255,255,0.5);font-size:0.88rem;font-weight:500;border:1.5px solid rgba(255,255,255,0.1);border-radius:10px;text-decoration:none;transition:all .2s;width:100%;}
    .btn-outline:hover{border-color:rgba(255,255,255,0.25);color:#fff;}
    .brand{font-family:'Playfair Display',serif;font-size:1.1rem;font-weight:900;color:rgba(255,255,255,0.15);margin-top:36px;letter-spacing:1px;}
    .brand span{color:#c9a84c;}
    .badge-wait{display:inline-flex;align-items:center;gap:6px;background:rgba(201,168,76,0.1);border:1px solid rgba(201,168,76,0.2);color:#c9a84c;padding:5px 14px;border-radius:100px;font-size:0.75rem;font-weight:700;letter-spacing:1px;margin-bottom:20px;}
  </style>
</head>
<body>
  <div class="card">
    <div class="icon-wrap"><i class="fas fa-hourglass-half"></i></div>
    <div class="badge-wait"><i class="fas fa-circle" style="font-size:0.5rem;"></i> EN REVISIÓN</div>
    <h1>Cuenta en revisión</h1>
    <div class="divider"></div>
    <p class="sub">
      Tu solicitud para ser <strong>Agente Inmobiliario</strong> en InmoVista fue recibida.<br>
      El administrador revisará tu información y activará tu cuenta pronto.
    </p>

    <div class="steps">
      <div class="step">
        <div class="step-n step-done"><i class="fas fa-check"></i></div>
        <div class="step-txt"><strong>Cuenta creada</strong><span>Tus datos fueron registrados correctamente</span></div>
      </div>
      <div class="step">
        <div class="step-n step-wait"><i class="fas fa-clock"></i></div>
        <div class="step-txt"><strong>Revisión del administrador</strong><span>Verificamos que cumples los requisitos</span></div>
      </div>
      <div class="step">
        <div class="step-n step-pend">3</div>
        <div class="step-txt"><strong>Aprobación y acceso</strong><span>Podrás iniciar sesión una vez aprobado</span></div>
      </div>
      <div class="step">
        <div class="step-n step-pend">4</div>
        <div class="step-txt"><strong>Publicar propiedades</strong><span>Empieza a gestionar tu catálogo</span></div>
      </div>
    </div>

    <a href="<%= request.getContextPath() %>/login.jsp" class="btn-outline">
      <i class="fas fa-sign-in-alt"></i> Volver al inicio de sesión
    </a>
  </div>

  <div class="brand">Inmo<span>Vista</span></div>
</body>
</html>
