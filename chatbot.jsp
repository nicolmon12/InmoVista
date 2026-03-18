<!-- ═══════════════════════════════════════
     INMOVISTA BOT — estilos
═══════════════════════════════════════ -->
<style>
/* ── Botón flotante ── */
#bot-trigger {
  position: fixed;
  bottom: 32px; right: 32px;
  width: 62px; height: 62px;
  background: linear-gradient(135deg, #c9a84c 0%, #e8c96a 50%, #c9a84c 100%);
  border-radius: 50%;
  border: none;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8px 32px rgba(201,168,76,0.45), 0 2px 8px rgba(0,0,0,0.3);
  z-index: 9999;
  transition: transform 0.3s cubic-bezier(.34,1.56,.64,1), box-shadow 0.3s;
  animation: botPulse 3s ease-in-out infinite;
}
#bot-trigger:hover {
  transform: scale(1.12);
  box-shadow: 0 12px 40px rgba(201,168,76,0.6), 0 2px 8px rgba(0,0,0,0.3);
}
#bot-trigger.open { animation: none; transform: scale(0.9) rotate(15deg); }

@keyframes botPulse {
  0%,100% { box-shadow: 0 8px 32px rgba(201,168,76,0.45), 0 0 0 0 rgba(201,168,76,0.3); }
  50%      { box-shadow: 0 8px 32px rgba(201,168,76,0.45), 0 0 0 12px rgba(201,168,76,0); }
}

/* Robot SVG icon */
.bot-icon { width: 34px; height: 34px; }

/* Burbuja de hint */
#bot-hint {
  position: fixed;
  bottom: 106px; right: 32px;
  background: #0d0d0d;
  color: #c9a84c;
  font-family: 'DM Sans', sans-serif;
  font-size: 0.78rem;
  font-weight: 500;
  padding: 8px 14px;
  border-radius: 20px 20px 4px 20px;
  border: 1px solid rgba(201,168,76,0.3);
  white-space: nowrap;
  z-index: 9998;
  opacity: 0;
  transform: translateY(8px);
  transition: opacity 0.4s, transform 0.4s;
  pointer-events: none;
}
#bot-hint.visible { opacity: 1; transform: translateY(0); }

/* ── Ventana del chat ── */
#bot-window {
  position: fixed;
  bottom: 110px; right: 32px;
  width: 360px;
  max-height: 520px;
  background: #0d0d0d;
  border: 1px solid rgba(201,168,76,0.25);
  border-radius: 20px;
  display: flex; flex-direction: column;
  z-index: 9999;
  box-shadow: 0 24px 64px rgba(0,0,0,0.6), 0 0 0 1px rgba(201,168,76,0.1);
  overflow: hidden;
  opacity: 0;
  transform: translateY(20px) scale(0.95);
  pointer-events: none;
  transition: opacity 0.3s, transform 0.3s cubic-bezier(.34,1.56,.64,1);
}
#bot-window.open {
  opacity: 1;
  transform: translateY(0) scale(1);
  pointer-events: all;
}

/* Header */
.bot-header {
  background: linear-gradient(135deg, #1a1a0a 0%, #0d0d0d 100%);
  border-bottom: 1px solid rgba(201,168,76,0.2);
  padding: 14px 16px;
  display: flex; align-items: center; gap: 12px;
  flex-shrink: 0;
}
.bot-avatar {
  width: 40px; height: 40px;
  background: linear-gradient(135deg, #c9a84c, #e8c96a);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.bot-avatar svg { width: 22px; height: 22px; }
.bot-name { font-family: 'Playfair Display', serif; font-size: 0.95rem; font-weight: 700; color: #c9a84c; }
.bot-status { font-family: 'DM Sans', sans-serif; font-size: 0.72rem; color: rgba(255,255,255,0.45); display: flex; align-items: center; gap: 4px; }
.bot-dot { width: 6px; height: 6px; background: #4ade80; border-radius: 50%; animation: blink 2s infinite; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.4} }
.bot-close { margin-left: auto; background: none; border: none; color: rgba(255,255,255,0.4); cursor: pointer; font-size: 1.1rem; padding: 4px; transition: color 0.2s; }
.bot-close:hover { color: #c9a84c; }

/* Mensajes */
#bot-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex; flex-direction: column; gap: 12px;
  scroll-behavior: smooth;
}
#bot-messages::-webkit-scrollbar { width: 4px; }
#bot-messages::-webkit-scrollbar-track { background: transparent; }
#bot-messages::-webkit-scrollbar-thumb { background: rgba(201,168,76,0.3); border-radius: 2px; }

.msg { display: flex; gap: 8px; align-items: flex-end; }
.msg.user { flex-direction: row-reverse; }

.msg-bubble {
  max-width: 82%;
  padding: 10px 14px;
  border-radius: 16px;
  font-family: 'DM Sans', sans-serif;
  font-size: 0.84rem;
  line-height: 1.5;
}
.msg.bot .msg-bubble {
  background: rgba(255,255,255,0.06);
  color: rgba(255,255,255,0.88);
  border-bottom-left-radius: 4px;
  border: 1px solid rgba(255,255,255,0.08);
}
.msg.user .msg-bubble {
  background: linear-gradient(135deg, #c9a84c, #b8962a);
  color: #0d0d0d;
  font-weight: 500;
  border-bottom-right-radius: 4px;
}

/* Typing indicator */
.typing-dots { display: flex; gap: 4px; padding: 4px 0; }
.typing-dots span {
  width: 6px; height: 6px;
  background: rgba(201,168,76,0.6);
  border-radius: 50%;
  animation: typing 1.2s infinite;
}
.typing-dots span:nth-child(2) { animation-delay: 0.2s; }
.typing-dots span:nth-child(3) { animation-delay: 0.4s; }
@keyframes typing { 0%,60%,100%{transform:translateY(0)} 30%{transform:translateY(-6px)} }

/* Sugerencias rápidas */
#bot-suggestions {
  padding: 0 16px 10px;
  display: flex; flex-wrap: wrap; gap: 6px;
  flex-shrink: 0;
}
.sug-btn {
  background: rgba(201,168,76,0.1);
  border: 1px solid rgba(201,168,76,0.25);
  color: #c9a84c;
  font-family: 'DM Sans', sans-serif;
  font-size: 0.74rem;
  padding: 5px 12px;
  border-radius: 20px;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
  white-space: nowrap;
}
.sug-btn:hover { background: rgba(201,168,76,0.2); border-color: rgba(201,168,76,0.5); }

/* Input */
.bot-input-row {
  display: flex; gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid rgba(255,255,255,0.07);
  flex-shrink: 0;
}
#bot-input {
  flex: 1;
  background: rgba(255,255,255,0.07);
  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 12px;
  padding: 10px 14px;
  color: #fff;
  font-family: 'DM Sans', sans-serif;
  font-size: 0.84rem;
  outline: none;
  transition: border-color 0.2s;
}
#bot-input:focus { border-color: rgba(201,168,76,0.5); }
#bot-input::placeholder { color: rgba(255,255,255,0.3); }
#bot-send {
  width: 40px; height: 40px;
  background: linear-gradient(135deg, #c9a84c, #b8962a);
  border: none; border-radius: 12px;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: transform 0.2s, opacity 0.2s;
  flex-shrink: 0;
}
#bot-send:hover { transform: scale(1.08); }
#bot-send:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }
#bot-send svg { width: 16px; height: 16px; fill: #0d0d0d; }

/* Responsive móvil */
@media (max-width: 420px) {
  #bot-window { width: calc(100vw - 24px); right: 12px; bottom: 100px; }
  #bot-trigger { right: 16px; bottom: 24px; }
  #bot-hint { right: 16px; }
}
</style>

<!-- ── Hint bubble ── -->
<div id="bot-hint">💬 ¿Buscas una propiedad?</div>

<!-- ── Botón flotante ── -->
<button id="bot-trigger" aria-label="Abrir asistente InmoVista" onclick="toggleBot()">
  <svg class="bot-icon" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- cabeza -->
    <rect x="10" y="12" width="28" height="22" rx="6" fill="#0d0d0d" stroke="#0d0d0d" stroke-width="1"/>
    <!-- ojos -->
    <circle cx="18" cy="22" r="3.5" fill="#00d4ff"/>
    <circle cx="30" cy="22" r="3.5" fill="#00d4ff"/>
    <circle cx="19" cy="21" r="1.2" fill="#fff"/>
    <circle cx="31" cy="21" r="1.2" fill="#fff"/>
    <!-- boca -->
    <path d="M18 28 Q24 32 30 28" stroke="#4ade80" stroke-width="2" stroke-linecap="round" fill="none"/>
    <!-- antena -->
    <line x1="24" y1="12" x2="24" y2="6" stroke="#0d0d0d" stroke-width="2.5" stroke-linecap="round"/>
    <circle cx="24" cy="5" r="2.5" fill="#0d0d0d"/>
    <!-- cuerpo -->
    <rect x="16" y="34" width="16" height="8" rx="3" fill="#0d0d0d"/>
    <!-- brazos -->
    <rect x="6" y="34" width="8" height="5" rx="2.5" fill="#0d0d0d"/>
    <rect x="34" y="34" width="8" height="5" rx="2.5" fill="#0d0d0d"/>
  </svg>
</button>

<!-- ── Ventana del chat ── -->
<div id="bot-window" role="dialog" aria-label="Asistente InmoVista">

  <!-- Header -->
  <div class="bot-header">
    <div class="bot-avatar">
      <svg viewBox="0 0 48 48" fill="none">
        <rect x="10" y="12" width="28" height="22" rx="6" fill="#0d0d0d"/>
        <circle cx="18" cy="22" r="3.5" fill="#00d4ff"/>
        <circle cx="30" cy="22" r="3.5" fill="#00d4ff"/>
        <circle cx="19" cy="21" r="1.2" fill="#fff"/>
        <circle cx="31" cy="21" r="1.2" fill="#fff"/>
        <path d="M18 28 Q24 32 30 28" stroke="#4ade80" stroke-width="2" stroke-linecap="round" fill="none"/>
        <line x1="24" y1="12" x2="24" y2="6" stroke="#0d0d0d" stroke-width="2.5" stroke-linecap="round"/>
        <circle cx="24" cy="5" r="2.5" fill="#0d0d0d"/>
        <rect x="16" y="34" width="16" height="8" rx="3" fill="#0d0d0d"/>
        <rect x="6" y="34" width="8" height="5" rx="2.5" fill="#0d0d0d"/>
        <rect x="34" y="34" width="8" height="5" rx="2.5" fill="#0d0d0d"/>
      </svg>
    </div>
    <div>
      <div class="bot-name">InmoBot</div>
      <div class="bot-status"><span class="bot-dot"></span> En línea — InmoVista</div>
    </div>
    <button class="bot-close" onclick="toggleBot()" aria-label="Cerrar">✕</button>
  </div>

  <!-- Mensajes -->
  <div id="bot-messages"></div>

  <!-- Sugerencias rápidas -->
  <div id="bot-suggestions">
    <button class="sug-btn" onclick="sendSuggestion(this)">🏠 Ver propiedades</button>
    <button class="sug-btn" onclick="sendSuggestion(this)">📅 Agendar visita</button>
    <button class="sug-btn" onclick="sendSuggestion(this)">💰 Precios</button>
    <button class="sug-btn" onclick="sendSuggestion(this)">📍 Zonas disponibles</button>
  </div>

  <!-- Input -->
  <div class="bot-input-row">
    <input id="bot-input" type="text" placeholder="Escribe tu pregunta..."
           onkeydown="if(event.key==='Enter') sendMessage()"
           maxlength="300" autocomplete="off">
    <button id="bot-send" onclick="sendMessage()" aria-label="Enviar">
      <svg viewBox="0 0 24 24"><path d="M2 21l21-9L2 3v7l15 2-15 2v7z"/></svg>
    </button>
  </div>
</div>

<!-- ═══════════════════════════════════════
     INMOVISTA BOT — lógica JavaScript
═══════════════════════════════════════ -->
<script>
(function() {
  const SYSTEM_PROMPT = `Eres InmoBot, el asistente virtual inteligente de InmoVista, una plataforma inmobiliaria colombiana. Tu personalidad es amigable, profesional y entusiasta con las propiedades.

Tu función principal es ayudar a los usuarios a:
1. Agendar visitas y citas para ver propiedades
2. Responder preguntas sobre propiedades disponibles (casas, apartamentos, terrenos, oficinas, locales)
3. Informar sobre tipos de operación: venta y arriendo
4. Orientar sobre el proceso de compra o arriendo en Colombia
5. Guiar al usuario hacia registrarse o iniciar sesión si quiere agendar

Información de la plataforma:
- Propiedades en ciudades colombianas, principalmente Bucaramanga y área metropolitana
- Para agendar una cita el usuario debe estar registrado como cliente
- El sistema tiene roles: admin, inmobiliaria, cliente, usuario
- URL de registro: /registro.jsp | URL de login: /login.jsp | Propiedades: /lista.jsp

Reglas importantes:
- Responde SIEMPRE en español
- Sé conciso — máximo 3 oraciones por respuesta
- Si el usuario quiere agendar una cita, dile que debe registrarse primero e ir a la página de detalle de la propiedad
- Usa emojis con moderación (máximo 1 por mensaje)
- No inventes precios ni direcciones específicas
- Si no sabes algo, di "Para más detalles, contáctanos directamente"`;

  let history = [];
  let isOpen = false;
  let hintShown = false;

  // Mostrar hint después de 4 segundos
  setTimeout(() => {
    if (!isOpen) {
      document.getElementById('bot-hint').classList.add('visible');
      hintShown = true;
      setTimeout(() => {
        document.getElementById('bot-hint').classList.remove('visible');
      }, 4000);
    }
  }, 4000);

  window.toggleBot = function() {
    isOpen = !isOpen;
    const win = document.getElementById('bot-window');
    const btn = document.getElementById('bot-trigger');
    const hint = document.getElementById('bot-hint');

    win.classList.toggle('open', isOpen);
    btn.classList.toggle('open', isOpen);
    hint.classList.remove('visible');

    if (isOpen && history.length === 0) {
      setTimeout(() => addBotMessage('¡Hola! Soy InmoBot 🤖 ¿En qué te puedo ayudar hoy? Puedo orientarte sobre propiedades o ayudarte a agendar una visita.'), 300);
    }
    if (isOpen) {
      setTimeout(() => document.getElementById('bot-input').focus(), 350);
    }
  };

  window.sendSuggestion = function(btn) {
    const text = btn.textContent.replace(/^[^\w]+/, '').trim();
    document.getElementById('bot-input').value = text;
    sendMessage();
    // Ocultar sugerencias después de usarlas
    document.getElementById('bot-suggestions').style.display = 'none';
  };

  window.sendMessage = async function() {
    const input = document.getElementById('bot-input');
    const text = input.value.trim();
    if (!text) return;

    input.value = '';
    document.getElementById('bot-send').disabled = true;

    addUserMessage(text);
    history.push({ role: 'user', content: text });

    const typingId = addTyping();

    try {
      const response = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'claude-sonnet-4-20250514',
          max_tokens: 300,
          system: SYSTEM_PROMPT,
          messages: history
        })
      });

      removeTyping(typingId);

      if (!response.ok) throw new Error('API error');

      const data = await response.json();
      const reply = data.content?.[0]?.text || 'Lo siento, no pude procesar tu mensaje. Intenta de nuevo.';

      history.push({ role: 'assistant', content: reply });
      addBotMessage(reply);

    } catch (e) {
      removeTyping(typingId);
      // Fallback con respuestas inteligentes predefinidas
      const fallback = getFallback(text);
      history.push({ role: 'assistant', content: fallback });
      addBotMessage(fallback);
    }

    document.getElementById('bot-send').disabled = false;
    document.getElementById('bot-input').focus();
  };

  function getFallback(text) {
    const t = text.toLowerCase();
    if (t.includes('cita') || t.includes('visita') || t.includes('agendar') || t.includes('ver')) {
      return 'Para agendar una visita, regístrate como cliente en /registro.jsp, luego busca la propiedad que te interesa y haz clic en "Solicitar Visita" 📅';
    }
    if (t.includes('precio') || t.includes('costo') || t.includes('valor') || t.includes('cuánto')) {
      return 'Los precios varían según el tipo y ubicación de la propiedad. Visita /lista.jsp para ver todas las opciones con sus precios actualizados 💰';
    }
    if (t.includes('propiedad') || t.includes('casa') || t.includes('apto') || t.includes('arrend') || t.includes('venta')) {
      return 'Tenemos casas, apartamentos, terrenos y locales en venta y arriendo. Puedes filtrar por ciudad, precio y tipo en nuestra página de propiedades 🏠';
    }
    if (t.includes('registro') || t.includes('registrar') || t.includes('cuenta')) {
      return 'Puedes registrarte gratis en /registro.jsp. Con tu cuenta podrás agendar visitas y gestionar tus solicitudes fácilmente.';
    }
    if (t.includes('bucaramanga') || t.includes('zona') || t.includes('ciudad') || t.includes('sector')) {
      return 'Contamos con propiedades en Bucaramanga y su área metropolitana. Usa el filtro de ciudad en /lista.jsp para ver disponibilidad por zona 📍';
    }
    return 'Entiendo tu consulta. Para más información detallada, visita nuestra sección de propiedades o contáctanos directamente. ¿Hay algo más en lo que pueda ayudarte?';
  }

  function addUserMessage(text) {
    const msgs = document.getElementById('bot-messages');
    const div = document.createElement('div');
    div.className = 'msg user';
    div.innerHTML = `<div class="msg-bubble">${escapeHtml(text)}</div>`;
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
  }

  function addBotMessage(text) {
    const msgs = document.getElementById('bot-messages');
    const div = document.createElement('div');
    div.className = 'msg bot';
    // Convertir URLs en enlaces
    const linked = text.replace(/(\/\w+\.jsp\S*)/g, '<a href="$1" style="color:#c9a84c;text-decoration:underline;">$1</a>');
    div.innerHTML = `<div class="msg-bubble">${linked}</div>`;
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
  }

  function addTyping() {
    const msgs = document.getElementById('bot-messages');
    const id = 'typing-' + Date.now();
    const div = document.createElement('div');
    div.className = 'msg bot';
    div.id = id;
    div.innerHTML = `<div class="msg-bubble"><div class="typing-dots"><span></span><span></span><span></span></div></div>`;
    msgs.appendChild(div);
    msgs.scrollTop = msgs.scrollHeight;
    return id;
  }

  function removeTyping(id) {
    const el = document.getElementById(id);
    if (el) el.remove();
  }

  function escapeHtml(text) {
    return text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }
})();
</script>
