"use client";
import { useState } from "react";
import Link from "next/link";

export default function RegisterPage() {
  const [form, setForm] = useState({ name: "", email: "", password: "", confirm: "" });
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState("");

  const update = (field: string, value: string) =>
    setForm((prev) => ({ ...prev, [field]: value }));

  const handleSubmit = async () => {
    setError("");
    if (!form.name || !form.email || !form.password || !form.confirm) {
      setError("Please fill in all fields."); return;
    }
    if (form.password !== form.confirm) { setError("Passwords do not match."); return; }
    if (form.password.length < 8) { setError("Password must be at least 8 characters."); return; }
    setLoading(true);
    try {
      // ⏳ TODO: swap this mock with real B1 API call when ready:
      // const res = await fetch("http://your-backend/auth/register", {
      //   method: "POST",
      //   headers: { "Content-Type": "application/json" },
      //   body: JSON.stringify({ name: form.name, email: form.email, password: form.password }),
      // });
      await new Promise((r) => setTimeout(r, 1000)); // mock delay
      window.location.href = "/subscription";
    } catch {
      setError("Registration failed. Please try again.");
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

  const labelStyle = {
    fontSize: "10px", letterSpacing: "0.3em", color: "#4A3F35",
    textTransform: "uppercase" as const, display: "block", marginBottom: "4px",
  };

  return (
    <div style={{
      minHeight: "100vh", background: "#0A0908",
      display: "flex", alignItems: "center", justifyContent: "center",
      padding: "120px 24px 60px", fontFamily: "'Cormorant Garamond', serif",
    }}>
      <div style={{ width: "100%", maxWidth: "440px" }}>

        <Link href="/" style={{ textDecoration: "none" }}>
          <div style={{ textAlign: "center", marginBottom: "48px" }}>
            <span style={{
              fontSize: "36px", fontWeight: 300, letterSpacing: "0.35em",
              color: "#D4AF37", textTransform: "uppercase",
            }}>Velura</span>
          </div>
        </Link>

        <h1 style={{
          fontSize: "38px", fontWeight: 300, color: "#F5F0E8",
          marginBottom: "40px", lineHeight: 1.1,
        }}>
          Create your<br/>
          <em style={{ color: "#D4AF37", fontStyle: "italic" }}>fashion story.</em>
        </h1>

        {[
          { label: "Full Name",         field: "name",     type: "text",     placeholder: "Your name" },
          { label: "Email Address",     field: "email",    type: "email",    placeholder: "your@email.com" },
          { label: "Password",          field: "password", type: "password", placeholder: "Min. 8 characters" },
          { label: "Confirm Password",  field: "confirm",  type: "password", placeholder: "Repeat password" },
        ].map((f) => (
          <div key={f.field} style={{ marginBottom: "28px" }}>
            <label style={labelStyle}>{f.label}</label>
            <input
              type={f.type}
              value={form[f.field as keyof typeof form]}
              onChange={(e) => update(f.field, e.target.value)}
              placeholder={f.placeholder}
              style={inputStyle}
            />
          </div>
        ))}

        {error && <p style={{ color: "#C0392B", fontSize: "13px", marginBottom: "16px" }}>{error}</p>}

        <button onClick={handleSubmit} disabled={loading} style={{
          width: "100%", padding: "18px",
          background: loading ? "#8B7A2E" : "#D4AF37",
          border: "none", color: "#0A0908",
          fontSize: "12px", letterSpacing: "0.3em", textTransform: "uppercase",
          fontWeight: 700, fontFamily: "'Cormorant Garamond', serif",
          cursor: loading ? "not-allowed" : "pointer", marginBottom: "28px",
        }}>
          {loading ? "Creating account..." : "Join Velura"}
        </button>

        <p style={{ textAlign: "center", fontSize: "14px", color: "#4A3F35" }}>
          Already a member?{" "}
          <Link href="/auth/login" style={{ color: "#D4AF37", textDecoration: "none" }}>
            Sign in
          </Link>
        </p>
      </div>
      <style>{`input::placeholder { color: #3D3328; }`}</style>
    </div>
  );
}