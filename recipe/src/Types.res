@genType
type nutrition = {
  totalCalories: int
}

@genType
type measuringUnit = G 
  | Oz
  | Ml 
  | Cup 
  | Tbsp

// Helper functions for measuring units
let measuringUnitToString = (unit: measuringUnit) => {
  switch unit {
  | G => "g"
  | Oz => "oz"
  | Ml => "ml"
  | Cup => "cup"
  | Tbsp => "tbsp"
  }
}

let stringToMeasuringUnit = (str: string) => {
  switch str {
  | "g" => Some(G)
  | "oz" => Some(Oz)
  | "ml" => Some(Ml)
  | "cup" => Some(Cup)
  | "tbsp" => Some(Tbsp)
  | _ => None
  }
}

let allMeasuringUnits = [G, Oz, Ml, Cup, Tbsp]

@genType
type ingredient = {
  name: string,
  quantity: int,
  unit: measuringUnit,
  caloriesPerUnit: int
}

@genType
type recipe = {
  id: string,
  name: string,
  ingredients: array<ingredient>,
  steps: array<string>,
  servings: int,
  nutritionPerServing: nutrition,
}

// Builder pattern for recipe
module RecipeBuilder = {
  type t = {
    id: option<string>,
    name: option<string>,
    ingredients: option<array<ingredient>>,
    steps: array<string>,
    servings: option<int>,
  }

  let empty = () => {
    id: None,
    name: None,
    ingredients: None,
    steps: [],
    servings: None,
  }

  let withId = (builder: t, id: string) => {
    ...builder,
    id: Some(id),
  }

  let withName = (builder: t, name: string) => {
    ...builder,
    name: Some(name),
  }

  let withServings = (builder: t, servings: int) => {
    ...builder,
    servings: Some(servings),
  }

  let addIngredient = (builder: t, ingredient: ingredient) => {
    ...builder,
    ingredients: Some(
      builder.ingredients
      ->Belt.Option.getWithDefault([])
      ->Array.concat([ingredient])
    ),
  }

  let addIngredients = (builder: t, ingredients: array<ingredient>) => {
    ...builder,
    ingredients: Some(
      builder.ingredients
      ->Belt.Option.getWithDefault([])
      ->Array.concat(ingredients)
    ),
  }

  let addStep = (builder: t, step: string) => {
    ...builder,
    steps: Array.concat(builder.steps, [step]),
  }

  let addSteps = (builder: t, steps: array<string>) => {
    ...builder,
    steps: Array.concat(builder.steps, steps),
  }

  // Calculate nutrition based on ingredients and servings
  let calculateNutrition = (ingredients: array<ingredient>, servings: int): nutrition => {
    let totalCalories = ingredients
      ->Array.map(ing => ing.quantity * ing.caloriesPerUnit)
      ->Array.reduce(0, (acc, calories) => acc + calories)
    
    {
      totalCalories: totalCalories / servings,
    }
  }

  // Build the final recipe
  let build = (builder: t): result<recipe, string> => {
    switch (builder.id, builder.name, builder.servings, builder.ingredients) {
    | (Some(id), Some(name), Some(servings), Some(ingredients)) => {
        let nutritionPerServing = calculateNutrition(ingredients, servings)
        Ok({
          id,
          name,
          ingredients,
          steps: builder.steps,
          servings,
          nutritionPerServing,
        })
      }
    | (None, _, _, _) => Error("Recipe ID is required")
    | (_, None, _, _) => Error("Recipe name is required")
    | (_, _, None, _) => Error("Servings count is required")
    | (_, _, _, None) => Error("Ingredients are required")
    }
  }

}

// Builder pattern for ingredients
module IngredientBuilder = {
  type t = {
    name: option<string>,
    quantity: option<int>,
    unit: option<measuringUnit>,
    caloriesPerUnit: option<int>,
  }

  let empty = () => {
    name: None,
    quantity: None,
    unit: None,
    caloriesPerUnit: None,
  }

  let withName = (builder: t, name: string) => {
    ...builder,
    name: Some(name),
  }

  let withQuantity = (builder: t, quantity: int) => {
    ...builder,
    quantity: Some(quantity),
  }

  let withUnit = (builder: t, unit: measuringUnit) => {
    ...builder,
    unit: Some(unit),
  }

  let withCaloriesPerUnit = (builder: t, caloriesPerUnit: int) => {
    ...builder,
    caloriesPerUnit: Some(caloriesPerUnit),
  }

  let build = (builder: t): result<ingredient, string> => {
    switch (builder.name, builder.quantity, builder.unit, builder.caloriesPerUnit) {
    | (Some(name), Some(quantity), Some(unit), Some(caloriesPerUnit)) => 
        Ok({
          name,
          quantity,
          unit,
          caloriesPerUnit,
        })
    | (None, _, _, _) => Error("Ingredient name is required")
    | (_, None, _, _) => Error("Ingredient quantity is required")
    | (_, _, None, _) => Error("Ingredient unit is required")
    | (_, _, _, None) => Error("Ingredient calories per unit is required")
    }
  }
}
