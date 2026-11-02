'use strict';
const toggle = document.querySelector('#menu-toggle');
const overlay = document.querySelector('#overlay');
const sidebar = document.querySelector('#sidebar');
const desktop = matchMedia('(min-width:761px)');
let desktopVisible = true;
let mobileVisible = false;
function navigationVisible() { return desktop.matches ? desktopVisible : mobileVisible; }
function renderNavigation() {
  const visible = navigationVisible();
  document.body.classList.toggle('sidebar-hidden', desktop.matches && !visible);
  document.body.classList.toggle('nav-open', !desktop.matches && visible);
  toggle.setAttribute('aria-expanded', String(visible));
  toggle.setAttribute('aria-label', visible ? 'Hide sidebar' : 'Show sidebar');
  overlay.hidden = desktop.matches || !visible;
  sidebar.inert = !visible;
}
function closeMobileNavigation() {
  if (!desktop.matches) { mobileVisible = false; renderNavigation(); }
}
toggle.addEventListener('click', () => {
  if (desktop.matches) desktopVisible = !desktopVisible;
  else mobileVisible = !mobileVisible;
  renderNavigation();
  if (!desktop.matches && mobileVisible) sidebar.querySelector('a').focus();
});
overlay.addEventListener('click', () => { closeMobileNavigation(); toggle.focus(); });
document.addEventListener('keydown', event => {
  if (desktop.matches || !mobileVisible) return;
  if (event.key === 'Escape') { closeMobileNavigation(); toggle.focus(); }
  if (event.key === 'Tab') {
    const controls = [...sidebar.querySelectorAll('a,button')].filter(el => !el.closest('[hidden]'));
    if (event.shiftKey && document.activeElement === controls[0]) { event.preventDefault(); controls.at(-1).focus(); }
    else if (!event.shiftKey && document.activeElement === controls.at(-1)) { event.preventDefault(); controls[0].focus(); }
  }
});
desktop.addEventListener('change', () => { mobileVisible = false; renderNavigation(); });
renderNavigation();
const moduleButtons = [...document.querySelectorAll('.module-toggle')];
function expandModule(button, open) {
  button.setAttribute('aria-expanded', String(open));
  document.getElementById(button.getAttribute('aria-controls')).hidden = !open;
}
moduleButtons.forEach(button => button.addEventListener('click', () => {
  const open = button.getAttribute('aria-expanded') !== 'true';
  moduleButtons.forEach(other => expandModule(other, other === button && open));
}));
function markActive() {
  const hash = location.hash || '#dashboard';
  let selected;
  document.querySelectorAll('nav a').forEach(link => {
    if (link.hash === hash) { link.setAttribute('aria-current', 'location'); selected = link; }
    else link.removeAttribute('aria-current');
  });
  const preview = document.querySelector('#module-preview');
  preview.hidden = !selected?.dataset.module;
  if (selected?.dataset.module) {
    const group = selected.closest('.nav-module');
    moduleButtons.forEach(button => expandModule(button, button === group.querySelector('button')));
    document.querySelector('#module-title').textContent = selected.textContent;
    document.querySelector('#module-parent').textContent = selected.dataset.module;
    preview.scrollIntoView({block:'start'});
    preview.focus({preventScroll:true});
  }
}
window.addEventListener('hashchange', markActive);
markActive();
sidebar.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
  closeMobileNavigation();
  if (!desktop.matches) toggle.focus();
  if (link.hash === location.hash) markActive();
}));
const search = document.querySelector('#search');
function filterRecords() {
  let visible = 0;
  document.querySelectorAll('#records-body tr').forEach(row => {
    row.hidden = !row.textContent.toLowerCase().includes(search.value.trim().toLowerCase());
    if (!row.hidden) visible++;
  });
  document.querySelector('#no-results').hidden = visible > 0;
}
search.addEventListener('input', filterRecords);
let sequence = 4;
document.querySelector('#record-form').addEventListener('submit', event => {
  event.preventDefault();
  const data = new FormData(event.currentTarget);
  const customer = String(data.get('customer')).trim();
  if (!customer) { document.querySelector('#feedback').textContent = 'Enter a customer name.'; return; }
  const row = document.createElement('tr');
  const values = [`INV-${String(sequence++).padStart(3, '0')}`, customer, data.get('status'), new Intl.NumberFormat('en-IN', {style:'currency',currency:'INR'}).format(Number(data.get('amount')))];
  values.forEach((value, index) => {
    const cell = document.createElement('td');
    if (index === 2) { const badge = document.createElement('span'); badge.className = `badge ${value === 'Paid' ? 'paid' : 'pending'}`; badge.textContent = value; cell.append(badge); }
    else cell.textContent = value;
    if (index === 3) cell.className = 'amount';
    row.append(cell);
  });
  document.querySelector('#records-body').prepend(row);
  event.currentTarget.reset();
  filterRecords();
  document.querySelector('#feedback').textContent = 'Sample record added. Demo records reset when the page reloads.';
});
