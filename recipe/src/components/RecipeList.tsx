// src/components/RecipeList.tsx
import React from 'react';
import { Recipe } from '../types.ts';

interface RecipeListProps {
  recipes: Recipe[];
}

const RecipeList: React.FC<RecipeListProps> = ({ recipes }) => {
  return (
    <div>
      <h2>Recipes</h2>
      {recipes.map(recipe => (
        <div key={recipe.id}>
          <h3>{recipe.name} (Serves {recipe.servings})</h3>
          <p>Nutrition per serving: {recipe.nutritionPerServing.totalCalories} calories</p>
          <h4>Ingredients:</h4>
          <ul>
            {recipe.ingredients.map((ing, idx) => (
              <li key={idx}>{`${ing.quantity} ${ing.unit} ${ing.name}`}</li>
            ))}
          </ul>
          <h4>Steps:</h4>
          <ol>
            {recipe.steps.map((step, idx) => (
              <li key={idx}>{step}</li>
            ))}
          </ol>
        </div>
      ))}
    </div>
  );
};

export default RecipeList;