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

