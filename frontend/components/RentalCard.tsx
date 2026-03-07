type Rental = {
  id: number;
  itemName: string;
  rentedAt: string;
  status: string;
};

export default function RentalCard({ rental }: { rental: Rental }) {
  return (
    <div className="border rounded-xl p-4">
      <h2 className="font-bold">{rental.itemName}</h2>
      <p className="text-sm text-gray-400">Rented: {rental.rentedAt}</p>
      <span className={`text-xs px-2 py-1 rounded-full ${
        rental.status === "active" ? "bg-green-100 text-green-700" : "bg-gray-100"
      }`}>
        {rental.status}
      </span>
    </div>
  );
}