// src/types.ts
export interface Ingredient {
  name: string;
  quantity: number;
  unit: 'g' | 'oz' | 'ml' | 'cup' | 'tbsp';
  caloriesPerUnit: number; // Calories per base unit (e.g., per g, per ml, etc.)
}

export interface Nutrition {
  totalCalories: number;
}

export interface Recipe {
  id: string;
  name: string;
  ingredients: Ingredient[];
  steps: string[];
  servings: number;
  nutritionPerServing: Nutrition;
}