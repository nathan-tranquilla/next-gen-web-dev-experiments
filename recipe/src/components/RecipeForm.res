type action = AddName(string)
  | AddServingSize(int)
  | AddIngredientName(string)
  | AddIngredientQuanity(int)
  | AddIngredientUnit(Types.measuringUnit)
  | AddIngredientCalories(int)
  | AddIngredient
  | StageStep(string)
  | AddStep
  | Clear

type state = {
  form_error: option<string>,
  recipes: array<Types.recipe>,
  staged_recipe: Types.RecipeBuilder.t,
  staged_ingredient: Types.IngredientBuilder.t,
  staged_step: option<string>
}

let initialState = {
  form_error: None,
  recipes: [],
  staged_recipe: Types.RecipeBuilder.empty(),
  staged_ingredient: Types.IngredientBuilder.empty(),
  staged_step: None
}

let reducer = (state, action) => {
  switch action {
  | AddName(name) => { 
      ...state, 
      form_error: None,
      staged_recipe: state.staged_recipe->Types.RecipeBuilder.withName(name)
    }
  | AddServingSize(size) => { 
      ...state, 
      form_error: None,
      staged_recipe: state.staged_recipe->Types.RecipeBuilder.withServings(size)
    }
  | AddIngredientName(name) => { 
      ...state, 
      form_error: None,
      staged_ingredient: state.staged_ingredient->Types.IngredientBuilder.withName(name)
    }
  | AddIngredientQuanity(quantity) => { 
      ...state, 
      form_error: None,
      staged_ingredient: state.staged_ingredient->Types.IngredientBuilder.withQuantity(quantity)
    }
  | AddIngredientUnit(unit) => { 
      ...state, 
      form_error: None,
      staged_ingredient: state.staged_ingredient->Types.IngredientBuilder.withUnit(unit)
    }
  | AddIngredientCalories(calories) => { 
      ...state, 
      form_error: None,
      staged_ingredient: state.staged_ingredient->Types.IngredientBuilder.withCaloriesPerUnit(calories)
    } 
  | AddIngredient => { 
      switch state.staged_ingredient->Types.IngredientBuilder.build {
      | Ok(ingredient) => {
          ...state,
          staged_recipe: state.staged_recipe->Types.RecipeBuilder.addIngredient(ingredient),
          staged_ingredient: Types.IngredientBuilder.empty()
        }
      | Error(msg) => {
          ...state,
          form_error: Some(msg)
        } 
      }
    }
  | StageStep(step) => { 
      ...state, 
      form_error: None,
      staged_step: Some(step)
    }
  | AddStep => {
      switch state.staged_step {
      | Some(step) => {
          ...state,
          form_error: None,
          staged_recipe: state.staged_recipe->Types.RecipeBuilder.addStep(step),
          staged_step: None
        }
      | None => state 
      }
    }
  | Clear => { 
      // First add an ID to the recipe builder
      let recipeWithId = state.staged_recipe->Types.RecipeBuilder.withId("recipe-" ++ Js.Date.now()->Float.toString)
      
      switch recipeWithId->Types.RecipeBuilder.build {
      | Ok(_) => {
          form_error: None,
          recipes: [],
          staged_recipe: Types.RecipeBuilder.empty(),
          staged_ingredient: Types.IngredientBuilder.empty(),
          staged_step: None
        }
      | Error(msg) => {
          ...state,
          form_error: Some(msg)
        } 
      }
    }
  }
}

@react.component
let make = (~onAddRecipe: Types.recipe => unit) => {

  let (state, dispatch) = React.useReducer(reducer, initialState);

  <div className="bg-white rounded-lg shadow-md p-6">
    <form className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-4">{React.string("Add New Recipe")}</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {React.string("Name:")}
          </label>
          <input 
            type_="text" 
            value={state.staged_recipe.name->Belt.Option.getWithDefault("")}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              let value: string = target["value"]
              dispatch(AddName(value))
            }}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {React.string("Servings:")}
          </label>
          <input 
            type_="number" 
            value={state.staged_recipe.servings->Belt.Option.getWithDefault(0)->Belt.Int.toString}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              let value: int = Belt.Int.fromString(target["value"])->Belt.Option.getWithDefault(0)
              dispatch(AddServingSize(value))
            }}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-3">{React.string("Ingredients")}</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mb-3">
          <input
            type_="text"
            placeholder="Ingredient name"
            value={state.staged_ingredient.name->Belt.Option.getWithDefault("")}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              let value: string = target["value"]
              dispatch(AddIngredientName(value))
            }}
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <input
            type_="number"
            placeholder="Quantity"
            value={state.staged_ingredient.quantity->Belt.Option.getWithDefault(0)->Belt.Int.toString}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              switch Belt.Int.fromString(target["value"]) {
              | Some(val) => dispatch(AddIngredientQuanity(val))
              | None => ()
              }
            }}
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <select
            value={state.staged_ingredient.unit->Belt.Option.map(Types.measuringUnitToString)->Belt.Option.getWithDefault("g")}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              let value: string = target["value"]
              switch Types.stringToMeasuringUnit(value) {
              | Some(unit) => dispatch(AddIngredientUnit(unit))
              | None => ()
              }
            }}
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            {Types.allMeasuringUnits
              ->Belt.Array.map(unit => {
                let stringValue = Types.measuringUnitToString(unit)
                <option key={stringValue} value={stringValue}>{React.string(stringValue)}</option>
              })
              ->React.array}
          </select>
          <input
            type_="number"
            value={state.staged_ingredient.caloriesPerUnit->Belt.Option.getWithDefault(0)->Belt.Int.toString}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              switch Belt.Int.fromString(target["value"]) {
              | Some(val) => dispatch(AddIngredientCalories(val))
              | None => ()
              }
            }}
            placeholder="Calories per unit"
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <button 
          type_="button" 
          onClick={(_) => dispatch(AddIngredient)}
          className="mb-3 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
        >
          {React.string("Add Ingredient")}
        </button>
        <ul className="space-y-1 mb-4">
          {state.staged_recipe.ingredients->Belt.Option.getWithDefault([])->Belt.Array.mapWithIndex((idx, ing) => {
            let unitString = ing.unit->Types.measuringUnitToString
            let quantityString = ing.quantity->Belt.Int.toString
            let caloriesString = ing.caloriesPerUnit->Belt.Int.toString
            <li key={Belt.Int.toString(idx)} className="text-sm bg-gray-100 px-3 py-2 rounded">
              {React.string(quantityString ++ " " ++ unitString ++ " " ++ ing.name ++ " (" ++ caloriesString ++ " cal/unit)")}
            </li>
          })->React.array}
        </ul>
      </div>

      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-3">{React.string("Steps")}</h3>
        <div className="flex gap-2 mb-3">
          <input
            type_="text"
            placeholder="Step description"
            value={state.staged_step->Belt.Option.getWithDefault("")}
            onChange={(ev: JsxEvent.Form.t) => {
              let target = JsxEvent.Form.target(ev)
              let value: string = target["value"]
              dispatch(StageStep(value))
            }}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <button 
            type_="button" 
            onClick={(_) => dispatch(AddStep)}
            className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
          >
            {React.string("Add Step")}
          </button>
        </div>
        <ol className="space-y-2 mb-6">
          {state.staged_recipe.steps->Belt.Array.mapWithIndex((idx, step) => (
            <li key={Belt.Int.toString(idx)} className="text-sm bg-gray-100 px-3 py-2 rounded flex">
              <span className="font-medium text-gray-600 mr-2">{React.int(idx + 1)}</span>
              <span>{React.string(step)}</span>
            </li>
          ))->React.array}
        </ol>
      </div>

      {state.form_error
        ->Belt.Option.map(err => 
          <div className="text-red-500 bg-red-50 border border-red-200 rounded-md p-3 mb-4">
            {React.string(err)}
          </div>
        )
        ->Belt.Option.getWithDefault(React.null)}

      <button 
        type_="submit"
        onClick={(ev) => {
          ev->JsxEventU.Mouse.preventDefault          
          let recipeWithId = state.staged_recipe->Types.RecipeBuilder.withId("recipe-" ++ Js.Date.now()->Float.toString)
          switch recipeWithId->Types.RecipeBuilder.build {
          | Ok(recipe) => {
            onAddRecipe(recipe)
            dispatch(Clear)
          }
          | Error(_) => () 
          }
        }}
        className="w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-4 rounded-md transition-colors"
      >
        {React.string("Save Recipe")}
      </button>
    </form>
  </div>
}


// src/components/RecipeForm.tsx
// import React from 'react';
// import { Recipe } from '../types.ts';

// interface RecipeFormProps {
//   onAddRecipe: (recipe: Recipe) => void;
// }

// const RecipeForm: React.FC<RecipeFormProps> = ({ onAddRecipe }) => {
//   return (
//     <div className="bg-white rounded-lg shadow-md p-6">
//       <form className="space-y-6">
//         <h2 className="text-2xl font-bold text-gray-900 mb-4">Add New Recipe</h2>
        
//         <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//           <div>
//             <label className="block text-sm font-medium text-gray-700 mb-1">
//               Name:
//             </label>
//             <input 
//               type="text" 
//               className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//           </div>
//           <div>
//             <label className="block text-sm font-medium text-gray-700 mb-1">
//               Servings:
//             </label>
//             <input 
//               type="number" 
//               className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//           </div>
//         </div>

//         <div>
//           <h3 className="text-lg font-semibold text-gray-900 mb-3">Ingredients</h3>
//           <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mb-3">
//             <input
//               type="text"
//               placeholder="Ingredient name"
//               className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//             <input
//               type="number"
//               placeholder="Quantity"
//               className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//             <select
//               className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             >
//               <option value="g">g</option>
//               <option value="oz">oz</option>
//               <option value="ml">ml</option>
//               <option value="cup">cup</option>
//               <option value="tbsp">tbsp</option>
//             </select>
//             <input
//               type="number"
//               placeholder="Calories per unit"
//               className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//           </div>
//           <button 
//             type="button" 
//             className="mb-3 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
//           >
//             Add Ingredient
//           </button>
//           <ul className="space-y-1 mb-4">
//             {/* {ingredients.map((ing, idx) => (
//               <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded">
//                 {`${ing.quantity} ${ing.unit} ${ing.name} (${ing.caloriesPerUnit} cal/unit)`}
//               </li>
//             ))} */}
//           </ul>
//         </div>

//         <div>
//           <h3 className="text-lg font-semibold text-gray-900 mb-3">Steps</h3>
//           <div className="flex gap-2 mb-3">
//             <input
//               type="text"
//               placeholder="Step description"
//               className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
//             />
//             <button 
//               type="button" 
//               className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
//             >
//               Add Step
//             </button>
//           </div>
//           <ol className="space-y-2 mb-6">
//             {/* {steps.map((step, idx) => (
//               <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded flex">
//                 <span className="font-medium text-gray-600 mr-2">{idx + 1}.</span>
//                 <span>{step}</span>
//               </li>
//             ))} */}
//           </ol>
//         </div>

//         <button 
//           type="submit"
//           className="w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-4 rounded-md transition-colors"
//         >
//           Save Recipe
//         </button>
//       </form>
//     </div>
//   );
// };

// export default RecipeForm;