<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Inicio" scope="request"/>
<%@ include file="header.jsp" %>

<!-- ============================================================
     INDEX.JSP — InmoVista  |  Diseño Cinematográfico Premium
     ============================================================ -->
<style>
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,700;1,300;1,400&family=Outfit:wght@200;300;400;500;600;700&display=swap');

:root {
  --ink:      #0a0a0f;
  --ink-2:    #111118;
  --gold:     #c9a84c;
  --gold-g:   #e8c96b;
  --gold-dim: rgba(201,168,76,0.15);
  --line:     rgba(201,168,76,0.2);
  --smoke:    rgba(255,255,255,0.04);
  --ease:     cubic-bezier(0.16, 1, 0.3, 1);
  --r:        16px;
}

/* ── CURSOR ── */
#cdot,#cring{position:fixed;pointer-events:none;border-radius:50%;z-index:9999;}
#cdot{width:8px;height:8px;background:var(--gold);margin:-4px 0 0 -4px;transition:transform .15s var(--ease);mix-blend-mode:difference;}
#cring{width:36px;height:36px;border:1px solid var(--gold);margin:-18px 0 0 -18px;opacity:.6;transition:all .35s var(--ease);}

/* ── PARTÍCULAS ── */
#pcanvas{position:fixed;inset:0;pointer-events:none;z-index:0;opacity:.5;}

/* ══ HERO ══ */
.hero{min-height:100svh;background:var(--ink);position:relative;overflow:hidden;display:flex;align-items:center;}
.hero__bg{position:absolute;inset:-8%;background:url('https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=2000&q=85') center/cover;opacity:.18;transform:scale(1.08);transition:transform 8s var(--ease);}
.hero__bg.go{transform:scale(1);}
.hero__grad{position:absolute;inset:0;background:radial-gradient(ellipse 80% 60% at 18% 50%,rgba(10,10,15,.93) 30%,transparent 80%),linear-gradient(180deg,rgba(10,10,15,.55),rgba(10,10,15,.88));}
.hero__vline{position:absolute;left:5%;top:15%;bottom:15%;width:1px;background:linear-gradient(180deg,transparent,var(--gold),transparent);opacity:0;animation:lreveal 1.4s .8s var(--ease) forwards;}
.hero__wm{position:absolute;right:-2%;bottom:-5%;font-family:'Cormorant Garamond',serif;font-size:clamp(12rem,22vw,28rem);font-weight:700;color:transparent;-webkit-text-stroke:1px rgba(201,168,76,.06);line-height:1;user-select:none;}
.hero__body{position:relative;z-index:2;padding-left:8%;max-width:780px;}

.h-tag{display:inline-flex;align-items:center;gap:10px;font-family:'Outfit',sans-serif;font-size:.72rem;font-weight:600;letter-spacing:3px;text-transform:uppercase;color:var(--gold);margin-bottom:28px;opacity:0;transform:translateY(16px);animation:fup .9s .3s var(--ease) forwards;}
.h-tag::before{content:'';width:40px;height:1px;background:var(--gold);}
.h-title{font-family:'Cormorant Garamond',serif;font-size:clamp(3.5rem,7vw,6.5rem);font-weight:300;line-height:1.05;color:#fff;margin-bottom:28px;opacity:0;transform:translateY(24px);animation:fup 1s .5s var(--ease) forwards;}
.h-title em{font-style:italic;color:var(--gold);font-weight:400;}
.h-title strong{font-weight:700;display:block;}
.h-sub{font-family:'Outfit',sans-serif;font-size:1rem;font-weight:300;color:rgba(255,255,255,.5);line-height:1.7;max-width:480px;margin-bottom:44px;opacity:0;transform:translateY(20px);animation:fup 1s .7s var(--ease) forwards;}

/* buscador hero */
.h-search{max-width:620px;background:rgba(255,255,255,.04);border:1px solid var(--line);border-radius:14px;overflow:hidden;backdrop-filter:blur(20px);opacity:0;transform:translateY(20px);animation:fup 1s .9s var(--ease) forwards;}
.h-stabs{display:flex;}
.h-stab{flex:1;padding:12px 8px;text-align:center;font-family:'Outfit',sans-serif;font-size:.78rem;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:rgba(255,255,255,.35);cursor:pointer;transition:all .3s;border-bottom:2px solid transparent;}
.h-stab.on{color:var(--gold);border-bottom-color:var(--gold);background:var(--gold-dim);}
.h-sbody{border-top:1px solid var(--line);padding:18px 20px;display:flex;gap:12px;align-items:center;flex-wrap:wrap;}
.h-sbody select,.h-sbody input[type=text]{background:transparent;border:none;border-bottom:1px solid rgba(255,255,255,.12);color:#fff;font-family:'Outfit',sans-serif;font-size:.85rem;padding:6px 0;outline:none;flex:1;min-width:120px;}
.h-sbody select option{background:var(--ink-2);}
.h-sbtn{background:var(--gold);color:var(--ink);border:none;padding:10px 24px;border-radius:8px;font-family:'Outfit',sans-serif;font-weight:700;font-size:.85rem;cursor:pointer;transition:all .3s var(--ease);white-space:nowrap;}
.h-sbtn:hover{background:var(--gold-g);transform:translateY(-1px);box-shadow:0 8px 24px rgba(201,168,76,.4);}

/* stats hero */
.h-stats{display:flex;gap:36px;margin-top:40px;opacity:0;animation:fup 1s 1.1s var(--ease) forwards;flex-wrap:wrap;}
.hs-num{font-family:'Cormorant Garamond',serif;font-size:2.4rem;font-weight:700;color:var(--gold);line-height:1;}
.hs-lbl{font-family:'Outfit',sans-serif;font-size:.7rem;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,.3);margin-top:4px;}
.hs-sep{width:1px;background:var(--line);align-self:stretch;}

/* scroll hint */
.h-scroll{position:absolute;bottom:36px;left:50%;transform:translateX(-50%);display:flex;flex-direction:column;align-items:center;gap:8px;opacity:0;animation:fin 1s 1.4s ease forwards;}
.h-scroll span{font-family:'Outfit',sans-serif;font-size:.65rem;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,.25);}
.h-scroll-line{width:1px;height:48px;background:linear-gradient(180deg,var(--gold),transparent);animation:spulse 2s ease infinite;}

@keyframes lreveal{to{opacity:.5;}}
@keyframes fup{to{opacity:1;transform:translateY(0);}}
@keyframes fin{to{opacity:1;}}
@keyframes spulse{0%,100%{opacity:.3;}50%{opacity:1;}}

/* ══ TICKER ══ */
.ticker{background:var(--gold);padding:14px 0;overflow:hidden;white-space:nowrap;}
.ticker-t{display:inline-flex;animation:tmove 30s linear infinite;}
.ticker-t:hover{animation-play-state:paused;}
.ticker-i{font-family:'Outfit',sans-serif;font-size:.78rem;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:var(--ink);padding:0 32px;}
.ticker-i i{margin-right:8px;opacity:.6;}
.ticker-dot{color:rgba(10,10,15,.3);font-size:1.2rem;vertical-align:middle;}
@keyframes tmove{from{transform:translateX(0);}to{transform:translateX(-50%);}}

/* ══ CATS ══ */
.s-cats{background:var(--ink-2);padding:100px 0;position:relative;}
.s-cats::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,var(--gold),transparent);}
.eyebrow{font-family:'Outfit',sans-serif;font-size:.7rem;font-weight:600;letter-spacing:4px;text-transform:uppercase;color:var(--gold);margin-bottom:12px;}
.s-head{font-family:'Cormorant Garamond',serif;font-size:clamp(2.2rem,4vw,3.6rem);font-weight:300;color:#fff;line-height:1.15;}
.s-head em{color:var(--gold);font-style:italic;}
.cat-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-top:56px;}
@media(max-width:900px){.cat-grid{grid-template-columns:repeat(3,1fr);}}
@media(max-width:600px){.cat-grid{grid-template-columns:repeat(2,1fr);}}
.ccat{position:relative;aspect-ratio:3/4;border-radius:var(--r);overflow:hidden;cursor:pointer;transform-style:preserve-3d;transition:transform .4s var(--ease),box-shadow .4s;border:1px solid var(--line);text-decoration:none;display:block;}
.ccat img{width:100%;height:100%;object-fit:cover;transition:transform .7s var(--ease);filter:brightness(.55) saturate(.8);}
.ccat:hover img{transform:scale(1.1);filter:brightness(.7);}
.ccat__ov{position:absolute;inset:0;background:linear-gradient(180deg,transparent 40%,rgba(10,10,15,.95));}
.ccat__body{position:absolute;bottom:0;left:0;right:0;padding:22px 18px;transform:translateY(8px);transition:transform .4s var(--ease);}
.ccat:hover .ccat__body{transform:translateY(0);}
.ccat__ico{width:42px;height:42px;background:var(--gold-dim);border:1px solid var(--line);border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--gold);font-size:1rem;margin-bottom:10px;backdrop-filter:blur(8px);}
.ccat__name{font-family:'Outfit',sans-serif;font-weight:600;font-size:.95rem;color:#fff;}
.ccat__hint{font-family:'Outfit',sans-serif;font-size:.75rem;color:var(--gold);margin-top:2px;opacity:0;transform:translateY(6px);transition:all .3s .1s;}
.ccat:hover .ccat__hint{opacity:1;transform:translateY(0);}
.ccat__shine{position:absolute;inset:0;background:radial-gradient(circle at var(--mx,50%) var(--my,50%),rgba(201,168,76,.12) 0%,transparent 60%);opacity:0;transition:opacity .3s;pointer-events:none;}
.ccat:hover .ccat__shine{opacity:1;}

/* ══ PROPS ══ */
.s-props{background:#0d0d14;padding:100px 0;}
.props-hd{display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:52px;flex-wrap:wrap;gap:20px;}
.f-btns{display:flex;gap:8px;flex-wrap:wrap;}
.fbtn{font-family:'Outfit',sans-serif;font-size:.75rem;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;padding:8px 18px;border-radius:30px;border:1px solid rgba(255,255,255,.1);color:rgba(255,255,255,.4);background:transparent;cursor:pointer;transition:all .25s;}
.fbtn.on,.fbtn:hover{background:var(--gold-dim);border-color:var(--gold);color:var(--gold);}
.pgrid{display:grid;grid-template-columns:repeat(3,1fr);gap:22px;}
@media(max-width:900px){.pgrid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:600px){.pgrid{grid-template-columns:1fr;}}
.pcard{background:var(--smoke);border:1px solid var(--line);border-radius:var(--r);overflow:hidden;transition:all .4s var(--ease);}
.pcard:hover{transform:translateY(-6px);border-color:rgba(201,168,76,.45);box-shadow:0 24px 60px rgba(0,0,0,.5);}
.pcard__img{position:relative;aspect-ratio:4/3;overflow:hidden;}
.pcard__img img{width:100%;height:100%;object-fit:cover;transition:transform .7s var(--ease);}
.pcard:hover .pcard__img img{transform:scale(1.06);}
.pbadge{position:absolute;top:14px;left:14px;font-family:'Outfit',sans-serif;font-size:.65rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:5px 12px;border-radius:20px;}
.pbadge.venta{background:rgba(201,168,76,.9);color:var(--ink);}
.pbadge.arriendo{background:rgba(41,182,246,.85);color:#fff;}
.pfav{position:absolute;top:14px;right:14px;width:34px;height:34px;background:rgba(10,10,15,.6);border:1px solid var(--line);border-radius:50%;display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,.4);cursor:pointer;transition:all .25s;backdrop-filter:blur(8px);}
.pfav:hover{color:#e74c3c;border-color:#e74c3c;}
.pcard__bd{padding:22px;}
.ptipo{font-family:'Outfit',sans-serif;font-size:.68rem;font-weight:700;letter-spacing:2.5px;text-transform:uppercase;color:var(--gold);margin-bottom:8px;}
.ptitle{font-family:'Cormorant Garamond',serif;font-size:1.25rem;font-weight:400;color:#fff;line-height:1.3;margin-bottom:10px;}
.ploc{font-family:'Outfit',sans-serif;font-size:.8rem;color:rgba(255,255,255,.35);display:flex;align-items:center;gap:5px;margin-bottom:16px;}
.ploc i{color:var(--gold);font-size:.7rem;}
.pfeats{display:flex;gap:14px;flex-wrap:wrap;padding:14px 0;border-top:1px solid rgba(255,255,255,.06);border-bottom:1px solid rgba(255,255,255,.06);margin-bottom:16px;}
.pfeat{font-family:'Outfit',sans-serif;font-size:.75rem;color:rgba(255,255,255,.4);display:flex;align-items:center;gap:5px;}
.pfeat i{color:var(--gold);font-size:.7rem;}
.pfoot{display:flex;justify-content:space-between;align-items:center;}
.pprice{font-family:'Cormorant Garamond',serif;font-size:1.5rem;font-weight:700;color:var(--gold);line-height:1;}
.pplbl{font-family:'Outfit',sans-serif;font-size:.68rem;color:rgba(255,255,255,.3);margin-top:2px;}
.pbtn{width:36px;height:36px;background:var(--gold-dim);border:1px solid var(--line);border-radius:50%;display:flex;align-items:center;justify-content:center;color:var(--gold);transition:all .3s var(--ease);text-decoration:none;}
.pbtn:hover{background:var(--gold);color:var(--ink);transform:rotate(45deg);box-shadow:0 6px 20px rgba(201,168,76,.4);}

/* ══ STATS ══ */
.s-stats{background:var(--ink);padding:80px 0;position:relative;overflow:hidden;}
.s-stats::before{content:'';position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:600px;height:600px;border-radius:50%;background:radial-gradient(circle,rgba(201,168,76,.06) 0%,transparent 70%);pointer-events:none;}
.sgrid{display:grid;grid-template-columns:repeat(4,1fr);gap:2px;}
@media(max-width:700px){.sgrid{grid-template-columns:repeat(2,1fr);}}
.sblk{padding:48px 32px;text-align:center;position:relative;}
.sblk:not(:last-child)::after{content:'';position:absolute;right:0;top:20%;bottom:20%;width:1px;background:var(--line);}
.snum{font-family:'Cormorant Garamond',serif;font-size:clamp(3rem,5vw,4.5rem);font-weight:700;color:var(--gold);line-height:1;display:block;}
.ssuf{font-family:'Outfit',sans-serif;font-size:1.4rem;font-weight:300;color:var(--gold);}
.slbl{font-family:'Outfit',sans-serif;font-size:.72rem;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,.3);margin-top:10px;}
.ssub{font-family:'Outfit',sans-serif;font-size:.78rem;color:rgba(255,255,255,.18);margin-top:4px;}

/* ══ WHY ══ */
.s-why{background:var(--ink-2);padding:110px 0;}
.why-lay{display:grid;grid-template-columns:1fr 1fr;gap:80px;align-items:center;}
@media(max-width:768px){.why-lay{grid-template-columns:1fr;gap:40px;}}
.why-vis{position:relative;}
.wmain{width:100%;aspect-ratio:4/5;object-fit:cover;border-radius:20px;filter:brightness(.85) saturate(.8);}
.wacc{position:absolute;width:48%;aspect-ratio:1;object-fit:cover;border-radius:14px;bottom:-5%;right:-8%;border:4px solid var(--ink-2);}
.wbadge{position:absolute;top:28px;left:-16px;background:var(--gold);color:var(--ink);padding:16px 22px;border-radius:14px;text-align:center;box-shadow:0 12px 40px rgba(201,168,76,.4);}
.wbnum{font-family:'Cormorant Garamond',serif;font-size:2.6rem;font-weight:700;line-height:1;display:block;}
.wbtxt{font-family:'Outfit',sans-serif;font-size:.65rem;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;margin-top:2px;}
.why-list{margin-top:44px;display:flex;flex-direction:column;gap:22px;}
.witem{display:flex;gap:18px;align-items:flex-start;padding:22px;border:1px solid rgba(255,255,255,.05);border-radius:12px;background:rgba(255,255,255,.02);transition:all .35s var(--ease);}
.witem:hover{border-color:var(--line);background:var(--gold-dim);transform:translateX(6px);}
.wico{width:48px;height:48px;border-radius:12px;background:var(--gold-dim);border:1px solid var(--line);display:flex;align-items:center;justify-content:center;color:var(--gold);font-size:1.1rem;flex-shrink:0;}
.wtitle{font-family:'Outfit',sans-serif;font-weight:600;font-size:.95rem;color:#fff;margin-bottom:4px;}
.wdesc{font-family:'Outfit',sans-serif;font-size:.82rem;color:rgba(255,255,255,.35);line-height:1.6;}

/* ══ TESTIMONIOS ══ */
.s-testi{background:var(--ink);padding:100px 0;overflow:hidden;}
.tt-wrap{overflow:hidden;margin-top:56px;-webkit-mask:linear-gradient(90deg,transparent 0%,black 10%,black 90%,transparent);mask:linear-gradient(90deg,transparent 0%,black 10%,black 90%,transparent);}
.tt-track{display:flex;gap:22px;animation:tscroll 35s linear infinite;width:max-content;}
.tt-track:hover{animation-play-state:paused;}
@keyframes tscroll{from{transform:translateX(0);}to{transform:translateX(-50%);}}
.tcard{flex:0 0 340px;background:rgba(255,255,255,.03);border:1px solid var(--line);border-radius:16px;padding:28px;transition:border-color .3s;}
.tcard:hover{border-color:rgba(201,168,76,.5);}
.tstars{display:flex;gap:3px;margin-bottom:16px;}
.tstar{color:var(--gold);font-size:.85rem;}
.tquote{font-family:'Cormorant Garamond',serif;font-size:1.08rem;font-style:italic;color:rgba(255,255,255,.7);line-height:1.65;margin-bottom:22px;}
.tauthor{display:flex;align-items:center;gap:12px;}
.tavatar{width:40px;height:40px;border-radius:50%;background:var(--gold-dim);border:1px solid var(--line);display:flex;align-items:center;justify-content:center;font-family:'Cormorant Garamond',serif;font-size:1rem;font-weight:700;color:var(--gold);}
.tname{font-family:'Outfit',sans-serif;font-size:.88rem;font-weight:600;color:#fff;}
.tcity{font-family:'Outfit',sans-serif;font-size:.72rem;color:rgba(255,255,255,.3);}

/* ══ CTA ══ */
.s-cta{min-height:55vh;position:relative;display:flex;align-items:center;overflow:hidden;}
.s-cta__bg{position:absolute;inset:0;background:url('https://images.unsplash.com/photo-1560184897-ae75f418493e?w=1800&q=80') center/cover;filter:brightness(.25) saturate(.5);}
.s-cta__ov{position:absolute;inset:0;background:linear-gradient(135deg,rgba(10,10,15,.9),rgba(10,10,15,.5));}
.s-cta__bd{position:relative;z-index:2;text-align:center;}
.cta-title{font-family:'Cormorant Garamond',serif;font-size:clamp(2.8rem,6vw,5rem);font-weight:300;color:#fff;line-height:1.1;margin-bottom:20px;}
.cta-title em{color:var(--gold);font-style:italic;}
.cta-sub{font-family:'Outfit',sans-serif;font-size:1rem;color:rgba(255,255,255,.45);margin-bottom:44px;max-width:500px;margin-left:auto;margin-right:auto;}
.cta-btns{display:flex;gap:16px;justify-content:center;flex-wrap:wrap;}
.cbtn-p{font-family:'Outfit',sans-serif;font-weight:700;font-size:.9rem;letter-spacing:1px;padding:16px 40px;border-radius:50px;background:var(--gold);color:var(--ink);border:none;text-decoration:none;transition:all .35s var(--ease);display:inline-flex;align-items:center;gap:10px;}
.cbtn-p:hover{background:var(--gold-g);transform:translateY(-3px);box-shadow:0 16px 44px rgba(201,168,76,.45);color:var(--ink);}
.cbtn-s{font-family:'Outfit',sans-serif;font-weight:600;font-size:.9rem;letter-spacing:1px;padding:15px 36px;border-radius:50px;background:transparent;color:rgba(255,255,255,.7);border:1px solid rgba(255,255,255,.2);text-decoration:none;transition:all .35s var(--ease);display:inline-flex;align-items:center;gap:10px;}
.cbtn-s:hover{border-color:var(--gold);color:var(--gold);transform:translateY(-2px);}

/* ── REVEAL ── */
.rv{opacity:0;transform:translateY(36px);transition:opacity .8s var(--ease),transform .8s var(--ease);}
.rv.show{opacity:1;transform:translateY(0);}
.d1{transition-delay:.1s;}.d2{transition-delay:.2s;}.d3{transition-delay:.3s;}.d4{transition-delay:.4s;}.d5{transition-delay:.5s;}
</style>

<div id="cdot"></div>
<div id="cring"></div>
<canvas id="pcanvas"></canvas>

<!-- ══ HERO ══ -->
<section class="hero">
  <div class="hero__bg" id="heroBg"></div>
  <div class="hero__grad"></div>
  <div class="hero__vline"></div>
  <div class="hero__wm">IV</div>
  <div class="container">
    <div class="hero__body">
      <div class="h-tag"><i class="fas fa-star"></i> N°1 en Inmobiliaria Digital — Bucaramanga</div>
      <h1 class="h-title">Tu próximo<br>hogar te<br><em>espera</em> <strong>aquí.</strong></h1>
      <p class="h-sub">Más de 500 propiedades verificadas. Compra, arrienda o publica con total confianza en la plataforma más elegante de Colombia.</p>

      <div class="h-search">
        <div class="h-stabs">
          <div class="h-stab on" onclick="setTab(this,'venta')">Comprar</div>
          <div class="h-stab" onclick="setTab(this,'arriendo')">Arrendar</div>
          <div class="h-stab" onclick="setTab(this,'')">Todo</div>
        </div>
        <form action="${ctx}/lista.jsp" method="get">
          <input type="hidden" name="operacion" id="tabOp" value="venta">
          <div class="h-sbody">
            <select name="tipo">
              <option value="">Tipo de inmueble</option>
              <option value="casa">Casa</option>
              <option value="apartamento">Apartamento</option>
              <option value="terreno">Terreno</option>
              <option value="oficina">Oficina</option>
              <option value="local">Local</option>
            </select>
            <input type="text" name="ciudad" placeholder="Ciudad o barrio…">
            <button type="submit" class="h-sbtn"><i class="fas fa-search me-1"></i> Buscar</button>
          </div>
        </form>
      </div>

      <div class="h-stats">
        <div><div class="hs-num">500<span style="font-size:1.5rem">+</span></div><div class="hs-lbl">Propiedades</div></div>
        <div class="hs-sep"></div>
        <div><div class="hs-num">200<span style="font-size:1.5rem">+</span></div><div class="hs-lbl">Clientes Felices</div></div>
        <div class="hs-sep"></div>
        <div><div class="hs-num">8<span style="font-size:1.5rem"> años</span></div><div class="hs-lbl">Experiencia</div></div>
      </div>
    </div>
  </div>
  <div class="h-scroll"><span>Descubrir</span><div class="h-scroll-line"></div></div>
</section>

<!-- ══ TICKER ══ -->
<div class="ticker">
  <div class="ticker-t" id="tickerT">
    <span class="ticker-i"><i class="fas fa-home"></i>Casas desde $180M</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-building"></i>Apartamentos Nuevos</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-key"></i>Arriendo desde $800K/mes</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-map-marker-alt"></i>Cabecera · Sotomayor · Lagos</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-shield-alt"></i>100% Verificadas</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-home"></i>Casas desde $180M</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-building"></i>Apartamentos Nuevos</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-key"></i>Arriendo desde $800K/mes</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-map-marker-alt"></i>Cabecera · Sotomayor · Lagos</span><span class="ticker-dot">·</span>
    <span class="ticker-i"><i class="fas fa-shield-alt"></i>100% Verificadas</span><span class="ticker-dot">·</span>
  </div>
</div>

<!-- ══ CATEGORÍAS ══ -->
<section class="s-cats">
  <div class="container">
    <div class="rv"><div class="eyebrow">Explorar por tipo</div><h2 class="s-head">¿Qué tipo de<br>propiedad <em>buscas?</em></h2></div>
    <div class="cat-grid">
      <a href="${ctx}/lista.jsp?tipo=casa" class="ccat rv d1" onmousemove="tilt(event,this)" onmouseleave="untilt(this)">
        <img src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&q=70" alt="Casas" loading="lazy">
        <div class="ccat__ov"></div><div class="ccat__shine"></div>
        <div class="ccat__body"><div class="ccat__ico"><i class="fas fa-home"></i></div><div class="ccat__name">Casas</div><div class="ccat__hint">Ver disponibles →</div></div>
      </a>
      <a href="${ctx}/lista.jsp?tipo=apartamento" class="ccat rv d2" onmousemove="tilt(event,this)" onmouseleave="untilt(this)">
        <img src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&q=70" alt="Apartamentos" loading="lazy">
        <div class="ccat__ov"></div><div class="ccat__shine"></div>
        <div class="ccat__body"><div class="ccat__ico"><i class="fas fa-building"></i></div><div class="ccat__name">Apartamentos</div><div class="ccat__hint">Ver disponibles →</div></div>
      </a>
      <a href="${ctx}/lista.jsp?tipo=terreno" class="ccat rv d3" onmousemove="tilt(event,this)" onmouseleave="untilt(this)">
        <img src="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600&q=70" alt="Terrenos" loading="lazy">
        <div class="ccat__ov"></div><div class="ccat__shine"></div>
        <div class="ccat__body"><div class="ccat__ico"><i class="fas fa-mountain"></i></div><div class="ccat__name">Terrenos</div><div class="ccat__hint">Ver disponibles →</div></div>
      </a>
      <a href="${ctx}/lista.jsp?tipo=oficina" class="ccat rv d4" onmousemove="tilt(event,this)" onmouseleave="untilt(this)">
        <img src="https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&q=70" alt="Oficinas" loading="lazy">
        <div class="ccat__ov"></div><div class="ccat__shine"></div>
        <div class="ccat__body"><div class="ccat__ico"><i class="fas fa-briefcase"></i></div><div class="ccat__name">Oficinas</div><div class="ccat__hint">Ver disponibles →</div></div>
      </a>
      <a href="${ctx}/lista.jsp?tipo=local" class="ccat rv d5" onmousemove="tilt(event,this)" onmouseleave="untilt(this)">
        <img src="https://images.unsplash.com/photo-1582037928769-181f2644ecb7?w=600&q=70" alt="Locales" loading="lazy">
        <div class="ccat__ov"></div><div class="ccat__shine"></div>
        <div class="ccat__body"><div class="ccat__ico"><i class="fas fa-store"></i></div><div class="ccat__name">Locales</div><div class="ccat__hint">Ver disponibles →</div></div>
      </a>
    </div>
  </div>
</section>

<!-- ══ PROPIEDADES ══ -->
<section class="s-props">
  <div class="container">
    <div class="props-hd">
      <div class="rv"><div class="eyebrow">En Vitrina</div><h2 class="s-head">Propiedades<br><em>Destacadas</em></h2></div>
      <div class="f-btns rv">
        <button class="fbtn on" onclick="fp('todos',this)">Todos</button>
        <button class="fbtn" onclick="fp('venta',this)">En Venta</button>
        <button class="fbtn" onclick="fp('arriendo',this)">En Arriendo</button>
      </div>
    </div>
    <div class="pgrid" id="pgrid">

      <c:choose>
        <c:when test="${not empty propiedadesDestacadas}">
          <c:forEach var="p" items="${propiedadesDestacadas}" varStatus="st">
            <c:if test="${st.index < 6}">
            <div class="pcard rv d${st.index + 1}" data-op="${p.operacion}">
              <div class="pcard__img">
                <img src="${not empty p.fotoPrincipal ? p.fotoPrincipal : 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&q=70'}" alt="${p.titulo}" loading="lazy">
                <span class="pbadge ${p.operacion}">${p.operacion}</span>
                <button class="pfav" title="Favorito"><i class="fas fa-heart"></i></button>
              </div>
              <div class="pcard__bd">
                <div class="ptipo">${p.tipo}</div>
                <div class="ptitle">${p.titulo}</div>
                <div class="ploc"><i class="fas fa-map-marker-alt"></i>${p.barrio}${not empty p.barrio ? ', ' : ''}${p.ciudad}</div>
                <div class="pfeats">
                  <c:if test="${p.habitaciones > 0}"><span class="pfeat"><i class="fas fa-bed"></i>${p.habitaciones} hab.</span></c:if>
                  <c:if test="${p.banos > 0}"><span class="pfeat"><i class="fas fa-bath"></i>${p.banos} baños</span></c:if>
                  <c:if test="${not empty p.area}"><span class="pfeat"><i class="fas fa-ruler-combined"></i><fmt:formatNumber value="${p.area}" maxFractionDigits="0"/>m²</span></c:if>
                </div>
                <div class="pfoot">
                  <div><div class="pprice">$<fmt:formatNumber value="${p.precio}" type="number" groupingUsed="true" maxFractionDigits="0"/></div><div class="pplbl">COP${p.operacion == 'arriendo' ? ' /mes' : ''}</div></div>
                  <a href="${ctx}/propiedades/detalle/${p.id}" class="pbtn"><i class="fas fa-arrow-right"></i></a>
                </div>
              </div>
            </div>
            </c:if>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <!-- Demo cards -->
          <div class="pcard rv d1" data-op="venta">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=600&q=70" alt="" loading="lazy"><span class="pbadge venta">venta</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Casa</div><div class="ptitle">Casa Moderna en Cabecera</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Cabecera, Bucaramanga</div><div class="pfeats"><span class="pfeat"><i class="fas fa-bed"></i>4 hab.</span><span class="pfeat"><i class="fas fa-bath"></i>3 baños</span><span class="pfeat"><i class="fas fa-ruler-combined"></i>180m²</span></div><div class="pfoot"><div><div class="pprice">$420.000.000</div><div class="pplbl">COP</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
          <div class="pcard rv d2" data-op="venta">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&q=70" alt="" loading="lazy"><span class="pbadge venta">venta</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Apartamento</div><div class="ptitle">Apto Lagos del Cacique</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Lagos del Cacique, BGA</div><div class="pfeats"><span class="pfeat"><i class="fas fa-bed"></i>3 hab.</span><span class="pfeat"><i class="fas fa-bath"></i>2 baños</span><span class="pfeat"><i class="fas fa-ruler-combined"></i>110m²</span></div><div class="pfoot"><div><div class="pprice">$280.000.000</div><div class="pplbl">COP</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
          <div class="pcard rv d3" data-op="arriendo">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&q=70" alt="" loading="lazy"><span class="pbadge arriendo">arriendo</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Oficina</div><div class="ptitle">Oficina Centro Empresarial</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Centro, Bucaramanga</div><div class="pfeats"><span class="pfeat"><i class="fas fa-ruler-combined"></i>65m²</span><span class="pfeat"><i class="fas fa-wifi"></i>Fibra óptica</span></div><div class="pfoot"><div><div class="pprice">$2.800.000</div><div class="pplbl">COP /mes</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
          <div class="pcard rv d4" data-op="venta">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&q=70" alt="" loading="lazy"><span class="pbadge venta">venta</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Casa</div><div class="ptitle">Casa Campestre Floridablanca</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Floridablanca, Santander</div><div class="pfeats"><span class="pfeat"><i class="fas fa-bed"></i>5 hab.</span><span class="pfeat"><i class="fas fa-bath"></i>4 baños</span><span class="pfeat"><i class="fas fa-ruler-combined"></i>320m²</span></div><div class="pfoot"><div><div class="pprice">$950.000.000</div><div class="pplbl">COP</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
          <div class="pcard rv d5" data-op="arriendo">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1560184897-ae75f418493e?w=600&q=70" alt="" loading="lazy"><span class="pbadge arriendo">arriendo</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Apartamento</div><div class="ptitle">Apartamento Amoblado Sotomayor</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Sotomayor, BGA</div><div class="pfeats"><span class="pfeat"><i class="fas fa-bed"></i>2 hab.</span><span class="pfeat"><i class="fas fa-bath"></i>1 baño</span><span class="pfeat"><i class="fas fa-ruler-combined"></i>75m²</span></div><div class="pfoot"><div><div class="pprice">$1.500.000</div><div class="pplbl">COP /mes</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
          <div class="pcard rv" data-op="venta">
            <div class="pcard__img"><img src="https://images.unsplash.com/photo-1599427303058-f04cbcf4756f?w=600&q=70" alt="" loading="lazy"><span class="pbadge venta">venta</span><button class="pfav"><i class="fas fa-heart"></i></button></div>
            <div class="pcard__bd"><div class="ptipo">Penthouse</div><div class="ptitle">Penthouse Vista Panorámica BGA</div><div class="ploc"><i class="fas fa-map-marker-alt"></i>Norte, Bucaramanga</div><div class="pfeats"><span class="pfeat"><i class="fas fa-bed"></i>4 hab.</span><span class="pfeat"><i class="fas fa-bath"></i>4 baños</span><span class="pfeat"><i class="fas fa-ruler-combined"></i>250m²</span></div><div class="pfoot"><div><div class="pprice">$680.000.000</div><div class="pplbl">COP</div></div><a href="${ctx}/lista.jsp" class="pbtn"><i class="fas fa-arrow-right"></i></a></div></div>
          </div>
        </c:otherwise>
      </c:choose>

    </div>
    <div class="text-center mt-5 rv">
      <a href="${ctx}/lista.jsp" class="cbtn-p" style="display:inline-flex;">Ver todas las propiedades <i class="fas fa-arrow-right"></i></a>
    </div>
  </div>
</section>

<!-- ══ STATS ══ -->
<section class="s-stats" id="statsSection">
  <div class="container">
    <div class="sgrid">
      <div class="sblk rv"><span class="snum" data-target="500">0</span><span class="ssuf">+</span><div class="slbl">Propiedades</div><div class="ssub">Activas en el sistema</div></div>
      <div class="sblk rv d1"><span class="snum" data-target="842">0</span><div class="slbl">Clientes Satisfechos</div><div class="ssub">Desde 2016</div></div>
      <div class="sblk rv d2"><span class="snum" data-target="98">0</span><span class="ssuf">%</span><div class="slbl">Satisfacción</div><div class="ssub">Basado en encuestas</div></div>
      <div class="sblk rv d3"><span class="snum" data-target="48">0</span><span class="ssuf">h</span><div class="slbl">Tiempo Promedio</div><div class="ssub">Para cerrar negocio</div></div>
    </div>
  </div>
</section>

<!-- ══ WHY ══ -->
<section class="s-why">
  <div class="container">
    <div class="why-lay">
      <div class="why-vis rv">
        <img class="wmain" src="https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&q=80" alt="Equipo">
        <img class="wacc" src="https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80" alt="Propiedad">
        <div class="wbadge"><span class="wbnum">8</span><span class="wbtxt">Años de<br>Experiencia</span></div>
      </div>
      <div>
        <div class="rv"><div class="eyebrow">Nuestra diferencia</div><h2 class="s-head">¿Por qué elegir<br><em>InmoVista?</em></h2></div>
        <div class="why-list">
          <div class="witem rv d1"><div class="wico"><i class="fas fa-shield-alt"></i></div><div><div class="wtitle">Propiedades 100% Verificadas</div><div class="wdesc">Cada propiedad pasa por un riguroso proceso de verificación legal y física antes de publicarse.</div></div></div>
          <div class="witem rv d2"><div class="wico"><i class="fas fa-search-dollar"></i></div><div><div class="wtitle">El Mejor Precio del Mercado</div><div class="wdesc">Analizamos el mercado para asegurarnos que obtienes el valor justo, siempre.</div></div></div>
          <div class="witem rv d3"><div class="wico"><i class="fas fa-headset"></i></div><div><div class="wtitle">Acompañamiento Total</div><div class="wdesc">Desde la búsqueda hasta la firma, te acompañamos en cada paso del proceso.</div></div></div>
          <div class="witem rv d4"><div class="wico"><i class="fas fa-bolt"></i></div><div><div class="wtitle">Proceso Digital y Ágil</div><div class="wdesc">Gestiona visitas, contratos y pagos desde nuestra plataforma, sin filas ni papeleos.</div></div></div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ══ TESTIMONIOS ══ -->
<section class="s-testi">
  <div class="container"><div class="text-center rv"><div class="eyebrow">Lo que dicen</div><h2 class="s-head">Nuestros <em>clientes</em><br>hablan por nosotros</h2></div></div>
  <div class="tt-wrap">
    <div class="tt-track">
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Encontré mi apartamento ideal en menos de una semana. El proceso fue transparente y el equipo siempre estuvo disponible."</div><div class="tauthor"><div class="tavatar">AM</div><div><div class="tname">Andrés Morales</div><div class="tcity">Cabecera, Bucaramanga</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"La plataforma es simplemente extraordinaria. Pude filtrar, agendar la visita y firmar el contrato todo desde mi celular."</div><div class="tauthor"><div class="tavatar">LC</div><div><div class="tname">Laura Castillo</div><div class="tcity">Lagos del Cacique, BGA</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Vendí mi casa en tiempo récord y al mejor precio. El análisis de mercado que hicieron fue impresionante."</div><div class="tauthor"><div class="tavatar">JR</div><div><div class="tname">Juan Rodríguez</div><div class="tcity">Sotomayor, BGA</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Como inversionista, valoro la transparencia y los datos confiables. InmoVista es lo más profesional que he usado."</div><div class="tauthor"><div class="tavatar">MP</div><div><div class="tname">María Pérez</div><div class="tcity">Centro, Bucaramanga</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star-half-alt tstar"></i></div><div class="tquote">"El agente que me asignaron fue increíble. Respondía en minutos y conocía perfectamente el mercado de la ciudad."</div><div class="tauthor"><div class="tavatar">DG</div><div><div class="tname">Diego Gómez</div><div class="tcity">Floridablanca</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Arrendé mi local comercial por InmoVista. En dos semanas tenía inquilino. Servicio absolutamente profesional."</div><div class="tauthor"><div class="tavatar">SP</div><div><div class="tname">Sandra Pinilla</div><div class="tcity">El Jardín, BGA</div></div></div></div>
      <!-- Duplicate -->
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Encontré mi apartamento ideal en menos de una semana. El proceso fue transparente y el equipo siempre estuvo disponible."</div><div class="tauthor"><div class="tavatar">AM</div><div><div class="tname">Andrés Morales</div><div class="tcity">Cabecera, Bucaramanga</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"La plataforma es simplemente extraordinaria. Pude filtrar, agendar la visita y firmar el contrato todo desde mi celular."</div><div class="tauthor"><div class="tavatar">LC</div><div><div class="tname">Laura Castillo</div><div class="tcity">Lagos del Cacique, BGA</div></div></div></div>
      <div class="tcard"><div class="tstars"><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i><i class="fas fa-star tstar"></i></div><div class="tquote">"Vendí mi casa en tiempo récord y al mejor precio. El análisis de mercado que hicieron fue impresionante."</div><div class="tauthor"><div class="tavatar">JR</div><div><div class="tname">Juan Rodríguez</div><div class="tcity">Sotomayor, BGA</div></div></div></div>
    </div>
  </div>
</section>

<!-- ══ CTA ══ -->
<section class="s-cta">
  <div class="s-cta__bg"></div><div class="s-cta__ov"></div>
  <div class="container">
    <div class="s-cta__bd">
      <h2 class="cta-title rv">¿Listo para encontrar<br>tu hogar <em>ideal?</em></h2>
      <p class="cta-sub rv d1">Regístrate gratis y accede a todas las funcionalidades de la plataforma inmobiliaria más avanzada de Colombia.</p>
      <div class="cta-btns rv d2">
        <a href="${ctx}/registro.jsp" class="cbtn-p"><i class="fas fa-user-plus"></i> Crear Cuenta Gratis</a>
        <a href="${ctx}/lista.jsp" class="cbtn-s"><i class="fas fa-search"></i> Explorar Propiedades</a>
      </div>
    </div>
  </div>
</section>

<%@ include file="footer.jsp" %>

<script>
/* ─ CURSOR ─ */
const $d=document.getElementById('cdot'), $r=document.getElementById('cring');
let mx=0,my=0,rx=0,ry=0;
document.addEventListener('mousemove',e=>{mx=e.clientX;my=e.clientY;$d.style.cssText=`left:${mx}px;top:${my}px;`;});
(function loop(){rx+=(mx-rx)*.13;ry+=(my-ry)*.13;$r.style.cssText=`left:${rx}px;top:${ry}px;`;requestAnimationFrame(loop);})();
document.querySelectorAll('a,button').forEach(el=>{
  el.addEventListener('mouseenter',()=>{$r.style.transform='scale(1.9)';$d.style.transform='scale(0)';});
  el.addEventListener('mouseleave',()=>{$r.style.transform='scale(1)';$d.style.transform='scale(1)';});
});

/* ─ PARTICLES ─ */
const cv=document.getElementById('pcanvas'),cx=cv.getContext('2d');
let W,H,pts=[];
function rsz(){W=cv.width=innerWidth;H=cv.height=innerHeight;}
rsz();window.addEventListener('resize',rsz);
class P{constructor(){this.reset();}reset(){this.x=Math.random()*W;this.y=Math.random()*H;this.s=Math.random()*1.4+.3;this.vx=(Math.random()-.5)*.3;this.vy=(Math.random()-.5)*.3-.1;this.a=Math.random()*.45+.1;this.c=Math.random()>.55?'#c9a84c':'#ffffff';}update(){this.x+=this.vx;this.y+=this.vy;if(this.y<-5||this.x<-5||this.x>W+5){this.reset();this.y=H+5;}}draw(){cx.beginPath();cx.arc(this.x,this.y,this.s,0,Math.PI*2);cx.fillStyle=this.c;cx.globalAlpha=this.a;cx.fill();}}
for(let i=0;i<130;i++)pts.push(new P());
(function anim(){cx.clearRect(0,0,W,H);pts.forEach(p=>{p.update();p.draw();});cx.globalAlpha=1;requestAnimationFrame(anim);})();

/* ─ HERO BG ─ */
window.addEventListener('load',()=>document.getElementById('heroBg').classList.add('go'));
window.addEventListener('scroll',()=>{const s=scrollY;const b=document.getElementById('heroBg');if(b)b.style.transform=`translateY(${s*.3}px)`;});

/* ─ SEARCH TABS ─ */
function setTab(el,op){document.querySelectorAll('.h-stab').forEach(t=>t.classList.remove('on'));el.classList.add('on');document.getElementById('tabOp').value=op;}

/* ─ TILT ─ */
function tilt(e,c){const r=c.getBoundingClientRect();const x=(e.clientX-r.left)/r.width-.5;const y=(e.clientY-r.top)/r.height-.5;c.style.transform=`perspective(600px) rotateY(${x*12}deg) rotateX(${-y*12}deg) scale(1.02)`;const sh=c.querySelector('.ccat__shine');if(sh){sh.style.setProperty('--mx',(e.clientX-r.left)/r.width*100+'%');sh.style.setProperty('--my',(e.clientY-r.top)/r.height*100+'%');}}
function untilt(c){c.style.transform='';}

/* ─ FILTER ─ */
function fp(op,btn){document.querySelectorAll('.fbtn').forEach(b=>b.classList.remove('on'));btn.classList.add('on');document.querySelectorAll('.pcard').forEach(c=>{const show=op==='todos'||c.dataset.op===op;c.style.opacity=show?'1':'0';c.style.transform=show?'':'scale(.95)';c.style.pointerEvents=show?'':'none';});}

/* ─ REVEAL ─ */
const ro=new IntersectionObserver(entries=>entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('show');}),{threshold:.1});
document.querySelectorAll('.rv').forEach(el=>ro.observe(el));

/* ─ COUNTERS ─ */
let counted=false;
const co=new IntersectionObserver(entries=>{entries.forEach(e=>{if(e.isIntersecting&&!counted){counted=true;document.querySelectorAll('.snum[data-target]').forEach(el=>{const t=+el.getAttribute('data-target');const start=performance.now();(function step(now){const p=Math.min((now-start)/2200,1);const ease=1-Math.pow(1-p,4);el.textContent=Math.floor(ease*t);if(p<1)requestAnimationFrame(step);else el.textContent=t;})(performance.now());});}});},{threshold:.4});
const ss=document.getElementById('statsSection');if(ss)co.observe(ss);

/* ─ FAV TOGGLE ─ */
document.querySelectorAll('.pfav').forEach(b=>{b.addEventListener('click',function(e){e.preventDefault();const on=this.classList.toggle('faved');this.style.color=on?'#e74c3c':'';this.style.borderColor=on?'#e74c3c':'';});});
</script>
