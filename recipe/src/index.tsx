// src/index.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
// import { make as Router} from './Router.res.mjs';
import App from './UsersApp.tsx'

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);