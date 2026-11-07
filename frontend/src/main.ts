import App from './App.svelte';
import './styles/app.css';

const target = document.getElementById('app');
if (target) {
  new App({ target });
}
