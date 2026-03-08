"use client";
import { useState } from "react";
import Link from "next/link";

export default function LoginPage() {
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading]   = useState(false);
  const [error, setError]       = useState("");

  const handleSubmit = async () => {
    setError("");
    if (!email || !password) { setError("Please fill in all fields."); return; }
    setLoading(true);
    try {
      // ⏳ TODO: swap this mock with real B1 API call when ready:
      // const res = await fetch("http://your-backend/auth/login", {
      //   method: "POST",
      //   headers: { "Content-Type": "application/json" },
      //   body: JSON.stringify({ email, password }),
      // });
      await new Promise((r) => setTimeout(r, 1000)); // mock delay
      window.location.href = "/dashboard";
    } catch {
      setError("Invalid credentials. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const inputStyle = {
    width: "100%", padding: "16px 0", background: "transparent",
    border: "none", borderBottom: "1px solid rgba(212,175,55,0.2)",
    color: "#F5F0E8", fontSize: "16px",
    fontFamily: "'Cormorant Garamond', serif", outline: "none",
  };

  return (
    <div style={{
      minHeight: "100vh", background: "#0A0908",
      display: "flex", alignItems: "center", justifyContent: "center",
      padding: "120px 24px 60px", fontFamily: "'Cormorant Garamond', serif",
    }}>
      <div style={{ width: "100%", maxWidth: "420px" }}>

        <Link href="/" style={{ textDecoration: "none" }}>
          <div style={{ textAlign: "center", marginBottom: "56px" }}>
            <span style={{
              fontSize: "36px", fontWeight: 300, letterSpacing: "0.35em",
              color: "#D4AF37", textTransform: "uppercase",
            }}>Velura</span>
          </div>
        </Link>

        <h1 style={{
          fontSize: "40px", fontWeight: 300, color: "#F5F0E8",
          marginBottom: "40px", lineHeight: 1.1,
        }}>
          Sign in to your<br/>
          <em style={{ color: "#D4AF37", fontStyle: "italic" }}>wardrobe.</em>
        </h1>

        <div style={{ marginBottom: "28px" }}>
          <label style={{ fontSize: "10px", letterSpacing: "0.3em", color: "#4A3F35", textTransform: "uppercase", display: "block", marginBottom: "4px" }}>
            Email Address
          </label>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
            placeholder="your@email.com" style={inputStyle} />
        </div>

        <div style={{ marginBottom: "36px" }}>
          <label style={{ fontSize: "10px", letterSpacing: "0.3em", color: "#4A3F35", textTransform: "uppercase", display: "block", marginBottom: "4px" }}>
            Password
          </label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••" style={inputStyle} />
        </div>

        {error && <p style={{ color: "#C0392B", fontSize: "13px", marginBottom: "16px" }}>{error}</p>}

        <button onClick={handleSubmit} disabled={loading} style={{
          width: "100%", padding: "18px",
          background: loading ? "#8B7A2E" : "#D4AF37",
          border: "none", color: "#0A0908",
          fontSize: "12px", letterSpacing: "0.3em", textTransform: "uppercase",
          fontWeight: 700, fontFamily: "'Cormorant Garamond', serif",
          cursor: loading ? "not-allowed" : "pointer", marginBottom: "28px",
        }}>
          {loading ? "Signing in..." : "Enter Velura"}
        </button>

        <p style={{ textAlign: "center", fontSize: "14px", color: "#4A3F35" }}>
          New to Velura?{" "}
          <Link href="/auth/register" style={{ color: "#D4AF37", textDecoration: "none" }}>
            Create an account
          </Link>
        </p>
      </div>
      <style>{`input::placeholder { color: #3D3328; }`}</style>
    </div>
  );
}