// Initialize Supabase - Using window.supabaseClient from supabase-new.js
// const subaseUrl = 'YOUR_SUPABASE_URL';
// const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
// const supabase = window.supabase.createClient(supabaseUrl, supabaseKey);

// Mobile Drawer & Side Menu Navigation Handler
function toggleMobileMenu(event) {
    event.preventDefault();
    const sideMenu = document.getElementById('sideMenu');
    const overlay = document.getElementById('sideMenuOverlay');
    
    if (sideMenu.classList.contains('active')) {
        closeSideMenu();
    } else {
        sideMenu.classList.add('active');
        overlay.classList.add('active');
    }
}

function closeSideMenu() {
    const sideMenu = document.getElementById('sideMenu');
    const overlay = document.getElementById('sideMenuOverlay');
    sideMenu.classList.remove('active');
    overlay.classList.remove('active');
}

// Update active drawer item on scroll
document.addEventListener('DOMContentLoaded', () => {
    const drawerItems = document.querySelectorAll('.drawer-item');
    const sections = document.querySelectorAll('section[id]');
    
    // Click handler for drawer items
    drawerItems.forEach(item => {
        item.addEventListener('click', (e) => {
            if (item.classList.contains('drawer-item') && !item.href.includes('orders.html')) {
                drawerItems.forEach(i => i.classList.remove('active'));
                item.classList.add('active');
            }
        });
    });
    
    // Update active item on scroll
    window.addEventListener('scroll', () => {
        let current = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            if (scrollY >= sectionTop - 300) {
                current = section.getAttribute('id');
            }
        });
        
        drawerItems.forEach(item => {
            item.classList.remove('active');
            if (item.getAttribute('href') === `#${current}`) {
                item.classList.add('active');
            }
        });
    });
});

// Wait for Supabase to be ready
let supabaseReady = false;
function getSupabaseClient() {
    if (window.supabaseClient) {
        supabaseReady = true;
        return window.supabaseClient;
    }
    return null;
}

// Load Home Video
async function loadHomeVideo() {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) {
            console.log('Waiting for Supabase for video...');
            setTimeout(loadHomeVideo, 500);
            return;
        }

        const { data: video, error } = await supabase
            .from('home_video')
            .select('*')
            .eq('is_active', true)
            .single();

        if (error && error.code !== 'PGRST116') {
            console.error('Error loading video:', error);
            return;
        }

        if (video) {
            const container = document.getElementById('hero-video-container');
            container.style.display = 'block';
            
            if (video.video_url.includes('youtube.com') || video.video_url.includes('youtu.be')) {
                // YouTube video
                const videoId = video.video_url.includes('youtu.be') 
                    ? video.video_url.split('youtu.be/')[1] 
                    : video.video_url.split('v=')[1]?.split('&')[0];
                
                container.innerHTML = `
                    <iframe width="100%" height="100%" 
                        src="https://www.youtube.com/embed/${videoId}?autoplay=1&mute=1&loop=1&playlist=${videoId}" 
                        frameborder="0" allowfullscreen 
                        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe>
                `;
            } else {
                // Direct video file
                container.innerHTML = `
                    <video autoplay muted loop style="width: 100%; height: 100%; object-fit: cover;">
                        <source src="${video.video_url}" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                `;
            }
            
            container.style.display = 'block';
        }
    } catch (error) {
        console.error('Error in loadHomeVideo:', error);
    }
}

// Mobile Menu Toggle with Enhanced Functionality
document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const navMenu = document.querySelector('.nav-menu ul');

    if (mobileMenuBtn && navMenu) {
        // Toggle menu on button click
        mobileMenuBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            navMenu.classList.toggle('show');
            mobileMenuBtn.classList.toggle('active');
        });

        // Close menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.nav-menu') && !e.target.closest('.mobile-menu-btn')) {
                navMenu.classList.remove('show');
                mobileMenuBtn.classList.remove('active');
            }
        });

        // Close mobile menu when clicking on a link
        document.querySelectorAll('.nav-menu a').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('show');
                mobileMenuBtn.classList.remove('active');
            });
        });

        // Handle window resize - close menu if opening to desktop size
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768) {
                navMenu.classList.remove('show');
                mobileMenuBtn.classList.remove('active');
            }
        });
    }
});

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    loadHomeVideo();
    updateCartBadge(); // Initialize cart badge on page load
    setupCartOverlay(); // Setup cart overlay functionality
});

// Gallery Filtering
document.querySelectorAll('.filter-btn').forEach(button => {
    button.addEventListener('click', function() {
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        this.classList.add('active');
        
        const filter = this.getAttribute('data-filter');
        document.querySelectorAll('.gallery-item').forEach(item => {
            if (filter === 'all' || item.getAttribute('data-category') === filter) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    });
});

// Load Services
async function loadServices() {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) {
            console.log('Waiting for Supabase...');
            setTimeout(loadServices, 500);
            return;
        }
        const { data: services, error } = await supabase
            .from('services')
            .select('*')
            .eq('is_active', true)
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        const servicesContainer = document.getElementById('services-container');
        const serviceSelect = document.getElementById('appointment-service');
        
        if (services.length === 0) {
            servicesContainer.innerHTML = '<p class="loading">No services available at the moment.</p>';
            return;
        }
        
        servicesContainer.innerHTML = '';
        serviceSelect.innerHTML = '<option value="">Select Service</option>';
        
        services.forEach(service => {
            // Add to services grid
            const serviceCard = document.createElement('div');
            serviceCard.className = 'service-card';
            serviceCard.innerHTML = `
                <img src="${service.image_url || 'https://via.placeholder.com/300x200'}" 
                     alt="${service.title}" class="service-img">
                <div class="service-content">
                    <h3>${service.title}</h3>
                    <p>${service.description}</p>
                    <p class="price">Rs. ${service.price}</p>
                    <p><i class="fas fa-clock"></i> ${service.duration_hours} hours</p>
                </div>
            `;
            servicesContainer.appendChild(serviceCard);
            
            // Add to appointment dropdown
            const option = document.createElement('option');
            option.value = service.id;
            option.textContent = `${service.title} - Rs. ${service.price}`;
            serviceSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading services:', error);
        document.getElementById('services-container').innerHTML = 
            '<p class="loading">Error loading services. Please try again later.</p>';
    }
}

// Load Products
async function loadProducts() {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) {
            console.log('Waiting for Supabase...');
            setTimeout(loadProducts, 500);
            return;
        }
        const { data: products, error } = await supabase
            .from('products')
            .select('*')
            .eq('is_active', true)
            .gt('stock_quantity', 0)
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        const productsContainer = document.getElementById('products-container');
        
        if (products.length === 0) {
            productsContainer.innerHTML = '<p class="loading">No products available at the moment.</p>';
            return;
        }
        
        productsContainer.innerHTML = '';
        
        products.forEach(product => {
            const productCard = document.createElement('div');
            productCard.className = 'product-card';
            productCard.setAttribute('data-product-id', product.id);
            productCard.innerHTML = `
                <img src="${product.image_url || 'https://via.placeholder.com/300x200'}" 
                     alt="${product.name}" class="product-img">
                <div class="product-content">
                    <h3>${product.name}</h3>
                    <p>${product.description}</p>
                    <p class="product-price">Rs. ${product.price}</p>
                    ${product.stock_quantity < 10 ? `<p class="stock-warning">Only ${product.stock_quantity} left!</p>` : ''}
                    <span class="product-stock" style="display:none;">${product.stock_quantity}</span>
                    <button class="btn add-to-cart" data-id="${product.id}" data-name="${product.name}" data-price="${product.price}" title="Add to cart">
                        <i class="fas fa-shopping-bag"></i> Add to Cart
                    </button>
                </div>
            `;
            productsContainer.appendChild(productCard);
        });
        
        // Add event listeners to cart buttons
        document.querySelectorAll('.add-to-cart').forEach(button => {
            button.addEventListener('click', addToCart);
        });

        // Initialize search functionality
        initializeSearch(products);
    } catch (error) {
        console.error('Error loading products:', error);
        document.getElementById('products-container').innerHTML = 
            '<p class="loading">Error loading products. Please try again later.</p>';
    }
}

// Initialize search functionality
function initializeSearch(allProducts) {
    const searchInput = document.getElementById('searchInput');
    const clearSearch = document.getElementById('clearSearch');
    
    if (!searchInput) return;

    // Search on input
    searchInput.addEventListener('input', (e) => {
        const query = e.target.value.toLowerCase().trim();
        
        // Show/hide clear button
        clearSearch.style.display = query ? 'block' : 'none';
        
        if (!query) {
            // Show all products if search is empty
            displayFilteredProducts(allProducts);
            return;
        }

        // Filter products based on search query
        const filtered = allProducts.filter(product => {
            const name = (product.name || '').toLowerCase();
            const description = (product.description || '').toLowerCase();
            const category = (product.category || '').toLowerCase();
            const fabric = (product.fabric_type || '').toLowerCase();
            
            return name.includes(query) || 
                   description.includes(query) || 
                   category.includes(query) || 
                   fabric.includes(query);
        });

        displayFilteredProducts(filtered);
    });

    // Clear search
    if (clearSearch) {
        clearSearch.addEventListener('click', () => {
            searchInput.value = '';
            clearSearch.style.display = 'none';
            displayFilteredProducts(allProducts);
        });
    }
}

// Display filtered products
function displayFilteredProducts(products) {
    const productsContainer = document.getElementById('products-container');
    const noResults = document.getElementById('noResults');

    if (products.length === 0) {
        productsContainer.style.display = 'none';
        noResults.style.display = 'flex';
        return;
    }

    productsContainer.style.display = 'grid';
    noResults.style.display = 'none';
    productsContainer.innerHTML = '';

    products.forEach(product => {
        const productCard = document.createElement('div');
        productCard.className = 'product-card';
        productCard.setAttribute('data-product-id', product.id);
        productCard.innerHTML = `
            <img src="${product.image_url || 'https://via.placeholder.com/300x200'}" 
                 alt="${product.name}" class="product-img">
            <div class="product-content">
                <h3>${product.name}</h3>
                <p>${product.description}</p>
                <p class="product-price">Rs. ${product.price}</p>
                ${product.stock_quantity < 10 ? `<p class="stock-warning">Only ${product.stock_quantity} left!</p>` : ''}
                <span class="product-stock" style="display:none;">${product.stock_quantity}</span>
                <button class="btn add-to-cart" data-id="${product.id}" data-name="${product.name}" data-price="${product.price}" title="Add to cart">
                    <i class="fas fa-shopping-bag"></i> Add to Cart
                </button>
            </div>
        `;
        productsContainer.appendChild(productCard);
    });

    // Add event listeners to cart buttons
    document.querySelectorAll('.add-to-cart').forEach(button => {
        button.addEventListener('click', addToCart);
    });
}

// Load Gallery
async function loadGallery() {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) {
            console.log('Waiting for Supabase...');
            setTimeout(loadGallery, 500);
            return;
        }
        const { data: gallery, error } = await supabase
            .from('gallery')
            .select('*')
            .eq('is_active', true)
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        const galleryContainer = document.getElementById('gallery-container');
        
        if (gallery.length === 0) {
            galleryContainer.innerHTML = '<p class="loading">No gallery items available.</p>';
            return;
        }
        
        galleryContainer.innerHTML = '';
        
        gallery.forEach(item => {
            const galleryItem = document.createElement('div');
            galleryItem.className = 'gallery-item';
            galleryItem.setAttribute('data-category', item.image_type || 'all');
            
            if (item.image_type === 'image' || item.image_url.includes(('.jpg', '.jpeg', '.png', '.gif'))) {
                galleryItem.innerHTML = `
                    <img src="${item.image_url}" alt="${item.title || 'Gallery image'}" 
                         onclick="openLightbox('${item.image_url}', 'image')">
                `;
            } else {
                galleryItem.innerHTML = `
                    <video controls onclick="openLightbox('${item.image_url}', 'video')">
                        <source src="${item.image_url}" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                `;
            }
            galleryContainer.appendChild(galleryItem);
        });
    } catch (error) {
        console.error('Error loading gallery:', error);
        document.getElementById('gallery-container').innerHTML = 
            '<p class="loading">Error loading gallery. Please try again later.</p>';
    }
}

// Open lightbox for gallery items
function openLightbox(src, type) {
    const lightbox = document.createElement('div');
    lightbox.className = 'lightbox';
    lightbox.innerHTML = `
        <div class="lightbox-content">
            <span class="close-lightbox">&times;</span>
            ${type === 'image' 
                ? `<img src="${src}" alt="Gallery image" style="display: block;">`
                : `<video controls autoplay style="display: block;"><source src="${src}" type="video/mp4"></video>`
            }
        </div>
    `;
    
    document.body.appendChild(lightbox);
    
    // Prevent body scroll when lightbox is open
    document.body.style.overflow = 'hidden';
    
    const closeBtn = lightbox.querySelector('.close-lightbox');
    const content = lightbox.querySelector('.lightbox-content');
    
    // Close on X button click
    closeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        document.body.style.overflow = 'auto';
        lightbox.remove();
    });
    
    // Close on background click (not on content)
    lightbox.addEventListener('click', (e) => {
        if (e.target === lightbox) {
            document.body.style.overflow = 'auto';
            lightbox.remove();
        }
    });
    
    // Prevent closing when clicking on content
    content.addEventListener('click', (e) => {
        e.stopPropagation();
    });
    
    // Close on Escape key
    const handleEscape = (e) => {
        if (e.key === 'Escape') {
            document.body.style.overflow = 'auto';
            document.removeEventListener('keydown', handleEscape);
            lightbox.remove();
        }
    };
    document.addEventListener('keydown', handleEscape);
}

// Add to cart function
function addToCart(e) {
    try {
        const productId = e.target.getAttribute('data-id');
        const productName = e.target.getAttribute('data-name');
        const productPrice = e.target.getAttribute('data-price');
        
        const price = parseFloat(productPrice.toString().replace('Rs. ', '').replace(',', ''));
        
        // Get existing cart from sessionStorage
        let cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        
        // Check if product already in cart
        const existingItem = cartItems.find(item => item.id === productId);
        
        if (existingItem) {
            // Increase quantity by 1 if already in cart
            existingItem.qty += 1;
            console.log(`✅ Updated ${productName} quantity to ${existingItem.qty}`);
        } else {
            // Add new item to cart
            cartItems.push({
                id: productId,
                name: productName,
                price: price,
                qty: 1
            });
            console.log(`✅ Added ${productName} to cart`);
        }
        
        // Calculate total amount
        const totalAmount = cartItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
        
        // Save to sessionStorage
        sessionStorage.setItem('cartItems', JSON.stringify(cartItems));
        sessionStorage.setItem('totalAmount', totalAmount.toFixed(2));
        sessionStorage.setItem('orderId', 'ORD-' + Date.now());
        
        // Update cart badge
        updateCartBadge();
        
        // Show notification
        showNotification(`${productName} added to cart!`);
        
        // Show cart count update animation
        const badge = document.getElementById('cart-count-badge');
        if (badge) {
            badge.style.transform = 'scale(1.3)';
            setTimeout(() => { badge.style.transform = 'scale(1)'; }, 300);
        }
    } catch (error) {
        console.error('Error adding to cart:', error);
        showNotification('Error adding to cart', 'error');
    }
}

// Update cart badge count
function updateCartBadge() {
    const badge = document.getElementById('cart-count-badge');
    if (!badge) return;
    
    try {
        const cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        const count = cartItems.reduce((sum, item) => sum + (item.qty || 1), 0);
        badge.textContent = count;
        badge.style.display = count > 0 ? 'inline-block' : 'none';
        console.log(`📊 Cart badge updated: ${count} items`);
    } catch (error) {
        console.error('Error updating cart badge:', error);
    }
}

// Setup cart overlay functionality
function setupCartOverlay() {
    const cartBtn = document.querySelector('.cart-btn');
    const cartOverlay = document.getElementById('cartOverlay');
    const closeBtn = document.getElementById('closeCartOverlay');
    const checkoutBtn = document.getElementById('goToCheckout');
    const clearBtn = document.getElementById('clearCart');

    if (cartBtn) {
        cartBtn.addEventListener('click', (e) => {
            e.preventDefault();
            showCartOverlay();
        });
    }

    if (closeBtn) {
        closeBtn.addEventListener('click', hideCartOverlay);
    }

    if (checkoutBtn) {
        checkoutBtn.addEventListener('click', goToCheckout);
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', clearCartItems);
    }

    // Close overlay when clicking outside
    if (cartOverlay) {
        cartOverlay.addEventListener('click', (e) => {
            if (e.target === cartOverlay) {
                hideCartOverlay();
            }
        });
    }
}

// Show cart overlay
function showCartOverlay() {
    const cartOverlay = document.getElementById('cartOverlay');
    if (cartOverlay) {
        cartOverlay.classList.remove('hidden');
        updateCartOverlayItems();
    }
}

// Hide cart overlay
function hideCartOverlay() {
    const cartOverlay = document.getElementById('cartOverlay');
    if (cartOverlay) {
        cartOverlay.classList.add('hidden');
    }
}

// Update cart overlay items display
function updateCartOverlayItems() {
    try {
        const cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        const itemsDiv = document.getElementById('cartOverlayItems');
        
        if (!itemsDiv) return;

        if (cartItems.length === 0) {
            itemsDiv.innerHTML = `
                <div style="text-align: center; padding: 40px 20px; color: #999;">
                    <i class="fas fa-shopping-cart" style="font-size: 3em; margin-bottom: 15px; display: block; opacity: 0.5;"></i>
                    <p>Your cart is empty</p>
                    <p style="font-size: 0.9rem; margin-top: 10px;">Add some products to get started!</p>
                </div>
            `;
            return;
        }

        let html = '';
        let total = 0;

        cartItems.forEach((item, index) => {
            const price = parseFloat(item.price) || 0;
            const qty = parseInt(item.qty) || 1;
            const itemTotal = price * qty;
            total += itemTotal;

            html += `
                <div class="cart-item-overlay" style="display: flex; gap: 15px; padding: 15px; border-bottom: 1px solid #eee; align-items: center;">
                    <div style="flex: 1;">
                        <div style="font-weight: 600; color: #333;">${item.name}</div>
                        <div style="font-size: 0.9rem; color: #999;">Rs. ${price.toFixed(2)} × ${qty} = Rs. ${itemTotal.toFixed(2)}</div>
                    </div>
                    <button onclick="deleteFromCartOverlay(${index})" class="delete-btn" style="background: #e74c3c; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 0.85rem;">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </div>
            `;
        });

        itemsDiv.innerHTML = html + `
            <div style="padding: 15px; background: #f8f9ff; text-align: right; font-weight: 600; color: #667eea; font-size: 1.1rem;">
                Total: Rs. ${total.toFixed(2)}
            </div>
        `;

        console.log(`✅ Cart overlay updated: ${cartItems.length} items`);
    } catch (error) {
        console.error('Error updating cart overlay:', error);
    }
}

// Delete from cart overlay
function deleteFromCartOverlay(index) {
    try {
        let cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        
        if (index >= 0 && index < cartItems.length) {
            const deletedItem = cartItems[index];
            cartItems.splice(index, 1);
            
            // Recalculate total
            const totalAmount = cartItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
            
            // Update storage
            sessionStorage.setItem('cartItems', JSON.stringify(cartItems));
            sessionStorage.setItem('totalAmount', totalAmount.toFixed(2));
            
            console.log(`🗑️ Deleted ${deletedItem.name} from cart`);
            
            // Update displays
            updateCartBadge();
            updateCartOverlayItems();
            
            showNotification(`${deletedItem.name} removed from cart`, 'info');
        }
    } catch (error) {
        console.error('Error deleting from cart:', error);
    }
}

// Clear entire cart
function clearCartItems() {
    try {
        // Show confirmation
        const confirmed = confirm('Are you sure you want to clear your entire cart?');
        if (!confirmed) return;
        
        // Clear storage
        sessionStorage.setItem('cartItems', '[]');
        sessionStorage.setItem('totalAmount', '0.00');
        
        console.log('🗑️ Cart cleared completely');
        
        // Update displays
        updateCartBadge();
        updateCartOverlayItems();
        
        showNotification('Cart cleared!', 'warning');
    } catch (error) {
        console.error('Error clearing cart:', error);
    }
}

// Go to checkout
function goToCheckout() {
    const cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
    
    if (cartItems.length === 0) {
        alert('Your cart is empty!');
        return;
    }
    
    // Hide overlay and redirect
    hideCartOverlay();
    window.location.href = 'payment.html';
}

// Show notification with type (success, error, info)
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    // Add icon based on type
    let icon = '';
    if (type === 'success') {
        icon = '<i class="fas fa-check-circle"></i> ';
    } else if (type === 'error') {
        icon = '<i class="fas fa-exclamation-circle"></i> ';
    } else if (type === 'info') {
        icon = '<i class="fas fa-info-circle"></i> ';
    }
    
    notification.innerHTML = icon + message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3500);
}

// Appointment Form Submission
if (document.getElementById('appointment-form')) {
    document.getElementById('appointment-form').addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const submitBtn = this.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        const formElement = this;
        
        try {
            submitBtn.textContent = 'Booking...';
            submitBtn.disabled = true;
            
            // Validate inputs
            const name = document.getElementById('appointment-name').value.trim();
            const phone = document.getElementById('appointment-phone').value.trim();
            const email = document.getElementById('appointment-email').value.trim();
            const service = document.getElementById('appointment-service').value;
            const date = document.getElementById('appointment-date').value;
            const time = document.getElementById('appointment-time').value;
            
            if (!name || !phone || !service || !date || !time) {
                throw new Error('Please fill all required fields');
            }
            
            // Validate date is not in past
            const selectedDate = new Date(date);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            if (selectedDate < today) {
                throw new Error('Please select a future date');
            }
            
            const appointmentData = {
                customer_name: name,
                customer_phone: phone,
                customer_email: email || null,
                service_id: service,
                appointment_date: date,
                appointment_time: time,
                appointment_notes: document.getElementById('appointment-requirements').value.trim() || '',
                status: 'pending',
                created_at: new Date().toISOString()
            };
            
            const supabase = getSupabaseClient();
            if (!supabase) throw new Error('Supabase not initialized');
            
            const { data, error } = await supabase
                .from('appointments')
                .insert([appointmentData]);
            
            if (error) {
                console.error('Appointment insert error:', error);
                throw new Error(error.message || 'Failed to book appointment');
            }
            
            // Get service name for email
            const { data: serviceData } = await supabase
                .from('services')
                .select('title')
                .eq('id', service)
                .single();
            
            // Send email to admin about new appointment
            console.log('📧 Sending appointment notification');
            if (typeof sendNewAppointmentEmailToAdmin === 'function') {
                const appointmentWithService = {
                    ...appointmentData,
                    service_name: serviceData?.title || 'Service',
                    requirements: appointmentData.appointment_notes
                };
                await sendNewAppointmentEmailToAdmin(appointmentWithService);
            }
            
            showNotification('✅ Appointment booked successfully! We will contact you soon.', 'success');
            
            // Scroll to top to show success message
            window.scrollTo({ top: 0, behavior: 'smooth' });
            
            // Reset form and button after 2 seconds
            setTimeout(() => {
                formElement.reset();
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            }, 2000);
            
        } catch (error) {
            console.error('Error booking appointment:', error);
            showNotification('❌ ' + (error.message || 'Failed to book appointment. Please try again or call us directly.'));
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    });
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', async () => {
    await Promise.all([
        loadServices(),
        loadProducts(),
        loadGallery()
    ]);
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - 80,
                behavior: 'smooth'
            });
        }
    });
});

// Sticky header
window.addEventListener('scroll', function() {
    const header = document.querySelector('header');
    if (window.scrollY > 100) {
        header.style.boxShadow = '0 2px 20px rgba(0,0,0,0.1)';
    } else {
        header.style.boxShadow = '0 2px 10px rgba(0,0,0,0.1)';
    }
});

// ===== PRODUCT MODAL AND CAROUSEL =====
let currentProduct = null;
let currentImageIndex = 0;
let productImages = [];
let carouselAutoPlayInterval = null;

// Open Product Modal
function openProductModal(productId) {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) {
            setTimeout(() => openProductModal(productId), 500);
            return;
        }

        // Find product from the DOM or fetch it
        const productCard = document.querySelector(`[data-product-id="${productId}"]`);
        if (!productCard) return;

        // Extract data from card
        currentProduct = {
            id: productId,
            name: productCard.querySelector('h3')?.textContent || 'Product',
            price: productCard.querySelector('.product-price')?.textContent?.match(/[\d.]+/)?.[0] || '0',
            description: productCard.querySelector('p')?.textContent || 'No description',
            stock: productCard.querySelector('.product-stock')?.textContent?.match(/\d+/)?.[0] || '10'
        };

        // Reset carousel
        currentImageIndex = 0;
        clearInterval(carouselAutoPlayInterval);
        
        // Load product images from database
        loadProductImages(productId);
        
        // Show modal
        document.getElementById('productModal').classList.add('show');
        
        // Start auto-rotate
        startCarouselAutoPlay();
        
    } catch (error) {
        console.error('Error opening product modal:', error);
    }
}

// Close Product Modal
function closeProductModal() {
    document.getElementById('productModal').classList.remove('show');
    clearInterval(carouselAutoPlayInterval);
    currentProduct = null;
    productImages = [];
}

// Load Product Images from Supabase
async function loadProductImages(productId) {
    try {
        const supabase = getSupabaseClient();
        if (!supabase) return;

        const { data: images, error } = await supabase
            .from('product_images')
            .select('*')
            .eq('product_id', productId)
            .order('image_order', { ascending: true })
            .limit(4);

        if (error) throw error;

        // Get placeholder if no images
        if (!images || images.length === 0) {
            productImages = [
                { id: 1, image_url: 'https://via.placeholder.com/400x400?text=Product+Image+1', image_order: 1 },
                { id: 2, image_url: 'https://via.placeholder.com/400x400?text=Product+Image+2', image_order: 2 },
                { id: 3, image_url: 'https://via.placeholder.com/400x400?text=Product+Image+3', image_order: 3 },
                { id: 4, image_url: 'https://via.placeholder.com/400x400?text=Product+Image+4', image_order: 4 }
            ];
        } else {
            productImages = images;
        }

        // Display images
        displayCarouselImage();
        displayThumbnails();
        document.getElementById('currentImage').textContent = currentImageIndex + 1;

    } catch (error) {
        console.error('Error loading product images:', error);
        // Use placeholders
        productImages = Array.from({ length: 4 }, (_, i) => ({
            id: i + 1,
            image_url: `https://via.placeholder.com/400x400?text=Product+Image+${i + 1}`,
            image_order: i + 1
        }));
        displayCarouselImage();
        displayThumbnails();
    }
}

// Display Current Image in Carousel
function displayCarouselImage() {
    if (productImages.length === 0) return;
    
    const image = productImages[currentImageIndex];
    document.getElementById('carouselMainImage').src = image.image_url;
    document.getElementById('currentImage').textContent = currentImageIndex + 1;
    
    // Update thumbnail highlight
    document.querySelectorAll('.thumbnail').forEach((thumb, idx) => {
        if (idx === currentImageIndex) {
            thumb.classList.add('active');
        } else {
            thumb.classList.remove('active');
        }
    });
}

// Display Thumbnails
function displayThumbnails() {
    const container = document.getElementById('thumbnailsContainer');
    container.innerHTML = '';
    
    productImages.forEach((image, index) => {
        const thumbnail = document.createElement('div');
        thumbnail.className = `thumbnail ${index === 0 ? 'active' : ''}`;
        thumbnail.innerHTML = `<img src="${image.image_url}" alt="Product image ${index + 1}">`;
        thumbnail.onclick = () => {
            currentImageIndex = index;
            clearInterval(carouselAutoPlayInterval);
            displayCarouselImage();
            startCarouselAutoPlay();
        };
        container.appendChild(thumbnail);
    });
}

// Previous Image
function prevImage() {
    if (productImages.length === 0) return;
    currentImageIndex = (currentImageIndex - 1 + productImages.length) % productImages.length;
    clearInterval(carouselAutoPlayInterval);
    displayCarouselImage();
    startCarouselAutoPlay();
}

// Next Image
function nextImage() {
    if (productImages.length === 0) return;
    currentImageIndex = (currentImageIndex + 1) % productImages.length;
    clearInterval(carouselAutoPlayInterval);
    displayCarouselImage();
    startCarouselAutoPlay();
}

// Auto-rotate carousel every 7 seconds
function startCarouselAutoPlay() {
    carouselAutoPlayInterval = setInterval(() => {
        nextImage();
    }, 7000);
}

// Quantity Selector
function increaseQuantity() {
    const input = document.getElementById('quantity');
    input.value = parseInt(input.value) + 1;
}

function decreaseQuantity() {
    const input = document.getElementById('quantity');
    const currentValue = parseInt(input.value);
    if (currentValue > 1) {
        input.value = currentValue - 1;
    }
}

// Add Product to Cart from Modal
function addProductToCart() {
    if (!currentProduct) return;
    
    const quantity = parseInt(document.getElementById('quantity').value);
    const price = parseFloat(currentProduct.price.toString().replace('Rs. ', '').replace(',', ''));
    
    // Create proper order data structure
    const orderData = {
        order_number: 'ORD-' + Date.now(),
        customer_name: 'Customer',
        customer_phone: '',
        customer_email: '',
        delivery_address: '',
        delivery_date: '',
        delivery_charge: 50,
        items: [{
            product_id: currentProduct.id,
            product_name: currentProduct.name,
            price: price,
            quantity: quantity
        }],
        total_amount: (price * quantity) + 50,
        payment_method: '',
        order_status: 'pending',
        created_at: new Date().toISOString()
    };

    // Save to localStorage
    localStorage.setItem('orderData', JSON.stringify(orderData));
    
    // Show success notification
    showNotification(`✅ ${currentProduct.name} (Qty: ${quantity}) added to cart!`, 'success');
    
    // Close modal and redirect to payment
    closeProductModal();
    
    setTimeout(() => {
        window.location.href = 'payment.html';
    }, 500);
}

// Click product card to open modal
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(() => {
        document.querySelectorAll('.product-card').forEach(card => {
            card.addEventListener('click', function(e) {
                // Don't trigger if clicking the Add to Cart button
                if (e.target.classList.contains('add-to-cart') || e.target.closest('.add-to-cart')) {
                    return;
                }
                
                const productId = this.getAttribute('data-product-id');
                if (productId) {
                    openProductModal(productId);
                }
            });
        });
    }, 1000);
});

// Close modal when clicking outside
document.addEventListener('click', function(event) {
    const modal = document.getElementById('productModal');
    if (event.target === modal) {
        closeProductModal();
    }
});

// Keyboard support for modal
document.addEventListener('keydown', function(event) {
    const modal = document.getElementById('productModal');
    if (modal && modal.classList.contains('show')) {
        if (event.key === 'Escape') {
            closeProductModal();
        } else if (event.key === 'ArrowLeft') {
            prevImage();
        } else if (event.key === 'ArrowRight') {
            nextImage();
        }
    }
});
