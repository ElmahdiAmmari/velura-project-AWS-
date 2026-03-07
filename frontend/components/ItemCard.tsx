type Item = {
  id: number;
  name: string;
  brand: string;
  size: string;
  price: number;
};

export default function ItemCard({ item }: { item: Item }) {
  return (
    <div className="border rounded-xl p-4 hover:shadow-lg transition">
      <h2 className="font-bold text-lg">{item.name}</h2>
      <p className="text-gray-500">{item.brand} · Size {item.size}</p>
      <p className="text-purple-600 font-semibold">{item.price} MAD/day</p>
    </div>
  );
}