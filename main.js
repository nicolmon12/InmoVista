/* =====================================================
   INMOVISTA — main.js
   Scripts globales del sistema inmobiliario
   ===================================================== */

// ===== ANIMACIONES AL HACER SCROLL =====
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = '1';
      entry.target.style.transform = 'translateY(0)';
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.fade-in-up').forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(20px)';
  el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
  observer.observe(el);
});

// ===== NAVBAR: sombra al hacer scroll =====
window.addEventListener('scroll', () => {
  const nav = document.querySelector('.navbar-inmovista');
  if (nav) {
    nav.style.boxShadow = window.scrollY > 20
      ? '0 4px 20px rgba(0,0,0,0.4)'
      : 'none';
  }
});

// ===== FORMATEAR PRECIOS en inputs =====
document.querySelectorAll('input[name="precio"]').forEach(input => {
  input.addEventListener('blur', function () {
    const val = parseFloat(this.value.replace(/[^\d.]/g, ''));
    if (!isNaN(val)) this.title = '$' + val.toLocaleString('es-CO') + ' COP';
  });
});

// ===== CONFIRMACIONES FORMULARIOS =====
document.querySelectorAll('form[data-confirm]').forEach(form => {
  form.addEventListener('submit', function (e) {
    if (!confirm(this.dataset.confirm)) e.preventDefault();
  });
});

// ===== AUTO-HIDE ALERTS =====
document.querySelectorAll('.alert-inmovista').forEach(alert => {
  setTimeout(() => {
    alert.style.transition = 'opacity 0.5s ease';
    alert.style.opacity = '0';
    setTimeout(() => alert.remove(), 500);
  }, 5000);
});

// ===== ACTIVE SIDEBAR LINK =====
const currentPath = window.location.pathname;
document.querySelectorAll('.sidebar-nav-link').forEach(link => {
  if (link.href && currentPath.includes(link.getAttribute('href'))) {
    link.classList.add('active');
  }
});

// ===== TOOLTIP Bootstrap =====
document.querySelectorAll('[title]').forEach(el => {
  new bootstrap.Tooltip(el, { trigger: 'hover', placement: 'top' });
});
