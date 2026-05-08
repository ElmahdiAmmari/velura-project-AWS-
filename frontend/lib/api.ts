// const BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
const BASE_URL = process.env.NEXT_PUBLIC_API_URL || "";
// ============ HELPERS ============
const getAuthHeaders = () => ({
  "Content-Type": "application/json",
  Authorization: `Bearer ${typeof window !== "undefined" ? localStorage.getItem("token") : ""}`,
});

// ============ AUTH ============
export const register = async (name: string, email: string, password: string) => {
  const res = await fetch(`${BASE_URL}/api/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, password }),
  });
  if (!res.ok) throw new Error("Registration failed");
  return res.json();
};

export const login = async (email: string, password: string) => {
  const res = await fetch(`${BASE_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) throw new Error("Login failed");
  const data = await res.json();
  if (typeof window !== "undefined") {
    localStorage.setItem("token", data.access_token);
  }
  return data;
};

export const logout = () => {
  if (typeof window !== "undefined") {
    localStorage.removeItem("token");
  }
};

// ============ USERS ============
export const getMe = async () => {
  const res = await fetch(`${BASE_URL}/api/users/me`, {
    headers: getAuthHeaders(),
  });
  if (!res.ok) throw new Error("Failed to get profile");
  return res.json();
};

// ============ CATALOG ============
export const getItems = async (params?: {
  category?: string;
  size?: string;
  q?: string;
  available?: boolean; 
}) => {
  const query = params ? new URLSearchParams(params as any).toString() : "";
  const res = await fetch(`${BASE_URL}/api/catalog/items${query ? "?" + query : ""}`);
  if (!res.ok) throw new Error("Failed to get items");
  return res.json();
};

export const getItem = async (id: number) => {
  const res = await fetch(`${BASE_URL}/api/catalog/items/${id}`);
  if (!res.ok) throw new Error("Item not found");
  return res.json();
};

// ============ RENTALS ============
export const getRentals = async () => {
  const res = await fetch(`${BASE_URL}/api/rentals`, {
    headers: getAuthHeaders(),
  });
  if (!res.ok) throw new Error("Failed to get rentals");
  return res.json();
};

export const rentItem = async (item_id: number) => {
  const res = await fetch(`${BASE_URL}/api/rentals`, {
    method: "POST",
    headers: getAuthHeaders(),
    body: JSON.stringify({ item_id }),
  });
  if (!res.ok) throw new Error("Failed to rent item");
  return res.json();
};

export const returnItem = async (rental_id: number) => {
  const res = await fetch(`${BASE_URL}/api/rentals/${rental_id}/return`, {
    method: "PUT",
    headers: getAuthHeaders(),
  });
  if (!res.ok) throw new Error("Failed to return item");
  return res.json();
};

// ============ SUBSCRIPTIONS ============
export const subscribe = async (plan: string) => {
  const res = await fetch(`${BASE_URL}/api/subscriptions`, {
    method: "POST",
    headers: getAuthHeaders(),
    body: JSON.stringify({ plan }),
  });
  if (!res.ok) throw new Error("Failed to subscribe");
  return res.json();
};
export const cancelSubscription = async () => {
  const res = await fetch(`${BASE_URL}/api/subscriptions/me`, {
    method: "DELETE",
    headers: getAuthHeaders(),
  });
  if (!res.ok) throw new Error("Failed to cancel subscription");
  return res.json();
};
export const upgradeSubscription = async (plan: string) => {
  const res = await fetch(`${BASE_URL}/api/subscriptions/upgrade`, {
    method: "PUT",
    headers: getAuthHeaders(),
    body: JSON.stringify({ plan }),
  });
  if (!res.ok) throw new Error("Failed to upgrade subscription");
  return res.json();
};

export const getMySubscription = async () => {
  const res = await fetch(`${BASE_URL}/api/subscriptions/me`, {
    headers: getAuthHeaders(),
  });
  if (!res.ok) throw new Error("No active subscription");
  return res.json();
};

// ============ AI STYLIST ============
export const chatWithStylist = async (
  message: string,
  history: { role: string; content: string }[]
) => {
  const res = await fetch(`${BASE_URL}/api/ai/chat`, {
    method: "POST",
    headers: getAuthHeaders(),
    body: JSON.stringify({ message, history }),
  });
  if (!res.ok) throw new Error("AI service unavailable");
  return res.json();
};


