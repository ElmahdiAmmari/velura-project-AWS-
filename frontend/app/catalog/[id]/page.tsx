// Single item detail page — use mock for now
export default function ItemDetailPage({ params }: { params: { id: string } }) {
  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold">Item #{params.id}</h1>
      <p className="text-gray-500 mt-2">Details coming once backend is ready.</p>
      {/* ⏳ WAIT for B2's catalog API to fill this in */}
    </main>
  );
}