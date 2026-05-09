/**
 * QueryGen AI — Plugin de Acessibilidade
 * 
 * Recursos:
 *  1. Leitura em voz alta (Text-to-Speech) com a Web Speech API
 *  2. Widget VLibras (VLIBRAS) — tradutor de Libras oficial do governo brasileiro
 * 
 * Como usar:
 *  Adicione este script no seu index.html ANTES do </body>:
 *
 *    <script src="acessibilidade_plugin.js"></script>
 *
 *  Opcionalmente, adicione também a linha abaixo para ativar o VLibras:
 *    <div vw class="enabled">
 *      <div vw-access-button class="active"></div>
 *      <div vw-plugin-wrapper>
 *        <div class="vw-plugin-top-wrapper"></div>
 *      </div>
 *    </div>
 *    <script src="https://vlibras.gov.br/app/vlibras-plugin.js"></script>
 *    <script>new window.VLibras.Widget('https://vlibras.gov.br/app');</script>
 */

(function () {
  'use strict';

  /* ─────────────── ESTADO GLOBAL ─────────────── */
  let ttsAtivo = false;
  let voz = null;
  let velocidade = 1.0;
  let volume = 1.0;
  let painelAberto = false;
  let destacandoElemento = null;
  let utteranceAtual = null;
  let modoLeituraAtivo = false;

  /* ─────────────── INJEÇÃO DE ESTILOS ─────────────── */
  const css = `
    #acc-fab {
      position: fixed;
      bottom: 24px;
      right: 24px;
      width: 56px;
      height: 56px;
      border-radius: 50%;
      background: #1565C0;
      color: #fff;
      border: none;
      cursor: pointer;
      font-size: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 16px rgba(0,0,0,0.28);
      z-index: 99998;
      transition: background 0.2s, transform 0.15s;
      outline: none;
    }
    #acc-fab:hover { background: #0D47A1; transform: scale(1.07); }
    #acc-fab:focus-visible { outline: 3px solid #FFD600; outline-offset: 3px; }

    #acc-painel {
      position: fixed;
      bottom: 90px;
      right: 24px;
      width: 320px;
      background: #fff;
      border-radius: 16px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.22);
      z-index: 99997;
      font-family: system-ui, sans-serif;
      overflow: hidden;
      transition: opacity 0.2s, transform 0.2s;
      opacity: 0;
      transform: translateY(12px) scale(0.97);
      pointer-events: none;
    }
    #acc-painel.aberto {
      opacity: 1;
      transform: translateY(0) scale(1);
      pointer-events: auto;
    }

    #acc-header {
      background: #1565C0;
      color: #fff;
      padding: 14px 18px;
      font-size: 15px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    #acc-header svg { flex-shrink: 0; }

    #acc-body { padding: 16px 18px; }

    .acc-secao { margin-bottom: 18px; }
    .acc-secao-titulo {
      font-size: 11px;
      font-weight: 600;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: #78909C;
      margin-bottom: 10px;
    }

    .acc-btn-grupo { display: flex; gap: 8px; flex-wrap: wrap; }

    .acc-btn {
      flex: 1 1 auto;
      padding: 9px 12px;
      border-radius: 8px;
      border: 1.5px solid #BBDEFB;
      background: #E3F2FD;
      color: #1565C0;
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      justify-content: center;
      transition: background 0.15s, border-color 0.15s;
      outline: none;
      white-space: nowrap;
    }
    .acc-btn:hover { background: #BBDEFB; border-color: #1565C0; }
    .acc-btn:focus-visible { outline: 3px solid #FFD600; }
    .acc-btn.ativo { background: #1565C0; color: #fff; border-color: #1565C0; }
    .acc-btn.ativo:hover { background: #0D47A1; }
    .acc-btn.perigo { border-color: #FFCDD2; background: #FFEBEE; color: #C62828; }
    .acc-btn.perigo:hover { background: #FFCDD2; }

    .acc-slider-linha {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 10px;
    }
    .acc-slider-label { font-size: 12px; color: #455A64; min-width: 72px; }
    .acc-slider-valor { font-size: 12px; font-weight: 600; color: #1565C0; min-width: 32px; text-align: right; }
    .acc-slider-linha input[type=range] {
      flex: 1;
      accent-color: #1565C0;
    }

    .acc-divisor { border: none; border-top: 1px solid #ECEFF1; margin: 14px 0; }

    .acc-status {
      font-size: 12px;
      color: #455A64;
      text-align: center;
      padding: 6px;
      background: #F5F5F5;
      border-radius: 8px;
      min-height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* destaque de leitura */
    .acc-lendo {
      outline: 3px solid #FFD600 !important;
      outline-offset: 2px !important;
      background-color: rgba(255, 214, 0, 0.18) !important;
      border-radius: 3px !important;
    }
  `;

  const style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  /* ─────────────── MARKUP DO PAINEL ─────────────── */
  const painelHTML = `
    <div id="acc-header" role="heading" aria-level="2">
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <circle cx="12" cy="12" r="10"/>
        <path d="M12 8v4l3 3"/>
      </svg>
      Acessibilidade
    </div>
    <div id="acc-body">

      <div class="acc-secao">
        <div class="acc-secao-titulo">♿ Leitura em voz alta</div>
        <div class="acc-btn-grupo" style="margin-bottom:10px;">
          <button class="acc-btn" id="acc-ler-pagina" aria-label="Ler toda a página em voz alta">
            ▶ Ler página
          </button>
          <button class="acc-btn" id="acc-pausar" aria-label="Pausar leitura" disabled>
            ⏸ Pausar
          </button>
          <button class="acc-btn perigo" id="acc-parar" aria-label="Parar leitura" disabled>
            ■ Parar
          </button>
        </div>

        <div class="acc-btn-grupo" style="margin-bottom:10px;">
          <button class="acc-btn" id="acc-modo-clique" title="Clique em qualquer texto da página para ouvi-lo">
            🖱 Ler ao clicar
          </button>
        </div>

        <div class="acc-slider-linha">
          <span class="acc-slider-label">Velocidade</span>
          <input type="range" min="0.5" max="2" step="0.1" value="1.0" id="acc-velocidade" aria-label="Velocidade da voz">
          <span class="acc-slider-valor" id="acc-velocidade-val">1.0×</span>
        </div>
        <div class="acc-slider-linha">
          <span class="acc-slider-label">Volume</span>
          <input type="range" min="0" max="1" step="0.1" value="1.0" id="acc-volume" aria-label="Volume da voz">
          <span class="acc-slider-valor" id="acc-volume-val">100%</span>
        </div>
      </div>

      <hr class="acc-divisor">

      <div class="acc-secao">
        <div class="acc-secao-titulo">🤟 Língua de sinais (LIBRAS)</div>
        <div class="acc-btn-grupo">
          <button class="acc-btn" id="acc-vlibras" aria-label="Ativar ou desativar o tradutor de Libras VLibras">
            Ativar VLibras
          </button>
        </div>
        <p style="font-size:11px; color:#78909C; margin-top:8px; line-height:1.5;">
          O VLibras é o tradutor oficial de Libras do governo federal.
          Ao ativar, um ícone flutuante aparecerá na página.
        </p>
      </div>

      <hr class="acc-divisor">

      <div class="acc-status" id="acc-status" aria-live="polite" aria-atomic="true">
        Pronto para leitura
      </div>
    </div>
  `;

  /* ─────────────── DOM ─────────────── */
  const painel = document.createElement('div');
  painel.id = 'acc-painel';
  painel.setAttribute('role', 'dialog');
  painel.setAttribute('aria-modal', 'false');
  painel.setAttribute('aria-label', 'Painel de acessibilidade');
  painel.innerHTML = painelHTML;
  document.body.appendChild(painel);

  const fab = document.createElement('button');
  fab.id = 'acc-fab';
  fab.setAttribute('aria-label', 'Abrir painel de acessibilidade');
  fab.setAttribute('aria-expanded', 'false');
  fab.innerHTML = `
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
      <circle cx="12" cy="4" r="2"/>
      <path d="M19 9H5l2 10h10l2-10zM12 10v9M9 13H7M17 13h-2"/>
    </svg>`;
  document.body.appendChild(fab);

  /* ─────────────── HELPERS TTS ─────────────── */
  function setStatus(msg) {
    const el = document.getElementById('acc-status');
    if (el) el.textContent = msg;
  }

  function carregarVoz() {
    const vozes = window.speechSynthesis.getVoices();
    voz = vozes.find(v => v.lang.startsWith('pt')) ||
          vozes.find(v => v.lang.startsWith('pt-BR')) ||
          vozes[0] || null;
  }

  if (window.speechSynthesis) {
    window.speechSynthesis.onvoiceschanged = carregarVoz;
    carregarVoz();
  }

  function falar(texto, onEnd) {
    if (!window.speechSynthesis) {
      setStatus('⚠ Navegador sem suporte a voz.');
      return;
    }
    window.speechSynthesis.cancel();
    const utt = new SpeechSynthesisUtterance(texto);
    utt.lang = 'pt-BR';
    utt.rate = velocidade;
    utt.volume = volume;
    if (voz) utt.voice = voz;
    utteranceAtual = utt;
    utt.onstart = () => {
      ttsAtivo = true;
      setStatus('🔊 Lendo…');
      atualizarBotoes();
    };
    utt.onend = () => {
      ttsAtivo = false;
      removerDestaque();
      setStatus('✔ Leitura concluída');
      atualizarBotoes();
      if (onEnd) onEnd();
    };
    utt.onerror = (e) => {
      if (e.error !== 'interrupted') {
        setStatus('⚠ Erro: ' + e.error);
      }
      ttsAtivo = false;
      atualizarBotoes();
    };
    window.speechSynthesis.speak(utt);
  }

  function removerDestaque() {
    if (destacandoElemento) {
      destacandoElemento.classList.remove('acc-lendo');
      destacandoElemento = null;
    }
  }

  function atualizarBotoes() {
    const btnPausar = document.getElementById('acc-pausar');
    const btnParar  = document.getElementById('acc-parar');
    if (!btnPausar || !btnParar) return;
    btnPausar.disabled = !ttsAtivo;
    btnParar.disabled  = !ttsAtivo;
    btnPausar.textContent = window.speechSynthesis.paused ? '▶ Retomar' : '⏸ Pausar';
  }

  /* Coleta o texto de elementos visíveis e relevantes */
  function coletarTextoPagina() {
    const seletores = [
      'h1, h2, h3, h4, h5, h6',
      'p',
      'label',
      'button:not([aria-hidden])',
      '[role="heading"]',
      '[aria-label]',
      'td, th',
    ].join(', ');
    const nos = Array.from(document.querySelectorAll(seletores));
    return nos
      .filter(el => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0 &&
               !el.closest('#acc-painel, #acc-fab');
      })
      .map(el => el.getAttribute('aria-label') || el.innerText || '')
      .filter(t => t.trim().length > 3)
      .join('. ');
  }

  /* ─────────────── VLIBRAS ─────────────── */
  let vlibrasAtivo = false;

  function ativarVLibras() {
    if (vlibrasAtivo) {
      setStatus('VLibras já está ativo.');
      return;
    }
    vlibrasAtivo = true;
    const btnVL = document.getElementById('acc-vlibras');
    if (btnVL) { btnVL.textContent = '✔ VLibras ativo'; btnVL.classList.add('ativo'); }

    // Estrutura requerida pelo VLibras
    const div = document.createElement('div');
    div.setAttribute('vw', '');
    div.className = 'enabled';
    div.innerHTML = `
      <div vw-access-button class="active"></div>
      <div vw-plugin-wrapper>
        <div class="vw-plugin-top-wrapper"></div>
      </div>`;
    document.body.appendChild(div);

    const s = document.createElement('script');
    s.src = 'https://vlibras.gov.br/app/vlibras-plugin.js';
    s.onload = () => {
      try {
        new window.VLibras.Widget('https://vlibras.gov.br/app');
        setStatus('🤟 VLibras iniciado! Clique no ícone azul da tela.');
      } catch(e) {
        setStatus('⚠ Erro ao iniciar VLibras.');
      }
    };
    s.onerror = () => setStatus('⚠ VLibras indisponível (sem internet?).');
    document.body.appendChild(s);
  }

  /* ─────────────── MODO CLIQUE PARA LER ─────────────── */
  function ativarModoClique() {
    modoLeituraAtivo = !modoLeituraAtivo;
    const btn = document.getElementById('acc-modo-clique');
    if (btn) {
      btn.classList.toggle('ativo', modoLeituraAtivo);
      btn.textContent = modoLeituraAtivo ? '✔ Modo clique ativo' : '🖱 Ler ao clicar';
    }
    if (modoLeituraAtivo) {
      document.body.style.cursor = 'crosshair';
      setStatus('Clique em qualquer texto da página para ouvi-lo.');
      document.addEventListener('click', handleCliqueNaPagina, true);
    } else {
      document.body.style.cursor = '';
      setStatus('Modo clique desativado.');
      document.removeEventListener('click', handleCliqueNaPagina, true);
    }
  }

  function handleCliqueNaPagina(e) {
    if (e.target.closest('#acc-painel') || e.target.closest('#acc-fab')) return;
    e.preventDefault();
    e.stopPropagation();
    const el = e.target;
    const texto = el.getAttribute('aria-label') || el.innerText || el.textContent || '';
    if (!texto.trim()) { setStatus('Nenhum texto encontrado nesse elemento.'); return; }
    removerDestaque();
    el.classList.add('acc-lendo');
    destacandoElemento = el;
    falar(texto.trim());
  }

  /* ─────────────── EVENTOS DO PAINEL ─────────────── */
  fab.addEventListener('click', () => {
    painelAberto = !painelAberto;
    painel.classList.toggle('aberto', painelAberto);
    fab.setAttribute('aria-expanded', painelAberto);
    if (painelAberto) {
      painel.querySelector('button, [tabindex]')?.focus();
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && painelAberto) {
      painelAberto = false;
      painel.classList.remove('aberto');
      fab.setAttribute('aria-expanded', 'false');
      fab.focus();
    }
  });

  painel.addEventListener('click', (e) => {
    const id = e.target.closest('button')?.id;
    if (!id) return;

    if (id === 'acc-ler-pagina') {
      const texto = coletarTextoPagina();
      if (!texto) { setStatus('Nenhum texto encontrado na página.'); return; }
      falar(texto);
    }
    if (id === 'acc-pausar') {
      if (window.speechSynthesis.paused) {
        window.speechSynthesis.resume();
        setStatus('▶ Continuando leitura…');
      } else {
        window.speechSynthesis.pause();
        setStatus('⏸ Pausado');
      }
      atualizarBotoes();
    }
    if (id === 'acc-parar') {
      window.speechSynthesis.cancel();
      removerDestaque();
      ttsAtivo = false;
      setStatus('■ Leitura interrompida');
      atualizarBotoes();
    }
    if (id === 'acc-modo-clique') {
      ativarModoClique();
    }
    if (id === 'acc-vlibras') {
      ativarVLibras();
    }
  });

  /* Sliders */
  const slVel = document.getElementById('acc-velocidade');
  const slVelVal = document.getElementById('acc-velocidade-val');
  if (slVel) {
    slVel.addEventListener('input', () => {
      velocidade = parseFloat(slVel.value);
      slVelVal.textContent = velocidade.toFixed(1) + '×';
    });
  }
  const slVol = document.getElementById('acc-volume');
  const slVolVal = document.getElementById('acc-volume-val');
  if (slVol) {
    slVol.addEventListener('input', () => {
      volume = parseFloat(slVol.value);
      slVolVal.textContent = Math.round(volume * 100) + '%';
    });
  }

  /* ─────────────── ATALHO DE TECLADO GLOBAL ─────────────── */
  // Alt + A = abre/fecha o painel
  document.addEventListener('keydown', (e) => {
    if (e.altKey && e.key === 'a') {
      fab.click();
    }
  });

  console.log('[Acessibilidade] Plugin carregado. Atalho: Alt+A');
})();
