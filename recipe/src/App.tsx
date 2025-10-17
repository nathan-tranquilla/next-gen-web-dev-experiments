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
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <h1 className="text-4xl font-bold text-gray-900 text-center mb-8">Recipe Planner</h1>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <RecipeForm onAddRecipe={addRecipe} />
          <RecipeList recipes={recipes} />
        </div>
        {/* TODO: Add Meal Planner Calendar component here */}
      </div>
    </div>
  );
}

export default App;