<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Reportes" scope="request"/>
<%@ include file="header.jsp" %>

<div class="dashboard-layout">
  <%@ include file="sidebar.jsp" %>

  <main class="dashboard-main">
    <div class="dashboard-header">
      <div class="dashboard-title">
        <i class="fas fa-chart-bar me-2" style="color:var(--gold);"></i>
        Reportes del Sistema
      </div>
      <div class="dashboard-subtitle">Estadísticas y métricas de la plataforma</div>
    </div>

    <!-- KPIs Generales -->
    <div class="kpi-grid mb-4">
      <div class="kpi-card">
        <div class="kpi-icon" style="background:rgba(39,174,96,0.12);color:#27ae60;">
          <i class="fas fa-home"></i>
        </div>
        <div class="kpi-num">${not empty totalPropDisp ? totalPropDisp : '0'}</div>
        <div class="kpi-label">Disponibles</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-icon" style="background:rgba(52,152,219,0.12);color:#3498db;">
          <i class="fas fa-handshake"></i>
        </div>
        <div class="kpi-num">${not empty totalVentas ? totalVentas : '0'}</div>
        <div class="kpi-label">Vendidas</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-icon" style="background:rgba(155,89,182,0.12);color:#9b59b6;">
          <i class="fas fa-key"></i>
        </div>
        <div class="kpi-num">${not empty totalArriendos ? totalArriendos : '0'}</div>
        <div class="kpi-label">Arrendadas</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-icon" style="background:rgba(201,168,76,0.12);color:var(--gold);">
          <i class="fas fa-chart-line"></i>
        </div>
        <div class="kpi-num">
          $<c:choose>
            <c:when test="${not empty ingresoTotal}">
              <fmt:formatNumber value="${ingresoTotal}" type="number" maxFractionDigits="0"/>
            </c:when>
            <c:otherwise>0</c:otherwise>
          </c:choose>
        </div>
        <div class="kpi-label">Valor Total Propiedades</div>
      </div>
    </div>

    <div class="row g-4">

      <!-- PROPIEDADES POR TIPO -->
      <div class="col-lg-6">
        <div class="table-card">
          <div class="table-card-header">
            <h5><i class="fas fa-chart-pie me-2" style="color:var(--gold);"></i>Propiedades por Tipo</h5>
          </div>
          <div class="p-4">
            <%-- Casa --%>
            <c:set var="cntCasa" value="${propsPorTipo['casa']}"/>
            <c:set var="pctCasa" value="${not empty cntCasa and totalPropTodo > 0 ? (cntCasa * 100 / totalPropTodo) : 0}"/>
            <div class="mb-3">
              <div class="d-flex justify-content-between mb-1">
                <span style="font-size:0.88rem;font-weight:600;">Casa</span>
                <span style="font-size:0.82rem;color:var(--gray-3);">${not empty cntCasa ? cntCasa : '0'} prop. (<fmt:formatNumber value="${pctCasa}" maxFractionDigits="1"/>%)</span>
              </div>
              <div style="height:8px;background:var(--gray-2);border-radius:4px;overflow:hidden;">
                <div style="height:100%;background:#27ae60;border-radius:4px;width:${pctCasa}%;transition:width 1s ease 0.2s;"></div>
              </div>
            </div>
            <%-- Apartamento --%>
            <c:set var="cntApto" value="${propsPorTipo['apartamento']}"/>
            <c:set var="pctApto" value="${not empty cntApto and totalPropTodo > 0 ? (cntApto * 100 / totalPropTodo) : 0}"/>
            <div class="mb-3">
              <div class="d-flex justify-content-between mb-1">
                <span style="font-size:0.88rem;font-weight:600;">Apartamento</span>
                <span style="font-size:0.82rem;color:var(--gray-3);">${not empty cntApto ? cntApto : '0'} prop. (<fmt:formatNumber value="${pctApto}" maxFractionDigits="1"/>%)</span>
              </div>
              <div style="height:8px;background:var(--gray-2);border-radius:4px;overflow:hidden;">
                <div style="height:100%;background:#3498db;border-radius:4px;width:${pctApto}%;transition:width 1s ease 0.2s;"></div>
              </div>
            </div>
            <%-- Terreno --%>
            <c:set var="cntTerr" value="${propsPorTipo['terreno']}"/>
            <c:set var="pctTerr" value="${not empty cntTerr and totalPropTodo > 0 ? (cntTerr * 100 / totalPropTodo) : 0}"/>
            <div class="mb-3">
              <div class="d-flex justify-content-between mb-1">
                <span style="font-size:0.88rem;font-weight:600;">Terreno</span>
                <span style="font-size:0.82rem;color:var(--gray-3);">${not empty cntTerr ? cntTerr : '0'} prop. (<fmt:formatNumber value="${pctTerr}" maxFractionDigits="1"/>%)</span>
              </div>
              <div style="height:8px;background:var(--gray-2);border-radius:4px;overflow:hidden;">
                <div style="height:100%;background:#f39c12;border-radius:4px;width:${pctTerr}%;transition:width 1s ease 0.2s;"></div>
              </div>
            </div>
            <%-- Oficina --%>
            <c:set var="cntOfic" value="${propsPorTipo['oficina']}"/>
            <c:set var="pctOfic" value="${not empty cntOfic and totalPropTodo > 0 ? (cntOfic * 100 / totalPropTodo) : 0}"/>
            <div class="mb-3">
              <div class="d-flex justify-content-between mb-1">
                <span style="font-size:0.88rem;font-weight:600;">Oficina</span>
                <span style="font-size:0.82rem;color:var(--gray-3);">${not empty cntOfic ? cntOfic : '0'} prop. (<fmt:formatNumber value="${pctOfic}" maxFractionDigits="1"/>%)</span>
              </div>
              <div style="height:8px;background:var(--gray-2);border-radius:4px;overflow:hidden;">
                <div style="height:100%;background:#9b59b6;border-radius:4px;width:${pctOfic}%;transition:width 1s ease 0.2s;"></div>
              </div>
            </div>
            <%-- Local --%>
            <c:set var="cntLoc" value="${propsPorTipo['local']}"/>
            <c:set var="pctLoc" value="${not empty cntLoc and totalPropTodo > 0 ? (cntLoc * 100 / totalPropTodo) : 0}"/>
            <div class="mb-3">
              <div class="d-flex justify-content-between mb-1">
                <span style="font-size:0.88rem;font-weight:600;">Local</span>
                <span style="font-size:0.82rem;color:var(--gray-3);">${not empty cntLoc ? cntLoc : '0'} prop. (<fmt:formatNumber value="${pctLoc}" maxFractionDigits="1"/>%)</span>
              </div>
              <div style="height:8px;background:var(--gray-2);border-radius:4px;overflow:hidden;">
                <div style="height:100%;background:#e74c3c;border-radius:4px;width:${pctLoc}%;transition:width 1s ease 0.2s;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- CITAS POR ESTADO -->
      <div class="col-lg-6">
        <div class="table-card">
          <div class="table-card-header">
            <h5><i class="fas fa-calendar me-2" style="color:var(--gold);"></i>Estado de Citas</h5>
          </div>
          <div class="p-4">
            <div class="d-flex align-items-center justify-content-between py-3 border-bottom" style="border-color:var(--gray-2)!important;">
              <div class="d-flex align-items-center gap-3">
                <div style="width:10px;height:10px;border-radius:50%;background:#f39c12;"></div>
                <span style="font-size:0.9rem;">Pendientes</span>
              </div>
              <span style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;color:#f39c12;">
                ${not empty citasPorEstado['pendiente'] ? citasPorEstado['pendiente'] : '0'}
              </span>
            </div>
            <div class="d-flex align-items-center justify-content-between py-3 border-bottom" style="border-color:var(--gray-2)!important;">
              <div class="d-flex align-items-center gap-3">
                <div style="width:10px;height:10px;border-radius:50%;background:#27ae60;"></div>
                <span style="font-size:0.9rem;">Confirmadas</span>
              </div>
              <span style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;color:#27ae60;">
                ${not empty citasPorEstado['confirmada'] ? citasPorEstado['confirmada'] : '0'}
              </span>
            </div>
            <div class="d-flex align-items-center justify-content-between py-3 border-bottom" style="border-color:var(--gray-2)!important;">
              <div class="d-flex align-items-center gap-3">
                <div style="width:10px;height:10px;border-radius:50%;background:#3498db;"></div>
                <span style="font-size:0.9rem;">Realizadas</span>
              </div>
              <span style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;color:#3498db;">
                ${not empty citasPorEstado['realizada'] ? citasPorEstado['realizada'] : '0'}
              </span>
            </div>
            <div class="d-flex align-items-center justify-content-between py-3" style="border-color:var(--gray-2)!important;">
              <div class="d-flex align-items-center gap-3">
                <div style="width:10px;height:10px;border-radius:50%;background:#e74c3c;"></div>
                <span style="font-size:0.9rem;">Canceladas</span>
              </div>
              <span style="font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;color:#e74c3c;">
                ${not empty citasPorEstado['cancelada'] ? citasPorEstado['cancelada'] : '0'}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- TOP PROPIEDADES -->
      <div class="col-12">
        <div class="table-card">
          <div class="table-card-header">
            <h5><i class="fas fa-trophy me-2" style="color:var(--gold);"></i>Propiedades con Más Solicitudes</h5>
          </div>
          <div class="table-responsive">
            <table class="table mb-0">
              <thead>
                <tr><th>#</th><th>Propiedad</th><th>Tipo</th><th>Ciudad</th><th>Precio</th><th>Solicitudes</th><th>Citas</th></tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${not empty topPropiedades}">
                    <c:forEach var="p" items="${topPropiedades}" varStatus="loop">
                    <tr>
                      <td>
                        <c:choose>
                          <c:when test="${loop.index == 0}">🥇</c:when>
                          <c:when test="${loop.index == 1}">🥈</c:when>
                          <c:when test="${loop.index == 2}">🥉</c:when>
                          <c:otherwise>${loop.index + 1}</c:otherwise>
                        </c:choose>
                      </td>
                      <td style="font-weight:600;font-size:0.88rem;">${p.titulo}</td>
                      <td>${p.tipo}</td>
                      <td>${p.ciudad}</td>
                      <td style="font-weight:700;">$<fmt:formatNumber value="${p.precio}" type="number" maxFractionDigits="0"/></td>
                      <td><span style="background:#d4edda;color:#155724;padding:3px 10px;border-radius:20px;font-size:0.8rem;">${p.totalSolicitudes}</span></td>
                      <td><span style="background:#cce5ff;color:#004085;padding:3px 10px;border-radius:20px;font-size:0.8rem;">${p.totalCitas}</span></td>
                    </tr>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <tr><td colspan="7" style="text-align:center;padding:30px;color:var(--gray-3);">Sin datos de reporte aún</td></tr>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>
  </main>
</div>

<%@ include file="footer.jsp" %>
