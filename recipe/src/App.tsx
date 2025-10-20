// src/App.tsx
import React, { useState } from 'react';
// import RecipeForm from './components/RecipeForm.tsx';
import { make as RecipeForm } from './components/RecipeForm.res.mjs' 
import RecipeList from './components/RecipeList.tsx';
import { recipe as Recipe } from './Types.gen.tsx';

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
          {/* <RecipeForm onAddRecipe={addRecipe} /> */}
          <RecipeForm onAddRecipe={addRecipe} />
          <RecipeList recipes={recipes} />
        </div>
      </div>
    </div>
  );
}

export default App;