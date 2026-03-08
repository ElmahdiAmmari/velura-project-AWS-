import PlanCard from "@/components/PlanCard";

const plans = [
  {
    name: "Essential", price: 299,
    description: "Perfect for occasional occasions. Discover the Velura experience.",
    features: ["2 items per month", "Standard delivery (72h)", "Basic catalog access", "Free returns"],
    isPopular: false,
  },
  {
    name: "Signature", price: 599,
    description: "Our most loved plan. Priority access to new arrivals and designer drops.",
    features: ["5 items per month", "Priority delivery (48h)", "Full catalog access", "AI Stylist included", "Free dry cleaning"],
    isPopular: true,
  },
  {
    name: "Couture", price: 999,
    description: "The ultimate fashion experience. Unlimited access and personal styling.",
    features: ["Unlimited items", "Express delivery (24h)", "Exclusive pieces", "Personal stylist sessions", "AI Stylist priority", "Free dry cleaning"],
    isPopular: false,
  },
];

const faqs = [
  { q: "Can I cancel anytime?",        a: "Yes. Cancel at any time with no hidden fees." },
  { q: "How does returning work?",      a: "Place items in the prepaid return bag and drop off at any post office." },
  { q: "What if an item gets damaged?", a: "Normal wear is covered. We handle all dry cleaning." },
  { q: "When are new pieces added?",    a: "New arrivals every week. Signature & Couture get early access." },
];

export default function SubscriptionPage() {
  return (
    <div style={{ background: "#0A0908", minHeight: "100vh", paddingTop: "100px", fontFamily: "'Cormorant Garamond', serif" }}>

      {/* Header */}
      <section style={{ padding: "80px 40px 60px", textAlign: "center" }}>
        <h1 style={{ fontSize: "clamp(40px, 6vw, 72px)", fontWeight: 300, color: "#F5F0E8", marginBottom: "24px" }}>
          Choose your{" "}
          <em style={{ color: "#D4AF37", fontStyle: "italic" }}>fashion chapter.</em>
        </h1>
        <p style={{ fontSize: "18px", color: "#6B5E4E", maxWidth: "560px", margin: "0 auto", lineHeight: 1.7 }}>
          All plans include free returns, 500+ pieces, and a 7-day free trial.
        </p>
      </section>

      {/* Plans */}
      <section style={{ padding: "20px 40px 100px", maxWidth: "1100px", margin: "0 auto" }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: "24px", alignItems: "center" }}>
          {plans.map((plan) => <PlanCard key={plan.name} {...plan} />)}
        </div>
        <p style={{ textAlign: "center", marginTop: "40px", fontSize: "13px", color: "#3D3328" }}>
          All prices in MAD. Billed monthly. Cancel anytime.
        </p>
      </section>

      {/* FAQ */}
      <section style={{ borderTop: "1px solid rgba(212,175,55,0.1)", padding: "80px 40px", maxWidth: "800px", margin: "0 auto" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "16px", marginBottom: "56px" }}>
          <div style={{ width: "48px", height: "1px", background: "#D4AF37" }}/>
          <span style={{ fontSize: "12px", letterSpacing: "0.35em", color: "#D4AF37", textTransform: "uppercase", fontWeight: 600 }}>
            Frequently Asked
          </span>
        </div>
        {faqs.map((faq, i) => (
          <div key={i} style={{ padding: "32px 0", borderBottom: "1px solid rgba(212,175,55,0.08)" }}>
            <h3 style={{ fontSize: "20px", fontWeight: 400, color: "#F5F0E8", marginBottom: "12px" }}>{faq.q}</h3>
            <p style={{ fontSize: "15px", color: "#6B5E4E", lineHeight: 1.8 }}>{faq.a}</p>
          </div>
        ))}
      </section>
    </div>
  );
}