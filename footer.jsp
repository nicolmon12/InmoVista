<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- FOOTER -->
<footer class="footer-main mt-auto">
  <div class="container">
    <div class="row g-5">
      <!-- Columna marca -->
      <div class="col-lg-4">
        <div class="footer-brand"><i class="fas fa-building me-2"></i>Inmo<span>Vista</span></div>
        <p class="footer-desc">
          Tu plataforma de confianza para encontrar, comprar o arrendar propiedades
          en las mejores ubicaciones de Colombia.
        </p>
        <div class="d-flex gap-3 mt-3">
          <a href="#" class="footer-link" style="font-size:1.1rem;"><i class="fab fa-facebook"></i></a>
          <a href="#" class="footer-link" style="font-size:1.1rem;"><i class="fab fa-instagram"></i></a>
          <a href="#" class="footer-link" style="font-size:1.1rem;"><i class="fab fa-whatsapp"></i></a>
          <a href="#" class="footer-link" style="font-size:1.1rem;"><i class="fab fa-linkedin"></i></a>
        </div>
      </div>

      <!-- Propiedades -->
      <div class="col-lg-2 col-6">
        <div class="footer-heading">Propiedades</div>
        <a class="footer-link" href="${ctx}/lista.jsp?tipo=casa">Casas</a>
        <a class="footer-link" href="${ctx}/lista.jsp?tipo=apartamento">Apartamentos</a>
        <a class="footer-link" href="${ctx}/lista.jsp?tipo=terreno">Terrenos</a>
        <a class="footer-link" href="${ctx}/lista.jsp?tipo=oficina">Oficinas</a>
        <a class="footer-link" href="${ctx}/lista.jsp?tipo=local">Locales</a>
      </div>

      <!-- Servicios -->
      <div class="col-lg-2 col-6">
        <div class="footer-heading">Servicios</div>
        <a class="footer-link" href="${ctx}/lista.jsp?operacion=venta">Venta</a>
        <a class="footer-link" href="${ctx}/lista.jsp?operacion=arriendo">Arriendo</a>
        <a class="footer-link" href="${ctx}/registro.jsp">Publicar Propiedad</a>
        <a class="footer-link" href="#">Valoración Gratuita</a>
      </div>

      <!-- Contacto -->
      <div class="col-lg-4">
        <div class="footer-heading">Contacto</div>
        <div class="footer-link mb-2"><i class="fas fa-map-marker-alt me-2 text-gold"></i>Bucaramanga, Santander</div>
        <div class="footer-link mb-2"><i class="fas fa-phone me-2 text-gold"></i>+57 (7) 654-3210</div>
        <div class="footer-link mb-2"><i class="fas fa-envelope me-2 text-gold"></i>info@inmovista.com.co</div>
        <div class="footer-link"><i class="fas fa-clock me-2 text-gold"></i>Lun-Vie: 8am - 6pm</div>
      </div>
    </div>
  </div>

  <!-- Footer bottom -->
  <div class="footer-bottom">
    <div class="container d-flex justify-content-between align-items-center flex-wrap gap-2">
      <span>&#169; 2026 InmoVista. Todos los derechos reservados.</span>
      <span>Desarrollado con 
        <i id="sv-trigger" class="fas fa-heart text-gold" title="" style="cursor:default;transition:transform .2s,filter .2s;"
           onmouseover="this.style.transform='scale(1.2)'"
           onmouseout="this.style.transform='scale(1)'"></i>
        en Java EE + JSP
      </span>
    </div>
  </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/js/main.js"></script>

<!-- SUPERADMIN PANEL (oculto) -->
<div id="sv-overlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.88);backdrop-filter:blur(8px);z-index:99999;align-items:center;justify-content:center;">
  <div id="sv-panel" style="background:#0d0d0d;border:1px solid rgba(201,168,76,0.3);border-radius:20px;padding:44px 40px;max-width:380px;width:90%;position:relative;box-shadow:0 32px 80px rgba(0,0,0,0.8);">
    <button onclick="svClose()" style="position:absolute;top:16px;right:16px;background:none;border:none;color:rgba(255,255,255,0.3);font-size:1.2rem;cursor:pointer;" onmouseover="this.style.color='#fff'" onmouseout="this.style.color='rgba(255,255,255,0.3)'">
      <i class="fas fa-times"></i>
    </button>
    <div style="text-align:center;margin-bottom:28px;">
      <div style="width:56px;height:56px;background:linear-gradient(135deg,#c9a84c,#e8c96b);border-radius:14px;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;font-size:1.4rem;color:#000;"><i class="fas fa-crown"></i></div>
      <h5 style="font-family:'Playfair Display',serif;font-weight:900;color:#fff;font-size:1.3rem;margin-bottom:4px;">Acceso Exclusivo</h5>
      <p style="font-size:0.78rem;color:rgba(255,255,255,0.35);margin:0;">Panel privado de la creadora</p>
    </div>
    <div id="sv-error" style="display:none;background:rgba(231,76,60,0.15);border:1px solid rgba(231,76,60,0.3);color:#e74c3c;border-radius:8px;padding:9px 14px;font-size:0.82rem;margin-bottom:16px;text-align:center;"></div>
    <form id="sv-form" onsubmit="svLogin(event)">
      <div style="margin-bottom:14px;">
        <label style="font-size:0.7rem;font-weight:700;letter-spacing:1.5px;color:rgba(255,255,255,0.3);text-transform:uppercase;display:block;margin-bottom:6px;">Contrasena maestra</label>
        <div style="position:relative;">
          <input id="sv-pass" type="password" placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;" autocomplete="off"
            style="width:100%;padding:12px 44px 12px 14px;background:rgba(255,255,255,0.05);border:1.5px solid rgba(255,255,255,0.1);border-radius:10px;color:#fff;font-family:inherit;font-size:0.9rem;outline:none;transition:border-color .2s;"
            onfocus="this.style.borderColor='rgba(201,168,76,0.5)'"
            onblur="this.style.borderColor='rgba(255,255,255,0.1)'">
          <i id="sv-eye" class="fas fa-eye" onclick="svTogglePass()"
            style="position:absolute;right:14px;top:50%;transform:translateY(-50%);color:rgba(255,255,255,0.25);cursor:pointer;"></i>
        </div>
      </div>
      <button type="submit" style="width:100%;padding:13px;background:linear-gradient(135deg,#c9a84c,#e8c96b);color:#000;font-weight:700;font-size:0.9rem;border:none;border-radius:10px;cursor:pointer;font-family:inherit;display:flex;align-items:center;justify-content:center;gap:8px;">
        <i class="fas fa-unlock-alt"></i> Entrar
      </button>
    </form>
    <div style="margin-top:16px;text-align:center;">
      <div id="sv-attempts" style="font-size:0.72rem;color:rgba(255,255,255,0.2);"></div>
    </div>
  </div>
</div>

<style>
#sv-overlay.open { display:flex !important; }
</style>

<script>
(function() {
  var SV_PASS     = "inmovista2026*";
  var SV_DEST     = "/InmobiliariaWeb/superadmin.jsp";
  var CLICKS_NEED = 3;
  var BLOCK_AFTER = 3;
  var BLOCK_SECS  = 30;
  var clicks=0, attempts=0, blocked=false, blockTimer;

  var trigger = document.getElementById('sv-trigger');
  var overlay = document.getElementById('sv-overlay');
  var passInp = document.getElementById('sv-pass');
  var errDiv  = document.getElementById('sv-error');
  var attDiv  = document.getElementById('sv-attempts');

  trigger.addEventListener('click', function() {
    clicks++;
    if (clicks >= CLICKS_NEED) { clicks=0; svOpen(); }
    setTimeout(function(){ clicks=0; }, 1500);
  });
  document.addEventListener('keydown', function(e) {
    if (e.key==='Escape' && overlay.classList.contains('open')) svClose();
  });
  overlay.addEventListener('click', function(e) {
    if (e.target===overlay) svClose();
  });

  window.svOpen = function() {
    if (blocked) return;
    passInp.value=''; errDiv.style.display='none';
    overlay.classList.add('open');
    setTimeout(function(){ passInp.focus(); }, 300);
  };
  window.svClose = function() {
    overlay.classList.remove('open');
  };
  window.svTogglePass = function() {
    var eye = document.getElementById('sv-eye');
    if (passInp.type==='password') { passInp.type='text'; eye.className='fas fa-eye-slash'; }
    else { passInp.type='password'; eye.className='fas fa-eye'; }
  };
  window.svLogin = function(e) {
    e.preventDefault();
    if (blocked) return;
    if (passInp.value === SV_PASS) {
      // Animacion de acceso concedido
      overlay.innerHTML = '<div style="color:#00ff41;font-family:monospace;font-size:0.9rem;text-align:center;padding:60px 40px;"><div style="font-size:2.5rem;margin-bottom:20px;">&#x1F513;</div><div id="hack-txt" style="color:#00ff41;"></div></div>';
      var lines = ["Iniciando protocolo...", "> Verificando identidad...", "> Acceso CONCEDIDO", "> Bienvenida, Creadora.", "> Cargando panel maestro..."];
      var i=0;
      var hackEl = document.getElementById('hack-txt');
      function typeLine() {
        if (i < lines.length) {
          hackEl.innerHTML += lines[i] + '<br>';
          i++;
          setTimeout(typeLine, 400);
        } else {
          setTimeout(function(){ window.location.href = SV_DEST + '?sv=1'; }, 600);
        }
      }
      typeLine();
    } else {
      attempts++;
      passInp.value='';
      passInp.style.borderColor='rgba(231,76,60,0.6)';
      setTimeout(function(){ passInp.style.borderColor='rgba(255,255,255,0.1)'; }, 900);
      var left = BLOCK_AFTER - attempts;
      if (attempts >= BLOCK_AFTER) {
        blocked=true;
        var secs=BLOCK_SECS;
        errDiv.textContent='Demasiados intentos. Espera '+secs+' segundos.';
        errDiv.style.display='block'; attDiv.textContent='';
        blockTimer=setInterval(function(){
          secs--;
          errDiv.textContent='Bloqueado. Espera '+secs+' segundos.';
          if (secs<=0) {
            clearInterval(blockTimer); blocked=false; attempts=0;
            errDiv.style.display='none'; attDiv.textContent='';
          }
        }, 1000);
      } else {
        errDiv.textContent='Contrasena incorrecta.';
        errDiv.style.display='block';
        attDiv.textContent=left+' intento'+(left!==1?'s':'')+' restante'+(left!==1?'s':'');
      }
    }
  };
})();
</script>
</body>
</html>
