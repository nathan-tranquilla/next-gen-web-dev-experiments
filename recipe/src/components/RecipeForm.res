
@react.component
let make = () => {
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
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {React.string("Servings:")}
          </label>
          <input 
            type_="number" 
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
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <input
            type_="number"
            placeholder="Quantity"
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <select
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="g">{React.string("g")}</option>
            <option value="oz">{React.string("oz")}</option>
            <option value="ml">{React.string("ml")}</option>
            <option value="cup">{React.string("cup")}</option>
            <option value="tbsp">{React.string("tbsp")}</option>
          </select>
          <input
            type_="number"
            placeholder="Calories per unit"
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <button 
          type_="button" 
          className="mb-3 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
        >
          {React.string("Add Ingredient")}
        </button>
        <ul className="space-y-1 mb-4">
          /* {ingredients.map((ing, idx) => (
            <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded">
              {`${ing.quantity} ${ing.unit} ${ing.name} (${ing.caloriesPerUnit} cal/unit)`}
            </li>
          ))} */
        </ul>
      </div>

      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-3">{React.string("Steps")}</h3>
        <div className="flex gap-2 mb-3">
          <input
            type_="text"
            placeholder="Step description"
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <button 
            type_="button" 
            className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-md transition-colors"
          >
            {React.string("Add Step")}
          </button>
        </div>
        <ol className="space-y-2 mb-6">
          /* {steps.map((step, idx) => (
            <li key={idx} className="text-sm bg-gray-100 px-3 py-2 rounded flex">
              <span className="font-medium text-gray-600 mr-2">{idx + 1}.</span>
              <span>{step}</span>
            </li>
          ))} */
        </ol>
      </div>

      <button 
        type_="submit"
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