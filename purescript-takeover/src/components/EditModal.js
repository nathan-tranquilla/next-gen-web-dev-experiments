import { useState } from 'react';
import { useDispatch } from 'react-redux';
import { updateItem } from '../redux/inventorySlice';

const EditModal = ({ item, onClose }) => {
  const dispatch = useDispatch();
  const [formData, setFormData] = useState({
    name: item.name,
    quantity: item.quantity,
    price: item.price,
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    let convertedValue = value;
    if (name === "price") {
      convertedValue = parseFloat(value);
    }
    setFormData(prev => ({ ...prev, [name]: convertedValue }));
  };

  const handleDone = () => {
    dispatch(updateItem({
      id: item.id,
      updates: { ...formData, status: "done" },
    }));
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div className="bg-white p-6 rounded shadow-lg w-96">
        <h2 className="text-xl mb-4">Edit Item {item.id}</h2>
        <div className="mb-4">
          <label className="block mb-1">Name</label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            className="w-full border p-2 rounded"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Quantity</label>
          <input
            type="number"
            name="quantity"
            value={formData.quantity}
            onChange={handleChange}
            className="w-full border p-2 rounded"
          />
        </div>
        <div className="mb-4">
          <label className="block mb-1">Price</label>
          <input
            type="number"
            name="price"
            value={formData.price}
            onChange={handleChange}
            className="w-full border p-2 rounded"
          />
        </div>
        <div className="flex justify-end gap-2">
          <button
            className="bg-gray-500 text-white px-4 py-2 rounded"
            onClick={onClose}
          >
            Cancel
          </button>
          <button
            className="bg-green-500 text-white px-4 py-2 rounded"
            onClick={handleDone}
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
};

export default EditModal;