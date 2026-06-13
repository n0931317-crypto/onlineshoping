# 🎨 Design Specifications & Visual Guide

## Color Palette

### Primary Colors
```
Purple (#667eea)    - Primary brand color
Pink (#764ba2)      - Secondary accent
Gold (#d4af37)      - Highlights and text
```

### Gradient
```
Linear Gradient: #667eea → #764ba2
Direction: 135deg (diagonal top-left to bottom-right)
Usage: Headers, buttons, card borders
```

### Neutral Colors
```
White (#ffffff)       - Backgrounds, text on dark
Dark Gray (#1a1a2e)   - Footer background
Light Gray (#f8f9fa)  - Section backgrounds
Black (#333333)       - Body text
```

## Typography

### Font Families
```
Primary: System fonts (Arial, Helvetica, sans-serif)
Weight: 400 (regular), 600 (semibold), 700 (bold)
```

### Font Sizes

**About Us Page:**
- H1 (Hero): 3rem (48px) → 2rem on mobile
- H2 (Sections): 2.5rem (40px)
- H3 (Cards): 1.8rem (28px)
- H4 (Sub-headers): 1.3rem (20px)
- P (Body): 1rem-1.1rem (16px-17px)

**Footer:**
- Section Headers: 18px, uppercase
- Links: 13px
- Text: 13px

## Spacing System

```
4px   - Minimal spacing
8px   - Icon margins
10px  - List item gaps
15px  - Card padding (small)
20px  - Section padding
30px  - Grid gaps (small screens)
40px  - Grid gaps (large screens)
50px  - Large section margins
60px  - Section padding (top/bottom)
```

## Shadow System

```
Card Shadow:        0 5px 20px rgba(0, 0, 0, 0.1)
Hover Shadow:       0 10px 40px rgba(0, 0, 0, 0.2)
Founder Image:      0 10px 40px rgba(0, 0, 0, 0.2)
Light Shadow:       0 2px 8px rgba(0, 0, 0, 0.08)
```

## Border Radius

```
Small:    8px
Medium:   12px
Large:    15px
Full:     50% (for circles)
```

## Layout Grid System

### About Us Page

```
┌────────────────────────────────┐
│     About Hero Section (full)  │  bg: gradient purple→pink
├────────────────────────────────┤
│                                │
│   Founder Section (2 cols)     │  bg: light gray
│   [Image] | [Content]          │  gap: 50px
│                                │
├────────────────────────────────┤
│                                │
│   Mission & Vision (2 cols)    │  gap: 40px
│   [Card]  |  [Card]            │
│                                │
├────────────────────────────────┤
│                                │
│   Values Section (3 cols)      │  min-width: 250px
│   6 cards in grid              │  gap: 30px
│                                │
├────────────────────────────────┤
│                                │
│   Stats Section (4 cols)       │  gradient bg
│   [Stat] [Stat] [Stat] [Stat]  │  white text
│                                │
├────────────────────────────────┤
│                                │
│   Team Section (4 cols)        │  gap: 30px
│   4 team member cards          │  min-width: 280px
│                                │
├────────────────────────────────┤
│                                │
│   Contact Methods (3 cols)     │  bg: light gray
│   [Method] [Method] [Method]   │  gap: 30px
│                                │
└────────────────────────────────┘
        Footer (full)             bg: dark gradient
```

### Contact Section (index.html)

```
┌────────────────────────────────┐
│   Contact Section (2 cols)     │
├─────────────────┬──────────────┤
│                 │              │
│ [Contact Info]  │  [MAP]       │
│ [Contact Form]  │  [MAP]       │
│                 │              │
└─────────────────┴──────────────┘
   50% width        50% width
   gap: 40px

Mobile (1 col):
┌────────────────────┐
│  [Contact Info]    │
├────────────────────┤
│  [Contact Form]    │
├────────────────────┤
│  [MAP]             │
│  (height: 300px)   │
└────────────────────┘
```

## Component Specifications

### Cards

**Value Cards / Team Cards:**
```
Width: 250px - 280px (auto-fit)
Padding: 30px
Border-radius: 15px
Box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1)
Background: white
Hover Transform: translateY(-10px)
```

**Mission/Vision Cards:**
```
Width: 100% (grid)
Padding: 40px
Border-radius: 15px
Border-top: 5px solid (gradient color)
Box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1)
Background: white
```

**Contact Method Cards:**
```
Width: 250px (auto-fit)
Padding: 30px
Text-align: center
Border-radius: 15px
Box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1)
Background: white
Icon Size: 2.5rem
Icon Color: #667eea
```

### Buttons

**Primary Button (.btn-primary):**
```
Background: linear-gradient(#667eea, #764ba2)
Color: white
Padding: 12px 30px
Border-radius: 8px
Font-size: 16px
Font-weight: 600
Transition: all 0.3s ease
Hover: scale(1.05), brighter gradient
```

**Secondary Button (.btn-secondary):**
```
Background: rgba(102, 126, 234, 0.1)
Color: #667eea
Border: 2px solid #667eea
Padding: 12px 30px
Border-radius: 8px
Font-size: 16px
Transition: all 0.3s ease
Hover: background gradient
```

### Forms

**Input/Textarea:**
```
Width: 100%
Padding: 12px 16px
Border: 1px solid #e0e0e0
Border-radius: 8px
Font-size: 14px
Transition: all 0.3s ease
Focus: border-color: #667eea, box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1)
```

### Icons

**Social Links Icons:**
```
Size: 16px (inside circles)
Color: white
Circle Size: 40px
Circle Bg: rgba(212, 175, 55, 0.2)
Circle Border: 1px solid rgba(212, 175, 55, 0.4)
Hover Circle Bg: gradient
Transform on Hover: translateY(-5px)
```

**Content Icons:**
```
Solid Icons: 3rem, 2.5rem, or inline
Color: #667eea (primary)
Margin-right: 8px (inline)
Margin-bottom: 15px (block)
```

## Animation Specifications

### Hero Section
```
Animation: slideDownBanner
Duration: 0.5s
Easing: ease-out
From: opacity 0, translateY -100%
To: opacity 1, translateY 0
```

### Card Hover
```
Transform: translateY(-10px)
Transition: 0.3s ease
```

### Link Hover
```
Transform: translateX(5px)
Transition: 0.3s ease
Color change to accent color
```

### Social Icon Hover
```
Transform: translateY(-5px)
Background: gradient animation
Transition: 0.3s ease
```

### Founder Image Hover
```
Transform: scale(1.05)
Transition: 0.3s ease
```

## Responsive Design Breakpoints

### Mobile (max-width: 480px)
```
Font sizes: reduced 10-15%
Padding: 15px
Grid columns: 1
Gap: 15px
Hero H1: 2rem
Section H2: 1.5rem
Hero text: center
Images: 100% width
```

### Tablet (max-width: 768px)
```
Font sizes: reduced 5-10%
Padding: 20px
Grid columns: 2
Gap: 20px
Contact section: 1 column
Map height: 300px
Founder section: 1 column
Mission/Vision: 1 column
```

### Desktop (min-width: 1024px)
```
Max-width container: 1200px
Full layouts: working
Large imagery
Optimal spacing
All features visible
```

## Accessibility Features

### Color Contrast
```
Text on white: #333333 (AAA)
Text on gradient: white (AAA)
Links: #667eea (AA on white)
```

### Font Readability
```
Line-height: 1.6 - 1.8 (body text)
Letter-spacing: 0.5px - 1px (headers)
Max-width: 600px (for text blocks)
Font-size minimum: 13px (for smaller text)
```

### Interactive Elements
```
Minimum touch target: 44x44px
Clear focus states: outline/border change
Hover states: color + transform
Title attributes on icons
Alt text on all images
```

### Navigation
```
Clear link styling
Visible focus indicators
Semantic HTML (nav, section, article)
Skip to main content link (optional)
```

## Image Specifications

### Founder Image
```
Format: JPEG (.jpeg)
Size: Recommended 400x400px (minimum)
Aspect ratio: 1:1 (square)
File size: < 200KB
Optimization: compressed
Border: 5px white
Border-radius: 15px
Shadow: 0 10px 40px rgba(0, 0, 0, 0.2)
```

### Logo
```
Format: PNG (.png)
Size: Recommended 50x50px
Aspect ratio: 1:1
Transparency: supported
File size: < 100KB
```

## Print Styles (Optional)

```css
@media print {
    .footer { page-break-inside: avoid; }
    .header { display: none; }
    .contact-form { display: none; }
    .social-links { display: none; }
    a { text-decoration: none; }
}
```

## Performance Optimization

### Image Optimization
- Use compressed images (75% quality)
- Lazy load where possible
- WebP format (with fallback)
- SVG for icons

### CSS Optimization
- Minify CSS in production
- Use CSS variables for colors
- Group similar properties

### JavaScript Optimization
- Minimal dependencies
- Deferred loading
- Event delegation

## Browser Support

```
Chrome:   Latest 2 versions ✅
Firefox:  Latest 2 versions ✅
Safari:   Latest 2 versions ✅
Edge:     Latest version ✅
Mobile:   iOS 12+, Android 8+ ✅
```

## SEO Specifications

```
Meta charset: UTF-8
Viewport: width=device-width, initial-scale=1.0
Title: "About Us - Nepo Online Stores"
Meta description: (max 160 chars)
Open Graph tags: og:title, og:description, og:image
Structured data: JSON-LD (optional)
```

---

**Design System Version:** 1.0
**Last Updated:** January 5, 2026
**Compliance:** WCAG 2.1 AA ✅
