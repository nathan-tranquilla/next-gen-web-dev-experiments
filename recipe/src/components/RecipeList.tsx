// src/components/RecipeList.tsx
import React from 'react';
import { Recipe } from '../types.ts';

interface RecipeListProps {
  recipes: Recipe[];
}

const RecipeList: React.FC<RecipeListProps> = ({ recipes }) => {
  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Recipes</h2>
      {recipes.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No recipes added yet. Add your first recipe to get started!</p>
      ) : (
        <div className="space-y-6">
          {recipes.map(recipe => (
            <div key={recipe.id} className="border border-gray-200 rounded-lg p-4">
              <div className="flex justify-between items-start mb-3">
                <h3 className="text-xl font-semibold text-gray-900">{recipe.name}</h3>
                <div className="text-right">
                  <span className="text-sm text-gray-600">Serves {recipe.servings}</span>
                  <p className="text-sm font-medium text-green-600">
                    {recipe.nutritionPerServing.totalCalories} cal/serving
                  </p>
                </div>
              </div>
              
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Ingredients:</h4>
                  <ul className="space-y-1">
                    {recipe.ingredients.map((ing, idx) => (
                      <li key={idx} className="text-sm text-gray-700">
                        • {`${ing.quantity} ${ing.unit} ${ing.name}`}
                      </li>
                    ))}
                  </ul>
                </div>
                
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Steps:</h4>
                  <ol className="space-y-1">
                    {recipe.steps.map((step, idx) => (
                      <li key={idx} className="text-sm text-gray-700 flex">
                        <span className="font-medium text-gray-500 mr-2">{idx + 1}.</span>
                        <span>{step}</span>
                      </li>
                    ))}
                  </ol>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default RecipeList;