const state = {
  favorite: false,
  ctaLoading: false,
  useBlueAccent: false,
};

const $ = (id) => document.getElementById(id);

function toast(message) {
  const el = $('toast');
  el.textContent = message;
  el.classList.remove('hidden');
  window.clearTimeout(toast._t);
  toast._t = window.setTimeout(() => el.classList.add('hidden'), 1800);
}

function updateStates() {
  $('state-loading').classList.toggle('hidden', !$('ctl-loading').checked);
  $('state-empty').classList.toggle('hidden', !$('ctl-empty').checked);
  $('state-error').classList.toggle('hidden', !$('ctl-error').checked);

  state.ctaLoading = $('ctl-cta').checked;
  const primary = $('btn-primary');
  primary.disabled = state.ctaLoading;
  primary.textContent = state.ctaLoading ? 'Carregando...' : 'Apliquei hoje';
}

$('ctl-loading').addEventListener('change', updateStates);
$('ctl-empty').addEventListener('change', updateStates);
$('ctl-error').addEventListener('change', updateStates);
$('ctl-cta').addEventListener('change', updateStates);

$('btn-favorite').addEventListener('click', () => {
  state.favorite = !state.favorite;
  $('btn-favorite').textContent = state.favorite ? 'Nos favoritos' : 'Favoritar';
  toast(state.favorite ? 'Adicionado aos favoritos' : 'Removido dos favoritos');
});

$('btn-primary').addEventListener('click', () => toast('Ação principal acionada.'));
$('btn-secondary').addEventListener('click', () => toast('Ação secundária acionada.'));
$('btn-sync').addEventListener('click', () => toast('Sincronização simulada.'));
$('btn-retry').addEventListener('click', () => toast('Retry acionado.'));

$('toggle-accent').addEventListener('click', () => {
  state.useBlueAccent = !state.useBlueAccent;
  document.documentElement.style.setProperty(
    '--accent',
    state.useBlueAccent ? '#2F4B66' : '#B87444',
  );
  toast(state.useBlueAccent ? 'Acento: Deep Blue' : 'Acento: Copper');
});

updateStates();
