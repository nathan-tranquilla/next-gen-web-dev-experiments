import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import UsersPage from './components/UsersPage.tsx';
import UserPage from './components/UserPage.tsx';

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/users" element={<UsersPage />} />
          <Route path="/users/:userid" element={<UserPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;