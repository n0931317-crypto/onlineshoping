# Quick Testing Guide - Nepo Online stores E-Commerce

## 🚀 Get Started in 5 Minutes

### Step 1: Add Sample Products
1. Open `admin.html` in your browser
2. Login with your Supabase credentials
3. Add products with these categories:
   - `fabrics`
   - `saree`
   - `suit`
   - `lehanga`
   - `accessories`

Example Product Data:
```
Name: Premium Cotton Fabric
Category: fabrics
Price: 599
Description: High-quality cotton fabric perfect for daily wear
```

### Step 2: Open the Homepage
1. Open `index.html` in your browser
2. You should see the advanced e-commerce interface
3. Products will load automatically from Supabase

### Step 3: Test Features

#### Search Functionality
- [ ] Type in search bar
- [ ] Products filter in real-time
- [ ] Click X button to clear search

#### Category Filtering
- [ ] Click "Fabrics" button → shows only fabric products
- [ ] Click "Sarees" button → shows only sarees
- [ ] Click "Ladies Suits" → shows only suits
- [ ] Click "All Products" → shows all products

#### Sorting
- [ ] Select "Name (A-Z)" → products sorted alphabetically
- [ ] Select "Price: Low to High" → cheapest first
- [ ] Select "Price: High to Low" → most expensive first
- [ ] Select "Newest" → recent products first

#### Price Filter
- [ ] Click "Filters" button → show advanced filters
- [ ] Move "Min Price" slider → filters from that price
- [ ] Move "Max Price" slider → filters up to that price
- [ ] Click "Reset Filters" → clears all filters

#### Product Modal
- [ ] Click any product card → modal opens
- [ ] Product name, price, description visible
- [ ] "In Stock" or "Out of Stock" shown
- [ ] Use +/- buttons to change quantity
- [ ] Click "Add to Cart" → shows alert
- [ ] Click "Buy Now" → shows alert

#### Image Carousel
- [ ] Modal opens with product image
- [ ] If multiple images:
  - [ ] Click left arrow → previous image
  - [ ] Click right arrow → next image
  - [ ] Click thumbnail → jump to image
  - [ ] Image counter shows current/total

#### Gallery
- [ ] Scroll to gallery section
- [ ] Click filter buttons → shows matching gallery items
- [ ] Images load from Supabase gallery table

#### Newsletter
- [ ] Scroll to newsletter section
- [ ] Enter email address
- [ ] Click "Subscribe" button
- [ ] Shows success message

#### Contact Form
- [ ] Scroll to contact section
- [ ] Fill out name, email, subject, message
- [ ] Click "Send Message" button
- [ ] Shows success message
- [ ] Form clears after submission

### Step 4: Test Mobile Responsiveness

1. Open browser DevTools (F12)
2. Click mobile view icon
3. Test different screen sizes:
   - [ ] iPhone (375px)
   - [ ] Tablet (768px)
   - [ ] Desktop (1024px+)

4. On mobile, verify:
   - [ ] Search bar is accessible
   - [ ] Category buttons don't overflow
   - [ ] Product cards stack vertically
   - [ ] Modal fits on screen
   - [ ] All buttons are easily tappable

### Step 5: Check Admin Panel

1. Open `admin.html`
2. Verify you can:
   - [ ] View all products
   - [ ] Add new products
   - [ ] Edit existing products
   - [ ] Upload product images
   - [ ] View gallery items

## 🔧 Common Issues & Solutions

### Issue: Products Not Loading
**Solution:**
1. Open browser console (F12)
2. Check for errors
3. Verify Supabase connection in `supabase-new.js`
4. Ensure `getClient()` returns valid client

### Issue: Search Not Working
**Solution:**
1. Check that product fields match:
   - `name` (not `title`)
   - `description`
   - `category` (lowercase values)

### Issue: Categories Not Filtering
**Solution:**
1. Verify database products have correct category values:
   - Use lowercase: `fabrics`, `saree`, `suit`, `lehanga`, `accessories`
   - Check for extra spaces or typos

### Issue: Images Not Showing
**Solution:**
1. Verify `image_url` field in database contains full URLs
2. Check image URLs are publicly accessible
3. Use placeholder images for testing

### Issue: Modal Not Opening
**Solution:**
1. Check browser console for JavaScript errors
2. Verify `ecommerce.js` is loaded
3. Check network tab to ensure all scripts load

## ✅ Expected Behavior

### Loading
- Products load within 2-3 seconds
- No console errors
- Loading indicator shows initially

### Filtering
- Instant results update (< 500ms)
- No page reload needed
- Smooth transitions

### Modal
- Opens within 500ms
- Smooth animations
- Responsive on all screen sizes

### Performance
- Homepage loads in < 2 seconds
- No jank or stuttering
- Smooth scrolling

## 📊 Sample Test Data

Use this to populate your database for testing:

```sql
-- Sample Products
INSERT INTO products (name, description, price, category, image_url, stock_quantity) VALUES
('Premium Cotton Fabric', 'High-quality 100% cotton', 599, 'fabrics', 'https://via.placeholder.com/300?text=Cotton+Fabric', 50),
('Silk Blend Fabric', 'Beautiful silk and cotton blend', 899, 'fabrics', 'https://via.placeholder.com/300?text=Silk+Blend', 40),
('Red Saree with Gold Border', 'Traditional red saree with gold embroidery', 2499, 'saree', 'https://via.placeholder.com/300?text=Red+Saree', 15),
('Blue Silk Saree', 'Elegant blue silk saree for special occasions', 3499, 'saree', 'https://via.placeholder.com/300?text=Blue+Saree', 20),
('Green Suit Set', 'Modern green ladies suit with dupatta', 1299, 'suit', 'https://via.placeholder.com/300?text=Green+Suit', 25),
('Pink Lehenga', 'Traditional pink lehenga for weddings', 5999, 'lehanga', 'https://via.placeholder.com/300?text=Pink+Lehenga', 10),
('Gold Jewelry Set', 'Matching earrings and necklace', 1999, 'accessories', 'https://via.placeholder.com/300?text=Jewelry', 30),
('Silk Dupatta', 'Beautiful silk dupatta in multiple colors', 599, 'accessories', 'https://via.placeholder.com/300?text=Dupatta', 50);
```

## 🎯 Success Criteria

Your implementation is successful when:
- ✅ Homepage loads without errors
- ✅ Products display in grid
- ✅ Search filters products in real-time
- ✅ Category buttons filter correctly
- ✅ Price range filter works
- ✅ Sorting options work
- ✅ Product modal opens and displays correctly
- ✅ Image carousel works if multiple images
- ✅ Mobile responsive design works
- ✅ All forms submit without errors
- ✅ No console JavaScript errors

## 📞 Support

If you encounter issues during testing:

1. **Check Console**: Press F12, go to Console tab
2. **Check Network**: Go to Network tab, check for failed requests
3. **Verify Data**: Check Supabase dashboard for correct product data
4. **Check Files**: Ensure all files are in the same directory:
   - index.html
   - ecommerce.js
   - ecommerce-styles.css
   - supabase-new.js
   - product-modal.css

## 🎉 Ready to Go!

Once testing is complete, your Nepo Online stores e-commerce website is ready for production!

Happy selling! 🚀
