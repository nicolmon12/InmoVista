/* =====================================================
   INMOVISTA — bot.js  v3.0
   Asistente virtual con flujo de sugerencias via Gmail
   ===================================================== */

(function () {
  var history = [];
  var isOpen = false;

  // Estado del flujo de sugerencia
  var sugerenciaFlow = {
    activo: false,
    paso: 0,       // 1=esperando nombre, 2=esperando email, 3=esperando mensaje
    nombre: '',
    email: '',
    mensaje: ''
  };

  // Rotación de respuestas
  var counters = {};
  function pick(key, arr) {
    if (!counters[key]) counters[key] = 0;
    var r = arr[counters[key] % arr.length];
    counters[key]++;
    return r;
  }

  // ── BANCO DE RESPUESTAS ──────────────────────────────
  var R = {
    saludo: [
      '¡Hola! Soy InmoBot, tu asistente de InmoVista 🤖 ¿Buscas comprar, arrendar o tienes alguna sugerencia para nosotros?',
      '¡Buenas! Con gusto te ayudo 😊 ¿Te interesa algo en venta, en arriendo, o quieres enviarnos un mensaje?',
      '¡Hola! Estoy aquí para orientarte con propiedades en Bucaramanga. También puedes enviarnos sugerencias o preguntas. ¿Por dónde empezamos?',
      '¡Qué bueno que estés aquí! Puedo ayudarte a buscar propiedad, agendar visitas o recibir tu mensaje. ¿Qué necesitas?'
    ],
    visita: [
      'Para agendar una visita primero regístrate en /registro.jsp. Luego entra a la propiedad que te interesa y haz clic en "Solicitar Visita" 📅',
      'Las visitas se agendan desde la página de cada propiedad. Solo necesitas cuenta de cliente — créala gratis en /registro.jsp.',
      'Fácil: regístrate en /registro.jsp, busca la propiedad en /lista.jsp y usa el botón "Solicitar Visita". Confirmamos en menos de 24h 📅',
      '¿Ya tienes cuenta? Ve a /lista.jsp, selecciona la propiedad y solicita la visita. Si no, el registro toma menos de 2 minutos.'
    ],
    precio: [
      'Los precios varían según tipo y zona. Arriendos desde $800.000/mes y ventas desde $180M. Filtra en /lista.jsp 💰',
      'Tenemos para todos los presupuestos: desde $800K/mes en arriendo y desde $180M en venta. ¿Tienes un rango en mente?',
      'En /lista.jsp puedes filtrar por precio mínimo y máximo. ¿Buscas comprar o arrendar?',
      'Arriendos desde $800K/mes hasta $5M+. Ventas desde $180M. Todo filtrable en /lista.jsp 💰'
    ],
    venta: [
      'Tenemos casas, apartamentos, terrenos y más en venta. Filtra por tipo y zona en /lista.jsp. ¿Qué tipo de propiedad buscas?',
      'En venta manejamos desde apartamentos de 1 habitación hasta penthouses y casas campestres. Explora en /lista.jsp 🏠',
      '¿Buscas comprar? Más de 200 propiedades verificadas en venta. ¿Cuál sector de Bucaramanga te interesa?',
      'Para compra recuerda guardar tus favoritos registrándote en /registro.jsp. Así comparas fácilmente antes de decidir.'
    ],
    arriendo: [
      'En arriendo tenemos apartamentos, casas, oficinas y locales desde $800.000/mes. Filtra por "En Arriendo" en /lista.jsp 🏠',
      '¿Residencial o comercial? Dime qué tipo buscas y te oriento mejor.',
      'Arriendos en Cabecera, Sotomayor, Lagos del Cacique y más. Desde estudios hasta casas grandes. ¿Cuántas habitaciones necesitas?',
      'Todos nuestros arriendos son verificados. Filtra por precio, habitaciones y zona en /lista.jsp 🔑'
    ],
    requisitosArriendo: [
      'Para arrendar generalmente se pide: 📋 Cédula, desprendibles de pago (últimos 3 meses), codeudor o póliza, y extractos bancarios.',
      'Documentos usuales: cédula, certificado laboral o declaración de renta, desprendibles de nómina y en algunos casos codeudor. ¿Eres empleado o independiente?',
      'Para arrendar necesitas acreditar ingresos de mínimo 3 veces el canon. Documentos: cédula, desprendibles o declaración de renta, y referencias.',
      'Requisitos: ✅ Cédula vigente ✅ Ingresos demostrables (mínimo 3x el arriendo) ✅ Codeudor o póliza ✅ Referencias laborales.'
    ],
    procesoCompra: [
      '🏠 Proceso de compra:\n1. Busca tu propiedad en /lista.jsp\n2. Solicita visita\n3. Carta de intención\n4. Promesa de compraventa\n5. Crédito hipotecario (si aplica)\n6. Escrituración notarial\n7. Registro en instrumentos públicos',
      'Comprar con InmoVista: explora en /lista.jsp → agenda visita → oferta formal → escrituras. Acompañamos todo el proceso. ¿En cuál paso tienes dudas?',
      '📋 Pasos: elegir → visita → oferta → promesa → trámite crédito → escritura → registro. Todo toma entre 30 y 90 días. ¿Quieres saber más de algún paso?',
      'Inicia en /lista.jsp. Cuando elijas tu propiedad, un asesor te guía desde la oferta hasta la entrega de llaves. ¿Vas a financiar o pagar de contado?'
    ],
    metodosPago: [
      'Aceptamos: 💳 Transferencia bancaria, consignación, cheque de gerencia y crédito hipotecario. Los detalles se coordinan con la inmobiliaria de cada propiedad.',
      'Para compra: contado o crédito hipotecario. Para arriendos: transferencia PSE o consignación mensual.',
      '🏦 Compras: crédito hipotecario, leasing o contado. 🔑 Arriendos: transferencia o PSE mensual. ¿Buscas comprar o arrendar?',
      'Trabajamos con todos los bancos del país para créditos hipotecarios. Los pagos de arriendo se coordinan directamente con la inmobiliaria.'
    ],
    casa: [
      'Tenemos casas en venta y arriendo en Bucaramanga y área metropolitana. Desde $180M en venta. ¿Prefieres Cabecera, Floridablanca u otra zona?',
      'Casas más solicitadas en Floridablanca y Cabecera. Desde 3 hasta 6 habitaciones. Búscalas en /lista.jsp 🏠',
      '¿Casa en venta o arriendo? ¿Cuál es tu presupuesto aproximado? Te oriento a las mejores opciones.',
      'Para casas te recomiendo revisar Cabecera, Floridablanca y Girón. Filtra en /lista.jsp por tipo "Casa".'
    ],
    apartamento: [
      'Apartamentos desde 1 hasta 4 habitaciones. Lagos del Cacique, Cabecera y El Norte son las zonas más solicitadas 🏢',
      'Desde estudios hasta penthouses. ¿Cuántas habitaciones necesitas?',
      '¿Nuevo o usado? Filtra en /lista.jsp por tipo "Apartamento" y ajusta el precio.',
      'Arriendos desde $800K y ventas desde $180M. Zonas top: Lagos, Cabecera y Norte. ¿Tienes zona preferida?'
    ],
    zona: [
      'Tenemos propiedades en Cabecera, Sotomayor, Lagos del Cacique, Norte, Floridablanca, Girón y Piedecuesta. ¿Cuál te interesa? 📍',
      'Zonas más solicitadas: Cabecera (familiar), Lagos del Cacique (exclusiva), Norte (moderna) y Floridablanca (casas amplias).',
      'Cubrimos todo el área metropolitana: BGA ciudad, Floridablanca, Girón y Piedecuesta. ¿Trabajas en algún sector específico?',
      'Cabecera (estrato 4-5), Sotomayor (céntrica), Lagos (exclusiva estrato 5-6), Norte (moderna). ¿Cuál se adapta a ti?'
    ],
    registro: [
      'Registrarte es gratis en /registro.jsp. Con tu cuenta agendas visitas, guardas favoritos y gestionas solicitudes 😊',
      'El registro toma menos de 2 minutos en /registro.jsp. Solo nombre, correo y contraseña.',
      '¿Sin cuenta aún? Créala gratis en /registro.jsp y accede a visitas y alertas de nuevas propiedades.',
      'Regístrate en /registro.jsp — completamente gratis. Luego guarda favoritos y solicita visitas directamente.'
    ],
    login: [
      'Inicia sesión en /login.jsp. Si olvidaste tu contraseña contáctanos para restablecerla.',
      'Tu cuenta te espera en /login.jsp. ¿Tienes algún problema para ingresar?',
      '¿No puedes entrar? Ve a /login.jsp. Si persiste, escríbenos y lo solucionamos rápido.'
    ],
    publicar: [
      'Para publicar necesitas cuenta de inmobiliaria. Regístrate en /registro.jsp y activamos tu cuenta en 24h 🏷️',
      '¿Tienes propiedad para vender o arrendar? Regístrate en /registro.jsp con rol de inmobiliaria.',
      'Publica tu propiedad en /registro.jsp, una vez aprobada sube fotos, descripción y precio. Llegamos a miles de compradores.'
    ],
    contacto: [
      'Puedes contactarnos usando la opción de sugerencias aquí en el chat, o visitar la sección de Ayuda 📞 ¿Quieres enviarnos un mensaje ahora?',
      'Para contacto directo escríbenos desde aquí mismo — escribe "quiero enviar un mensaje" y te ayudo. También está la sección de Ayuda en la plataforma.',
      'Nuestro equipo está disponible de lunes a sábado. ¿Prefieres enviarnos tu mensaje desde aquí? Solo escribe "sugerencia".'
    ],
    gracias: [
      '¡Con mucho gusto! Si necesitas algo más, aquí estaré 🏠✨',
      '¡A ti! Espero haberte ayudado. Recuerda que puedes volver cuando quieras 😊',
      '¡Fue un placer! Éxitos en tu búsqueda. InmoVista tiene lo que necesitas 🌟',
      '¡Claro que sí! Cualquier duda adicional no dudes en preguntar. ¡Buen día! ☀️'
    ],
    noEntiendo: [
      'No estoy seguro de entenderte. ¿Me cuentas un poco más? Puedo ayudar con propiedades, visitas, precios o enviarnos una sugerencia.',
      'Hmm, ¿puedes reformular? Puedo orientarte sobre: buscar propiedad, agendar visita, requisitos, proceso de compra o enviar sugerencias 🤔',
      'Para esa consulta te recomiendo contactarnos directamente. Escribe "sugerencia" aquí y te ayudo a enviarnos tu mensaje.',
      'Para más detalles explora /lista.jsp o escribe "sugerencia" si quieres enviarnos un mensaje. ¿Puedo ayudarte con algo más?'
    ]
  };

  // ── FLUJO DE SUGERENCIAS ─────────────────────────────
  function iniciarFlujoSugerencia() {
    sugerenciaFlow.activo = true;
    sugerenciaFlow.paso = 1;
    sugerenciaFlow.nombre = '';
    sugerenciaFlow.email = '';
    sugerenciaFlow.mensaje = '';
    return '¡Claro! Con gusto recibimos tu mensaje 📩\n\nPrimero, ¿cuál es tu nombre?';
  }

  function procesarFlujo(texto) {
    var t = texto.trim();

    if (sugerenciaFlow.paso === 1) {
      if (t.length < 2) return 'Por favor escribe tu nombre completo.';
      sugerenciaFlow.nombre = t;
      sugerenciaFlow.paso = 2;
      return 'Gracias, ' + t + ' 😊\nAhora, ¿cuál es tu correo electrónico?';
    }

    if (sugerenciaFlow.paso === 2) {
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(t))
        return 'Ese correo no parece válido. Por favor escríbelo de nuevo (ejemplo: tucorreo@gmail.com)';
      sugerenciaFlow.email = t;
      sugerenciaFlow.paso = 3;
      return 'Perfecto 👍\nAhora escribe tu sugerencia o pregunta. Puedes escribir todo lo que quieras:';
    }

    if (sugerenciaFlow.paso === 3) {
      if (t.length < 5) return 'Por favor escribe un mensaje un poco más detallado.';
      sugerenciaFlow.mensaje = t;
      sugerenciaFlow.paso = 4;
      // Mostrar resumen y pedir confirmación
      return '📋 Resumen de tu mensaje:\n\n👤 Nombre: ' + sugerenciaFlow.nombre +
             '\n📧 Correo: ' + sugerenciaFlow.email +
             '\n💬 Mensaje: ' + sugerenciaFlow.mensaje +
             '\n\n¿Confirmas el envío? Escribe "sí" para enviar o "no" para cancelar.';
    }

    if (sugerenciaFlow.paso === 4) {
      var resp = t.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
      if (/^(si|yes|ok|confirmo|enviar|dale)/.test(resp)) {
        enviarSugerencia();
        return null; // la respuesta la maneja enviarSugerencia()
      } else {
        sugerenciaFlow.activo = false;
        sugerenciaFlow.paso = 0;
        return 'Mensaje cancelado. Si cambias de opinión, escribe "sugerencia" cuando quieras 😊';
      }
    }

    return null;
  }

  function enviarSugerencia() {
    var datos = {
      nombre: sugerenciaFlow.nombre,
      email: sugerenciaFlow.email,
      mensaje: sugerenciaFlow.mensaje
    };

    // Reset del flujo
    sugerenciaFlow.activo = false;
    sugerenciaFlow.paso = 0;

    var typingId = addTyping();

    fetch('/InmobiliariaWeb/guardar-sugerencia.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(datos)
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      removeTyping(typingId);
      if (data.ok) {
        addBotMessage('✅ ¡Mensaje enviado con éxito! Gracias, ' + datos.nombre + '. Revisaremos tu mensaje y te responderemos a ' + datos.email + ' pronto 🙌');
      } else {
        addBotMessage('⚠️ Hubo un problema al enviar. Por favor intenta de nuevo o contáctanos directamente desde la sección de Ayuda.');
      }
    })
    .catch(function() {
      removeTyping(typingId);
      addBotMessage('⚠️ No pude conectarme con el servidor. Por favor intenta de nuevo en unos momentos o visita la sección de Ayuda.');
    });
  }

  // ── MOTOR DE RESPUESTAS ──────────────────────────────
  function getReply(text) {
    var t = text.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');

    if (/^(hola|buenas|buenos|hey|hi|saludos|que tal|buen dia|buenas tardes|buenas noches)/.test(t))
      return pick('saludo', R.saludo);

    if (/sugerencia|quiero escribir|enviar mensaje|quiero contactar|tengo una pregunta general|feedback/.test(t))
      return iniciarFlujoSugerencia();

    if (/cita|visita|agendar|ver propiedad|quiero ver/.test(t))
      return pick('visita', R.visita);

    if (/requisito|documento|que necesito|que piden|papeles|para arrendar/.test(t))
      return pick('requisitosArriendo', R.requisitosArriendo);

    if (/proceso|como compro|pasos|como funciona|escritura|notaria|cuanto tarda/.test(t))
      return pick('procesoCompra', R.procesoCompra);

    if (/pago|pagar|transferencia|credito|hipoteca|financ|cuotas|metodo|forma de pago|pse|consign/.test(t))
      return pick('metodosPago', R.metodosPago);

    if (/precio|costo|valor|cuanto|cobran|valen|presupuesto|barato/.test(t))
      return pick('precio', R.precio);

    if (/\bventa\b|comprar|compra\b|adquirir/.test(t))
      return pick('venta', R.venta);

    if (/arrend|alquil|arrendar|alquilar|renta/.test(t))
      return pick('arriendo', R.arriendo);

    if (/\bcasa\b|casas/.test(t))
      return pick('casa', R.casa);

    if (/apartamento|apto|aparta/.test(t))
      return pick('apartamento', R.apartamento);

    if (/terreno|lote|tierra|finca/.test(t))
      return '¡Tenemos terrenos y lotes para construcción o inversión. Selecciona "Terreno" en /lista.jsp para verlos.';

    if (/oficina|local|comercial|bodega/.test(t))
      return 'Disponemos de oficinas y locales en zonas empresariales de Bucaramanga. Ver opciones en /lista.jsp 💼';

    if (/zona|barrio|sector|cabecera|sotomayor|lagos|floridablanca|giron|piedecuesta|norte|donde/.test(t))
      return pick('zona', R.zona);

    if (/registr|crear cuenta|cuenta nueva/.test(t))
      return pick('registro', R.registro);

    if (/login|iniciar sesion|ingresar|entrar|contrasena/.test(t))
      return pick('login', R.login);

    if (/publicar|vender mi|arrendar mi|tengo una propiedad/.test(t))
      return pick('publicar', R.publicar);

    if (/contact|telefono|whatsapp|llamar|correo|email|hablar con/.test(t))
      return pick('contacto', R.contacto);

    if (/gracias|listo|ok|perfecto|entendi|genial|excelente/.test(t))
      return pick('gracias', R.gracias);

    return pick('noEntiendo', R.noEntiendo);
  }

  // ── UI ───────────────────────────────────────────────
  setTimeout(function () {
    if (!isOpen) {
      var h = document.getElementById('bot-hint');
      if (h) {
        h.classList.add('visible');
        setTimeout(function () { h.classList.remove('visible'); }, 4000);
      }
    }
  }, 4000);

  window.toggleBot = function () {
    isOpen = !isOpen;
    var win = document.getElementById('bot-window');
    var btn = document.getElementById('bot-trigger');
    var hint = document.getElementById('bot-hint');
    if (!win || !btn) return;
    if (hint) hint.classList.remove('visible');
    win.classList.toggle('open', isOpen);
    btn.classList.toggle('open', isOpen);
    if (isOpen && history.length === 0) {
      setTimeout(function () { addBotMessage(pick('saludo', R.saludo)); }, 300);
    }
    if (isOpen) {
      setTimeout(function () {
        var inp = document.getElementById('bot-input');
        if (inp) inp.focus();
      }, 350);
    }
  };

  window.sendSuggestion = function (btn) {
    var text = btn.textContent.replace(/^[^\w]+/, '').trim();
    // Si el botón dice "Enviar sugerencia" iniciar flujo directamente
    if (/sugerencia/i.test(text)) text = 'sugerencia';
    var inp = document.getElementById('bot-input');
    if (inp) inp.value = text;
    window.sendMessage();
    var sugs = document.getElementById('bot-suggestions');
    if (sugs) sugs.style.display = 'none';
  };

  window.sendMessage = function () {
    var input = document.getElementById('bot-input');
    if (!input) return;
    var text = input.value.trim();
    if (!text) return;
    input.value = '';
    addUserMessage(text);
    history.push(text);

    // Si estamos en flujo de sugerencia
    if (sugerenciaFlow.activo) {
      var r = procesarFlujo(text);
      if (r === null) return; // enviarSugerencia() maneja la respuesta async
      var typingId = addTyping();
      setTimeout(function () {
        removeTyping(typingId);
        addBotMessage(r);
        var inp = document.getElementById('bot-input');
        if (inp) inp.focus();
      }, 500);
      return;
    }

    var typingId = addTyping();
    setTimeout(function () {
      removeTyping(typingId);
      var reply = getReply(text);
      addBotMessage(reply);
      var inp = document.getElementById('bot-input');
      if (inp) inp.focus();
    }, 600 + Math.random() * 600);
  };

  function addUserMessage(text) {
    var msgs = document.getElementById('bot-messages');
    if (!msgs) return;
    var div = document.createElement('div');
    div.className = 'msg user';
    div.innerHTML = '<div class="msg-bubble">' + escapeHtml(text) + '</div>';
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
  }

  function addBotMessage(text) {
    var msgs = document.getElementById('bot-messages');
    if (!msgs) return;
    var div = document.createElement('div');
    div.className = 'msg bot';
    var formatted = text
      .replace(/\n/g, '<br>')
      .replace(/(\/[\w][\w./?=&-]*)/g, '<a href="$1" style="color:#c9a84c;text-decoration:underline;">$1</a>');
    div.innerHTML = '<div class="msg-bubble">' + formatted + '</div>';
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
  }

  function addTyping() {
    var msgs = document.getElementById('bot-messages');
    if (!msgs) return '';
    var id = 'typing-' + Date.now();
    var div = document.createElement('div');
    div.className = 'msg bot'; div.id = id;
    div.innerHTML = '<div class="msg-bubble"><div class="typing-dots"><span></span><span></span><span></span></div></div>';
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
    return id;
  }

  function removeTyping(id) { var el = document.getElementById(id); if (el) el.remove(); }
  function escapeHtml(t) { return t.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

  document.addEventListener('DOMContentLoaded', function () {
    var inp = document.getElementById('bot-input');
    if (inp) inp.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') window.sendMessage();
    });
  });

})();
