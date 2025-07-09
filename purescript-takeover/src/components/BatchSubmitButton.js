import { useDispatch, useSelector } from 'react-redux';
import { submitBatchSuccess } from '../redux/inventorySlice';
import { submitBatch } from '../utils/api';

const BatchSubmitButton = () => {
  const dispatch = useDispatch();
  const items = useSelector(state => state.inventory.items);
  const doneItems = items.filter(item => item.status === "done");

  const handleSubmit = () => {
    if (doneItems.length === 0) {
      alert("No items marked as done to submit.");
      return;
    }
    submitBatch(doneItems)
      .then(response => {
        dispatch(submitBatchSuccess(response.items));
        alert("Batch submitted successfully!");
      })
      .catch(err => alert("Submission failed: " + err.message));
  };

  return (
    <div className="p-4">
      <button
        className="bg-purple-500 text-white px-4 py-2 rounded"
        onClick={handleSubmit}
        disabled={doneItems.length === 0}
      >
        Submit Batch ({doneItems.length} items)
      </button>
    </div>
  );
};

export default BatchSubmitButton;