"use client";
import { useState } from "react";

export default function AIStylistPage() {
  const [message, setMessage] = useState("");
  const [chat, setChat] = useState<string[]>([]);

  const sendMessage = () => {
    setChat([...chat, `You: ${message}`]);
    setMessage("");
    // ⏳ WAIT for B2's ai/ backend route — then call real API here
    setTimeout(() => setChat(c => [...c, "Velura AI: Feature coming soon!"]), 500);
  };

  return (
    <main className="p-8 max-w-xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">AI Stylist</h1>
      <div className="border rounded-xl p-4 h-64 overflow-y-auto mb-4 flex flex-col gap-2">
        {chat.map((m, i) => <p key={i} className="text-sm">{m}</p>)}
      </div>
      <div className="flex gap-2">
        <input
          className="flex-1 border rounded-lg px-4 py-2"
          value={message}
          onChange={e => setMessage(e.target.value)}
          placeholder="Ask your stylist..."
        />
        <button onClick={sendMessage} className="bg-black text-white px-4 py-2 rounded-lg">
          Send
        </button>
      </div>
    </main>
  );
}