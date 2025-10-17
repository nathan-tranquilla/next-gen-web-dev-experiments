// src/components/RecipeForm.tsx
import React, { useState } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { Recipe, Ingredient } from '../types.ts';
import { calculateNutrition } from '../utils/calculations.ts';

interface RecipeFormProps {
  onAddRecipe: (recipe: Recipe) => void;
}

const RecipeForm: React.FC<RecipeFormProps> = ({ onAddRecipe }) => {
  const [name, setName] = useState('');
  const [ingredients, setIngredients] = useState<Ingredient[]>([]);
  const [steps, setSteps] = useState<string[]>([]);
  const [servings, setServings] = useState(1);
  const [newIngredient, setNewIngredient] = useState({ name: '', quantity: 0, unit: 'g', caloriesPerUnit: 0 });
  const [newStep, setNewStep] = useState('');

  const addIngredient = () => {
    if (newIngredient.name && newIngredient.quantity > 0) {
      setIngredients([...ingredients, newIngredient]);
      setNewIngredient({ name: '', quantity: 0, unit: 'g', caloriesPerUnit: 0 });
    }
  };

  const addStep = () => {
    if (newStep) {
      setSteps([...steps, newStep]);
      setNewStep('');
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (name && ingredients.length > 0 && steps.length > 0 && servings > 0) {
      const nutrition = calculateNutrition(ingredients, servings);
      const recipe: Recipe = {
        id: uuidv4(),
        name,
        ingredients,
        steps,
        servings,
        nutritionPerServing: nutrition,
      };
      onAddRecipe(recipe);
      // Reset form
      setName('');
      setIngredients([]);
      setSteps([]);
      setServings(1);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <form onSubmit={handleSubmit} className="space-y-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Add New Recipe</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Name:
            </label>
            <input 
              type="text" 
              value={name} 
              onChange={e => setName(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Servings:
            </label>
            <input 
              type="number" 
              value={servings} 
              onChange={e => setServings(parseInt(e.target.value) || 1)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        <div>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Ingredients</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mb-3">
            <input
              type="text"
              placeholder="Ingredient name"
              value={newIngredient.name}
              onChange={e => setNewIngredient({ ...newIngredient, name: e.target.value })}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <input
              type="number"
              placeholder="Quantity"
              value={newIngredient.quantity}
              onChange={e => setNewIngredient({ ...newIngredient, quantity: parseFloat(e.target.value) || 0 })}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <select
              value={newIngredient.unit}
              onChange={e => setNewIngredient({ ...newIngredient, unit: e.target.value as Ingredient['unit'] })}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="g">g</option>
              <option value="oz">oz</option>
              <option value="ml">ml</option>
              <option value="cup">cup</option>
              <option value="tbsp">tbsp</option>
            </select>
            <input
              type="number"
              placeholder="Calories per unit"
              value={newIngredient.caloriesPerUnit}
              onChange={e => setNewIngredient({ ...newIngredient, caloriesPerUnit: parseFloat(e.target.value) || 0 })}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <button 
            type="button" 
            onClick={addIngredient}
            className="mb-3 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
          >
            Add Ingredient
          </button>
          <ul className="space-y-1 mb-4">
            {ingredients.map((ing, idx) => (
              <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded">
                {`${ing.quantity} ${ing.unit} ${ing.name} (${ing.caloriesPerUnit} cal/unit)`}
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Steps</h3>
          <div className="flex gap-2 mb-3">
            <input
              type="text"
              placeholder="Step description"
              value={newStep}
              onChange={e => setNewStep(e.target.value)}
              className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <button 
              type="button" 
              onClick={addStep}
              className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
            >
              Add Step
            </button>
          </div>
          <ol className="space-y-2 mb-6">
            {steps.map((step, idx) => (
              <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded flex">
                <span className="font-medium text-gray-600 mr-2">{idx + 1}.</span>
                <span>{step}</span>
              </li>
            ))}
          </ol>
        </div>

        <button 
          type="submit"
          className="w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-4 rounded-md transition-colors"
        >
          Save Recipe
        </button>
      </form>
    </div>
  );
};

export default RecipeForm;