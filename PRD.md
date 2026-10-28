# PRD: Sorted — Weekly Meal Planning on Autopilot

*Working name. Hackathon proof of concept · Solo build · ~4 hours · 28 Oct 2026*

---

## 1. Problem

Doing a proper weekly meal plan and grocery shop takes **~90 minutes** of fiddly, manual work:

1. Decide what to eat
2. Check the calendar for which nights you're actually cooking
3. Pick recipes (and check they hit your macros — protein up, fat down)
4. Translate each recipe from each website into ingredients
5. Merge everything into one list with correct quantities
6. Check the cupboards for what you already have
7. Find every item on the supermarket website, handling out-of-stock substitutions (which can break the meal plan)
8. Pick a delivery slot and check out

Every step is solvable; nobody has stitched them together.

## 2. Vision

> Tell it about you once. Every week, it reads your calendar, plans meals that hit your macros, works out what you already have, fills your basket, handles substitutions, and books a slot — you just approve.

**Demo moment:** the audience *watches 90 minutes disappear* — calendar → plan → list → basket → slot → "You just saved ~90 minutes."

## 3. Goals & non-goals

**Goals (for the hackathon)**
- A polished, end-to-end, clickable flow covering the full pipeline (onboarding → confirmed order)
- Visible "intelligence" at every step — the app explains *why* it made each decision
- Works reliably with **no network/API key** (golden-run fallback); upgrades to live Claude when a key is present
- A beautiful mobile-first UI that feels like a real consumer product

**Non-goals**
- Real supermarket integration (no UK supermarket offers a public ordering API — mocked, retailer-agnostic)
- Real calendar OAuth (mocked)
- Real payments, accounts, auth, or persistence beyond localStorage
- Weekly budget constraints (future)
- Fridge photo recognition (stretch at most)

## 4. Target user

Health-conscious home cook (persona: me) who meal-preps weekly, tracks macros, shops online for delivery, and has a busy, variable calendar. Cooks for 1 by default; household size is configurable.

## 5. User flow

```
Onboarding (3 screens)
  → Week view (calendar-aware cooking nights)
  → Meal plan (macro-balanced)
  → Shopping list ("probably have" review)
  → Basket (store mapping + substitutions)
  → Delivery slot (calendar-aware)
  → Order confirmed (week summary + time saved)
```

## 6. Features & requirements

Priority: **P0** = must ship for demo · **P1** = should ship · **P2** = stretch

### 6.1 Onboarding — 3 screens (P0)

| Screen | Content |
|---|---|
| **1. You** | Household size (default 1) · Meals to plan: Dinners / Lunches / Breakfasts, default **Dinners + staples** · Dietary requirements chips (vegetarian, vegan, pescatarian, gluten-free, dairy-free, nut allergy, + free text dislikes) |
| **2. Macros** | Presets: **High protein · Balanced · Cut · Custom** → shows daily kcal / protein / fat / carbs, editable in Custom |
| **3. Connect** | "Connect calendar" (Google / Outlook buttons → mocked success state) · "Choose supermarket" (Tesco / ASDA / Ocado / Sainsbury's tiles → mocked connect) |

- All settings editable later from a Settings screen (P1).

### 6.2 Calendar-aware week (P0)
- Reads a **mock calendar** (seeded week of realistic events, e.g. "Thu 7pm team drinks", "Sat away – Brighton", "Tue late meeting till 8pm").
- Infers each day's status: **Cooking · Eating out · Away · Quick meal** (late night → ≤20-min recipe).
- Shows reasoning per day: *"Skipping Thursday — you've got team drinks at 7pm."*
- User can tap any day to override the status.

### 6.3 Meal plan (P0)
- Picks a recipe for each cooking night from a **curated library (~25 recipes)** with exact ingredients, servings, prep time, and macros per serving.
- Respects dietary requirements, quick-meal nights, variety (no repeat protein two nights running), and macro targets.
- **Macro view:** a daily ring per day (planned meals + staples vs target) and a **weekly "on track" score** — a heavier day can be balanced by lighter ones.
- Per-meal actions: **Swap** (get alternatives that keep macros on track), **Remove**.
- **Staples:** recurring breakfast/lunch items (oats, Greek yoghurt, wraps, eggs, fruit) with rough macros, included in daily totals and the shopping list.
- **Add recipe (P1):** "Ask Claude for an idea" → generated recipe with ingredients + estimated macros.
- **Import from URL (P2):** paste a recipe link → Claude extracts ingredients. *First to cut.*

### 6.4 Smart shopping list (P0)
- Merges ingredients across all meals + staples, **normalises units and sums quantities in code** (e.g. 2 × 200g chicken + 300g → 700g), scaled by household size.
- Grouped by aisle (Produce, Meat & Fish, Dairy, Cupboard, Frozen).
- **"Probably have"** section with reasoning:
  - Common staples assumed in stock (oil, salt, pepper, spices) — *"Pantry basic"*
  - Purchase memory — *"You bought rice 5 days ago"* (seeded mock history)
- Quick review: each item toggles **Got it / Need it**.

### 6.5 Basket & substitutions (P0)
- Maps each list item to a product in the **mock store catalogue** (~80–120 products: name, brand, pack size, price, macros, stock status), choosing pack sizes to cover the quantity needed.
- Animated "filling your basket" sequence — items tick in one by one (the autopilot moment).
- Seeded with **2–3 deliberately out-of-stock items** to demo:
  - **Ingredient swap, macro-aware:** *"Greek yoghurt is out — swapped for skyr: same protein, +2g fat."* Accept / choose another.
  - **Meal swap escalation:** *"No salmon available. Swap Wednesday's Salmon & Greens for Chilli Prawn Stir-fry — same macros, 5 min quicker?"* → accepting updates the plan, list, and basket.
- Basket summary: item count, total price, store branding of the chosen retailer.

### 6.6 Delivery slot (P0)
- Mock slot grid for the next few days.
- **Recommended slot** based on calendar: *"Sunday 6–7pm — you're home, and it arrives before your first cooking night (Monday)."*

### 6.7 Order confirmed (P0)
- Week summary: meals by night, weekly macro score, total cost, item count.
- **"You just saved ~90 minutes"** hero stat.

## 7. AI design

**Principle:** Claude makes judgement calls and writes the explanations; **code does all arithmetic** (quantity merging, unit conversion, macro sums, pack sizing).

| Step | Claude does | Code does |
|---|---|---|
| Calendar | Classify each day + write reasoning | Load mock events |
| Plan | Choose recipes per night from the library given constraints | Validate macros, dietary filters, compute rings & score |
| Pantry | Write "probably have" reasons | Apply staple rules + purchase history |
| Substitutions | Pick macro-appropriate substitute or propose meal swap | Detect out-of-stock, recompute macros/list |
| Slot | Write recommendation reason | Rank slots by calendar availability |
| Add/Import recipe | Generate / extract recipe as JSON | Validate schema |

**Reliability: hybrid with fallback**
- All Claude calls go through a small server route (API key never in the browser) and return **structured JSON** (tool use / JSON schema).
- If no `ANTHROPIC_API_KEY` is set, a call fails, or it exceeds a timeout (~8s) → fall back to a **cached golden run** for the seeded demo data.
- A subtle "Live AI / Demo mode" badge in Settings.
- Model: latest Claude Sonnet (fast); configurable via env.

## 8. Design direction

- **Mobile-first web app**, shown inside a phone frame on desktop for demos.
- **Look & feel inspired by Too Good To Go:** deep teal/forest green primary, warm cream/off-white backgrounds, rounded cards, friendly bold headings, food photography. Inspired-by, not a copy — our own name, logo, and palette.
- **Macro rings** borrowed from fitness/fintech apps: bold numbers, clean progress rings.
- Microinteractions: basket-filling animation, ring fills, swap transitions.
- Food imagery: free stock photos (e.g. Unsplash) or emoji/illustration fallback.

## 9. Technical approach

- **Stack:** Next.js (App Router) + TypeScript + Tailwind CSS. API routes host Claude calls. `@anthropic-ai/sdk`.
- **Data (static JSON in repo):** `recipes.json`, `store-catalogue.json`, `calendar.json`, `purchase-history.json`, `staples.json`, `golden-run.json`.
- **State:** client-side (React context/Zustand) + localStorage for onboarding settings.
- **Run:** `npm run dev`; optional `.env.local` with `ANTHROPIC_API_KEY`.

## 10. Build plan (~4 hours)

| Time | Milestone |
|---|---|
| 0:00–0:30 | Scaffold Next.js + Tailwind, design tokens, phone-frame layout, seed data files |
| 0:30–1:00 | Onboarding (3 screens) |
| 1:00–1:45 | Week view + meal plan + macro rings (deterministic first, using golden run) |
| 1:45–2:30 | Shopping list merge + "probably have" review |
| 2:30–3:15 | Basket fill animation + substitutions (ingredient + meal swap) |
| 3:15–3:35 | Delivery slot + confirmation |
| 3:35–4:00 | Wire live Claude (if key) behind fallback, polish, rehearse demo |

**Cut order if behind:** URL import → Ask Claude for a recipe → Settings screen → live Claude (golden run only) → meal-swap escalation.

## 11. Demo script (~2 min)

1. "Every week I spend ~90 minutes doing this…" (show the 8 steps)
2. Onboarding: 1 person, dinners + staples, High protein, connect calendar + Tesco
3. Week view: "It skipped Thursday — team drinks"
4. Meal plan: rings fill, weekly score on track; swap one meal
5. List: "probably have rice — bought 5 days ago"; tick through
6. Basket fills live; skyr swap; salmon → prawn meal swap
7. Slot recommended around calendar → confirm → **"You just saved ~90 minutes"**

## 12. Success criteria

- Full flow runs end-to-end without errors, with and without an API key
- Every AI decision shows a human-readable reason
- Shopping quantities are arithmetically correct and match the plan
- Both substitution types demo reliably
- UI looks like a shippable consumer app at phone width

## 13. Future

Real calendar OAuth · real retailer integration (browser agent / partnerships) · weekly budget · fridge photo pantry scan · leftovers/batch cooking · learning preferences from past weeks · multi-person macros.

## 14. Open questions

- Final product name (working: **Sorted**)
- Anthropic API key available? (App works without one)
