import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchStart, fetchSuccess, fetchFailure } from '../redux/inventorySlice';
import { fetchInventory } from '../utils/api';
import EditModal from './EditModal';

const InventoryTable = () => {
  const dispatch = useDispatch();
  const { items, loading, error } = useSelector(state => state.inventory);
  const [editingItem, setEditingItem] = useState(null);

  useEffect(() => {
    dispatch(fetchStart());
    fetchInventory()
      .then(data => dispatch(fetchSuccess(data)))
      .catch(err => dispatch(fetchFailure(err.message)));
  }, [dispatch]);

  if (loading) return <div className="text-center p-4">Loading...</div>;
  if (error) return <div className="text-red-500 p-4">Error: {error}</div>;

  return (
    <div className="p-4">
      <table className="w-full border-collapse border">
        <thead>
          <tr className="bg-gray-100">
            <th className="border p-2">ID</th>
            <th className="border p-2">Name</th>
            <th className="border p-2">Quantity</th>
            <th className="border p-2">Price</th>
            <th className="border p-2">Status</th>
            <th className="border p-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map(item => (
            <tr key={item.id}>
              <td className="border p-2">{item.id}</td>
              <td className="border p-2">{item.name}</td>
              <td className="border p-2">{item.quantity}</td>
              <td className="border p-2">${item.price.toFixed(2)}</td>
              <td className="border p-2">{item.status}</td>
              <td className="border p-2">
                <button
                  className="bg-blue-500 text-white px-2 py-1 rounded"
                  onClick={() => setEditingItem(item)}
                  disabled={item.status === "submitted"}
                >
                  Edit
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {editingItem && <EditModal item={editingItem} onClose={() => setEditingItem(null)} />}
    </div>
  );
};

export default InventoryTable;