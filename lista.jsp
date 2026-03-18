<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Propiedades" scope="request"/>
<%@ include file="header.jsp" %>

<style>
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;0,700;1,300;1,400&family=Outfit:wght@200;300;400;500;600;700&display=swap');

/* ═══════════════════════════════════════
   RESET DE PÁGINA
═══════════════════════════════════════ */
#lista-universe * { box-sizing: border-box; }

/* ═══════════════════════════════════════
   CANVAS DE PARTÍCULAS
═══════════════════════════════════════ */
#particleCanvas {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  pointer-events: none;
  z-index: 0;
  opacity: 0.6;
}

/* ═══════════════════════════════════════
   UNIVERSO CONTENEDOR
═══════════════════════════════════════ */
#lista-universe {
  position: relative;
  z-index: 1;
  background: linear-gradient(160deg, #050509 0%, #0a0a12 40%, #080810 100%);
  min-height: 100vh;
  padding-bottom: 100px;
  font-family: 'Outfit', sans-serif;
}

/* ═══════════════════════════════════════
   HERO HEADER
═══════════════════════════════════════ */
.lv-hero {
  position: relative;
  padding: 100px 0 60px;
  overflow: hidden;
}

.lv-hero__orb {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  filter: blur(80px);
}
.lv-hero__orb--1 {
  width: 500px; height: 500px;
  background: radial-gradient(circle, rgba(201,168,76,0.12) 0%, transparent 70%);
  top: -150px; left: -100px;
  animation: orbFloat1 12s ease-in-out infinite;
}
.lv-hero__orb--2 {
  width: 400px; height: 400px;
  background: radial-gradient(circle, rgba(100,80,200,0.08) 0%, transparent 70%);
  top: 0; right: -80px;
  animation: orbFloat2 15s ease-in-out infinite;
}
.lv-hero__orb--3 {
  width: 300px; height: 300px;
  background: radial-gradient(circle, rgba(201,168,76,0.06) 0%, transparent 70%);
  bottom: -50px; left: 40%;
  animation: orbFloat1 10s ease-in-out infinite reverse;
}
@keyframes orbFloat1 {
  0%,100% { transform: translate(0,0) scale(1); }
  33%      { transform: translate(30px,-20px) scale(1.05); }
  66%      { transform: translate(-20px,15px) scale(0.97); }
}
@keyframes orbFloat2 {
  0%,100% { transform: translate(0,0) scale(1); }
  50%      { transform: translate(-40px,25px) scale(1.08); }
}

.lv-hero__content {
  position: relative;
  z-index: 2;
  text-align: center;
}

.lv-hero__eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 14px;
  font-size: 0.65rem;
  font-weight: 600;
  letter-spacing: 5px;
  text-transform: uppercase;
  color: #c9a84c;
  margin-bottom: 20px;
  opacity: 0;
  animation: fadeUp 0.8s 0.2s ease forwards;
}
.lv-hero__eyebrow::before,
.lv-hero__eyebrow::after {
  content: '';
  width: 40px; height: 1px;
  background: linear-gradient(90deg, transparent, #c9a84c);
}
.lv-hero__eyebrow::after { background: linear-gradient(270deg, transparent, #c9a84c); }

.lv-hero__title {
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(3rem, 7vw, 6rem);
  font-weight: 300;
  line-height: 1.05;
  color: #fff;
  margin-bottom: 16px;
  opacity: 0;
  animation: fadeUp 1s 0.35s ease forwards;
}
.lv-hero__title em {
  font-style: italic;
  color: #c9a84c;
}
.lv-hero__title strong {
  font-weight: 700;
  display: block;
}

.lv-hero__sub {
  font-size: 0.9rem;
  color: rgba(255,255,255,0.35);
  letter-spacing: 0.5px;
  opacity: 0;
  animation: fadeUp 0.8s 0.5s ease forwards;
}

/* ═══════════════════════════════════════
   BARRA DE BÚSQUEDA FLOTANTE
═══════════════════════════════════════ */
.lv-searchbar {
  position: relative;
  z-index: 10;
  margin: 0 auto 60px;
  max-width: 920px;
  padding: 0 20px;
  opacity: 0;
  animation: fadeUp 1s 0.6s ease forwards;
}

.lv-searchbar__glass {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(201,168,76,0.2);
  border-radius: 20px;
  padding: 8px 8px 8px 8px;
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  box-shadow: 0 30px 80px rgba(0,0,0,0.5),
              inset 0 1px 0 rgba(255,255,255,0.06);
  display: flex;
  align-items: center;
  gap: 4px;
  flex-wrap: wrap;
}

.lv-field {
  flex: 1;
  min-width: 120px;
  position: relative;
}

.lv-field__label {
  position: absolute;
  top: -8px; left: 14px;
  font-size: 0.58rem;
  font-weight: 700;
  letter-spacing: 2.5px;
  text-transform: uppercase;
  color: #c9a84c;
  background: #0a0a12;
  padding: 0 6px;
  border-radius: 4px;
  z-index: 1;
}

.lv-field select,
.lv-field input[type="text"],
.lv-field input[type="number"] {
  width: 100%;
  height: 52px;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 12px;
  color: #fff;
  font-family: 'Outfit', sans-serif;
  font-size: 0.85rem;
  padding: 0 14px;
  outline: none;
  transition: all 0.3s ease;
  -webkit-appearance: none;
}
.lv-field select option { background: #0d0d1a; color: #fff; }
.lv-field select:focus,
.lv-field input:focus {
  border-color: rgba(201,168,76,0.5);
  background: rgba(201,168,76,0.05);
  box-shadow: 0 0 0 3px rgba(201,168,76,0.08);
}
.lv-field input::placeholder { color: rgba(255,255,255,0.2); }

.lv-searchbar__divider {
  width: 1px;
  height: 32px;
  background: rgba(255,255,255,0.08);
  flex-shrink: 0;
}

.lv-searchbar__btn {
  height: 52px;
  padding: 0 28px;
  background: linear-gradient(135deg, #c9a84c 0%, #e8c96b 100%);
  border: none;
  border-radius: 12px;
  font-family: 'Outfit', sans-serif;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: #05050a;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  flex-shrink: 0;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}
.lv-searchbar__btn::before {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(255,255,255,0.2), transparent);
  opacity: 0;
  transition: opacity 0.3s;
}
.lv-searchbar__btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 36px rgba(201,168,76,0.4);
}
.lv-searchbar__btn:hover::before { opacity: 1; }

/* ═══════════════════════════════════════
   CONTROLES DE RESULTADOS
═══════════════════════════════════════ */
.lv-controls {
  max-width: 1280px;
  margin: 0 auto 32px;
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  opacity: 0;
  animation: fadeUp 0.8s 0.75s ease forwards;
}

.lv-controls__count {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.6rem;
  font-weight: 400;
  color: #fff;
}
.lv-controls__count em {
  color: #c9a84c;
  font-style: normal;
  font-weight: 600;
}
.lv-controls__sub {
  font-size: 0.75rem;
  color: rgba(255,255,255,0.25);
  letter-spacing: 1px;
  margin-top: 2px;
}

.lv-controls__right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.lv-sort {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 10px;
  color: rgba(255,255,255,0.5);
  font-family: 'Outfit', sans-serif;
  font-size: 0.78rem;
  padding: 8px 14px;
  outline: none;
  cursor: pointer;
  transition: all 0.25s;
}
.lv-sort:focus { border-color: rgba(201,168,76,0.4); color: #c9a84c; }
.lv-sort option { background: #0d0d1a; }

.lv-view-btn {
  width: 38px; height: 38px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.03);
  color: rgba(255,255,255,0.3);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.25s;
  font-size: 0.85rem;
}
.lv-view-btn.active,
.lv-view-btn:hover {
  background: rgba(201,168,76,0.12);
  border-color: rgba(201,168,76,0.3);
  color: #c9a84c;
}

/* ═══════════════════════════════════════
   FILTROS ACTIVOS
═══════════════════════════════════════ */
.lv-active-filters {
  max-width: 1280px;
  margin: 0 auto 28px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.lv-filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 14px;
  background: rgba(201,168,76,0.1);
  border: 1px solid rgba(201,168,76,0.25);
  border-radius: 100px;
  font-size: 0.75rem;
  font-weight: 500;
  color: #c9a84c;
  letter-spacing: 0.5px;
}
.lv-filter-tag a {
  color: rgba(201,168,76,0.5);
  text-decoration: none;
  font-size: 0.9em;
  transition: color 0.2s;
}
.lv-filter-tag a:hover { color: #e74c3c; }
.lv-clear-all {
  font-size: 0.75rem;
  color: #e74c3c;
  text-decoration: none;
  font-weight: 600;
  padding: 5px 10px;
  border-radius: 100px;
  border: 1px solid rgba(231,76,60,0.2);
  transition: all 0.25s;
}
.lv-clear-all:hover { background: rgba(231,76,60,0.1); }

/* ═══════════════════════════════════════
   GRID DE PROPIEDADES
═══════════════════════════════════════ */
.lv-grid {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}
@media(max-width: 1024px) { .lv-grid { grid-template-columns: repeat(2,1fr); } }
@media(max-width: 640px)  { .lv-grid { grid-template-columns: 1fr; } }

.lv-grid.list-view {
  grid-template-columns: 1fr;
}
.lv-grid.list-view .lv-card {
  display: grid;
  grid-template-columns: 340px 1fr;
}
.lv-grid.list-view .lv-card__img {
  aspect-ratio: unset;
  height: 100%;
}
@media(max-width:768px) {
  .lv-grid.list-view .lv-card { grid-template-columns: 1fr; }
  .lv-grid.list-view .lv-card__img { aspect-ratio: 16/9; height: auto; }
}

/* ═══════════════════════════════════════
   PROPERTY CARD
═══════════════════════════════════════ */
.lv-card {
  position: relative;
  border-radius: 20px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.06);
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  opacity: 0;
  transform: translateY(30px);
  cursor: pointer;
}
.lv-card.revealed {
  opacity: 1;
  transform: translateY(0);
}
.lv-card:hover {
  border-color: rgba(201,168,76,0.35);
  transform: translateY(-8px);
  box-shadow: 0 40px 80px rgba(0,0,0,0.6),
              0 0 0 1px rgba(201,168,76,0.15),
              inset 0 1px 0 rgba(255,255,255,0.06);
}

/* Imagen */
.lv-card__img {
  position: relative;
  aspect-ratio: 4/3;
  overflow: hidden;
}
.lv-card__img img {
  width: 100%; height: 100%;
  object-fit: cover;
  transition: transform 0.8s cubic-bezier(0.16,1,0.3,1);
  filter: brightness(0.85) saturate(0.9);
}
.lv-card:hover .lv-card__img img {
  transform: scale(1.07);
  filter: brightness(0.95) saturate(1.05);
}

/* Gradiente imagen */
.lv-card__img::after {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(
    180deg,
    transparent 40%,
    rgba(5,5,9,0.7) 75%,
    rgba(5,5,9,0.92) 100%
  );
  transition: opacity 0.4s;
}

/* Badge operación */
.lv-badge {
  position: absolute;
  top: 16px; left: 16px;
  z-index: 3;
  font-size: 0.58rem;
  font-weight: 700;
  letter-spacing: 2.5px;
  text-transform: uppercase;
  padding: 5px 14px;
  border-radius: 100px;
  backdrop-filter: blur(12px);
  border: 1px solid;
}
.lv-badge--venta {
  background: rgba(201,168,76,0.2);
  border-color: rgba(201,168,76,0.5);
  color: #e8c96b;
}
.lv-badge--arriendo {
  background: rgba(41,182,246,0.15);
  border-color: rgba(41,182,246,0.4);
  color: #29b6f6;
}

/* Botón favorito */
.lv-fav {
  position: absolute;
  top: 14px; right: 14px;
  z-index: 3;
  width: 36px; height: 36px;
  border-radius: 50%;
  background: rgba(5,5,9,0.5);
  border: 1px solid rgba(255,255,255,0.1);
  backdrop-filter: blur(12px);
  display: flex; align-items: center; justify-content: center;
  color: rgba(255,255,255,0.35);
  cursor: pointer;
  transition: all 0.25s;
  font-size: 0.8rem;
}
.lv-fav:hover, .lv-fav.active {
  color: #e74c3c;
  border-color: rgba(231,76,60,0.4);
  background: rgba(231,76,60,0.15);
}

/* Número de fotos */
.lv-photo-count {
  position: absolute;
  bottom: 14px; right: 14px;
  z-index: 3;
  font-size: 0.68rem;
  color: rgba(255,255,255,0.45);
  display: flex;
  align-items: center;
  gap: 5px;
}

/* Cuerpo de la card */
.lv-card__body {
  padding: 22px 22px 20px;
  display: flex;
  flex-direction: column;
  gap: 0;
  background: linear-gradient(180deg, rgba(10,10,18,0.98) 0%, rgba(8,8,14,1) 100%);
}

.lv-card__tipo {
  font-size: 0.62rem;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: #c9a84c;
  margin-bottom: 6px;
}

.lv-card__titulo {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.25rem;
  font-weight: 400;
  color: #fff;
  line-height: 1.25;
  margin-bottom: 8px;
  transition: color 0.25s;
}
.lv-card:hover .lv-card__titulo { color: #e8c96b; }

.lv-card__loc {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.77rem;
  color: rgba(255,255,255,0.3);
  margin-bottom: 16px;
}
.lv-card__loc i { color: #c9a84c; font-size: 0.65rem; }

/* Separador decorativo */
.lv-card__sep {
  height: 1px;
  background: linear-gradient(90deg, rgba(201,168,76,0.2), transparent);
  margin-bottom: 16px;
}

/* Features */
.lv-card__feats {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 18px;
}
.lv-feat {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.75rem;
  color: rgba(255,255,255,0.35);
}
.lv-feat i { color: rgba(201,168,76,0.6); font-size: 0.7rem; }

/* Footer card */
.lv-card__foot {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-top: auto;
}

.lv-precio-val {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.75rem;
  font-weight: 600;
  color: #c9a84c;
  line-height: 1;
}
.lv-precio-lbl {
  font-size: 0.68rem;
  color: rgba(255,255,255,0.2);
  letter-spacing: 1px;
  margin-top: 3px;
}

.lv-card__cta {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px; height: 42px;
  border-radius: 12px;
  background: rgba(201,168,76,0.1);
  border: 1px solid rgba(201,168,76,0.2);
  color: #c9a84c;
  text-decoration: none;
  font-size: 0.9rem;
  transition: all 0.3s cubic-bezier(0.16,1,0.3,1);
  flex-shrink: 0;
}
.lv-card__cta:hover {
  background: #c9a84c;
  color: #05050a;
  transform: rotate(45deg) scale(1.1);
  box-shadow: 0 8px 24px rgba(201,168,76,0.4);
}

/* Shine hover effect */
.lv-card__shine {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 5;
  background: radial-gradient(
    600px circle at var(--mx,50%) var(--my,50%),
    rgba(201,168,76,0.06),
    transparent 50%
  );
  opacity: 0;
  transition: opacity 0.4s;
  border-radius: 20px;
}
.lv-card:hover .lv-card__shine { opacity: 1; }

/* ═══════════════════════════════════════
   EMPTY STATE
═══════════════════════════════════════ */
.lv-empty {
  grid-column: 1/-1;
  text-align: center;
  padding: 100px 24px;
}
.lv-empty__icon {
  font-size: 3rem;
  color: rgba(201,168,76,0.2);
  margin-bottom: 24px;
}
.lv-empty__title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2rem;
  font-weight: 300;
  color: rgba(255,255,255,0.5);
  margin-bottom: 10px;
}
.lv-empty__sub {
  font-size: 0.85rem;
  color: rgba(255,255,255,0.2);
  margin-bottom: 32px;
}
.lv-empty__btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 28px;
  background: rgba(201,168,76,0.1);
  border: 1px solid rgba(201,168,76,0.25);
  border-radius: 100px;
  color: #c9a84c;
  text-decoration: none;
  font-size: 0.82rem;
  font-weight: 600;
  letter-spacing: 1px;
  text-transform: uppercase;
  transition: all 0.3s ease;
}
.lv-empty__btn:hover {
  background: rgba(201,168,76,0.2);
  transform: translateY(-2px);
}

/* ═══════════════════════════════════════
   PAGINACIÓN
═══════════════════════════════════════ */
.lv-pagination {
  max-width: 1280px;
  margin: 60px auto 0;
  padding: 0 24px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}
.lv-page {
  width: 42px; height: 42px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.07);
  background: rgba(255,255,255,0.03);
  color: rgba(255,255,255,0.3);
  font-family: 'Outfit', sans-serif;
  font-size: 0.85rem;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.25s;
}
.lv-page:hover {
  border-color: rgba(201,168,76,0.3);
  color: #c9a84c;
  background: rgba(201,168,76,0.07);
}
.lv-page.active {
  background: #c9a84c;
  color: #05050a;
  border-color: #c9a84c;
  font-weight: 700;
}
.lv-page.disabled {
  opacity: 0.25;
  cursor: default;
  pointer-events: none;
}

/* ═══════════════════════════════════════
   LÍNEA DECORATIVA LATERAL
═══════════════════════════════════════ */
.lv-sideline {
  position: fixed;
  left: 28px; top: 30%; bottom: 30%;
  width: 1px;
  background: linear-gradient(180deg, transparent, rgba(201,168,76,0.3), transparent);
  z-index: 0;
  animation: sidelineIn 2s 1s ease forwards;
  opacity: 0;
}
@keyframes sidelineIn { to { opacity: 1; } }
@media(max-width:1200px) { .lv-sideline { display: none; } }

/* ═══════════════════════════════════════
   CURSOR PERSONALIZADO
═══════════════════════════════════════ */
#lv-cursor-dot, #lv-cursor-ring {
  position: fixed;
  border-radius: 50%;
  pointer-events: none;
  z-index: 9999;
  mix-blend-mode: difference;
}
#lv-cursor-dot {
  width: 6px; height: 6px;
  background: #c9a84c;
  transform: translate(-50%,-50%);
  transition: transform 0.1s;
}
#lv-cursor-ring {
  width: 32px; height: 32px;
  border: 1.5px solid rgba(201,168,76,0.7);
  transform: translate(-50%,-50%);
  transition: all 0.38s cubic-bezier(0.16,1,0.3,1);
}

/* ═══════════════════════════════════════
   ANIMACIONES BASE
═══════════════════════════════════════ */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
</style>

<!-- Cursor -->
<div id="lv-cursor-dot"></div>
<div id="lv-cursor-ring"></div>

<!-- Canvas partículas -->
<canvas id="particleCanvas"></canvas>

<!-- Línea lateral decorativa -->
<div class="lv-sideline"></div>

<div id="lista-universe">

  <!-- ══ HERO ══ -->
  <section class="lv-hero">
    <div class="lv-hero__orb lv-hero__orb--1"></div>
    <div class="lv-hero__orb lv-hero__orb--2"></div>
    <div class="lv-hero__orb lv-hero__orb--3"></div>
    <div class="container">
      <div class="lv-hero__content">
        <div class="lv-hero__eyebrow">
          <i class="fas fa-gem"></i> Catálogo Premium InmoVista
        </div>
        <h1 class="lv-hero__title">
          Encuentra tu<br>próximo <em>hogar</em><br><strong>ideal.</strong>
        </h1>
        <p class="lv-hero__sub">
          Más de 500 propiedades verificadas · Bucaramanga y Santander
        </p>
      </div>
    </div>
  </section>

  <!-- ══ BARRA DE BÚSQUEDA ══ -->
  <div class="container">
    <div class="lv-searchbar">
      <form action="${ctx}/lista.jsp" method="get">
        <div class="lv-searchbar__glass">

          <div class="lv-field">
            <span class="lv-field__label">Operación</span>
            <select name="operacion" id="f-operacion" onchange="applyClientFilters()">
              <option value="">Todas</option>
              <option value="venta"    ${param.operacion == 'venta'    ? 'selected' : ''}>Venta</option>
              <option value="arriendo" ${param.operacion == 'arriendo' ? 'selected' : ''}>Arriendo</option>
            </select>
          </div>

          <div class="lv-searchbar__divider"></div>

          <div class="lv-field">
            <span class="lv-field__label">Tipo</span>
            <select name="tipo" id="f-tipo" onchange="applyClientFilters()">
              <option value="">Todos</option>
              <option value="casa"        ${param.tipo == 'casa'        ? 'selected' : ''}>Casa</option>
              <option value="apartamento" ${param.tipo == 'apartamento' ? 'selected' : ''}>Apartamento</option>
              <option value="terreno"     ${param.tipo == 'terreno'     ? 'selected' : ''}>Terreno</option>
              <option value="oficina"     ${param.tipo == 'oficina'     ? 'selected' : ''}>Oficina</option>
              <option value="local"       ${param.tipo == 'local'       ? 'selected' : ''}>Local</option>
              <option value="penthouse"   ${param.tipo == 'penthouse'   ? 'selected' : ''}>Penthouse</option>
            </select>
          </div>

          <div class="lv-searchbar__divider"></div>

          <div class="lv-field" style="flex:1.5">
            <span class="lv-field__label">Ubicación</span>
            <input type="text" name="ciudad" id="f-ciudad" oninput="applyClientFilters()" placeholder="Ciudad o barrio…" value="${param.ciudad}">
          </div>

          <div class="lv-searchbar__divider"></div>

          <div class="lv-field">
            <span class="lv-field__label">Precio mín.</span>
            <input type="number" name="precioMin" id="f-pmin" oninput="applyClientFilters()" placeholder="$0" value="${param.precioMin}">
          </div>

          <div class="lv-searchbar__divider"></div>

          <div class="lv-field">
            <span class="lv-field__label">Precio máx.</span>
            <input type="number" name="precioMax" id="f-pmax" oninput="applyClientFilters()" placeholder="Sin límite" value="${param.precioMax}">
          </div>

          <button type="submit" class="lv-searchbar__btn">
            <i class="fas fa-search"></i> Buscar
          </button>

        </div>
      </form>
    </div>
  </div>

  <!-- ══ CONTROLES ══ -->
  <div class="lv-controls">
    <div>
      <div class="lv-controls__count">
        <c:choose>
          <c:when test="${not empty propiedades}">
            <em>${fn:length(propiedades)}</em> propiedades
            <c:if test="${not empty param.ciudad}"> en <em>${param.ciudad}</em></c:if>
          </c:when>
          <c:otherwise><em>60</em> propiedades disponibles</c:otherwise>
        </c:choose>
      </div>
      <div class="lv-controls__sub">CATÁLOGO INMOVISTA · BUCARAMANGA, SANTANDER</div>
    </div>
    <div class="lv-controls__right">
      <select class="lv-sort" onchange="sortCards(this.value)">
        <option value="reciente">Más recientes</option>
        <option value="precio_asc">Precio ↑</option>
        <option value="precio_desc">Precio ↓</option>
        <option value="area">Mayor área</option>
      </select>
      <button class="lv-view-btn active" id="btnGrid" onclick="setView('grid')" title="Vista cuadrícula">
        <i class="fas fa-th"></i>
      </button>
      <button class="lv-view-btn" id="btnList" onclick="setView('list')" title="Vista lista">
        <i class="fas fa-list"></i>
      </button>
    </div>
  </div>

  <!-- ══ FILTROS ACTIVOS ══ -->
  <c:if test="${not empty param.operacion or not empty param.tipo or not empty param.ciudad}">
    <div class="lv-active-filters">
      <c:if test="${not empty param.operacion}">
        <span class="lv-filter-tag">
          <i class="fas fa-tag" style="font-size:0.65rem;"></i>
          ${param.operacion}
          <a href="javascript:removeFilter('operacion')">✕</a>
        </span>
      </c:if>
      <c:if test="${not empty param.tipo}">
        <span class="lv-filter-tag">
          <i class="fas fa-home" style="font-size:0.65rem;"></i>
          ${param.tipo}
          <a href="javascript:removeFilter('tipo')">✕</a>
        </span>
      </c:if>
      <c:if test="${not empty param.ciudad}">
        <span class="lv-filter-tag">
          <i class="fas fa-map-marker-alt" style="font-size:0.65rem;"></i>
          ${param.ciudad}
          <a href="javascript:removeFilter('ciudad')">✕</a>
        </span>
      </c:if>
      <a href="${ctx}/lista.jsp" class="lv-clear-all">
        <i class="fas fa-times"></i> Limpiar todo
      </a>
    </div>
  </c:if>

  <!-- ══ GRID ══ -->
  <div class="lv-grid" id="propiedadesGrid">

    <c:choose>
      <%-- ── BD REAL ── --%>
      <c:when test="${not empty propiedades}">
        <c:forEach var="prop" items="${propiedades}" varStatus="loop">
        <div class="lv-card" data-precio="${prop.precio}" data-area="${prop.area}">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="${not empty prop.fotoPrincipal ? prop.fotoPrincipal : 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=700&q=80'}"
                 alt="${prop.titulo}" loading="lazy">
            <span class="lv-badge lv-badge--${prop.operacion}">${prop.operacion}</span>
            <c:if test="${not empty sessionScope.usuario}">
              <form action="${ctx}/lista.jsp" method="post" style="display:contents;">
                <input type="hidden" name="propiedadId" value="${prop.id}">
                <button type="submit" class="lv-fav" title="Guardar">
                  <i class="fas fa-heart"></i>
                </button>
              </form>
            </c:if>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">${prop.tipo}</div>
            <div class="lv-card__titulo">${prop.titulo}</div>
            <div class="lv-card__loc">
              <i class="fas fa-map-marker-alt"></i>
              <c:if test="${not empty prop.barrio}">${prop.barrio}, </c:if>${prop.ciudad}
            </div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <c:if test="${prop.habitaciones > 0}">
                <span class="lv-feat"><i class="fas fa-bed"></i> ${prop.habitaciones} hab.</span>
              </c:if>
              <c:if test="${prop.banos > 0}">
                <span class="lv-feat"><i class="fas fa-bath"></i> ${prop.banos} baños</span>
              </c:if>
              <c:if test="${not empty prop.area}">
                <span class="lv-feat">
                  <i class="fas fa-ruler-combined"></i>
                  <fmt:formatNumber value="${prop.area}" maxFractionDigits="0"/>m²
                </span>
              </c:if>
              <c:if test="${prop.garaje}">
                <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
              </c:if>
            </div>
            <div class="lv-card__foot">
              <div>
                <div class="lv-precio-val">
                  $<fmt:formatNumber value="${prop.precio}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                </div>
                <div class="lv-precio-lbl">COP${prop.operacion == 'arriendo' ? ' / MES' : ''}</div>
              </div>
              <a href="${ctx}/detalle.jsp?id=${prop.id}" class="lv-card__cta">
                <i class="fas fa-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
        </c:forEach>
      </c:when>

      <%-- ── DEMO (sin BD) ── --%>
      <c:otherwise>

        <%-- Macro de card demo como JSP include sería ideal, pero usamos repetición directa --%>

        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="420000000" data-area="180">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=700&q=80" alt="Casa Cabecera" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Moderna en Cabecera</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 180m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$420.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=1" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="280000000" data-area="110">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=700&q=80" alt="Apto Lagos" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apto Exclusivo Lagos del Cacique</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Lagos del Cacique, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 110m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$280.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=2" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="arriendo" data-tipo="oficina" data-precio="2800000" data-area="65">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1497366216548-37526070297c?w=700&q=80" alt="Oficina" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 4</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Oficina</div>
            <div class="lv-card__titulo">Oficina Centro Empresarial</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Centro, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 65m²</span>
              <span class="lv-feat"><i class="fas fa-wifi"></i> Fibra óptica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$2.800.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=3" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="950000000" data-area="320">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=700&q=80" alt="Casa Campestre" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 12</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Campestre Floridablanca</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Floridablanca, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 320m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$950.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=4" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="1500000" data-area="75">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1560184897-ae75f418493e?w=700&q=80" alt="Apto Amoblado" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Amoblado Sotomayor</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Sotomayor, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 75m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=5" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="penthouse" data-precio="680000000" data-area="250">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=700&q=80" alt="Penthouse" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 10</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Penthouse</div>
            <div class="lv-card__titulo">Penthouse Vista Panorámica BGA</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Norte, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 250m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$680.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=6" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="380000000" data-area="145">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=700&q=80" alt="Casa Girón" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Conjunto Cerrado Girón</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Girón, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 145m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$380.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=7" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="3500000" data-area="90">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=700&q=80" alt="Apto El Jardín" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Nuevo El Jardín</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> El Jardín, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 90m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$3.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=8" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="terreno" data-precio="550000000" data-area="800">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=700&q=80" alt="Terreno" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 3</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Terreno</div>
            <div class="lv-card__titulo">Terreno Urbanizable Piedecuesta</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Piedecuesta, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 800m²</span>
              <span class="lv-feat"><i class="fas fa-water"></i> Servicios</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$550.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=9" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="arriendo" data-tipo="local" data-precio="4200000" data-area="120">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=700&q=80" alt="Local Comercial" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 4</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Local</div>
            <div class="lv-card__titulo">Local Comercial Vía Principal</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 120m²</span>
              <span class="lv-feat"><i class="fas fa-store"></i> Vitrina doble</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$4.200.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=10" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="195000000" data-area="68">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=700&q=80" alt="Apto VIS" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento VIS Morrorico</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Morrorico, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 68m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$195.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=11" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="1200000000" data-area="450">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=700&q=80" alt="Mansión" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 15</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Mansión Exclusiva Lagos del Cacique</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Lagos del Cacique, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 6 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 5 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 450m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 3 Garajes</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.200.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=12" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>


        <%-- 13 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="320000000" data-area="95">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=700&q=80" alt="Apto Cañaveral" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Cañaveral con Piscina</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cañaveral, Floridablanca</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 95m²</span>
              <span class="lv-feat"><i class="fas fa-water"></i> Piscina</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$320.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=13" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 14 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="oficina" data-precio="5800000" data-area="200">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=700&q=80" alt="Piso Corporativo" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 9</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Oficina</div>
            <div class="lv-card__titulo">Piso Corporativo Torre Empresarial</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Zona Rosa, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 200m²</span>
              <span class="lv-feat"><i class="fas fa-wifi"></i> Fibra 1Gbps</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 4 parqueaderos</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$5.800.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=14" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 15 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="750000000" data-area="380">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=700&q=80" alt="Casa Lujo" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 14</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa de Lujo Sector Chico BGA</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> El Chico, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 380m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 2 Garajes</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$750.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=15" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 16 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="2200000" data-area="55">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=700&q=80" alt="Estudio" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 4</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Estudio Amoblado Centro Histórico</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Centro Histórico, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 1 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 55m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$2.200.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=16" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 17 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="finca" data-precio="1500000000" data-area="1200">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=700&q=80" alt="Finca" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 18</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Finca</div>
            <div class="lv-card__titulo">Finca de Recreo Río de Oro</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Río de Oro, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 6 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 1.200m²</span>
              <span class="lv-feat"><i class="fas fa-tree"></i> Jardín amplio</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.500.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=17" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 18 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="460000000" data-area="160">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=700&q=80" alt="Casa Condominio" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 10</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Condominio Campestre Piedecuesta</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Piedecuesta, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 160m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje doble</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$460.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=18" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 19 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="890000000" data-area="290">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=700&q=80" alt="Casa Premium" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 13</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Premium Urbanización El Bosque</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> El Bosque, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 290m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 2 Garajes</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$890.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=19" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 20 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="local" data-precio="6500000" data-area="350">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=700&q=80" alt="Bodega" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Local</div>
            <div class="lv-card__titulo">Bodega-Local Industrial Girón</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Zona Industrial, Girón</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 350m²</span>
              <span class="lv-feat"><i class="fas fa-truck"></i> Zona de cargue</span>
              <span class="lv-feat"><i class="fas fa-bolt"></i> Trifásica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$6.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=20" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 21 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="235000000" data-area="78">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1554995207-c18c203602cb?w=700&q=80" alt="Apto Moderno" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apto Moderno Sector Universitario UIS</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Sector UIS, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 78m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$235.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=21" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 22 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="1800000" data-area="50">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=700&q=80" alt="Apartaestudio" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 3</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartaestudio Amoblado Girardot</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Girardot, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 1 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 50m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.800.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=22" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 23 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="terreno" data-precio="980000000" data-area="2000">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=700&q=80" alt="Lote Grande" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Terreno</div>
            <div class="lv-card__titulo">Lote Proyecto Urbanístico Lebrija</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Lebrija, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 2.000m²</span>
              <span class="lv-feat"><i class="fas fa-road"></i> Vía pavimentada</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$980.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=23" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 24 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="530000000" data-area="205">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=700&q=80" alt="Casa Contemporánea" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 11</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Arquitectura Contemporánea Provenza</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Provenza, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 205m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$530.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=24" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 25 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="local" data-precio="4800000" data-area="140">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=700&q=80" alt="Local Mall" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Local</div>
            <div class="lv-card__titulo">Local en Centro Comercial Cacique</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> CC Cacique, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 140m²</span>
              <span class="lv-feat"><i class="fas fa-users"></i> Alto tráfico</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$4.800.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=25" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 26 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="410000000" data-area="130">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=700&q=80" alt="Apto Piso Alto" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 9</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento de Lujo Piso 18</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 130m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 2 parqueaderos</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$410.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=26" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 27 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="edificio" data-precio="2600000000" data-area="5000">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?w=700&q=80" alt="Hotel Boutique" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 22</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Edificio</div>
            <div class="lv-card__titulo">Hotel Boutique en Venta — Centro BGA</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Centro, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-door-open"></i> 24 habitaciones</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 5.000m²</span>
              <span class="lv-feat"><i class="fas fa-utensils"></i> Restaurante</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$2.600.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=27" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 28 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="3200000" data-area="82">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1484154218962-a197022b5858?w=700&q=80" alt="Apto Remodelado" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Remodelado Altos del Poblado</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Altos del Poblado, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 82m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$3.200.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=28" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 29 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="620000000" data-area="240">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=700&q=80" alt="Casa Prado" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 12</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Tradicional Sector Prado</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Prado, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 240m²</span>
              <span class="lv-feat"><i class="fas fa-tree"></i> Jardín</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$620.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=29" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 30 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="oficina" data-precio="9500000" data-area="420">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=700&q=80" alt="Sede Empresarial" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 10</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Oficina</div>
            <div class="lv-card__titulo">Sede Empresarial Completa Zona Norte</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Zona Norte, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 420m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 10 parqueaderos</span>
              <span class="lv-feat"><i class="fas fa-wifi"></i> Fibra óptica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$9.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=30" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 31 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="345000000" data-area="102">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=700&q=80" alt="Apto Confort" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Confort Sector Ricaurte</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Ricaurte, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 102m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$345.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=31" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 32 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="2900000" data-area="88">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1615873968403-89e068629265?w=700&q=80" alt="Apto Amoblado" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apto Amoblado Frente al Parque</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Mejoras Públicas, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 88m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$2.900.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=32" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 33 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="1100000000" data-area="400">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=700&q=80" alt="Villa" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 17</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Villa con Piscina y Cancha — Floridablanca</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Villabel, Floridablanca</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 6 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 5 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 400m²</span>
              <span class="lv-feat"><i class="fas fa-water"></i> Piscina</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.100.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=33" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 34 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="175000000" data-area="62">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=700&q=80" alt="Casa VIS" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa VIS Conjunto La Arboleda</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> La Arboleda, Girón</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 62m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$175.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=34" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 35 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="oficina" data-precio="7200000" data-area="280">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=700&q=80" alt="Clínica" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Oficina</div>
            <div class="lv-card__titulo">Sede Clínica u Odontológica Equipada</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 280m²</span>
              <span class="lv-feat"><i class="fas fa-procedures"></i> Consultorios</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Parqueaderos</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$7.200.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=35" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 36 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="490000000" data-area="175">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=700&q=80" alt="Casa Moderna" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 11</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Remodelada Conjunto Lagos</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Lagos del Cacique, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 175m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$490.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=36" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 37 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="terreno" data-precio="730000000" data-area="600">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1503174971373-b1f69850bded?w=700&q=80" alt="Terreno Comercial" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 4</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Terreno</div>
            <div class="lv-card__titulo">Lote Comercial Vía a Piedecuesta</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Anillo Vial, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 600m²</span>
              <span class="lv-feat"><i class="fas fa-road"></i> Doble vía</span>
              <span class="lv-feat"><i class="fas fa-city"></i> Uso mixto</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$730.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=37" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 38 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="1600000" data-area="44">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=700&q=80" alt="Habitación" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 3</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartaestudio Estudiantil Bucarica</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Bucarica, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 1 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 44m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.600.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=38" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 39 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="850000000" data-area="310">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=700&q=80" alt="Casa Club" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 15</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Club House — Conjunto Privado</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Bello Horizonte, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 310m²</span>
              <span class="lv-feat"><i class="fas fa-dumbbell"></i> Gym</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$850.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=39" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 40 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="3800000" data-area="115">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=700&q=80" alt="Duplex" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 9</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Dúplex Estilo Loft — Zona Rosa</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Zona Rosa, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 115m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$3.800.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=40" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 41 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="590000000" data-area="220">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=700&q=80" alt="Casa Barrio" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 10</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Amplia Sector Álamos</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Álamos, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 220m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje doble</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$590.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=41" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 42 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="oficina" data-precio="5200000" data-area="180">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=700&q=80" alt="Coworking" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Oficina</div>
            <div class="lv-card__titulo">Espacio Coworking Premium</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Sotomayor, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 180m²</span>
              <span class="lv-feat"><i class="fas fa-users"></i> 30 puestos</span>
              <span class="lv-feat"><i class="fas fa-wifi"></i> Fibra óptica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$5.200.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=42" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 43 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="260000000" data-area="85">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=700&q=80" alt="Apto VIS" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Nuevo Entrega Inmediata</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Café Madrid, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 85m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$260.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=43" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 44 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="edificio" data-precio="3300000000" data-area="8000">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1486325212027-8081e485255e?w=700&q=80" alt="Edificio" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 25</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Edificio</div>
            <div class="lv-card__titulo">Edificio Completo para Inversión</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-layer-group"></i> 12 pisos</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 8.000m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 40 parqueaderos</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$3.300.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=44" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 45 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="casa" data-precio="4100000" data-area="145">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=700&q=80" alt="Casa Arriendo" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Bifamiliar Sector Manga</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> La Manga, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 145m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> Garaje</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$4.100.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=45" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 46 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="660000000" data-area="260">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600673132756-6d6a7b0b81ee?w=700&q=80" alt="Casa Golf" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 14</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Frente al Parque Estadio</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Estadio, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 5 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 4 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 260m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 2 Garajes</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$660.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=46" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 47 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="215000000" data-area="70">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=700&q=80" alt="Apto Estrenar" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Para Estrenar — Sur BGA</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Sur, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 70m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$215.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=47" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 48 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="local" data-precio="8900000" data-area="500">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1581093196277-9f608bb3b511?w=700&q=80" alt="Bodega Grande" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Local</div>
            <div class="lv-card__titulo">Bodega Industrial Parque Tecnológico</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Parque Tec., Piedecuesta</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 500m²</span>
              <span class="lv-feat"><i class="fas fa-snowflake"></i> Cuarto frío</span>
              <span class="lv-feat"><i class="fas fa-bolt"></i> Trifásica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$8.900.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=48" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 49 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="1350000000" data-area="520">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=700&q=80" alt="Casa Ultra Lujo" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 20</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Residencia Ultra Lujo — Los Pinos</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Los Pinos, Floridablanca</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 7 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 6 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 520m²</span>
              <span class="lv-feat"><i class="fas fa-water"></i> Piscina</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.350.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=49" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 50 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="2500000" data-area="60">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=700&q=80" alt="Apto Ejecutivo" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Ejecutivo Amoblado</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 1 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 1 baño</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 60m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$2.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=50" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 51 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="finca" data-precio="1800000000" data-area="3500">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1464082354059-27db6ce50048?w=700&q=80" alt="Hacienda" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 24</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Finca</div>
            <div class="lv-card__titulo">Hacienda Ganadera — San Gil</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> San Gil, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 3.500m²</span>
              <span class="lv-feat"><i class="fas fa-tractor"></i> Maquinaria</span>
              <span class="lv-feat"><i class="fas fa-tree"></i> Bosque nativo</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$1.800.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=51" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 52 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="375000000" data-area="118">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=700&q=80" alt="Apto Balcón" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 9</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento con Balcón Vista Ciudad</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Terrazas, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 118m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$375.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=52" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 53 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="local" data-precio="6000000" data-area="230">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1555636222-cae831e670b3?w=700&q=80" alt="Restaurant" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 8</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Local</div>
            <div class="lv-card__titulo">Local Gastronómico con Terraza</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> La Concordia, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 230m²</span>
              <span class="lv-feat"><i class="fas fa-chair"></i> 80 puestos</span>
              <span class="lv-feat"><i class="fas fa-fire"></i> Cocina equipada</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$6.000.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=53" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 54 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="440000000" data-area="155">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1600047508788-786f3865b29c?w=700&q=80" alt="Casa Norte" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 11</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Norte con Terraza y BBQ</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Norte, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 155m²</span>
              <span class="lv-feat"><i class="fas fa-fire"></i> BBQ</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$440.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=54" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 55 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="apartamento" data-precio="310000000" data-area="92">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=700&q=80" alt="Apto Conjunto" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 7</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apto Conjunto Cerrado El Campestre</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> El Campestre, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 2 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 92m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$310.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=55" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 56 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="terreno" data-precio="420000000" data-area="1500">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=700&q=80" alt="Lote Rural" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 5</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Terreno</div>
            <div class="lv-card__titulo">Lote con Nacedero de Agua</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Vía Guane, Santander</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 1.500m²</span>
              <span class="lv-feat"><i class="fas fa-tint"></i> Agua propia</span>
              <span class="lv-feat"><i class="fas fa-mountain"></i> Vista panorámica</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$420.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=56" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 57 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="casa" data-precio="4500000" data-area="160">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80" alt="Casa Arriendo Lujo" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 10</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa de Lujo Amoblada Mensual</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Cabecera, Bucaramanga</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 160m²</span>
              <span class="lv-feat"><i class="fas fa-couch"></i> Amoblada</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$4.500.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=57" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 58 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="casa" data-precio="570000000" data-area="210">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1570010589765-3c68e430f7d5?w=700&q=80" alt="Casa Conjunto Premium" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 13</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Casa</div>
            <div class="lv-card__titulo">Casa Conjunto Premium Santa Barbara</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Santa Bárbara, Floridablanca</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 4 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 3 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 210m²</span>
              <span class="lv-feat"><i class="fas fa-shield-alt"></i> Vigilancia 24h</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$570.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=58" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 59 --%>
        <div class="lv-card" data-operacion="arriendo" data-tipo="apartamento" data-precio="3000000" data-area="100">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=700&q=80" alt="Apto Familia" loading="lazy">
            <span class="lv-badge lv-badge--arriendo">arriendo</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 6</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Apartamento</div>
            <div class="lv-card__titulo">Apartamento Familiar Sector Toscana</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Toscana, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-bed"></i> 3 hab.</span>
              <span class="lv-feat"><i class="fas fa-bath"></i> 2 baños</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 100m²</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$3.000.000</div><div class="lv-precio-lbl">COP / MES</div></div>
              <a href="${ctx}/detalle.jsp?id=59" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>

        <%-- 60 --%>
        <div class="lv-card" data-operacion="venta" data-tipo="edificio" data-precio="4000000000" data-area="12000">
          <div class="lv-card__shine"></div>
          <div class="lv-card__img">
            <img src="https://images.unsplash.com/photo-1486325212027-8081e485255e?w=700&q=80" alt="Centro Comercial" loading="lazy">
            <span class="lv-badge lv-badge--venta">venta</span>
            <span class="lv-photo-count"><i class="fas fa-camera"></i> 30</span>
          </div>
          <div class="lv-card__body">
            <div class="lv-card__tipo">Edificio</div>
            <div class="lv-card__titulo">Plaza Comercial — Inversión Estratégica</div>
            <div class="lv-card__loc"><i class="fas fa-map-marker-alt"></i> Vía Floridablanca, BGA</div>
            <div class="lv-card__sep"></div>
            <div class="lv-card__feats">
              <span class="lv-feat"><i class="fas fa-store"></i> 45 locales</span>
              <span class="lv-feat"><i class="fas fa-ruler-combined"></i> 12.000m²</span>
              <span class="lv-feat"><i class="fas fa-car"></i> 200 parqueaderos</span>
            </div>
            <div class="lv-card__foot">
              <div><div class="lv-precio-val">$4.000.000.000</div><div class="lv-precio-lbl">COP</div></div>
              <a href="${ctx}/detalle.jsp?id=60" class="lv-card__cta"><i class="fas fa-arrow-right"></i></a>
            </div>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- ══ PAGINACIÓN ══ -->
  <c:if test="${not empty propiedades and fn:length(propiedades) >= 9}">
    <div class="lv-pagination">
      <a href="#" class="lv-page disabled"><i class="fas fa-chevron-left"></i></a>
      <a href="#" class="lv-page active">1</a>
      <a href="#" class="lv-page">2</a>
      <a href="#" class="lv-page">3</a>
      <span style="color:rgba(255,255,255,0.2);padding:0 4px;">…</span>
      <a href="#" class="lv-page">8</a>
      <a href="#" class="lv-page"><i class="fas fa-chevron-right"></i></a>
    </div>
  </c:if>

</div><%-- fin #lista-universe --%>

<%@ include file="footer.jsp" %>

<script>
/* ══════════════════════════════════════════
   PARTÍCULAS
══════════════════════════════════════════ */
(function() {
  const cv = document.getElementById('particleCanvas');
  const ctx = cv.getContext('2d');
  let W, H, pts = [], tick = 0;
  const mouse = { x: -999, y: -999 };

  function resize() {
    W = cv.width = window.innerWidth;
    H = cv.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize);
  window.addEventListener('mousemove', e => { mouse.x = e.clientX; mouse.y = e.clientY; });

  class Particle {
    constructor() { this.reset(true); }
    reset(init) {
      this.x  = Math.random() * (W || window.innerWidth);
      this.y  = init ? Math.random() * (H || window.innerHeight) : (H || window.innerHeight) + 10;
      this.vx = (Math.random() - 0.5) * 0.3;
      this.vy = -(Math.random() * 0.5 + 0.1);
      this.r  = Math.random() * 1.6 + 0.3;
      this.alpha = Math.random() * 0.5 + 0.08;
      this.gold = Math.random() > 0.65;
      this.pulse = Math.random() * Math.PI * 2;
    }
    update() {
      // Mouse repulsion
      const dx = this.x - mouse.x, dy = this.y - mouse.y;
      const dist = Math.sqrt(dx*dx + dy*dy);
      if (dist < 100) {
        const f = (100 - dist) / 100 * 0.5;
        this.vx += (dx / dist) * f;
        this.vy += (dy / dist) * f;
      }
      this.vx *= 0.98; this.vy *= 0.98;
      this.x += this.vx; this.y += this.vy;
      this.pulse += 0.015;
      if (this.y < -10 || this.x < -10 || this.x > W + 10) this.reset(false);
    }
    draw() {
      const a = this.alpha + Math.sin(this.pulse) * 0.08;
      const r = this.r + Math.sin(this.pulse) * 0.25;
      ctx.beginPath();
      ctx.arc(this.x, this.y, r, 0, Math.PI * 2);
      ctx.fillStyle = this.gold
        ? `rgba(201,168,76,${a})`
        : `rgba(180,180,220,${a * 0.4})`;
      ctx.fill();
    }
  }

  // Connections
  function drawConnections() {
    const MAX = 110;
    for (let i = 0; i < pts.length - 1; i++) {
      for (let j = i + 1; j < pts.length; j++) {
        const dx = pts[i].x - pts[j].x;
        const dy = pts[i].y - pts[j].y;
        const d = Math.sqrt(dx*dx + dy*dy);
        if (d < MAX && pts[i].gold && pts[j].gold) {
          ctx.beginPath();
          ctx.moveTo(pts[i].x, pts[i].y);
          ctx.lineTo(pts[j].x, pts[j].y);
          ctx.strokeStyle = `rgba(201,168,76,${(1 - d/MAX) * 0.12})`;
          ctx.lineWidth = 0.5;
          ctx.stroke();
        }
      }
    }
  }

  for (let i = 0; i < 110; i++) pts.push(new Particle());

  (function loop() {
    ctx.clearRect(0, 0, W, H);
    tick++;
    drawConnections();
    pts.forEach(p => { p.update(); p.draw(); });
    requestAnimationFrame(loop);
  })();
})();

/* ══════════════════════════════════════════
   CURSOR PERSONALIZADO
══════════════════════════════════════════ */
const $dot = document.getElementById('lv-cursor-dot');
const $ring = document.getElementById('lv-cursor-ring');
let mx = 0, my = 0, rx = 0, ry = 0;

document.addEventListener('mousemove', e => {
  mx = e.clientX; my = e.clientY;
  $dot.style.left = mx + 'px';
  $dot.style.top  = my + 'px';
});
(function cursorLoop() {
  rx += (mx - rx) * 0.12;
  ry += (my - ry) * 0.12;
  $ring.style.left = rx + 'px';
  $ring.style.top  = ry + 'px';
  requestAnimationFrame(cursorLoop);
})();

document.querySelectorAll('a,button,.lv-card,select,input').forEach(el => {
  el.addEventListener('mouseenter', () => {
    $ring.style.transform = 'translate(-50%,-50%) scale(2)';
    $ring.style.borderColor = 'rgba(201,168,76,0.9)';
    $dot.style.transform = 'translate(-50%,-50%) scale(0)';
  });
  el.addEventListener('mouseleave', () => {
    $ring.style.transform = 'translate(-50%,-50%) scale(1)';
    $dot.style.transform  = 'translate(-50%,-50%) scale(1)';
  });
});

/* ══════════════════════════════════════════
   REVEAL SCROLL (Intersection Observer)
══════════════════════════════════════════ */
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      const idx = Array.from(document.querySelectorAll('.lv-card'))
                       .indexOf(entry.target);
      setTimeout(() => {
        entry.target.classList.add('revealed');
      }, (idx % 3) * 80);
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.lv-card').forEach(c => revealObserver.observe(c));

/* ══════════════════════════════════════════
   EFECTO SHINE EN CARDS (mouse tracking)
══════════════════════════════════════════ */
document.querySelectorAll('.lv-card').forEach(card => {
  card.addEventListener('mousemove', e => {
    const r = card.getBoundingClientRect();
    const x = ((e.clientX - r.left) / r.width  * 100).toFixed(1) + '%';
    const y = ((e.clientY - r.top)  / r.height * 100).toFixed(1) + '%';
    card.querySelector('.lv-card__shine').style.setProperty('--mx', x);
    card.querySelector('.lv-card__shine').style.setProperty('--my', y);
  });
});

/* ══════════════════════════════════════════
   VISTA GRID / LISTA
══════════════════════════════════════════ */
function setView(type) {
  const grid = document.getElementById('propiedadesGrid');
  const btnG = document.getElementById('btnGrid');
  const btnL = document.getElementById('btnList');
  if (type === 'list') {
    grid.classList.add('list-view');
    btnL.classList.add('active'); btnG.classList.remove('active');
  } else {
    grid.classList.remove('list-view');
    btnG.classList.add('active'); btnL.classList.remove('active');
  }
}

/* ══════════════════════════════════════════
   FILTRAR (cliente-side para modo demo)
══════════════════════════════════════════ */
function applyClientFilters() {
  const grid = document.getElementById('propiedadesGrid');
  if (!grid) return;
  const operacion = document.getElementById('f-operacion') ? document.getElementById('f-operacion').value.toLowerCase() : '';
  const tipo      = document.getElementById('f-tipo')      ? document.getElementById('f-tipo').value.toLowerCase()      : '';
  const ciudad    = document.getElementById('f-ciudad')    ? document.getElementById('f-ciudad').value.toLowerCase()    : '';
  const pMin      = parseFloat(document.getElementById('f-pmin')?.value) || 0;
  const pMax      = parseFloat(document.getElementById('f-pmax')?.value) || Infinity;

  let visible = 0;
  grid.querySelectorAll('.lv-card').forEach(card => {
    const op  = (card.dataset.operacion || '').toLowerCase();
    const tp  = (card.dataset.tipo      || '').toLowerCase();
    const loc = (card.dataset.ciudad    || card.querySelector('.lv-card__loc')?.textContent || '').toLowerCase();
    const pr  = parseFloat(card.dataset.precio) || 0;

    const okOp  = !operacion || op === operacion;
    const okTp  = !tipo      || tp.includes(tipo);
    const okLoc = !ciudad    || loc.includes(ciudad);
    const okPr  = pr >= pMin && pr <= pMax;

    const show = okOp && okTp && okLoc && okPr;
    card.style.display = show ? '' : 'none';
    if (show) visible++;
  });

  // Update counter
  const counter = document.querySelector('.lv-controls__count em');
  if (counter) counter.textContent = visible;
}

/* ══════════════════════════════════════════
   ORDENAR
══════════════════════════════════════════ */
function sortCards(by) {
  const grid = document.getElementById('propiedadesGrid');
  const items = Array.from(grid.querySelectorAll('.lv-card'));
  items.sort((a, b) => {
    const pA = parseFloat(a.dataset.precio) || 0;
    const pB = parseFloat(b.dataset.precio) || 0;
    const aA = parseFloat(a.dataset.area) || 0;
    const aB = parseFloat(b.dataset.area) || 0;
    if (by === 'precio_asc')  return pA - pB;
    if (by === 'precio_desc') return pB - pA;
    if (by === 'area')        return aB - aA;
    return 0;
  });
  items.forEach(c => grid.appendChild(c));
}

/* ══════════════════════════════════════════
   QUITAR FILTRO
══════════════════════════════════════════ */
function removeFilter(name) {
  const url = new URL(window.location.href);
  url.searchParams.delete(name);
  window.location.href = url.toString();
}

/* ══════════════════════════════════════════
   FAVORITOS (toggle visual)
══════════════════════════════════════════ */
document.querySelectorAll('.lv-fav').forEach(btn => {
  btn.addEventListener('click', function(e) {
    e.preventDefault();
    this.classList.toggle('active');
  });
});
</script>
