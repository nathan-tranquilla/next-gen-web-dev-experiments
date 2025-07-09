import { configureStore } from '@reduxjs/toolkit';
import inventoryReducer from './inventorySlice';

const store = configureStore({
  reducer: {
    inventory: inventoryReducer,
  },
});

export default store;