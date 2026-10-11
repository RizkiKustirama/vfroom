# DESIGN.md - VYRO / FitWardrobe AI (Personal Virtual Try-On & AI Stylist)

A high-end, modern, luxury tech design system for an AI-powered personal Virtual Try-On and Wardrobe Stylist mobile application.

---

## 1. Visual Theme & Aesthetic Direction

* **Theme Name:** Warm Sunset Modernism / Urban High-Fashion Tech
* **Aesthetic Characteristics:** Soft gradient glows, glassmorphic floating cards, rounded pill buttons, subtle 3D rotation indicators, clean geometric typography, warm luxury sunset tones.
* **Border Radius System:**
  * Pill / Full Round: `9999px` (Buttons, Category tags, Badges, Search bar)
  * Large Cards / Containers: `24px` to `32px`
  * Medium Cards / Wardrobe Items: `16px` to `20px`
  * Small Icons / Buttons: `12px`

---

## 2. Color Palette & Tokens

### Primary Accent & Gradients
* **Primary Brand Orange:** `#FF6B4A`
* **Gradient Start (Warm Sunset):** `#FF8C66`
* **Gradient End (Vibrant Coral Orange):** `#FF4D2D`
* **Gradient Accent Fill:** `linear-gradient(135deg, #FF8C66 0%, #FF4D2D 100%)`

### Backgrounds & Surfaces
* **Dark Theme Background (Onboarding):** `#121318` (Dark Charcoal / Midnight Blue)
* **Dark Card Surface:** `rgba(255, 255, 255, 0.08)` (Glassmorphic Frosted Glass)
* **Light Theme Background (Main App):** `linear-gradient(180deg, #FFE8DE 0%, #F6F5F2 40%, #F6F5F2 100%)` (Warm Sunset Glow to Soft Off-White)
* **Light Card Surface:** `#FFFFFF` (Pure White) with soft shadow `0px 10px 30px rgba(0, 0, 0, 0.04)`

### Typography Colors
* **Dark Background Text Primary:** `#FFFFFF`
* **Dark Background Text Secondary:** `#9E9EA7`
* **Light Background Text Primary:** `#1A1B20`
* **Light Background Text Secondary:** `#767882`

### Swatches / Accent Palette
* **Obsidian Black:** `#18181B`
* **Slate Grey:** `#64748B`
* **Sage Olive Green:** `#4D5D4E`
* **Nude Beige:** `#E3DAC9`
* **Sunset Coral:** `#FF6B4A`

---

## 3. Typography System

* **Font Family:** `Plus Jakarta Sans`, `Inter`, or `SF Pro Display`
* **Font Weights:** `Regular (400)`, `Medium (500)`, `SemiBold (600)`, `Bold (700)`

### Type Scale
* **Display / Hero Title:** `32px` / `Line Height 1.2` / `Bold`
* **Screen Header:** `20px` / `Line Height 1.3` / `SemiBold`
* **Card Title / Item Name:** `18px` / `Line Height 1.3` / `Bold`
* **Subheading / Label:** `14px` / `Line Height 1.4` / `Medium`
* **Body Text:** `14px` / `Line Height 1.5` / `Regular`
* **Caption / Badge:** `11px` / `Line Height 1.4` / `SemiBold` / `Uppercase`

---

## 4. Iconography & UI Components

### Navigation Components
* **Top Navigation Bar:**
  * Left: Search Icon / Back Arrow
  * Center: Greeting ("Hi, Alex" + "AI Stylist") / Screen Title
  * Right: Notification Bell / Favorites Heart & More Options
* **Bottom Floating Navigation Bar:**
  * Pill-shaped white floating container with shadow `0px 12px 32px rgba(0,0,0,0.08)`
  * 5 Icons: `Home (Active Orange)`, `Favorites`, `Wardrobe / Hanger`, `Bag / Shop`, `Profile`

### Buttons & Inputs
* **Primary Gradient Button:** Full width or inline rounded button with `linear-gradient(135deg, #FF8C66, #FF4D2D)`, white text, right arrow icon or spark icon (`✨`).
* **Secondary Pill Input Bar:** Floating glassmorphic text input field with `+` attachment button on left and `Generate ✨` button on right.
* **Color Swatch Selector:** Vertical or horizontal stack of circular color pills (`24px x 24px`) with active border ring.

### Floating Wardrobe Selector
* Horizontal scrollable container containing white rounded square cards (`64px x 64px`).
* Icons: Cap, T-Shirt, Pants, Sneakers, Bag.
* Active state: Orange border ring or subtle shadow elevation.

### 360° Rotation Arc Indicator
* Curved dashed line behind avatar waist level with `< 360° >` label in center pill.

---

## 5. Screen Layout Specifications

### Screen 1: Onboarding / Welcome Screen (Dark Theme)
* **Background:** Deep Midnight Charcoal (`#121318`) with warm orange ambient glow at bottom right.
* **Top Bar:** VYRO Brand Logo (left), Hamburger Menu (right).
* **Hero Content:** Full-bleed portrait image of high-fashion model.
* **Headline:** "Redefine Your Style with AI" (with "Style" highlighted in Orange `#FF6B4A`).
* **Subtitle:** "Smart recommendations. Tailored to you."
* **Card Element:** "Upload Your Photo - Let AI understand your vibe and style preferences" with upload icon button.
* **CTA:** Full-width Orange Gradient Button "Get Started ->".

### Screen 2: AI Stylist & Virtual Fitting Viewport (Light / Sunset Theme)
* **Background:** Warm Sunset Orange Gradient (`#FFE8DE` top gradient fading to `#F6F5F2`).
* **Top Bar:** Search Icon (left), "Hi, Alex - AI Stylist" (center), Notification Bell (right).
* **Center Viewport:** Full-body user model avatar standing in center space with `< 360° >` rotation arc indicator.
* **Wardrobe Strip:** Floating capsule card grid displaying clothing items (Cap, T-Shirt, Pants, Shoes, Bag).
* **AI Prompt Input:** "Describe your look..." text field + `+` button + `Generate ✨` button.
* **Bottom Bar:** Floating 5-tab navigation bar.

### Screen 3: Item Detail & Registration Screen (Clean Card View)
* **Header:** Back Arrow, "Detail Items", Heart Icon, More Options (`...`).
* **Main Product Display:** Large rounded rectangle card (`#FFFFFF`) with garment image (e.g. Nexus Tech Jacket), left-aligned color swatches (Black, Grey, Olive, Beige, Orange), left/right carousel arrows (`<` `>`).
* **Product Info:**
  * Tag Badge: `NEW ARRIVAL` (Orange text)
  * Title: `NEXUS TECH JACKET` (Bold Slate)
  * Description: "Water-resistant fabric with a modern urban fit."
* **Action Footer:** Price `$129.00` (Strikethrough `$199.00` 35% OFF) + Orange Gradient `Add to Cart` Button + Cart Icon.
