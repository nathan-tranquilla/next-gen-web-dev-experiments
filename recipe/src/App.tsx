// src/App.tsx
import React, { useState } from 'react';
import RecipeForm from './components/RecipeForm.tsx';
import RecipeList from './components/RecipeList.tsx';
import { Recipe } from './types.ts';

function App() {
  const [recipes, setRecipes] = useState<Recipe[]>([]);

  const addRecipe = (recipe: Recipe) => {
    setRecipes([...recipes, recipe]);
  };

  return (
    <div className="App">
      <h1>Recipe Planner</h1>
      <RecipeForm onAddRecipe={addRecipe} />
      <RecipeList recipes={recipes} />
      {/* TODO: Add Meal Planner Calendar component here */}
    </div>
  );
}

export default App;