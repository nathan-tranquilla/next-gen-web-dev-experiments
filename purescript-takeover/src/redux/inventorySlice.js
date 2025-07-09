import { createSlice } from '@reduxjs/toolkit';

const inventorySlice = createSlice({
  name: 'inventory',
  initialState: { items: [], loading: false, error: null },
  reducers: {
    fetchStart(state) {
      state.loading = true;
      state.error = null;
    },
    fetchSuccess(state, action) {
      state.items = action.payload;
      state.loading = false;
    },
    fetchFailure(state, action) {
      state.error = action.payload;
      state.loading = false;
    },
    updateItem(state, action) {
      const { id, updates } = action.payload;
      const item = state.items.find(item => item.id === id);
      if (item) Object.assign(item, updates);
    },
    submitBatchSuccess(state, action) {
      state.items = state.items.map(item =>
        action.payload.find(i => i.id === item.id) ? { ...item, status: 'submitted' } : item
      );
    },
  },
});

export const { fetchStart, fetchSuccess, fetchFailure, updateItem, submitBatchSuccess } = inventorySlice.actions;
export default inventorySlice.reducer;