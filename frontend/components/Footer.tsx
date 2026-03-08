import Link from "next/link";

export default function Footer() {
  return (
    <footer style={{
      background: "#0A0908",
      borderTop: "1px solid rgba(212,175,55,0.15)",
      padding: "60px 40px 32px",
      fontFamily: "'Cormorant Garamond', serif",
    }}>
      <div style={{
        maxWidth: "1200px", margin: "0 auto",
        display: "grid", gridTemplateColumns: "2fr 1fr 1fr 1fr",
        gap: "48px", marginBottom: "48px",
      }}>
        <div>
          <span style={{
            fontSize: "32px", fontWeight: 300, letterSpacing: "0.3em",
            color: "#D4AF37", textTransform: "uppercase", display: "block", marginBottom: "16px",
          }}>Velura</span>
          <p style={{ color: "#6B5E4E", fontSize: "14px", lineHeight: "1.8", maxWidth: "260px" }}>
            Wear the world's finest fashion. Rent, return, repeat.
          </p>
        </div>

        {[
          { title: "Explore", links: ["Collection", "AI Stylist", "How It Works"] },
          { title: "Members", links: ["Dashboard", "My Rentals", "Plans & Pricing"] },
          { title: "Legal",   links: ["Privacy Policy", "Terms of Use", "Contact"] },
        ].map((col) => (
          <div key={col.title}>
            <h4 style={{
              color: "#D4AF37", fontSize: "11px", letterSpacing: "0.25em",
              textTransform: "uppercase", marginBottom: "20px", fontWeight: 600,
            }}>{col.title}</h4>
            {col.links.map((item) => (
              <Link key={item} href="#" style={{
                display: "block", color: "#6B5E4E", fontSize: "14px",
                textDecoration: "none", marginBottom: "12px",
              }}>{item}</Link>
            ))}
          </div>
        ))}
      </div>

      <div style={{
        borderTop: "1px solid rgba(212,175,55,0.1)", paddingTop: "24px",
        display: "flex", justifyContent: "space-between",
      }}>
        <p style={{ color: "#3D3328", fontSize: "12px" }}>
          © {new Date().getFullYear()} Velura. All rights reserved.
        </p>
        <p style={{ color: "#3D3328", fontSize: "12px" }}>Made in Morocco 🇲🇦</p>
      </div>
    </footer>
  );
}