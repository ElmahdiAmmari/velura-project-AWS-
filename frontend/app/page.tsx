import HeroSection from "@/components/HeroSection";
import Link from "next/link";

const categories = [
  { label: "Gowns & Eveningwear", count: "124 pieces" },
  { label: "Ready-to-Wear",       count: "238 pieces" },
  { label: "Accessories & Bags",  count: "89 pieces"  },
  { label: "Casual & Streetwear", count: "156 pieces" },
];

const howItWorks = [
  { step: "01", title: "Choose Your Plan",   text: "Select the subscription tier that fits your lifestyle." },
  { step: "02", title: "Browse & Select",    text: "Discover hundreds of curated designer pieces." },
  { step: "03", title: "Wear & Return",      text: "Receive within 48 hours. Wear, return, repeat." },
];

export default function HomePage() {
  return (
    <div style={{ background: "#0A0908" }}>
      <HeroSection />

      {/* Categories */}
      <section style={{ padding: "100px 40px", maxWidth: "1200px", margin: "0 auto" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "16px", marginBottom: "60px" }}>
          <div style={{ width: "48px", height: "1px", background: "#D4AF37" }}/>
          <span style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: "12px", letterSpacing: "0.35em",
            color: "#D4AF37", textTransform: "uppercase", fontWeight: 600,
          }}>Browse by Category</span>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: "2px" }}>
          {categories.map((cat) => (
            <Link key={cat.label} href="/catalog" style={{
              display: "block", padding: "40px 32px",
              background: "#0F0D0B",
              border: "1px solid rgba(212,175,55,0.08)",
              textDecoration: "none",
              fontFamily: "'Cormorant Garamond', serif",
            }}>
              <h3 style={{ fontSize: "20px", fontWeight: 400, color: "#F5F0E8", marginBottom: "8px" }}>
                {cat.label}
              </h3>
              <p style={{ fontSize: "12px", color: "#4A3F35", letterSpacing: "0.1em" }}>{cat.count}</p>
            </Link>
          ))}
        </div>
      </section>

      {/* How It Works */}
      <section style={{
        padding: "100px 40px",
        borderTop: "1px solid rgba(212,175,55,0.08)",
        background: "#0C0B09",
      }}>
        <div style={{ maxWidth: "1200px", margin: "0 auto" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "16px", marginBottom: "72px" }}>
            <div style={{ width: "48px", height: "1px", background: "#D4AF37" }}/>
            <span style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: "12px", letterSpacing: "0.35em",
              color: "#D4AF37", textTransform: "uppercase", fontWeight: 600,
            }}>How It Works</span>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: "64px" }}>
            {howItWorks.map((s) => (
              <div key={s.step}>
                <div style={{
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: "72px", fontWeight: 300,
                  color: "rgba(212,175,55,0.1)", lineHeight: 1, marginBottom: "24px",
                }}>{s.step}</div>
                <h3 style={{
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: "24px", fontWeight: 400, color: "#F5F0E8", marginBottom: "16px",
                }}>{s.title}</h3>
                <p style={{
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: "15px", color: "#6B5E4E", lineHeight: 1.8,
                }}>{s.text}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section style={{ padding: "120px 40px", textAlign: "center", fontFamily: "'Cormorant Garamond', serif" }}>
        <h2 style={{
          fontSize: "clamp(36px, 6vw, 72px)", fontWeight: 300,
          color: "#F5F0E8", marginBottom: "48px",
        }}>
          Your wardrobe,{" "}
          <em style={{ color: "#D4AF37", fontStyle: "italic" }}>reimagined.</em>
        </h2>
        <Link href="/auth/register" style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: "13px", letterSpacing: "0.25em", color: "#0A0908",
          background: "#D4AF37", padding: "18px 56px",
          textDecoration: "none", textTransform: "uppercase", fontWeight: 700,
          display: "inline-block",
        }}>Start Free Trial</Link>
      </section>
    </div>
  );
}