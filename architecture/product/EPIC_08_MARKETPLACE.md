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

- Foundation Features 010 (Equipment / Specifications / Ownership / Review base)
- Foundation Features 011 (Equipment History / Usage / Maintenance / Lifecycle)
- Foundation Features 012 (Comparison Engine / Equipment Metadata)
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

Build a complete Equipment Marketplace System on top of the existing
Equipment Foundation (FEATURE 010–012). Marketplace manages Reviews,
Ratings, Equipment comparison, Listings, Buy/Sell workflow, Wishlist, and
Personal Inventory. No AI, no payment, no chat, no shipping, no auction.

---

# §1 — Deliverables

## 1.1 Equipment Review

Extends FEATURE_010. Users can:

- Create review
- Edit own review
- Delete own review
- View all reviews
- Sort reviews

Each review contains:

- Rating (1–5 stars)
- Title
- Body text
- Pros list
- Cons list
- Images
- Created Date
- Updated Date

Optional: Verified Owner badge.

**Review States:** Draft / Published / Hidden / Archived.

**Rules:**
- One review per user per equipment.
- Editing preserves history timestamp.
- Deleting never removes rating statistics immediately (soft delete).

## 1.2 Equipment Rating

Aggregate reviews.

**Metrics:**

- Average Rating
- Total Reviews count
- Rating Distribution (e.g. ★★★★★ 45 / ★★★★☆ 23 / ★★★☆☆ 11 / ★★☆☆☆ 2 / ★☆☆☆☆ 0)

**Filters:** Newest / Oldest / Highest Rating / Lowest Rating / Verified Owner.

**Rules:** Rating is calculated from Published reviews only. Draft and Archived reviews excluded.

## 1.3 Equipment Comparison

Built on FEATURE_012.

**Support:** Cue / Shaft / Tip / Extension / Case / Glove / Chalk / Accessory.

**Compare:** Brand / Model / Weight / Length / Balance Point / Tip Diameter / Joint / Material / Price / User Rating / Review Count / Specifications.

**Comparison Modes:** 2 items / 3 items / 4 items.

No AI. Only factual comparison.

## 1.4 Buy / Sell

Listing management.

**Listing contains:** Listing ID / Equipment / Seller / Price / Currency / Condition / Description / Images / Location / Created Date / Updated Date.

**Listing State:** Draft / Published / Reserved / Sold / Archived / Cancelled.

**Actions:** Create / Edit / Publish / Reserve / Mark Sold / Archive / Delete Draft.

**Rules:**
- Only owner may edit.
- Sold listing becomes read-only.
- Archived listing hidden.

## 1.5 Marketplace

Marketplace Browser.

**Browse:** Search / Category / Brand / Price / Condition / Location / Rating / Newest / Oldest.

**Filter:** Cue / Shaft / Tip / Accessory / Case / Extension / Glove / Chalk.

**Sort:** Newest / Oldest / Lowest Price / Highest Price / Highest Rating / Most Reviews.

**Detail Page:** Equipment / Reviews / Seller / Listing / Specifications / Comparison shortcut / Wishlist shortcut.

## 1.6 Wishlist

Personal wishlist.

**Actions:** Add / Remove / Favorite / Move to Inventory.

**Wishlist Item:** Equipment / Desired Price / Notes / Priority / Added Date.

**State:** Active / Purchased / Removed / Archived.

**Placeholder:** Notify when available (capability only — no notification implementation).

## 1.7 Inventory

Personal equipment ownership.

**Inventory Groups:** Current Equipment / Past Equipment / Wishlist Purchases / For Sale / Sold / Archived.

**Inventory Record:** Equipment / Purchase Date / Purchase Price / Sell Date / Sell Price / Condition / Notes / Ownership Status.

**Ownership Status:** Owned / For Sale / Sold / Archived.

---

# §2 — Architecture

```
Marketplace UI
  ↓
MarketplaceService           ← sole entry point
  ↓
MarketplacePipeline         ← orchestrator
  ↓
7 Engines
 ├── ReviewEngine
 ├── RatingEngine
 ├── ComparisonEngine
 ├── ListingEngine
 ├── WishlistEngine
 ├── InventoryEngine
 └── SearchEngine
  ↓
Equipment Repository        ← EPIC 010–012 foundation only
```

Marketplace NEVER owns Equipment. Equipment Foundation remains owner.

---

# §3 — Reuse (Foundation — Mandatory)

EPIC 08 MUST reuse, no duplication allowed:

- ✅ FEATURE_010 — Equipment / Specifications / Ownership / Review base
- ✅ FEATURE_011 — Equipment History / Usage / Maintenance / Lifecycle
- ✅ FEATURE_012 — Comparison Engine / Equipment Metadata / Specification Compare

No new Equipment engine. No schema redesign outside Marketplace scope.

---

# §4 — Data Ownership

Marketplace OWNS:

- Review
- Rating Aggregate
- Listing
- Wishlist
- Inventory
- Marketplace Search

Marketplace NEVER OWNS:

- Equipment
- Match
- Training
- Knowledge
- Statistics
- AI

---

# §5 — Capability Pattern

Unavailable functions return `CapabilityResult.notAvailable(...)`.
Never throw production exceptions.

Examples:

- Future Payment → `notAvailable`
- Shipping → `notAvailable`
- Auction → `notAvailable`
- Availability Notification → `notAvailable`

Same pattern as EPIC 04 and EPIC 06.

---

# §6 — UI Screens

Required:

- Marketplace Home
- Equipment Detail
- Equipment Review
- Comparison
- Create Listing
- Listing Detail
- Wishlist
- Inventory
- My Listings
- Review Editor

---

# §7 — Beta Constraints

- No realtime / websocket
- No payment
- No shipping
- No auction
- No live negotiation
- No messaging
- No AI
- No recommendation

---

# §8 — Forbidden

Engineering MUST NOT implement:

- ❌ AI Equipment Suggestion / Price Prediction / Recommendation / Marketplace Ranking AI
- ❌ Payment Gateway / Wallet / Stripe / PayPal / Banking
- ❌ Shipping / Delivery Tracking
- ❌ Auction / Live Bid
- ❌ Messaging / Chat / Voice / Video
- ❌ Social Commerce
- ❌ External Marketplace Integration
- ❌ Schema redesign outside Marketplace scope

---

# §9 — Lifecycle (single — Roadmap V3 Beta)

```
Wave 1  — Equipment Review / Rating / Extended Comparison
Wave 2  — Buy / Sell / Marketplace / Search / Filter / Listing lifecycle
Wave 3  — Wishlist / Inventory / My Listings / Integration / Architecture audit
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

Engineering may work internally by waves. Official lifecycle remains:
Engineering → Engineering Report → Full Regression → PO Review → Merge → accepted_closed.

---

# §10 — Success Criteria

The Epic is accepted when:

- [ ] All 7 deliverables implemented.
- [ ] FEATURE 010–012 reused (no duplicated Equipment logic).
- [ ] No AI features introduced.
- [ ] No payment or shipping features introduced.
- [ ] Marketplace isolated from Match, Training, Knowledge, and AI ownership.
- [ ] One Engineering Report.
- [ ] One Full Regression.
- [ ] One PO Review.
- [ ] One Merge.
- [ ] One accepted_closed.

---

*Spec authored by PO 2026-07-31, recorded by Engineering.*