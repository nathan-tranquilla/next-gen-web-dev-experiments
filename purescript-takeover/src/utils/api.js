const mockInventory = [
    { id: 1, name: 'Widget A', quantity: 100, price: 10.99, status: 'pending' },
    { id: 2, name: 'Widget B', quantity: 50, price: 5.99, status: 'pending' },
    { id: 3, name: 'Widget C', quantity: 200, price: 15.49, status: 'pending' },
  ];
  
  export const fetchInventory = () =>
    new Promise(resolve => setTimeout(() => resolve(mockInventory), 1000));
  
  export const submitBatch = (items) =>
    new Promise(resolve => setTimeout(() => resolve({ success: true, items }), 1000));