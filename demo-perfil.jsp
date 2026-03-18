<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  ══════════════════════════════════════════════════════
  DEMO-PERFIL.JSP  ·  InmoVista
  Muestra cómo se ve el sistema desde la perspectiva
  de un cliente recién registrado / ya ingresado.
  Acceso: cualquier usuario (no requiere sesión).
  ══════════════════════════════════════════════════════
--%>
<c:set var="pageTitle" value="Vista Demo — Perfil Cliente" scope="request"/>
<%@ include file="header.jsp" %>

<style>
/* ── Variables ─────────────────────────────────── */
:root {
  --dp-gold:   #c9a84c;
  --dp-dark:   #0d0d0d;
  --dp-dark2:  #1a1a1a;
  --dp-cream:  #f5f0e8;
  --dp-gray:   #f8f7f5;
  --dp-border: #e8e5df;
  --dp-text:   #1a1a1a;
  --dp-muted:  #9a9590;
}

/* ── Layout ─────────────────────────────────────── */
.dp-page {
  background: var(--dp-gray);
  min-height: 100vh;
  padding-bottom: 80px;
  font-family: 'DM Sans', sans-serif;
}

/* ── Hero banner ─────────────────────────────────── */
.dp-hero {
  background: linear-gradient(135deg, #0d0d0d 0%, #1a1a1a 60%, #242424 100%);
  padding: 48px 0 36px;
  position: relative;
  overflow: hidden;
}
.dp-hero::before {
  content: '';
  position: absolute;
  top: -80px; right: -80px;
  width: 320px; height: 320px;
  background: radial-gradient(circle, rgba(201,168,76,0.12) 0%, transparent 70%);
  border-radius: 50%;
}
.dp-hero__badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(201,168,76,0.12);
  border: 1px solid rgba(201,168,76,0.3);
  color: var(--dp-gold);
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  padding: 5px 14px;
  border-radius: 100px;
  margin-bottom: 16px;
}
.dp-hero__title {
  font-family: 'Playfair Display', serif;
  font-size: 2rem;
  font-weight: 900;
  color: #fff;
  margin-bottom: 6px;
}
.dp-hero__sub {
  font-size: 0.88rem;
  color: rgba(255,255,255,0.4);
}

/* ── Nav tabs ─────────────────────────────────── */
.dp-tabs {
  background: #fff;
  border-bottom: 2px solid var(--dp-border);
  position: sticky;
  top: 72px;
  z-index: 100;
}
.dp-tabs__list {
  display: flex;
  gap: 0;
  list-style: none;
  padding: 0;
  margin: 0;
  overflow-x: auto;
}
.dp-tabs__item {
  flex-shrink: 0;
}
.dp-tabs__btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 22px;
  font-size: 0.83rem;
  font-weight: 600;
  color: var(--dp-muted);
  border: none;
  background: none;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  transition: all 0.2s;
  white-space: nowrap;
}
.dp-tabs__btn:hover { color: var(--dp-text); }
.dp-tabs__btn.active {
  color: var(--dp-dark);
  border-bottom-color: var(--dp-gold);
}

/* ── Contenido de pestañas ────────────────────── */
.dp-pane { display: none; padding-top: 32px; }
.dp-pane.active { display: block; }

/* ── Cards de sección ────────────────────────── */
.dp-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid var(--dp-border);
  padding: 28px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
}
.dp-card__title {
  font-family: 'Playfair Display', serif;
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--dp-dark);
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.dp-card__title i { color: var(--dp-gold); font-size: 1rem; }
.dp-card__sub {
  font-size: 0.78rem;
  color: var(--dp-muted);
  margin-bottom: 20px;
}

/* ── Avatar ──────────────────────────────────── */
.dp-avatar {
  width: 72px; height: 72px;
  background: linear-gradient(135deg, #c9a84c, #e8c96b);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-family: 'Playfair Display', serif;
  font-size: 1.6rem;
  font-weight: 900;
  color: #0d0d0d;
  flex-shrink: 0;
}

/* ── Info list ───────────────────────────────── */
.dp-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--dp-border);
  font-size: 0.88rem;
}
.dp-info-row:last-child { border-bottom: none; }
.dp-info-row__label { color: var(--dp-muted); font-weight: 500; }
.dp-info-row__val { color: var(--dp-dark); font-weight: 600; }

/* ── KPI grid ────────────────────────────────── */
.dp-kpis {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 28px;
}
@media(max-width:768px) { .dp-kpis { grid-template-columns: repeat(2,1fr); } }
.dp-kpi {
  background: #fff;
  border: 1px solid var(--dp-border);
  border-radius: 14px;
  padding: 20px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.dp-kpi__num {
  font-family: 'Playfair Display', serif;
  font-size: 2.2rem;
  font-weight: 900;
  color: var(--dp-dark);
  line-height: 1;
  margin-bottom: 4px;
}
.dp-kpi__label { font-size: 0.75rem; color: var(--dp-muted); font-weight: 500; }
.dp-kpi__icon { font-size: 1.2rem; color: var(--dp-gold); margin-bottom: 10px; }

/* ── Cita card ───────────────────────────────── */
.dp-cita {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  padding: 14px 0;
  border-bottom: 1px solid var(--dp-border);
}
.dp-cita:last-child { border-bottom: none; padding-bottom: 0; }
.dp-cita__date {
  flex-shrink: 0;
  width: 52px; height: 52px;
  background: var(--dp-dark);
  border-radius: 12px;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  color: #fff;
}
.dp-cita__day { font-size: 1.2rem; font-weight: 900; line-height: 1; }
.dp-cita__month { font-size: 0.6rem; font-weight: 600; letter-spacing: 1px; opacity: 0.6; }
.dp-cita__info { flex: 1; }
.dp-cita__prop { font-weight: 700; font-size: 0.88rem; color: var(--dp-dark); margin-bottom: 2px; }
.dp-cita__time { font-size: 0.78rem; color: var(--dp-muted); }
.dp-cita__badge {
  font-size: 0.68rem; font-weight: 700; padding: 3px 10px;
  border-radius: 100px; flex-shrink: 0;
}
.dp-cita__badge--pendiente { background: #fff3cd; color: #856404; }
.dp-cita__badge--confirmada { background: #d1e7dd; color: #0f5132; }
.dp-cita__badge--cancelada  { background: #f8d7da; color: #842029; }

/* ── Propiedad favorito card ─────────────────── */
.dp-fav-card {
  display: flex;
  gap: 14px;
  padding: 12px 0;
  border-bottom: 1px solid var(--dp-border);
  text-decoration: none;
  color: inherit;
  transition: background 0.2s;
}
.dp-fav-card:last-child { border-bottom: none; }
.dp-fav-card__img {
  width: 80px; height: 64px;
  border-radius: 10px;
  overflow: hidden;
  flex-shrink: 0;
  background: var(--dp-border);
}
.dp-fav-card__img img { width:100%;height:100%;object-fit:cover; }
.dp-fav-card__name { font-size: 0.85rem; font-weight: 700; color: var(--dp-dark); margin-bottom: 2px; }
.dp-fav-card__price { font-size: 0.8rem; color: var(--dp-gold); font-weight: 700; }
.dp-fav-card__loc { font-size: 0.72rem; color: var(--dp-muted); }

/* ── Badge de rol ────────────────────────────── */
.dp-role-badge {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 4px 12px;
  border-radius: 100px;
  font-size: 0.72rem; font-weight: 700;
  text-transform: uppercase; letter-spacing: 1px;
}
.dp-role-badge--cliente  { background: rgba(52,152,219,0.12); color: #1a6c9f; }
.dp-role-badge--inmobiliaria { background: rgba(201,168,76,0.15); color: #7a5d0f; }
.dp-role-badge--admin    { background: rgba(231,76,60,0.12); color: #922b21; }

/* ── Screenshot frame ─────────────────────────── */
.dp-screen {
  border: 2px solid var(--dp-border);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
}
.dp-screen__bar {
  background: var(--dp-dark);
  padding: 10px 16px;
  display: flex; align-items: center; gap: 8px;
}
.dp-screen__dot {
  width: 10px; height: 10px; border-radius: 50%;
}
.dp-screen__url {
  flex: 1;
  background: rgba(255,255,255,0.08);
  border-radius: 6px;
  padding: 4px 12px;
  font-size: 0.7rem;
  color: rgba(255,255,255,0.5);
  font-family: monospace;
}

/* ── Botón dorado ────────────────────────────── */
.dp-btn-gold {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 10px 22px;
  background: linear-gradient(135deg, #c9a84c, #e8c96b);
  color: #0d0d0d;
  font-weight: 700; font-size: 0.83rem;
  border: none; border-radius: 10px;
  cursor: pointer; text-decoration: none;
  transition: all 0.25s;
}
.dp-btn-gold:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(201,168,76,0.35); color: #0d0d0d; }
.dp-btn-outline {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 9px 20px;
  background: transparent;
  color: var(--dp-dark);
  font-weight: 600; font-size: 0.83rem;
  border: 1.5px solid var(--dp-border); border-radius: 10px;
  cursor: pointer; text-decoration: none;
  transition: all 0.25s;
}
.dp-btn-outline:hover { border-color: var(--dp-gold); color: var(--dp-gold); }

/* ── Formulario demo ─────────────────────────── */
.dp-form-control {
  width: 100%; padding: 10px 14px;
  border: 1.5px solid var(--dp-border); border-radius: 10px;
  font-family: 'DM Sans', sans-serif; font-size: 0.88rem;
  color: var(--dp-dark); background: var(--dp-gray);
  transition: border-color 0.2s;
  outline: none;
}
.dp-form-control:focus { border-color: var(--dp-gold); background: #fff; }
.dp-form-label { font-size: 0.78rem; font-weight: 600; color: var(--dp-muted); margin-bottom: 6px; display: block; }

/* ── Notif ───────────────────────────────────── */
.dp-notif {
  display: flex; align-items: flex-start; gap: 12px;
  padding: 12px; border-radius: 12px;
  background: var(--dp-gray); border: 1px solid var(--dp-border);
  margin-bottom: 10px; font-size: 0.82rem;
}
.dp-notif__icon {
  width: 36px; height: 36px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; font-size: 0.85rem;
}
.dp-notif--success .dp-notif__icon { background: #d1e7dd; color: #0f5132; }
.dp-notif--warn    .dp-notif__icon { background: #fff3cd; color: #856404; }
.dp-notif--info    .dp-notif__icon { background: #cff4fc; color: #055160; }
.dp-notif__title { font-weight: 700; color: var(--dp-dark); margin-bottom: 2px; }
.dp-notif__time  { font-size: 0.72rem; color: var(--dp-muted); }

/* ── Registro steps ──────────────────────────── */
.dp-step {
  display: flex; align-items: flex-start; gap: 16px;
  padding: 16px 0; border-bottom: 1px solid var(--dp-border);
}
.dp-step:last-child { border-bottom: none; }
.dp-step__num {
  width: 36px; height: 36px; border-radius: 50%;
  background: var(--dp-dark); color: var(--dp-gold);
  display: flex; align-items: center; justify-content: center;
  font-weight: 900; font-size: 0.9rem; flex-shrink: 0;
}
.dp-step__num.done { background: #0f5132; color: #fff; }
.dp-step__title { font-weight: 700; font-size: 0.9rem; color: var(--dp-dark); margin-bottom: 2px; }
.dp-step__desc  { font-size: 0.8rem; color: var(--dp-muted); }
</style>

<div class="dp-page">

  <!-- ══ HERO ══ -->
  <div class="dp-hero">
    <div class="container">
      <div class="dp-hero__badge"><i class="fas fa-eye"></i> Vista Demo del Sistema</div>
      <h1 class="dp-hero__title">Perspectiva del Cliente</h1>
      <p class="dp-hero__sub">
        Así ve el sistema un usuario registrado como <strong style="color:var(--dp-gold);">Cliente</strong>
        — sin necesidad de iniciar sesión real.
      </p>
    </div>
  </div>

  <!-- ══ TABS ══ -->
  <div class="dp-tabs">
    <div class="container">
      <ul class="dp-tabs__list">
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn active" onclick="showTab('perfil',this)">
            <i class="fas fa-user-circle"></i> Mi Perfil
          </button>
        </li>
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn" onclick="showTab('dashboard',this)">
            <i class="fas fa-tachometer-alt"></i> Mi Dashboard
          </button>
        </li>
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn" onclick="showTab('citas',this)">
            <i class="fas fa-calendar-alt"></i> Mis Citas
          </button>
        </li>
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn" onclick="showTab('favoritos',this)">
            <i class="fas fa-heart"></i> Favoritos
          </button>
        </li>
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn" onclick="showTab('agendar',this)">
            <i class="fas fa-calendar-plus"></i> Agendar Visita
          </button>
        </li>
        <li class="dp-tabs__item">
          <button class="dp-tabs__btn" onclick="showTab('registro',this)">
            <i class="fas fa-user-plus"></i> Flujo de Registro
          </button>
        </li>
      </ul>
    </div>
  </div>

  <div class="container">

    <!-- ══════════════════════════════════
         PESTAÑA 1: MI PERFIL
    ══════════════════════════════════ -->
    <div class="dp-pane active" id="pane-perfil">
      <div class="row g-4">

        <!-- Tarjeta perfil principal -->
        <div class="col-lg-4">
          <div class="dp-card text-center">
            <div class="dp-avatar mx-auto mb-3">JS</div>
            <h5 style="font-family:'Playfair Display',serif;font-weight:900;margin-bottom:4px;">Juan Sebastián Torres</h5>
            <span class="dp-role-badge dp-role-badge--cliente mb-3 d-inline-flex">
              <i class="fas fa-user"></i> Cliente
            </span>
            <div class="dp-info-row">
              <span class="dp-info-row__label">Correo</span>
              <span class="dp-info-row__val">js.torres@gmail.com</span>
            </div>
            <div class="dp-info-row">
              <span class="dp-info-row__label">Teléfono</span>
              <span class="dp-info-row__val">+57 310 456 7890</span>
            </div>
            <div class="dp-info-row">
              <span class="dp-info-row__label">Ciudad</span>
              <span class="dp-info-row__val">Bucaramanga</span>
            </div>
            <div class="dp-info-row">
              <span class="dp-info-row__label">Miembro desde</span>
              <span class="dp-info-row__val">Enero 2025</span>
            </div>
            <div class="dp-info-row">
              <span class="dp-info-row__label">Estado cuenta</span>
              <span style="background:#d1e7dd;color:#0f5132;padding:3px 10px;border-radius:100px;font-size:0.72rem;font-weight:700;">
                <i class="fas fa-check-circle me-1"></i>Activa
              </span>
            </div>
            <div class="mt-4 d-flex gap-2">
              <button class="dp-btn-gold flex-fill" onclick="showTab('dashboard',document.querySelectorAll('.dp-tabs__btn')[1])">
                <i class="fas fa-tachometer-alt"></i> Mi Panel
              </button>
              <button class="dp-btn-outline" style="padding:10px 14px;">
                <i class="fas fa-edit"></i>
              </button>
            </div>
          </div>
        </div>

        <!-- Actividad reciente -->
        <div class="col-lg-8">
          <div class="dp-card mb-4">
            <div class="dp-card__title"><i class="fas fa-bell"></i> Notificaciones Recientes</div>
            <div class="dp-card__sub">Lo que ha pasado en tu cuenta esta semana</div>
            <div class="dp-notif dp-notif--success">
              <div class="dp-notif__icon"><i class="fas fa-calendar-check"></i></div>
              <div>
                <div class="dp-notif__title">Cita confirmada — Casa Moderna Cabecera</div>
                <div style="font-size:0.8rem;color:#333;">Tu visita del <strong>28 de marzo, 10:00 am</strong> fue confirmada por la inmobiliaria.</div>
                <div class="dp-notif__time">Hace 2 horas</div>
              </div>
            </div>
            <div class="dp-notif dp-notif--info">
              <div class="dp-notif__icon"><i class="fas fa-home"></i></div>
              <div>
                <div class="dp-notif__title">Nueva propiedad disponible en Lagos del Cacique</div>
                <div style="font-size:0.8rem;color:#333;">Penthouse de 250m² que podría interesarte según tus búsquedas anteriores.</div>
                <div class="dp-notif__time">Ayer</div>
              </div>
            </div>
            <div class="dp-notif dp-notif--warn">
              <div class="dp-notif__icon"><i class="fas fa-clock"></i></div>
              <div>
                <div class="dp-notif__title">Cita pendiente — Terreno Piedecuesta</div>
                <div style="font-size:0.8rem;color:#333;">Tienes una solicitud pendiente de confirmación para el 2 de abril.</div>
                <div class="dp-notif__time">Hace 3 días</div>
              </div>
            </div>
          </div>

          <div class="dp-card">
            <div class="dp-card__title"><i class="fas fa-search"></i> Búsquedas Guardadas</div>
            <div class="dp-card__sub">Tus filtros favoritos para encontrar propiedades rápido</div>
            <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:8px;">
              <span style="background:rgba(201,168,76,0.1);border:1px solid rgba(201,168,76,0.3);color:#7a5d0f;padding:6px 14px;border-radius:100px;font-size:0.78rem;font-weight:600;">
                <i class="fas fa-home me-1"></i>Casa · Venta · Cabecera
              </span>
              <span style="background:rgba(52,152,219,0.1);border:1px solid rgba(52,152,219,0.25);color:#1a6c9f;padding:6px 14px;border-radius:100px;font-size:0.78rem;font-weight:600;">
                <i class="fas fa-building me-1"></i>Apto · Arriendo · BGA · &lt;$3M
              </span>
              <span style="background:rgba(39,174,96,0.1);border:1px solid rgba(39,174,96,0.25);color:#1a6b3c;padding:6px 14px;border-radius:100px;font-size:0.78rem;font-weight:600;">
                <i class="fas fa-map me-1"></i>Terreno · Floridablanca
              </span>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- ══════════════════════════════════
         PESTAÑA 2: DASHBOARD
    ══════════════════════════════════ -->
    <div class="dp-pane" id="pane-dashboard">
      <div class="dp-kpis">
        <div class="dp-kpi">
          <div class="dp-kpi__icon"><i class="fas fa-calendar-check"></i></div>
          <div class="dp-kpi__num">3</div>
          <div class="dp-kpi__label">Citas agendadas</div>
        </div>
        <div class="dp-kpi">
          <div class="dp-kpi__icon" style="color:#3498db;"><i class="fas fa-file-alt"></i></div>
          <div class="dp-kpi__num">2</div>
          <div class="dp-kpi__label">Solicitudes enviadas</div>
        </div>
        <div class="dp-kpi">
          <div class="dp-kpi__icon" style="color:#e74c3c;"><i class="fas fa-heart"></i></div>
          <div class="dp-kpi__num">7</div>
          <div class="dp-kpi__label">Favoritos guardados</div>
        </div>
        <div class="dp-kpi">
          <div class="dp-kpi__icon" style="color:#27ae60;"><i class="fas fa-home"></i></div>
          <div class="dp-kpi__num">60</div>
          <div class="dp-kpi__label">Propiedades disponibles</div>
        </div>
      </div>

      <div class="row g-4">
        <div class="col-lg-6">
          <div class="dp-card h-100">
            <div class="dp-card__title"><i class="fas fa-calendar-alt"></i> Próximas Citas</div>
            <div class="dp-card__sub">Tus visitas programadas</div>
            <div class="dp-cita">
              <div class="dp-cita__date"><div class="dp-cita__day">28</div><div class="dp-cita__month">MAR</div></div>
              <div class="dp-cita__info">
                <div class="dp-cita__prop">Casa Moderna en Cabecera</div>
                <div class="dp-cita__time"><i class="fas fa-clock me-1"></i>10:00 am · Cra 27 # 42-10</div>
              </div>
              <span class="dp-cita__badge dp-cita__badge--confirmada">Confirmada</span>
            </div>
            <div class="dp-cita">
              <div class="dp-cita__date"><div class="dp-cita__day">02</div><div class="dp-cita__month">ABR</div></div>
              <div class="dp-cita__info">
                <div class="dp-cita__prop">Terreno Urbanizable Piedecuesta</div>
                <div class="dp-cita__time"><i class="fas fa-clock me-1"></i>2:00 pm · Km 2 Vía Piedecuesta</div>
              </div>
              <span class="dp-cita__badge dp-cita__badge--pendiente">Pendiente</span>
            </div>
            <div class="dp-cita">
              <div class="dp-cita__date"><div class="dp-cita__day">10</div><div class="dp-cita__month">ABR</div></div>
              <div class="dp-cita__info">
                <div class="dp-cita__prop">Penthouse Vista Panorámica BGA</div>
                <div class="dp-cita__time"><i class="fas fa-clock me-1"></i>11:30 am · Av 30 # 52-80</div>
              </div>
              <span class="dp-cita__badge dp-cita__badge--pendiente">Pendiente</span>
            </div>
            <div class="mt-3">
              <button class="dp-btn-gold" onclick="showTab('agendar',document.querySelectorAll('.dp-tabs__btn')[4])">
                <i class="fas fa-plus"></i> Agendar nueva visita
              </button>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="dp-card h-100">
            <div class="dp-card__title"><i class="fas fa-heart"></i> Mis Favoritos</div>
            <div class="dp-card__sub">Propiedades que has guardado</div>
            <a href="${ctx}/detalle.jsp?id=1" class="dp-fav-card">
              <div class="dp-fav-card__img"><img src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=200&q=70" alt="Casa"></div>
              <div>
                <div class="dp-fav-card__name">Casa Moderna en Cabecera</div>
                <div class="dp-fav-card__price">$420.000.000</div>
                <div class="dp-fav-card__loc"><i class="fas fa-map-marker-alt me-1"></i>Cabecera, BGA</div>
              </div>
            </a>
            <a href="${ctx}/detalle.jsp?id=6" class="dp-fav-card">
              <div class="dp-fav-card__img"><img src="https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=200&q=70" alt="Penthouse"></div>
              <div>
                <div class="dp-fav-card__name">Penthouse Vista Panorámica BGA</div>
                <div class="dp-fav-card__price">$680.000.000</div>
                <div class="dp-fav-card__loc"><i class="fas fa-map-marker-alt me-1"></i>Norte, BGA</div>
              </div>
            </a>
            <a href="${ctx}/detalle.jsp?id=9" class="dp-fav-card">
              <div class="dp-fav-card__img"><img src="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=200&q=70" alt="Terreno"></div>
              <div>
                <div class="dp-fav-card__name">Terreno Urbanizable Piedecuesta</div>
                <div class="dp-fav-card__price">$550.000.000</div>
                <div class="dp-fav-card__loc"><i class="fas fa-map-marker-alt me-1"></i>Piedecuesta, Santander</div>
              </div>
            </a>
            <a href="${ctx}/lista.jsp" class="dp-btn-outline mt-3 d-inline-flex">
              <i class="fas fa-search"></i> Ver más propiedades
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════════════════════════
         PESTAÑA 3: CITAS
    ══════════════════════════════════ -->
    <div class="dp-pane" id="pane-citas">
      <div class="dp-card">
        <div class="dp-card__title"><i class="fas fa-calendar-alt"></i> Historial de Citas</div>
        <div class="dp-card__sub">Todas tus visitas agendadas en InmoVista</div>

        <div class="table-responsive mt-3">
          <table class="table table-hover align-middle" style="font-size:0.86rem;">
            <thead>
              <tr style="background:var(--dp-gray);">
                <th>Propiedad</th>
                <th>Fecha y Hora</th>
                <th>Estado</th>
                <th>Notas</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Casa Moderna en Cabecera</strong><br><small class="text-muted">Cra 27 # 42-10, BGA</small></td>
                <td>28 Mar 2025<br><small class="text-muted">10:00 am</small></td>
                <td><span class="dp-cita__badge dp-cita__badge--confirmada">Confirmada</span></td>
                <td style="max-width:180px;font-size:0.78rem;color:#555;">¿Tiene zona de BBQ y parqueadero adicional?</td>
                <td><button class="dp-btn-outline" style="padding:5px 12px;font-size:0.76rem;color:#e74c3c;border-color:#e74c3c;" onclick="alert('Cita cancelada (demo)')"><i class="fas fa-times"></i> Cancelar</button></td>
              </tr>
              <tr>
                <td><strong>Terreno Urbanizable Piedecuesta</strong><br><small class="text-muted">Km 2 Vía Piedecuesta</small></td>
                <td>02 Abr 2025<br><small class="text-muted">2:00 pm</small></td>
                <td><span class="dp-cita__badge dp-cita__badge--pendiente">Pendiente</span></td>
                <td style="max-width:180px;font-size:0.78rem;color:#555;">Quiero saber si tiene escritura al día</td>
                <td><button class="dp-btn-outline" style="padding:5px 12px;font-size:0.76rem;color:#e74c3c;border-color:#e74c3c;" onclick="alert('Cita cancelada (demo)')"><i class="fas fa-times"></i> Cancelar</button></td>
              </tr>
              <tr>
                <td><strong>Penthouse Vista Panorámica</strong><br><small class="text-muted">Av 30 # 52-80, Piso 18</small></td>
                <td>10 Abr 2025<br><small class="text-muted">11:30 am</small></td>
                <td><span class="dp-cita__badge dp-cita__badge--pendiente">Pendiente</span></td>
                <td style="max-width:180px;font-size:0.78rem;color:#555;">¿Incluye depósito de almacenamiento?</td>
                <td><button class="dp-btn-outline" style="padding:5px 12px;font-size:0.76rem;color:#e74c3c;border-color:#e74c3c;" onclick="alert('Cita cancelada (demo)')"><i class="fas fa-times"></i> Cancelar</button></td>
              </tr>
              <tr style="opacity:0.55;">
                <td><strong>Oficina Centro Empresarial</strong><br><small class="text-muted">Cra 15 # 36-22, Centro</small></td>
                <td>05 Feb 2025<br><small class="text-muted">9:00 am</small></td>
                <td><span class="dp-cita__badge dp-cita__badge--cancelada">Cancelada</span></td>
                <td style="max-width:180px;font-size:0.78rem;color:#555;">Cancelada por el usuario</td>
                <td><span style="font-size:0.75rem;color:var(--dp-muted);">—</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="mt-4">
          <button class="dp-btn-gold" onclick="showTab('agendar',document.querySelectorAll('.dp-tabs__btn')[4])">
            <i class="fas fa-calendar-plus"></i> Agendar nueva visita
          </button>
        </div>
      </div>
    </div>

    <!-- ══════════════════════════════════
         PESTAÑA 4: FAVORITOS
    ══════════════════════════════════ -->
    <div class="dp-pane" id="pane-favoritos">
      <div class="row g-3">
        <c:forEach items="${[1,6,4,9,2,12,11]}" var="favId">
        <%-- Demo: mostrar mini cards de propiedades favoritas --%>
        </c:forEach>
        <%-- Cards favoritas en HTML estático demo --%>
        <c:set var="favs" value="${'1,6,4,9,2,12,11'}" />
      </div>

      <div class="row g-3">
        <!-- Fav 1 -->
        <div class="col-md-4 col-lg-3">
          <div class="dp-card" style="padding:0;overflow:hidden;">
            <div style="aspect-ratio:4/3;overflow:hidden;">
              <img src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=500&q=70" style="width:100%;height:100%;object-fit:cover;" alt="">
            </div>
            <div style="padding:14px;">
              <div style="font-size:0.62rem;font-weight:700;letter-spacing:2px;color:var(--dp-gold);text-transform:uppercase;">Casa · Venta</div>
              <div style="font-family:'Playfair Display',serif;font-weight:700;font-size:0.95rem;margin:4px 0;">Casa Moderna en Cabecera</div>
              <div style="font-size:0.78rem;color:var(--dp-muted);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1"></i>Cabecera, BGA</div>
              <div style="font-size:1.1rem;font-weight:900;color:var(--dp-dark);">$420.000.000</div>
              <a href="${ctx}/detalle.jsp?id=1" class="dp-btn-gold mt-3 w-100 justify-content-center" style="font-size:0.78rem;">Ver propiedad</a>
            </div>
          </div>
        </div>
        <!-- Fav 6 -->
        <div class="col-md-4 col-lg-3">
          <div class="dp-card" style="padding:0;overflow:hidden;">
            <div style="aspect-ratio:4/3;overflow:hidden;">
              <img src="https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=500&q=70" style="width:100%;height:100%;object-fit:cover;" alt="">
            </div>
            <div style="padding:14px;">
              <div style="font-size:0.62rem;font-weight:700;letter-spacing:2px;color:var(--dp-gold);text-transform:uppercase;">Penthouse · Venta</div>
              <div style="font-family:'Playfair Display',serif;font-weight:700;font-size:0.95rem;margin:4px 0;">Penthouse Vista Panorámica BGA</div>
              <div style="font-size:0.78rem;color:var(--dp-muted);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1"></i>Norte, BGA</div>
              <div style="font-size:1.1rem;font-weight:900;color:var(--dp-dark);">$680.000.000</div>
              <a href="${ctx}/detalle.jsp?id=6" class="dp-btn-gold mt-3 w-100 justify-content-center" style="font-size:0.78rem;">Ver propiedad</a>
            </div>
          </div>
        </div>
        <!-- Fav 4 -->
        <div class="col-md-4 col-lg-3">
          <div class="dp-card" style="padding:0;overflow:hidden;">
            <div style="aspect-ratio:4/3;overflow:hidden;">
              <img src="https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500&q=70" style="width:100%;height:100%;object-fit:cover;" alt="">
            </div>
            <div style="padding:14px;">
              <div style="font-size:0.62rem;font-weight:700;letter-spacing:2px;color:var(--dp-gold);text-transform:uppercase;">Casa · Venta</div>
              <div style="font-family:'Playfair Display',serif;font-weight:700;font-size:0.95rem;margin:4px 0;">Casa Campestre Floridablanca</div>
              <div style="font-size:0.78rem;color:var(--dp-muted);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1"></i>Floridablanca</div>
              <div style="font-size:1.1rem;font-weight:900;color:var(--dp-dark);">$950.000.000</div>
              <a href="${ctx}/detalle.jsp?id=4" class="dp-btn-gold mt-3 w-100 justify-content-center" style="font-size:0.78rem;">Ver propiedad</a>
            </div>
          </div>
        </div>
        <!-- Fav 9 -->
        <div class="col-md-4 col-lg-3">
          <div class="dp-card" style="padding:0;overflow:hidden;">
            <div style="aspect-ratio:4/3;overflow:hidden;">
              <img src="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=500&q=70" style="width:100%;height:100%;object-fit:cover;" alt="">
            </div>
            <div style="padding:14px;">
              <div style="font-size:0.62rem;font-weight:700;letter-spacing:2px;color:#27ae60;text-transform:uppercase;">Terreno · Venta</div>
              <div style="font-family:'Playfair Display',serif;font-weight:700;font-size:0.95rem;margin:4px 0;">Terreno Urbanizable Piedecuesta</div>
              <div style="font-size:0.78rem;color:var(--dp-muted);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1"></i>Piedecuesta</div>
              <div style="font-size:1.1rem;font-weight:900;color:var(--dp-dark);">$550.000.000</div>
              <a href="${ctx}/detalle.jsp?id=9" class="dp-btn-gold mt-3 w-100 justify-content-center" style="font-size:0.78rem;">Ver propiedad</a>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-4">
        <a href="${ctx}/lista.jsp" class="dp-btn-outline">
          <i class="fas fa-search"></i> Explorar más propiedades
        </a>
      </div>
    </div>

    <!-- ══════════════════════════════════
         PESTAÑA 5: AGENDAR VISITA (Demo interactivo)
    ══════════════════════════════════ -->
    <div class="dp-pane" id="pane-agendar">
      <div class="row g-4">

        <div class="col-lg-7">
          <div class="dp-card">
            <div class="dp-card__title"><i class="fas fa-calendar-plus"></i> Solicitar Visita</div>
            <div class="dp-card__sub">Agenda una visita para cualquier propiedad del catálogo</div>

            <!-- Selector de propiedad -->
            <div class="mb-3">
              <label class="dp-form-label">Propiedad de interés</label>
              <select class="dp-form-control" id="demo-prop-sel">
                <option value="">-- Selecciona una propiedad --</option>
                <option value="1">Casa Moderna en Cabecera — $420.000.000 (Venta)</option>
                <option value="2">Apto Lagos del Cacique — $280.000.000 (Venta)</option>
                <option value="3">Oficina Centro Empresarial — $2.800.000/mes (Arriendo)</option>
                <option value="4">Casa Campestre Floridablanca — $950.000.000 (Venta)</option>
                <option value="5">Apto Amoblado Sotomayor — $1.500.000/mes (Arriendo)</option>
                <option value="6">Penthouse Panorámica BGA — $680.000.000 (Venta)</option>
                <option value="9">Terreno Piedecuesta — $550.000.000 (Venta)</option>
                <option value="10">Local Comercial Cabecera — $4.200.000/mes (Arriendo)</option>
              </select>
            </div>

            <!-- Tipo de interés -->
            <div class="mb-3">
              <label class="dp-form-label">Tipo de solicitud</label>
              <div class="d-flex gap-3">
                <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:0.85rem;">
                  <input type="radio" name="tipoSol" value="visita" checked
                         style="accent-color:var(--dp-gold);width:16px;height:16px;"> Visitar la propiedad
                </label>
                <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:0.85rem;">
                  <input type="radio" name="tipoSol" value="informacion"
                         style="accent-color:var(--dp-gold);width:16px;height:16px;"> Solo información
                </label>
                <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:0.85rem;">
                  <input type="radio" name="tipoSol" value="oferta"
                         style="accent-color:var(--dp-gold);width:16px;height:16px;"> Hacer una oferta
                </label>
              </div>
            </div>

            <!-- Fecha y hora -->
            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <label class="dp-form-label">Fecha preferida</label>
                <input type="date" class="dp-form-control" id="demo-fecha"
                       min="${pageContext.request.attribute['today']}">
              </div>
              <div class="col-md-6">
                <label class="dp-form-label">Hora preferida</label>
                <select class="dp-form-control" id="demo-hora">
                  <option>8:00 am</option><option>9:00 am</option><option>10:00 am</option>
                  <option>11:00 am</option><option>2:00 pm</option><option>3:00 pm</option>
                  <option>4:00 pm</option><option>5:00 pm</option>
                </select>
              </div>
            </div>

            <!-- Comentarios -->
            <div class="mb-4">
              <label class="dp-form-label">Comentarios o preguntas (opcional)</label>
              <textarea class="dp-form-control" id="demo-notas" rows="3"
                        placeholder="¿Tienes preguntas específicas sobre la propiedad? ¿Necesitas estacionamiento adicional? ¿Llevas a más personas?"></textarea>
            </div>

            <button class="dp-btn-gold w-100 justify-content-center py-3" onclick="enviarCitaDemo()"
                    style="font-size:0.95rem;">
              <i class="fas fa-calendar-check me-2"></i>Confirmar Solicitud de Visita
            </button>
          </div>
        </div>

        <!-- Panel info lateral -->
        <div class="col-lg-5">
          <div class="dp-card mb-3" id="demo-prop-preview" style="display:none;">
            <div class="dp-card__title"><i class="fas fa-home"></i> Propiedad Seleccionada</div>
            <div id="demo-preview-content"></div>
          </div>

          <div class="dp-card">
            <div class="dp-card__title"><i class="fas fa-info-circle"></i> ¿Cómo funciona?</div>
            <div class="dp-step">
              <div class="dp-step__num">1</div>
              <div><div class="dp-step__title">Solicitas la visita</div>
                <div class="dp-step__desc">Seleccionas la propiedad, fecha y hora de tu preferencia.</div></div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num">2</div>
              <div><div class="dp-step__title">La inmobiliaria confirma</div>
                <div class="dp-step__desc">Recibes una notificación cuando confirmen la disponibilidad.</div></div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num done"><i class="fas fa-check"></i></div>
              <div><div class="dp-step__title">¡Visitas la propiedad!</div>
                <div class="dp-step__desc">El día acordado haces la visita con el asesor inmobiliario.</div></div>
            </div>
          </div>
        </div>

      </div>

      <!-- Confirmación (oculta) -->
      <div id="demo-confirmacion" style="display:none;" class="dp-card mt-4" style="border:2px solid #0f5132;background:#f0fdf4;">
        <div class="text-center py-3">
          <div style="font-size:3rem;color:#0f5132;margin-bottom:16px;"><i class="fas fa-check-circle"></i></div>
          <h5 style="font-family:'Playfair Display',serif;font-weight:900;color:#0f5132;margin-bottom:8px;">
            ¡Solicitud enviada correctamente!
          </h5>
          <p style="color:#555;font-size:0.88rem;margin-bottom:20px;">
            La inmobiliaria revisará tu solicitud y recibirás una notificación con la confirmación.
            Puedes ver el estado en <strong>Mis Citas</strong>.
          </p>
          <div class="d-flex gap-3 justify-content-center">
            <button class="dp-btn-gold" onclick="showTab('citas',document.querySelectorAll('.dp-tabs__btn')[2])">
              <i class="fas fa-calendar-alt"></i> Ver Mis Citas
            </button>
            <a href="${ctx}/lista.jsp" class="dp-btn-outline">
              <i class="fas fa-search"></i> Ver más propiedades
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════════════════════════
         PESTAÑA 6: FLUJO DE REGISTRO
    ══════════════════════════════════ -->
    <div class="dp-pane" id="pane-registro">
      <div class="row g-4">

        <div class="col-lg-6">
          <div class="dp-card">
            <div class="dp-card__title"><i class="fas fa-user-plus"></i> Paso a Paso: Registro</div>
            <div class="dp-card__sub">Así se crea una cuenta nueva en InmoVista</div>

            <div class="dp-step">
              <div class="dp-step__num done"><i class="fas fa-check"></i></div>
              <div>
                <div class="dp-step__title">1. Ir a Crear Cuenta</div>
                <div class="dp-step__desc">El visitante hace clic en "Crear Cuenta Gratis" en la página de inicio o en la navbar.</div>
              </div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num done"><i class="fas fa-check"></i></div>
              <div>
                <div class="dp-step__title">2. Completar el formulario</div>
                <div class="dp-step__desc">Ingresa nombre, apellido, correo electrónico y contraseña (mínimo 8 caracteres).</div>
              </div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num done"><i class="fas fa-check"></i></div>
              <div>
                <div class="dp-step__title">3. El sistema asigna el rol "Cliente"</div>
                <div class="dp-step__desc">Automáticamente se crea la cuenta con rol Cliente y se inicia la sesión.</div>
              </div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num done"><i class="fas fa-check"></i></div>
              <div>
                <div class="dp-step__title">4. Redirección al Dashboard</div>
                <div class="dp-step__desc">El usuario llega a su panel personalizado donde puede explorar, guardar favoritos y agendar visitas.</div>
              </div>
            </div>
            <div class="dp-step">
              <div class="dp-step__num"><i class="fas fa-key"></i></div>
              <div>
                <div class="dp-step__title">5. Acceso a funciones exclusivas</div>
                <div class="dp-step__desc">Puede agendar citas desde detalle.jsp, guardar favoritos y ver el historial de sus solicitudes.</div>
              </div>
            </div>

            <div class="mt-4 d-flex gap-2 flex-wrap">
              <a href="${ctx}/registro.jsp" class="dp-btn-gold">
                <i class="fas fa-user-plus"></i> Ir al Registro Real
              </a>
              <a href="${ctx}/login.jsp" class="dp-btn-outline">
                <i class="fas fa-sign-in-alt"></i> Iniciar Sesión
              </a>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="dp-card">
            <div class="dp-card__title"><i class="fas fa-shield-alt"></i> Roles del Sistema</div>
            <div class="dp-card__sub">InmoVista tiene 3 tipos de usuario con diferentes permisos</div>

            <!-- Cliente -->
            <div style="border:1.5px solid rgba(52,152,219,0.25);border-radius:12px;padding:16px;margin-bottom:12px;background:rgba(52,152,219,0.04);">
              <div class="d-flex align-items-center gap-10 mb-2">
                <span class="dp-role-badge dp-role-badge--cliente"><i class="fas fa-user"></i> Cliente</span>
                <span style="font-size:0.75rem;color:var(--dp-muted);">— Acceso por defecto al registrarse</span>
              </div>
              <ul style="font-size:0.8rem;color:#555;padding-left:20px;margin:0;">
                <li>Ver y buscar propiedades</li>
                <li>Agendar visitas desde el detalle</li>
                <li>Guardar propiedades en favoritos</li>
                <li>Ver historial de citas y solicitudes</li>
              </ul>
            </div>

            <!-- Inmobiliaria -->
            <div style="border:1.5px solid rgba(201,168,76,0.3);border-radius:12px;padding:16px;margin-bottom:12px;background:rgba(201,168,76,0.04);">
              <div class="d-flex align-items-center gap-10 mb-2">
                <span class="dp-role-badge dp-role-badge--inmobiliaria"><i class="fas fa-building"></i> Inmobiliaria</span>
                <span style="font-size:0.75rem;color:var(--dp-muted);">— Asignado por el admin</span>
              </div>
              <ul style="font-size:0.8rem;color:#555;padding-left:20px;margin:0;">
                <li>Publicar, editar y eliminar propiedades</li>
                <li>Gestionar citas (confirmar / rechazar)</li>
                <li>Ver solicitudes de clientes</li>
                <li>Ver reportes de sus propiedades</li>
              </ul>
            </div>

            <!-- Admin -->
            <div style="border:1.5px solid rgba(231,76,60,0.25);border-radius:12px;padding:16px;background:rgba(231,76,60,0.04);">
              <div class="d-flex align-items-center gap-10 mb-2">
                <span class="dp-role-badge dp-role-badge--admin"><i class="fas fa-user-shield"></i> Admin</span>
                <span style="font-size:0.75rem;color:var(--dp-muted);">— Control total del sistema</span>
              </div>
              <ul style="font-size:0.8rem;color:#555;padding-left:20px;margin:0;">
                <li>Gestionar todos los usuarios y roles</li>
                <li>Ver y eliminar cualquier propiedad</li>
                <li>Acceso a reportes globales</li>
                <li>Configuración general del sistema</li>
              </ul>
            </div>
          </div>
        </div>

      </div>
    </div>

  </div><%-- container --%>
</div><%-- dp-page --%>

<%@ include file="footer.jsp" %>

<script>
/* ── Tab navigation ─────────────────────────── */
function showTab(name, btn) {
  document.querySelectorAll('.dp-pane').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.dp-tabs__btn').forEach(b => b.classList.remove('active'));
  const pane = document.getElementById('pane-' + name);
  if (pane) pane.classList.add('active');
  if (btn) btn.classList.add('active');
  window.scrollTo({ top: 130, behavior: 'smooth' });
}

/* ── Preview de propiedad en el form ─────────── */
const propData = {
  '1': { name:'Casa Moderna en Cabecera', tipo:'Casa · Venta', precio:'$420.000.000', img:'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400&q=70', loc:'Cra 27 # 42-10, Cabecera BGA' },
  '2': { name:'Apto Exclusivo Lagos del Cacique', tipo:'Apartamento · Venta', precio:'$280.000.000', img:'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&q=70', loc:'Cl 52 # 31-15, Lagos del Cacique' },
  '3': { name:'Oficina Centro Empresarial', tipo:'Oficina · Arriendo', precio:'$2.800.000 / mes', img:'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&q=70', loc:'Cra 15 # 36-22, Centro BGA' },
  '4': { name:'Casa Campestre Floridablanca', tipo:'Casa · Venta', precio:'$950.000.000', img:'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&q=70', loc:'Km 3 Vía Floridablanca' },
  '5': { name:'Apartamento Amoblado Sotomayor', tipo:'Apartamento · Arriendo', precio:'$1.500.000 / mes', img:'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=400&q=70', loc:'Cra 22 # 34-50, Sotomayor' },
  '6': { name:'Penthouse Vista Panorámica BGA', tipo:'Penthouse · Venta', precio:'$680.000.000', img:'https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=400&q=70', loc:'Av 30 # 52-80, Piso 18' },
  '9': { name:'Terreno Urbanizable Piedecuesta', tipo:'Terreno · Venta', precio:'$550.000.000', img:'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400&q=70', loc:'Km 2 Vía Piedecuesta' },
  '10': { name:'Local Comercial Cabecera', tipo:'Local · Arriendo', precio:'$4.200.000 / mes', img:'https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=400&q=70', loc:'Cra 33 # 44-21, Cabecera' },
};

document.getElementById('demo-prop-sel').addEventListener('change', function() {
  const preview = document.getElementById('demo-prop-preview');
  const content = document.getElementById('demo-preview-content');
  const p = propData[this.value];
  if (p) {
    content.innerHTML = `
      <div style="border-radius:10px;overflow:hidden;aspect-ratio:16/9;margin-bottom:12px;">
        <img src="${p.img}" style="width:100%;height:100%;object-fit:cover;" alt="">
      </div>
      <div style="font-size:0.62rem;font-weight:700;letter-spacing:2px;color:var(--dp-gold);text-transform:uppercase;margin-bottom:4px;">${p.tipo}</div>
      <div style="font-family:'Playfair Display',serif;font-weight:700;font-size:1rem;margin-bottom:6px;">${p.name}</div>
      <div style="font-size:0.8rem;color:var(--dp-muted);margin-bottom:8px;"><i class="fas fa-map-marker-alt me-1"></i>${p.loc}</div>
      <div style="font-size:1.3rem;font-weight:900;color:var(--dp-dark);">${p.precio}</div>
    `;
    preview.style.display = 'block';
  } else {
    preview.style.display = 'none';
  }
});

/* ── Enviar cita demo ──────────────────────── */
function enviarCitaDemo() {
  const prop = document.getElementById('demo-prop-sel').value;
  const fecha = document.getElementById('demo-fecha').value;
  if (!prop || !fecha) {
    alert('Por favor selecciona una propiedad y una fecha.');
    return;
  }
  document.querySelector('#pane-agendar .row').style.display = 'none';
  document.getElementById('demo-confirmacion').style.display = 'block';
  window.scrollTo({ top: 400, behavior: 'smooth' });
}

/* ── Preselect from URL param ──────────────── */
const urlParams = new URLSearchParams(window.location.search);
const propId = urlParams.get('propId');
if (propId && document.getElementById('demo-prop-sel')) {
  document.getElementById('demo-prop-sel').value = propId;
  document.getElementById('demo-prop-sel').dispatchEvent(new Event('change'));
  showTab('agendar', document.querySelectorAll('.dp-tabs__btn')[4]);
}

/* ── Set min date ─────────────────────────── */
const today = new Date().toISOString().split('T')[0];
const fechaInput = document.getElementById('demo-fecha');
if (fechaInput) { fechaInput.min = today; fechaInput.value = ''; }
</script>
