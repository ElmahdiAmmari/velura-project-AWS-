// MOCK — replace with real URLs when backend is ready
export const getItems = async () => [
  { id: 1, name: "Silk Dress", brand: "Zara", size: "M", price: 12 },
  { id: 2, name: "Linen Blazer", brand: "Mango", size: "S", price: 18 },
];

export const getRentals = async () => [
  { id: 1, itemName: "Silk Dress", rentedAt: "2025-01-01", status: "active" },
];

// ⏳ WAIT for backend — swap these mocks for real fetch() calls later
// export const getItems = () => fetch("/api/catalog/items").then(r => r.json())