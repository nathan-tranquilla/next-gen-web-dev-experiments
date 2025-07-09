import { Provider } from 'react-redux';
import store from './redux/store';
import InventoryTable from './components/InventoryTable';
import BatchSubmitButton from './components/BatchSubmitButton';
import './index.css';

function App() {
  return (
    <Provider store={store}>
      <div className="max-w-4xl mx-auto p-4">
        <h1 className="text-2xl font-bold mb-4">Inventory Adjustments</h1>
        <InventoryTable />
        <BatchSubmitButton />
      </div>
    </Provider>
  );
}

export default App;