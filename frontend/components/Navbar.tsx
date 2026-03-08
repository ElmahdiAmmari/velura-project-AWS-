"use client";
import { useState, useEffect } from "react";
import Link from "next/link";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <nav style={{
      position: "fixed", top: 0, left: 0, right: 0, zIndex: 100,
      padding: scrolled ? "12px 40px" : "24px 40px",
      background: scrolled ? "rgba(10,9,8,0.95)" : "transparent",
      backdropFilter: scrolled ? "blur(12px)" : "none",
      borderBottom: scrolled ? "1px solid rgba(212,175,55,0.15)" : "none",
      transition: "all 0.4s ease",
      display: "flex", alignItems: "center", justifyContent: "space-between",
    }}>
      <Link href="/" style={{ textDecoration: "none" }}>
        <span style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: "28px", fontWeight: 300,
          letterSpacing: "0.3em", color: "#D4AF37", textTransform: "uppercase",
        }}>Velura</span>
      </Link>

      <div style={{ display: "flex", gap: "40px", alignItems: "center" }}>
        {[
          { href: "/catalog", label: "Collection" },
          { href: "/subscription", label: "Plans" },
          { href: "/ai-stylist", label: "AI Stylist" },
        ].map((link) => (
          <Link key={link.href} href={link.href} style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: "15px", letterSpacing: "0.15em", color: "#C8B89A",
            textDecoration: "none", textTransform: "uppercase",
          }}>{link.label}</Link>
        ))}
        <Link href="/auth/login" style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: "14px", letterSpacing: "0.2em",
          color: "#0A0908", background: "#D4AF37",
          padding: "10px 28px", textDecoration: "none",
          textTransform: "uppercase", fontWeight: 600,
        }}>Enter</Link>
      </div>

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;400;600&display=swap');
      `}</style>
    </nav>
  );
}