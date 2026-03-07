"use client";
// ⏳ user data will come from auth (B1) — use mock for now
const mockUser = { name: "Salma", plan: "Premium", itemsLeft: 2 };

export default function DashboardPage() {
  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold">Welcome, {mockUser.name}</h1>
      <p>Plan: {mockUser.plan} · Items left this month: {mockUser.itemsLeft}</p>
      {/* ⏳ Replace mockUser with real user from auth token later */}
    </main>
  );
}