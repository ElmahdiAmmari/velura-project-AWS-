"use client";
import { useEffect, useState } from "react";
import RentalCard from "@/components/RentalCard";
import { getRentals } from "@/lib/api";

export default function RentalsPage() {
  const [rentals, setRentals] = useState([]);

  useEffect(() => {
    getRentals().then(setRentals);
  }, []);

  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold mb-4">My Rentals</h1>
      <div className="flex flex-col gap-4">
        {rentals.map((r: any) => <RentalCard key={r.id} rental={r} />)}
      </div>
    </main>
  );
}