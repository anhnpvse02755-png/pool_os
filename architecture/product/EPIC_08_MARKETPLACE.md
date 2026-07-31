# EPIC 08 — Marketplace

Status:
Authorized

Roadmap:
Roadmap V3 (Beta)

Owner:
Product Owner

Priority:
Medium

Dependencies:

- Foundation Features 010 (Equipment Reviews / Specifications / Ownership)
- Foundation Features 011 (Equipment History / Usage / Maintenance)
- Foundation Features 012 (Comparison Engine / Specification Compare)
- EPIC 01 — Match Engine
- EPIC 02 — Statistics & Analytics
- EPIC 03 — Training System
- EPIC 04 — Tournament & Competition System
- EPIC 05 — Knowledge System
- EPIC 06 — AI Coach
- EPIC 07 — Community System

Wave Model:
Internal — 3 Waves, but **single lifecycle** (1 Engineering Report +
1 Full Regression + 1 PO Review + 1 Close) per PO directive 2026-07-31.

---

# §0 — Objective

Build Equipment Marketplace on top of the existing Equipment foundation.
Marketplace is a listing and basic transaction management layer between users.
No AI, no payment, no chat, no shipping, no auction.

---

# §1 — Deliverables

## 1.1 Equipment Review

Extends FEATURE_010. Includes:

- Review text
- Rating (1–5 stars)
- Pros list
- Cons list
- Photos
- Verified Owner badge

## 1.2 Equipment Rating

Aggregate statistics:

- Average rating
- Total reviews count
- Rating distribution (★5: N / ★4: N / ★3: N / …)

## 1.3 Equipment Comparison

Extends FEATURE_012. Adds:

- Compare more than 2 cues
- Compare shaft
- Compare tip
- Compare weight
- Compare balance
- Compare user rating

No AI.

## 1.4 Buy / Sell

Listing management:

- Price
- Condition
- Location
- Images
- Description
- Seller

States: Draft / Published / Reserved / Sold / Archived.

## 1.5 Marketplace Browser

Browse and search listings:

- Search
- Category
- Filter: Brand / Cue / Shaft / Tip / Weight / Price / Condition / Location
- Sort: Newest / Oldest / Lowest Price / Highest Price / Rating

## 1.6 Wishlist

User watches equipment:

- Add to wishlist
- Remove from wishlist
- Favorite toggle
- Notify when available (placeholder — no push)

## 1.7 Inventory

Personal inventory management:

- Owned Equipment
- Past Equipment
- Current Equipment
- For Sale
- Sold History
- Purchase History

---

# §2 — Architecture

```
Marketplace UI
  ↓
MarketplaceService           ← sole entry point
  ↓
MarketplacePipeline         ← orchestrator
  ↓
6 Engines
 ├── ReviewEngine
 ├── RatingEngine
 ├── ComparisonEngine
 ├── ListingEngine
 ├── WishlistEngine
 └── InventoryEngine
  ↓
Equipment Repository        ← EPIC 010–012 foundation only
```

Marketplace uses existing Equipment data. Does NOT create a new Equipment engine.

---

# §3 — Reuse (Foundation)

EPIC 08 MUST reuse:

- ✅ FEATURE_010 — Equipment / Reviews / Specifications / Ownership
- ✅ FEATURE_011 — Equipment History / Usage / Maintenance
- ✅ FEATURE_012 — Comparison Engine / Specification Compare / Equipment Metadata

No new Equipment engine. No schema redesign outside Marketplace scope.

---

# §4 — Forbidden

Engineering must NOT implement:

- ❌ AI Suggestion / Equipment Recommendation / Price Prediction / Smart Matching
- ❌ Payment Gateway / Stripe / PayPal / Banking / Wallet
- ❌ Shipping / Delivery Tracking
- ❌ Auction / Live Bidding
- ❌ Chat / Messaging
- ❌ Social Feed
- ❌ Notification Engine (already in EPIC 07)
- ❌ Schema redesign outside Marketplace scope

---

# §5 — Lifecycle (single — Roadmap V3 Beta)

```
Wave 1  — Equipment Review / Rating / Comparison
Wave 2  — Buy / Sell / Marketplace Browser / Search
Wave 3  — Wishlist / Inventory / History
         ↓
1 Engineering Report
         ↓
1 Full Regression
         ↓
1 PO Review
         ↓
1 Merge
         ↓
1 Close
```

---

*Spec authored by PO 2026-07-31, recorded by Engineering.*