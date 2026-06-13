# Code Reference & Quick Updates Guide

## 🔍 Key Code Sections

### 1. Updated Navigation Menu (index.html)
Location: After logo, before closing nav tag

```html
<li><a href="about-us.html" class="nav-link">
    <i class="fas fa-info-circle"></i> About
</a></li>
```

### 2. Enhanced Contact Section (index.html)
Location: Lines 467-530

**Key Features:**
- 2-column grid layout
- Left: Contact info + form
- Right: Embedded Google Map
- Location: Mirchaiya Bazar, Sirha, Nepal
- Email: contact@nepoonline.com

```html
<section id="contact" class="contact">
    <div class="container">
        <h2 class="section-title">Get In Touch</h2>
        <div class="contact-content" style="display: grid; 
            grid-template-columns: 1fr 1fr; gap: 40px; 
            align-items: start;">
            
            <!-- Left Column: Contact Info + Form -->
            <div>
                <div class="contact-info">
                    <div class="info-item">
                        <i class="fas fa-map-marker-alt"></i>
                        <div>
                            <h4>Location</h4>
                            <p id="contactAddress">
                                Mirchaiya Bazar<br>Sirha, Nepal
                            </p>
                        </div>
                    </div>
                    <!-- More items... -->
                </div>
                <form id="contactForm" class="contact-form">
                    <!-- Form fields -->
                </form>
            </div>
            
            <!-- Right Column: Map -->
            <div style="border-radius: 15px; overflow: hidden;">
                <iframe 
                    width="100%" 
                    height="500" 
                    frameborder="0" 
                    src="https://www.google.com/maps/embed?pb=..."
                    allowfullscreen="" 
                    loading="lazy">
                </iframe>
            </div>
        </div>
    </div>
</section>
```

### 3. Updated Footer (index.html)
Location: Lines 620-643

**Email Section in Footer:**
```html
<div class="footer-section">
    <h4>Contact Info</h4>
    <ul style="list-style: none; padding: 0;">
        <li>
            <i class="fas fa-envelope"></i> 
            <a href="mailto:contact@nepoonline.com">
                contact@nepoonline.com
            </a>
        </li>
        <li>
            <i class="fas fa-envelope"></i> 
            <a href="mailto:sales@nepoonline.com">
                sales@nepoonline.com
            </a>
        </li>
        <li>
            <i class="fas fa-envelope"></i> 
            <a href="mailto:admin@nepoonline.com">
                admin@nepoonline.com
            </a>
        </li>
    </ul>
</div>
```

### 4. Enhanced Footer CSS (modern-premium-styles.css)
Location: Lines 1724-1800

**Key CSS Changes:**
```css
.footer {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    border-top: 3px solid var(--gradient-primary);
    padding: 60px 0 20px;
}

.footer-section h4 {
    color: var(--gold-light);
    text-transform: uppercase;
    letter-spacing: 1px;
}

.footer-section p i,
.footer-section ul li i {
    margin-right: 8px;
    color: var(--accent);
}

.footer-section a {
    transition: all 0.3s ease;
}

.footer-section a:hover {
    color: var(--accent-light);
    transform: translateX(5px);
}

.social-links a {
    border: 1px solid rgba(212, 175, 55, 0.4);
}

.social-links a:hover {
    border-color: var(--accent);
}
```

### 5. About Us Page Header Section

```html
<section class="about-hero">
    <h1>About Nepo Online Stores</h1>
    <p>Your trusted destination for premium fashion and fabrics 
        with exceptional quality and customer service since day one.
    </p>
</section>
```

### 6. Founder Section in About Us

```html
<section class="founder-section">
    <div class="founder-image">
        <img src="uploads/admin.jpeg" alt="Founder" 
            style="width: 100%; max-width: 400px; border-radius: 15px;
                   box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
                   border: 5px solid white;">
    </div>
    <div class="founder-info">
        <h2>Meet Our Founder</h2>
        <p>Welcome to Nepo Online Stores, where passion for premium 
            fashion meets outstanding customer service...</p>
        <div class="social-links">
            <a href="mailto:admin@nepoonline.com" title="Email">
                <i class="fas fa-envelope"></i>
            </a>
            <a href="https://www.facebook.com" target="_blank">
                <i class="fab fa-facebook"></i>
            </a>
        </div>
    </div>
</section>
```

### 7. Contact Methods Section (About Us)

```html
<div class="contact-methods">
    <div class="contact-method">
        <i class="fas fa-map-marker-alt"></i>
        <h4>Location</h4>
        <p>Mirchaiya Bazar<br>Sirha, Nepal</p>
    </div>
    <div class="contact-method">
        <i class="fas fa-envelope"></i>
        <h4>Email</h4>
        <p><a href="mailto:contact@nepoonline.com">
            contact@nepoonline.com
        </a></p>
    </div>
    <div class="contact-method">
        <i class="fas fa-phone"></i>
        <h4>Phone</h4>
        <p><a href="tel:+977XXXXXXXXX">
            +977 (Coming Soon)
        </a></p>
    </div>
</div>
```

## 🎨 CSS Classes Reference

### About Us Page Classes

```css
/* Hero Section */
.about-hero { }

/* Founder Section */
.founder-section { }
.founder-image { }
.founder-info { }

/* Mission & Vision */
.mission-vision { }
.mission-card { }
.vision-card { }

/* Values Section */
.values-section { }
.values-grid { }
.value-card { }

/* Team Section */
.team-section { }
.team-grid { }
.team-member { }

/* Statistics */
.stats-section { }
.stats-grid { }
.stat-item { }

/* Contact Methods */
.contact-info-section { }
.contact-methods { }
.contact-method { }

/* Social Links */
.social-links { }
```

### Footer Classes (Updated)

```css
.footer { }
.footer-content { }
.footer-section { }
.footer-section h4 { }
.footer-section a { }
.footer-bottom { }
.social-links { }
.social-links a { }
```

## 📝 How to Modify Content

### Change Location:
**File:** index.html, about-us.html

Find and replace:
```
Mirchaiya Bazar, Sirha, Nepal
```

With your location.

### Change Email Addresses:
**Files:** index.html, about-us.html

Find and replace:
```
contact@nepoonline.com  → your-email@domain.com
sales@nepoonline.com    → sales-email@domain.com
admin@nepoonline.com    → admin-email@domain.com
```

### Change Founder Image:
**File:** about-us.html, line: 
```html
<img src="uploads/admin.jpeg" alt="Founder">
```

Replace `uploads/admin.jpeg` with your image path.

### Change Business Name:
**Files:** Multiple locations

Find and replace:
```
Nepo Online Stores
```

With your business name.

### Update Social Media Links:
**File:** about-us.html

Find social links section:
```html
<a href="https://www.facebook.com" target="_blank">
    <i class="fab fa-facebook"></i>
</a>
```

Replace URLs with your actual social profiles.

## 🗺️ Google Map Customization

**Current Coordinates:**
- Latitude: 26.13872
- Longitude: 86.32895

**To change location:**
1. Go to Google Maps Embed API documentation
2. Get the embed code for your location
3. Replace the `src` URL in the iframe

**Or use this formula:**
```
https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d[COORDINATES]...
```

## 📊 Responsive Breakpoints

### Mobile (Under 768px):
```css
@media (max-width: 768px) {
    .founder-section {
        grid-template-columns: 1fr;
        gap: 30px;
    }
    
    .mission-vision {
        grid-template-columns: 1fr;
    }
    
    .contact-content {
        grid-template-columns: 1fr;
        gap: 30px;
    }
    
    iframe {
        height: 300px !important;
    }
}
```

### Tablet (768px - 1024px):
- 2-column layouts work well
- Adjusted font sizes
- Flexible spacing

### Desktop (1024px+):
- Full 2-column layouts
- Large imagery
- Optimal spacing

## 🔗 Links Reference

### Navigation Links:
```html
Home          → index.html
About         → about-us.html
Shop          → #shop
Gallery       → #gallery
Contact       → #contact
Orders        → orders.html
Track         → track.html
Admin         → admin.html
```

### Email Links:
```html
<a href="mailto:contact@nepoonline.com">Email</a>
<a href="mailto:sales@nepoonline.com">Sales</a>
<a href="mailto:admin@nepoonline.com">Admin</a>
```

### Phone Links:
```html
<a href="tel:+977XXXXXXXXX">Call</a>
```

## 🎯 Implementation Checklist

- [x] Created about-us.html file
- [x] Updated index.html navigation
- [x] Enhanced contact section with map
- [x] Updated footer with emails
- [x] Enhanced footer CSS styling
- [x] Added location to multiple pages
- [x] All emails configured
- [x] Responsive design implemented
- [x] Icons added throughout
- [x] Documentation created

## ⚡ Quick Edit Commands

### To update all emails at once:
Use Find & Replace in VS Code:
1. Ctrl+H (Find & Replace)
2. Search: `contact@nepoonline.com`
3. Replace with: your email
4. Click "Replace All"

### To test contact form:
1. Open index.html
2. Scroll to Contact section
3. Fill out form
4. Click "Send Message"
5. Check admin panel → Messages

### To test About Us page:
1. Open index.html
2. Click "About" in navigation
3. Or visit: about-us.html directly

---

**Document Version:** 1.0
**Last Updated:** January 5, 2026
**Status:** Complete ✅
