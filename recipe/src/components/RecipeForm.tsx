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
    <form onSubmit={handleSubmit}>
      <h2>Add New Recipe</h2>
      <label>
        Name:
        <input type="text" value={name} onChange={e => setName(e.target.value)} />
      </label>
      <label>
        Servings:
        <input type="number" value={servings} onChange={e => setServings(parseInt(e.target.value) || 1)} />
      </label>
      <h3>Ingredients</h3>
      <input
        type="text"
        placeholder="Ingredient name"
        value={newIngredient.name}
        onChange={e => setNewIngredient({ ...newIngredient, name: e.target.value })}
      />
      <input
        type="number"
        placeholder="Quantity"
        value={newIngredient.quantity}
        onChange={e => setNewIngredient({ ...newIngredient, quantity: parseFloat(e.target.value) || 0 })}
      />
      <select
        value={newIngredient.unit}
        onChange={e => setNewIngredient({ ...newIngredient, unit: e.target.value as Ingredient['unit'] })}
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
      />
      <button type="button" onClick={addIngredient}>Add Ingredient</button>
      <ul>
        {ingredients.map((ing, idx) => (
          <li key={idx}>{`${ing.quantity} ${ing.unit} ${ing.name} (${ing.caloriesPerUnit} cal/unit)`}</li>
        ))}
      </ul>
      <h3>Steps</h3>
      <input
        type="text"
        placeholder="Step description"
        value={newStep}
        onChange={e => setNewStep(e.target.value)}
      />
      <button type="button" onClick={addStep}>Add Step</button>
      <ol>
        {steps.map((step, idx) => (
          <li key={idx}>{step}</li>
        ))}
      </ol>
      <button type="submit">Save Recipe</button>
    </form>
  );
};

export default RecipeForm;