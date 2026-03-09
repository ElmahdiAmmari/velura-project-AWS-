"use client";
import { useEffect, useState } from "react";
import ItemCard from "@/components/ItemCard";
import { getItems } from "@/lib/api";

export default function CatalogPage() {
const [items, setItems] = useState<{id: number; name: string; brand: string; size: string; price: number;}[]>([]);
  useEffect(() => {
    getItems().then(setItems);
  }, []);

  return (
    <main className="p-8">
      <h1 className="text-3xl font-bold mb-6">Browse Collection</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {items.map((item: any) => <ItemCard key={item.id} item={item} />)}
      </div>
    </main>
  );
}