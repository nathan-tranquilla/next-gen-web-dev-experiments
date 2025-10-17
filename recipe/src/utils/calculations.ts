// src/utils/calculations.ts
import { Ingredient, Nutrition } from '../types.ts';

// Conversion factors to grams (for weight) or ml (for volume). This is simplified and can be error-prone.
const conversionToBase: Record<string, number> = {
  g: 1,      // grams to grams
  oz: 28.35, // ounces to grams
  ml: 1,     // ml to ml
  cup: 240,  // cup to ml
  tbsp: 15,  // tbsp to ml
};

export function convertToBase(quantity: number, unit: string): number {
  if (!(unit in conversionToBase)) {
    throw new Error(`Unknown unit: ${unit}`);
  }
  return quantity * conversionToBase[unit];
}

export function calculateTotalCalories(ingredients: Ingredient[]): number {
  let total = 0;
  ingredients.forEach(ing => {
    // Assume all caloriesPerUnit are normalized, but in reality, units differ.
    // This is where bugs can creep in: mixing weight and volume without proper handling.
    const baseQuantity = convertToBase(ing.quantity, ing.unit);
    // Simplification: assuming caloriesPerUnit is per base unit (g or ml), but this can mismatch.
    total += baseQuantity * ing.caloriesPerUnit / 100; // Pretend it's per 100 base units for variety.
  });
  return total;
}

export function calculateNutrition(ingredients: Ingredient[], servings: number): Nutrition {
  const totalCalories = calculateTotalCalories(ingredients);
  return {
    totalCalories: Math.round(totalCalories / servings),
  };
}