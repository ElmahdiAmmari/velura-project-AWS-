"use client";
import { useEffect, useRef } from "react";
import Link from "next/link";

export default function HeroSection() {
  const textRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = textRef.current;
    if (!el) return;
    el.style.opacity = "0";
    el.style.transform = "translateY(40px)";
    setTimeout(() => {
      el.style.transition = "opacity 1.2s ease, transform 1.2s ease";
      el.style.opacity = "1";
      el.style.transform = "translateY(0)";
    }, 100);
  }, []);

  return (
    <section style={{
      minHeight: "100vh", background: "#0A0908",
      position: "relative", display: "flex", alignItems: "center", overflow: "hidden",
    }}>
      {/* Decorative gold line */}
      <div style={{
        position: "absolute", top: 0, right: "15%", width: "1px", height: "100%",
        background: "linear-gradient(to bottom, transparent, rgba(212,175,55,0.3), transparent)",
      }}/>

      {/* Large background text */}
      <div style={{
        position: "absolute", right: "-40px", top: "50%", transform: "translateY(-50%)",
        fontFamily: "'Cormorant Garamond', serif",
        fontSize: "clamp(120px, 18vw, 280px)", fontWeight: 300,
        color: "rgba(212,175,55,0.04)", userSelect: "none", whiteSpace: "nowrap",
      }}>VELURA</div>

      {/* Main content */}
      <div ref={textRef} style={{
        maxWidth: "1200px", margin: "0 auto",
        padding: "120px 40px 80px", position: "relative", zIndex: 2,
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: "16px", marginBottom: "40px" }}>
          <div style={{ width: "48px", height: "1px", background: "#D4AF37" }}/>
          <span style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: "12px", letterSpacing: "0.35em",
            color: "#D4AF37", textTransform: "uppercase", fontWeight: 600,
          }}>Fashion Rental · Morocco</span>
        </div>

        <h1 style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: "clamp(52px, 8vw, 110px)", fontWeight: 300,
          lineHeight: 1.0, color: "#F5F0E8", letterSpacing: "-0.02em",
          marginBottom: "32px", maxWidth: "700px",
        }}>
          Wear the{" "}
          <em style={{ color: "#D4AF37", fontStyle: "italic", fontWeight: 300 }}>world.</em>
          <br />Own nothing.
          <br />Miss nothing.
        </h1>

        <p style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: "18px", color: "#6B5E4E", letterSpacing: "0.08em",
          lineHeight: 1.8, maxWidth: "440px", marginBottom: "56px",
        }}>
          Rent designer pieces. Return them. Discover new ones.
          A rotating wardrobe of luxury — delivered to your door.
        </p>

        <div style={{ display: "flex", gap: "20px", flexWrap: "wrap" }}>
          <Link href="/catalog" style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: "13px", letterSpacing: "0.25em", color: "#0A0908",
            background: "#D4AF37", padding: "16px 40px", textDecoration: "none",
            textTransform: "uppercase", fontWeight: 600, display: "inline-block",
          }}>Browse Collection</Link>

          <Link href="/subscription" style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: "13px", letterSpacing: "0.25em", color: "#D4AF37",
            background: "transparent", padding: "16px 40px", textDecoration: "none",
            textTransform: "uppercase", fontWeight: 600,
            border: "1px solid rgba(212,175,55,0.4)", display: "inline-block",
          }}>View Plans</Link>
        </div>

        {/* Stats */}
        <div style={{
          display: "flex", gap: "56px", marginTop: "80px",
          paddingTop: "48px", borderTop: "1px solid rgba(212,175,55,0.12)",
        }}>
          {[
            { num: "500+", label: "Designer Pieces" },
            { num: "3",    label: "Flexible Plans" },
            { num: "48h",  label: "Delivery" },
          ].map((stat) => (
            <div key={stat.label}>
              <div style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: "36px", fontWeight: 300, color: "#D4AF37",
              }}>{stat.num}</div>
              <div style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: "11px", letterSpacing: "0.2em",
                color: "#4A3F35", textTransform: "uppercase", marginTop: "4px",
              }}>{stat.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}