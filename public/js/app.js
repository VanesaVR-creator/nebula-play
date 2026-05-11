(function () {
'use strict';
const $ = (selector, scope = document) => scope.querySelector(selector);
const $$ = (selector, scope = document) => [...scope.querySelectorAll(selector)];

async function api(url, options = {}) {
  const response = await fetch(url, {
    headers: {
      ...(options.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }),
      ...(options.headers || {}),
    },
    ...options,
  });

  const isJson = response.headers.get('content-type')?.includes('application/json');
  const data = isJson ? await response.json() : await response.text();
  if (!response.ok) {
    throw new Error(data?.error || data || 'Ocurrió un error.');
  }
  return data;
}

function setActiveNav() {
  const current = window.location.pathname;
  $$('.nav-link[data-match]').forEach((link) => {
    const match = link.dataset.match;
    const isActive = match && current.includes(match);
    link.classList.toggle('active', Boolean(isActive));
  });
}

async function ensureAuth(allowed = []) {
  try {
    const { user } = await api('/api/auth/me');
    if (!user) {
      window.location.href = '/';
      return null;
    }
    if (allowed.length && !allowed.includes(user.tipo_usuario)) {
      window.location.href = user.tipo_usuario === 'empresa'
        ? '/pages/company.html'
        : user.tipo_usuario === 'admin'
          ? '/pages/admin.html'
          : '/pages/profile.html';
      return null;
    }
    return user;
  } catch {
    window.location.href = '/';
    return null;
  }
}

async function logout() {
  const ok = confirm('¿Deseas cerrar sesión?');
  if (!ok) return;
  await api('/api/auth/logout', { method: 'POST' });
  window.location.href = '/';
}

function bindLogout() {
  $$('.js-logout').forEach((btn) => {
    if (btn.dataset.boundLogout) return;
    btn.dataset.boundLogout = 'true';
    btn.addEventListener('click', logout);
  });
}

function toast(target, message, type = 'notice') {
  if (!target) return;
  target.textContent = message;
  target.className = type;
}

function serializeForm(form) {
  const formData = new FormData(form);
  return Object.fromEntries(formData.entries());
}

function initTheme() {
  const saved = localStorage.getItem('nebula-theme') || 'dark';
  document.body.dataset.theme = saved;
}

function toggleTheme() {
  const current = document.body.dataset.theme || 'dark';
  const next = current === 'dark' ? 'light' : 'dark';
  document.body.dataset.theme = next;
  localStorage.setItem('nebula-theme', next);
  updateThemeButtons();
}

function updateThemeButtons() {
  const current = document.body.dataset.theme || 'dark';
  $$('.js-theme-toggle').forEach((btn) => {
    btn.textContent = current === 'dark' ? 'Modo claro' : 'Modo oscuro';
    btn.setAttribute('aria-label', btn.textContent);
  });
}

function ensureThemeButtons() {
  $$('.nav-links').forEach((nav) => {
    if (nav.querySelector('.js-theme-toggle')) return;
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'nav-link theme-toggle js-theme-toggle';
    btn.addEventListener('click', toggleTheme);
    nav.insertBefore(btn, nav.querySelector('.js-logout'));
  });
  updateThemeButtons();
}

function ensureFooter() {
  if (document.querySelector('.footer')) return;
  const footer = document.createElement('footer');
  footer.className = 'footer';
  footer.innerHTML = `
    <div><strong>Nebula Play</strong><span>Plataforma de reclutamiento inteligente y perfiles profesionales.</span></div>
    <div class="footer__links"><a href="/pages/about.html">Acerca de</a><a href="/pages/contact.html">Contacto</a><a href="/pages/support.html">Ayuda</a></div>
  `;
  document.body.appendChild(footer);
}

function openModal(id) {
  const modal = document.getElementById(id);
  if (!modal) return;
  modal.classList.remove('hidden');
  modal.setAttribute('aria-hidden', 'false');
}

function closeModal(id) {
  const modal = document.getElementById(id);
  if (!modal) return;
  modal.classList.add('hidden');
  modal.setAttribute('aria-hidden', 'true');
}

function bindModals() {
  $$('[data-close-modal]').forEach((btn) => {
    if (btn.dataset.boundModal) return;
    btn.dataset.boundModal = 'true';
    btn.addEventListener('click', () => closeModal(btn.dataset.closeModal));
  });
  $$('.modal-backdrop').forEach((modal) => {
    if (modal.dataset.boundBackdrop) return;
    modal.dataset.boundBackdrop = 'true';
    modal.addEventListener('click', (event) => {
      if (event.target === modal) closeModal(modal.id);
    });
  });
}

async function handleLoginSubmit(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const message = document.getElementById('loginMessage');
  const email = form.email?.value.trim();
  const password = form.password?.value;

  toast(message, 'Validando acceso...', 'notice');

  try {
    const data = await api('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });

    toast(message, 'Inicio de sesión correcto. Redirigiendo...', 'success');
    setTimeout(() => {
      window.location.href = data.redirect || '/pages/profile.html';
    }, 250);
  } catch (error) {
    toast(message, error.message || 'No se pudo iniciar sesión.', 'error');
  }
}

function bindLogin() {
  const form = document.getElementById('loginForm');
  if (!form) return;
  form.addEventListener('submit', handleLoginSubmit);
}

function initNebula() {
  initTheme();
  bindLogin();
  bindLogout();
  bindModals();
  setActiveNav();
  ensureThemeButtons();
  ensureFooter();
}

document.addEventListener('DOMContentLoaded', initNebula);

window.Nebula = {
  $, $$, api, ensureAuth, bindLogout, toast, serializeForm,
  setActiveNav, logout, openModal, closeModal, bindModals,
  toggleTheme, initTheme, ensureThemeButtons, ensureFooter,
};

})();
