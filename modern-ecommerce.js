// Modern Premium E-Commerce JavaScript with Dynamic Features

let allProducts = [];
let filteredProducts = [];
let currentCategory = 'all';
let currentSortOrder = '';
let priceMin = 0;
let priceMax = 10000;
let currentProductId = null;
let currentImageIndex = 0;
let slidingImages = [];
let currentSlideIndex = 0;

document.addEventListener('DOMContentLoaded', async () => {
    await initializeEcommerce();
    await loadSlidingImages();
    setupEventListeners();
    initHeroSlider();
    await loadGallery();
    loadHeroVideo();
    updateCartCountBadge();
    await loadOffers();
    await loadAdminSettings();

    // Cart overlay/modal event listeners
    const cartBtn = document.querySelector('.cart-btn');
    const cartOverlay = document.getElementById('cartOverlay');
    const closeCartOverlay = document.getElementById('closeCartOverlay');
    const goToCheckout = document.getElementById('goToCheckout');
    if (cartBtn && cartOverlay) {
        cartBtn.addEventListener('click', function(e) {
            e.preventDefault();
            renderCartOverlay();
            cartOverlay.classList.remove('hidden');
        });
    }
    if (closeCartOverlay && cartOverlay) {
        closeCartOverlay.addEventListener('click', function() {
            cartOverlay.classList.add('hidden');
        });
    }
    if (goToCheckout) {
        goToCheckout.addEventListener('click', async function() {
            await buildAndStoreOrderData();
            window.location.href = 'payment.html';
        });
    }
    // Close overlay on outside click
    if (cartOverlay) {
        cartOverlay.addEventListener('click', function(e) {
            if (e.target === cartOverlay) cartOverlay.classList.add('hidden');
        });
    }
});

// ============================================================
// SLIDING IMAGES (HERO SLIDER) FUNCTIONS
// ============================================================

// Initialize Hardcoded Sliding Images
function loadSlidingImages() {
    slidingImages = [
        {
            id: 1,
            image_url: 'uploads/back.png',
            title: 'Premium Collection',
            description: 'Explore our exclusive fabrics',
            is_active: true
        },
        {
            id: 2,
            image_url: 'uploads/back2.png',
            title: 'Modern Styles',
            description: 'Latest fashion trends',
            is_active: true
        },
        {
            id: 3,
            image_url: 'uploads/back3.png',
            title: 'Traditional Elegance',
            description: 'Timeless designs',
            is_active: true
        },
        {
            id: 4,
            image_url: 'uploads/back.png',
            title: 'Quality Assured',
            description: 'Best fabric quality',
            is_active: true
        }
    ];
    console.log('✅ Sliding images initialized:', slidingImages.length);
}

// Initialize Hero Slider
function initHeroSlider() {
    const heroSlide = document.getElementById('heroSliderSlide');
    const prevBtn = document.getElementById('heroSliderPrev');
    const nextBtn = document.getElementById('heroSliderNext');

    if (!heroSlide || slidingImages.length === 0) {
        console.log('Hero slider not ready');
        return;
    }

    // Set initial slide
    updateHeroSlide();

    // Previous button
    if (prevBtn) {
        prevBtn.onclick = function() {
            currentSlideIndex = (currentSlideIndex - 1 + slidingImages.length) % slidingImages.length;
            updateHeroSlide();
        };
    }

    // Next button
    if (nextBtn) {
        nextBtn.onclick = function() {
            currentSlideIndex = (currentSlideIndex + 1) % slidingImages.length;
            updateHeroSlide();
        };
    }

    // Auto slide every 5 seconds
    setInterval(() => {
        if (nextBtn) nextBtn.click();
    }, 5000);
}

// Update Hero Slide Display
function updateHeroSlide() {
    const heroSlide = document.getElementById('heroSliderSlide');
    if (!heroSlide || slidingImages.length === 0) return;

    const currentImage = slidingImages[currentSlideIndex];
    
    if (currentImage.image_url) {
        heroSlide.style.backgroundImage = `url('${currentImage.image_url}')`;
    }
    
    // Update text content if available
    const heroContent = heroSlide.querySelector('.hero-content');
    if (heroContent && currentImage.title) {
        const h2 = heroContent.querySelector('h2');
        const p = heroContent.querySelector('p');
        const a = heroContent.querySelector('a');
        
        if (h2) h2.innerHTML = currentImage.title.replace(/\n/g, '<br>');
        if (p && currentImage.description) p.textContent = currentImage.description;
        if (a && currentImage.link_url) a.href = currentImage.link_url;
    }
}

// Render cart overlay/modal with product images
async function renderCartOverlay() {
    const cartItemsContainer = document.getElementById('cartOverlayItems');
    if (!cartItemsContainer) return;
    let cart = [];
    try {
        cart = JSON.parse(localStorage.getItem('cart') || '[]');
    } catch {}
    if (!cart.length) {
        cartItemsContainer.innerHTML = '<div class="empty-cart">Your cart is empty.</div>';
        return;
    }
    // Fetch all products if not already loaded
    if (!allProducts || !allProducts.length) {
        allProducts = await fetchProducts();
    }
    let html = '';
    const placeholder = 'https://via.placeholder.com/80x80?text=No+Image';
    cart.forEach(item => {
        const product = allProducts.find(p => p.id == item.id);
        if (!product) return;
        // Use logo_url and background_url if present, else fallback to image_url, then placeholder
        const logo = product.logo_url || product.image_url || placeholder;
        const bg = product.background_url || product.image_url || placeholder;
        html += `
            <div class="cart-overlay-item">
                <div class="cart-overlay-img-bg" style="background-image:url('${bg}');">
                    <img class="cart-overlay-logo" src="${logo}" alt="${product.name}">
                </div>
                <div class="cart-overlay-info">
                    <div class="cart-overlay-title">${product.name}</div>
                    <div class="cart-overlay-qty">Qty: ${item.quantity}</div>
                    <div class="cart-overlay-price">₹${product.price.toFixed(0)}</div>
                </div>
            </div>
        `;
    });
    cartItemsContainer.innerHTML = html;
}

// Load Hero Video from Supabase (Admin can configure)
async function loadHeroVideo() {
    try {
        console.log('🎬 Loading hero video...');
        
        // Wait for Supabase to be initialized
        let client = getClient();
        let retries = 0;
        while (!client && retries < 5) {
            await new Promise(resolve => setTimeout(resolve, 200));
            client = getClient();
            retries++;
        }
        
        if (!client) {
            console.log('Supabase client not available, using fallback');
            return;
        }

        // Fetch hero video URL from home_video table
        const { data, error } = await client
            .from('home_video')
            .select('video_url')
            .eq('is_active', true)
            .limit(1);

        if (error) {
            console.warn('Could not fetch video URL:', error.message);
            return;
        }

        if (data && data.length > 0 && data[0].video_url) {
            const videoUrl = data[0].video_url.trim();
            
            if (videoUrl && videoUrl.length > 0) {
                const videoElement = document.getElementById('heroVideo');
                if (videoElement) {
                    console.log('✓ Setting video source:', videoUrl.substring(0, 60));
                    videoElement.src = videoUrl;
                    videoElement.style.display = 'block';
                    videoElement.style.visibility = 'visible';
                    
                    // Log when video is ready
                    videoElement.onloadedmetadata = () => {
                        console.log('✓ Video metadata loaded');
                    };
                    
                    videoElement.oncanplay = () => {
                        console.log('✓ Video can play');
                    };
                    
                    videoElement.onerror = (err) => {
                        console.warn('⚠ Video loading failed:', err);
                    };
                } else {
                    console.error('❌ Video element #heroVideo not found in DOM');
                }
            } else {
                console.log('⚠ Video URL is empty');
            }
        } else {
            console.log('⚠ No video URL in database');
        }
    } catch (error) {
        console.warn('Error loading hero video:', error.message);
    }
}

// ============================================================
// EXCLUSIVE OFFER BANNER FUNCTIONS
// ============================================================

async function loadOffers() {
    try {
        const offerBanner = document.getElementById('offerBanner');
        const offerTitle = document.getElementById('offerTitle');
        const offerDesc = document.getElementById('offerDesc');
        const offerCountdown = document.getElementById('offerCountdown');

        // Get supabase from global window object
        const supabaseClient = window.supabaseClient;
        
        if (!supabaseClient) {
            console.error('❌ Supabase client not initialized');
            offerCountdown.textContent = 'Database not ready';
            return;
        }

        console.log('🔄 Fetching offers...');
        
        // Fetch all active offers (not expired)
        const now = new Date().toISOString();
        const { data: offers, error } = await supabaseClient
            .from('offers')
            .select('*')
            .eq('is_active', true)
            .gt('end_date', now)
            .order('created_at', { ascending: false })
            .limit(1);

        console.log('📊 Supabase response:', { offers, error });

        if (error) {
            console.error('❌ Error fetching offers:', error.message);
            offerCountdown.textContent = 'Error loading offers';
            return;
        }

        if (!offers || offers.length === 0) {
            console.log('⚠️ No active offers found in database');
            offerBanner.classList.add('hidden');
            offerCountdown.textContent = 'No active offers';
            return;
        }

        // Show banner with offer data
        offerBanner.classList.remove('hidden');
        const offer = offers[0];
        console.log('✅ Offer loaded:', offer);
        
        offerTitle.textContent = offer.title || 'Exclusive Offer!';
        offerDesc.textContent = offer.description || 'Limited Time Only';

        // Start countdown timer
        startOfferCountdown(offer.end_date, offerCountdown);

    } catch (error) {
        console.error('❌ Exception in loadOffers:', error);
        document.getElementById('offerCountdown').textContent = 'Error: ' + error.message;
    }
}

function startOfferCountdown(endDate, countdownElement) {
    if (!endDate || !countdownElement) return;

    function updateCountdown() {
        const now = new Date().getTime();
        const end = new Date(endDate).getTime();
        const distance = end - now;

        if (distance < 0) {
            countdownElement.textContent = 'Offer Expired';
            return;
        }

        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((distance % (1000 * 60)) / 1000);

        if (days > 0) {
            countdownElement.textContent = `Ends in ${days}d ${hours}h ${minutes}m`;
        } else if (hours > 0) {
            countdownElement.textContent = `Ends in ${hours}h ${minutes}m ${seconds}s`;
        } else if (minutes > 0) {
            countdownElement.textContent = `Ends in ${minutes}m ${seconds}s`;
        } else {
            countdownElement.textContent = `Ends in ${seconds}s`;
        }
    }

    updateCountdown();
    setInterval(updateCountdown, 1000);
}

function closeOfferBanner() {
    const offerBanner = document.getElementById('offerBanner');
    if (offerBanner) {
        offerBanner.classList.add('hidden');
    }
}

// ============================================================
// LOAD ADMIN SETTINGS (Business Hours, Contact Info)
// ============================================================

async function loadAdminSettings() {
    try {
        const supabaseClient = window.supabaseClient;
        if (!supabaseClient) {
            console.log('Supabase client not ready for settings');
            return;
        }

        // Fetch all admin settings
        const { data: settings, error } = await supabaseClient
            .from('admin_settings')
            .select('*');

        if (error) {
            console.warn('Error loading admin settings:', error.message);
            return;
        }

        if (settings && settings.length > 0) {
            // Sort settings by updated_at ascending so that more recently updated settings take precedence
            settings.sort((a, b) => {
                const dateA = new Date(a.updated_at || 0);
                const dateB = new Date(b.updated_at || 0);
                return dateA - dateB;
            });

            let mergedContactInfo = { phone: '', email: '', address: '' };
            let mergedAdminInfo = { businessName: '', business_name: '' };
            let businessHours = { opening: '', closing: '' };

            settings.forEach(setting => {
                let value = setting.setting_value;
                if (typeof value === 'string') {
                    try { value = JSON.parse(value); } catch (e) { value = {}; }
                }
                if (!value) return;

                if (setting.setting_key === 'company_profile') {
                    if (value.company_name) {
                        mergedAdminInfo.businessName = value.company_name;
                        mergedAdminInfo.business_name = value.company_name;
                    }
                    if (value.phone) mergedContactInfo.phone = value.phone;
                    if (value.email) mergedContactInfo.email = value.email;
                    if (value.location) mergedContactInfo.address = value.location;
                } else if (setting.setting_key === 'contact_info') {
                    if (value.phone) mergedContactInfo.phone = value.phone;
                    if (value.email) mergedContactInfo.email = value.email;
                    if (value.address) mergedContactInfo.address = value.address;
                } else if (setting.setting_key === 'admin_settings') {
                    const name = value.businessName || value.business_name;
                    if (name) {
                        mergedAdminInfo.businessName = name;
                        mergedAdminInfo.business_name = name;
                    }
                } else if (setting.setting_key === 'business_hours') {
                    if (value.opening && value.closing) {
                        businessHours.opening = value.opening;
                        businessHours.closing = value.closing;
                    }
                }
            });

            // Update UI elements with merged values
            updateBusinessHours(businessHours);
            updateContactInfo(mergedContactInfo);
            updateAdminInfo(mergedAdminInfo);
        }

        console.log('✅ Admin settings loaded');
    } catch (error) {
        console.warn('Error in loadAdminSettings:', error.message);
    }
}

function updateBusinessHours(hoursData) {
    const hoursElement = document.getElementById('contactHours');
    if (hoursElement && hoursData.opening && hoursData.closing) {
        hoursElement.textContent = `${hoursData.opening} - ${hoursData.closing}`;
    }
}

function updateContactInfo(contactData) {
    // Update address
    if (contactData.address) {
        const addressElement = document.getElementById('contactAddress');
        if (addressElement) {
            addressElement.textContent = contactData.address;
        }
    }
    
    // Update phone
    if (contactData.phone) {
        const phoneElement = document.getElementById('contactPhone');
        if (phoneElement) {
            phoneElement.textContent = contactData.phone;
        }
    }
    
    // Update email
    if (contactData.email) {
        const emailElement = document.getElementById('contactEmail');
        if (emailElement) {
            emailElement.textContent = contactData.email;
        }
    }
}

function updateAdminInfo(adminData) {
    // Update business name in footer if needed
    if (adminData.business_name) {
        const footerName = document.querySelector('.footer-section h3');
        if (footerName) {
            footerName.textContent = adminData.business_name;
        }
    }
}

async function initializeEcommerce() {
    try {
        console.log('Initializing premium e-commerce...');
        allProducts = await fetchProducts();
        filteredProducts = [...allProducts];
        displayProducts(filteredProducts);
        await loadAndDisplayCategories();
    } catch (error) {
        console.error('Error loading products:', error);
        document.getElementById('productsContainer').innerHTML = '<p class="error">Error loading products. Please refresh the page.</p>';
    }
}

function setupEventListeners() {
    // Search functionality
    const searchInput = document.getElementById('searchInput');
    const clearSearch = document.getElementById('clearSearch');
    
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            if (e.target.value) {
                clearSearch.style.display = 'block';
            } else {
                clearSearch.style.display = 'none';
            }
            applyFilters();
        });

        clearSearch.addEventListener('click', () => {
            searchInput.value = '';
            clearSearch.style.display = 'none';
            applyFilters();
        });
    }

    // Category filter
    document.querySelectorAll('.category-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentCategory = btn.dataset.category;
            applyFilters();
        });
    });

    // Sort functionality
    const sortBy = document.getElementById('sortBy');
    if (sortBy) {
        sortBy.addEventListener('change', (e) => {
            currentSortOrder = e.target.value;
            applyFilters();
        });
    }

    // Price range filters
    const priceMinInput = document.getElementById('priceMin');
    const priceMaxInput = document.getElementById('priceMax');
    
    if (priceMinInput) {
        priceMinInput.addEventListener('input', (e) => {
            priceMin = parseInt(e.target.value);
            document.getElementById('minDisplay').textContent = '₹' + priceMin.toLocaleString('en-IN');
            applyFilters();
        });
    }

    if (priceMaxInput) {
        priceMaxInput.addEventListener('input', (e) => {
            priceMax = parseInt(e.target.value);
            document.getElementById('maxDisplay').textContent = '₹' + priceMax.toLocaleString('en-IN');
            applyFilters();
        });
    }

    // Filter toggle
    const filterToggle = document.getElementById('filterToggle');
    if (filterToggle) {
        filterToggle.addEventListener('click', () => {
            const filters = document.getElementById('advancedFilters');
            filters.style.display = filters.style.display === 'none' ? 'block' : 'none';
        });
    }

    // Reset filters
    const resetFilters = document.getElementById('resetFilters');
    if (resetFilters) {
        resetFilters.addEventListener('click', resetAllFilters);
    }

    // Gallery filter
    document.querySelectorAll('.gallery-filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.gallery-filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            filterGallery(btn.dataset.filter);
        });
    });

    // Newsletter subscription
    const newsletterBtn = document.querySelector('.newsletter-form .btn');
    if (newsletterBtn) {
        newsletterBtn.addEventListener('click', subscribeNewsletter);
    }

    // Contact form
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', handleContactSubmit);
    }

    // Product modal close on background click
    const modal = document.getElementById('productModal');
    if (modal) {
        window.addEventListener('click', (event) => {
            if (event.target === modal) {
                closeProductModal();
            }
        });
    }
}

// Load and Display Categories
async function loadAndDisplayCategories() {
    try {
        const client = window.supabaseClient;
        if (!client) {
            console.log('Supabase client not available for categories');
            return;
        }

        const { data: categories, error } = await client
            .from('categories')
            .select('*')
            .eq('is_active', true)
            .order('created_at', { ascending: false });

        if (error) {
            console.log('Categories table may not exist or error occurred:', error.message);
            return;
        }

        if (!categories || categories.length === 0) {
            console.log('No active categories found');
            document.getElementById('categoriesCarousel').innerHTML = '<p style="text-align: center; padding: 40px; color: #999;">No categories available</p>';
            return;
        }

        displayCategoriesCarousel(categories);
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Display Categories as Carousel with Auto-Rotation
function displayCategoriesCarousel(categories) {
    const carousel = document.getElementById('categoriesCarousel');
    const dotsContainer = document.getElementById('carouselDots');
    
    if (!carousel || !dotsContainer) return;

    carousel.innerHTML = '';
    dotsContainer.innerHTML = '';

    let currentSlide = 0;
    let autoRotateInterval;

    // Create carousel slides
    categories.forEach((category, index) => {
        const slide = document.createElement('div');
        slide.className = `carousel-slide ${index === 0 ? 'active' : ''}`;
        
        const imageUrl = category.image_url || 'uploads/placeholder.png';
        
        slide.innerHTML = `
            <div class="category-carousel-card">
                <div class="category-carousel-image" style="background-image: url('${imageUrl}')"></div>
                <div class="category-carousel-overlay">
                    <h3 class="category-carousel-title">${category.name}</h3>
                    <p class="category-carousel-description">${category.description || 'Explore our collection'}</p>
                    <button class="category-carousel-btn" onclick="shopByCategory('${category.name}')">
                        <i class="fas fa-shopping-bag"></i> Shop Now
                    </button>
                </div>
            </div>
        `;
        carousel.appendChild(slide);

        // Create navigation dots
        const dot = document.createElement('div');
        dot.className = `carousel-dot ${index === 0 ? 'active' : ''}`;
        dot.onclick = () => goToSlide(index);
        dotsContainer.appendChild(dot);
    });

    // Navigate to specific slide
    function goToSlide(n) {
        if (n >= categories.length) currentSlide = 0;
        if (n < 0) currentSlide = categories.length - 1;
        
        const slides = document.querySelectorAll('.carousel-slide');
        const dots = document.querySelectorAll('.carousel-dot');
        
        slides.forEach(slide => slide.classList.remove('active'));
        dots.forEach(dot => dot.classList.remove('active'));
        
        slides[currentSlide].classList.add('active');
        dots[currentSlide].classList.add('active');
        
        // Reset auto-rotate timer
        clearInterval(autoRotateInterval);
        startAutoRotate();
    }

    // Next slide
    function nextSlide() {
        currentSlide++;
        goToSlide(currentSlide);
    }

    // Previous slide
    function prevSlide() {
        currentSlide--;
        goToSlide(currentSlide);
    }

    // Auto-rotate every 4 seconds
    function startAutoRotate() {
        autoRotateInterval = setInterval(() => {
            nextSlide();
        }, 4000);
    }

    // Attach controls
    const prevBtn = document.getElementById('prevCategory');
    const nextBtn = document.getElementById('nextCategory');
    
    if (prevBtn) prevBtn.onclick = prevSlide;
    if (nextBtn) nextBtn.onclick = nextSlide;

    // Start auto-rotation
    startAutoRotate();

    // Pause rotation on hover
    carousel.addEventListener('mouseenter', () => clearInterval(autoRotateInterval));
    carousel.addEventListener('mouseleave', startAutoRotate);
}


// Shop by Category - Filter products and scroll to shop section
function shopByCategory(categoryName) {
    currentCategory = categoryName.toLowerCase();
    
    // Update category buttons if they exist
    const categoryBtns = document.querySelectorAll('.category-btn');
    categoryBtns.forEach(btn => {
        if (btn.dataset.category === currentCategory) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    applyFilters();
    
    // Smooth scroll to products section
    const shopSection = document.getElementById('shop');
    if (shopSection) {
        shopSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function filterByCategory(category) {
    currentCategory = category;
    document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'));
    document.querySelector(`[data-category="${category}"]`).classList.add('active');
    applyFilters();
    document.getElementById('shop').scrollIntoView({ behavior: 'smooth' });
}

function applyFilters() {
    let filtered = [...allProducts];

    // Category filter
    if (currentCategory !== 'all') {
        filtered = filtered.filter(p => {
            const category = (p.category || '').toLowerCase();
            return category.includes(currentCategory);
        });
    }

    // Search filter
    const searchInput = document.getElementById('searchInput');
    const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
    if (searchTerm) {
        filtered = filtered.filter(p => 
            p.name.toLowerCase().includes(searchTerm) ||
            p.description.toLowerCase().includes(searchTerm) ||
            (p.category && p.category.toLowerCase().includes(searchTerm))
        );
    }

    // Price filter
    filtered = filtered.filter(p => p.price >= priceMin && p.price <= priceMax);

    // Sorting
    if (currentSortOrder) {
        filtered.sort((a, b) => {
            switch(currentSortOrder) {
                case 'name-asc':
                    return a.name.localeCompare(b.name);
                case 'name-desc':
                    return b.name.localeCompare(a.name);
                case 'price-low':
                    return a.price - b.price;
                case 'price-high':
                    return b.price - a.price;
                case 'newest':
                    return new Date(b.created_at || 0) - new Date(a.created_at || 0);
                default:
                    return 0;
            }
        });
    }

    filteredProducts = filtered;
    displayProducts(filteredProducts);
}

function resetAllFilters() {
    const searchInput = document.getElementById('searchInput');
    const sortBy = document.getElementById('sortBy');
    const priceMin = document.getElementById('priceMin');
    const priceMax = document.getElementById('priceMax');

    if (searchInput) searchInput.value = '';
    if (sortBy) sortBy.value = '';
    if (priceMin) priceMin.value = '0';
    if (priceMax) priceMax.value = '10000';

    document.getElementById('minDisplay').textContent = '₹0';
    document.getElementById('maxDisplay').textContent = '₹10000';

    currentCategory = 'all';
    currentSortOrder = '';
    priceMin = 0;
    priceMax = 10000;

    document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'));
    document.querySelector('[data-category="all"]').classList.add('active');

    applyFilters();
}

function displayProducts(products) {
    const container = document.getElementById('productsContainer');
    const noResults = document.getElementById('noResults');

    if (products.length === 0) {
        container.style.display = 'none';
        noResults.style.display = 'block';
        return;
    }

    container.style.display = 'grid';
    noResults.style.display = 'none';
    
    container.innerHTML = products.map(product => `
        <div class="product-card" onclick="openProductModal('${product.id}')">
            <div class="product-image">
                ${product.image_url ? 
                    `<img src="${product.image_url}" alt="${product.name}" loading="lazy">` :
                    `<div class="image-placeholder"><i class="fas fa-image"></i></div>`
                }
                <span class="category-badge">${product.category || 'Uncategorized'}</span>
            </div>
            <div class="product-info">
                <h3>${product.name}</h3>
                <p class="product-description">${product.description.substring(0, 60)}...</p>
                <div class="product-footer">
                    <span class="price">₹${product.price.toFixed(0)}</span>
                    <button class="quick-add order-now-btn" onclick="event.stopPropagation(); orderNowFromCollection('${product.id}')" title="Order Now">
                        <i class="fas fa-check-circle"></i> Order Now
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

async function openProductModal(productId) {
    currentProductId = productId;
    currentImageIndex = 0;

    try {
        const products = await fetchProducts();
        const product = products.find(p => p.id == productId);

        if (!product) {
            alert('Product not found');
            return;
        }

        document.getElementById('modalProductName').textContent = product.name;
        document.getElementById('modalProductPrice').textContent = `₹${product.price.toFixed(0)}`;
        document.getElementById('modalProductDescription').textContent = product.description;
        document.getElementById('quantityInput').value = '1';

        // Set stock status
        const stockStatus = document.getElementById('stockStatus');
        if (product.stock_quantity > 0) {
            stockStatus.textContent = 'In Stock';
            stockStatus.style.color = '#10b981';
        } else {
            stockStatus.textContent = 'Out of Stock';
            stockStatus.style.color = '#ef4444';
        }

        // Load images
        try {
            const productImages = await fetchProductImages(productId);
            if (productImages && productImages.length > 0) {
                loadCarouselImages(productImages);
                updateCarousel();
            } else if (product.image_url) {
                document.getElementById('carouselMainImage').src = product.image_url;
            }
        } catch (err) {
            console.log('Using default product image');
            if (product.image_url) {
                document.getElementById('carouselMainImage').src = product.image_url;
            }
        }

        document.getElementById('productModal').style.display = 'block';
    } catch (error) {
        console.error('Error opening modal:', error);
        alert('Error loading product details');
    }
}

function closeProductModal() {
    document.getElementById('productModal').style.display = 'none';
    currentProductId = null;
    currentImageIndex = 0;
}

function nextImage() {
    const thumbnails = document.querySelectorAll('.carousel-thumbnails img');
    if (thumbnails.length > 0) {
        currentImageIndex = (currentImageIndex + 1) % thumbnails.length;
        updateCarousel();
    }
}

function prevImage() {
    const thumbnails = document.querySelectorAll('.carousel-thumbnails img');
    if (thumbnails.length > 0) {
        currentImageIndex = (currentImageIndex - 1 + thumbnails.length) % thumbnails.length;
        updateCarousel();
    }
}

function updateCarousel() {
    const thumbnails = document.querySelectorAll('.carousel-thumbnails img');
    if (thumbnails.length > 0) {
        const mainImage = document.getElementById('carouselMainImage');
        mainImage.src = thumbnails[currentImageIndex].src;
        document.getElementById('currentImage').textContent = currentImageIndex + 1;
        document.getElementById('totalImages').textContent = thumbnails.length;

        // Update thumbnail selection
        document.querySelectorAll('.carousel-thumbnails img').forEach((img, index) => {
            img.style.opacity = index === currentImageIndex ? '1' : '0.5';
            img.style.borderColor = index === currentImageIndex ? '#e94560' : 'transparent';
        });
    }
}

function loadCarouselImages(images) {
    const container = document.getElementById('thumbnailsContainer');
    container.innerHTML = images
        .sort((a, b) => a.image_order - b.image_order)
        .map((img, index) => `
            <img src="${img.image_url}" alt="Image ${index + 1}" 
                 onclick="setCarouselImage(${index})" 
                 style="cursor: pointer; width: 100%; height: 80px; object-fit: cover; border-radius: 8px; border: 2px solid transparent; opacity: ${index === 0 ? '1' : '0.5'};">
        `).join('');
}

function setCarouselImage(index) {
    currentImageIndex = index;
    updateCarousel();
}

function increaseQuantity() {
    const input = document.getElementById('quantityInput');
    input.value = parseInt(input.value) + 1;
}

function decreaseQuantity() {
    const input = document.getElementById('quantityInput');
    if (parseInt(input.value) > 1) {
        input.value = parseInt(input.value) - 1;
    }
}

async function addToCart() {
    try {
        const quantity = parseInt(document.getElementById('quantityInput').value) || 1;
        
        if (!currentProductId) {
            alert('Product not found');
            return;
        }

        // Get product details
        if (!allProducts || !allProducts.length) {
            allProducts = await fetchProducts();
        }
        
        const product = allProducts.find(p => p.id == currentProductId);

        if (!product) {
            alert('Product not found');
            return;
        }

        // Get existing cart from sessionStorage
        let cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        
        // Check if product already in cart
        const existingItem = cartItems.find(item => item.id === product.id);
        
        if (existingItem) {
            // Increase quantity by 1 if already in cart
            existingItem.qty += 1;
            console.log(`✅ Updated ${product.name} quantity to ${existingItem.qty}`);
        } else {
            // Add new item to cart with actual product data
            cartItems.push({
                id: product.id,
                name: product.name,
                price: product.price,
                qty: 1,
                image: product.image_url || '',
                description: product.description || ''
            });
            console.log(`✅ Added ${product.name} to cart`);
        }

        // Calculate total amount
        const totalAmount = cartItems.reduce((sum, item) => sum + (item.price * item.qty), 0);

        // Save to session storage
        sessionStorage.setItem('cartItems', JSON.stringify(cartItems));
        sessionStorage.setItem('totalAmount', totalAmount.toFixed(2));
        sessionStorage.setItem('orderId', 'ORD-' + Date.now());

        // Update cart badge
        updateCartCountBadge();

        // Show success message
        alert(`✅ ${product.name} added to cart! Proceeding to checkout...`);
        closeProductModal();

        // Navigate to payment page
        window.location.href = 'payment.html';
    } catch (error) {
        console.error('Error adding to cart:', error);
        alert('Error adding to cart. Please try again.');
    }
}
// Build and store orderData with product details for payment page
async function buildAndStoreOrderData() {
    let cart = [];
    try {
        cart = JSON.parse(localStorage.getItem('cart') || '[]');
    } catch {}
    if (!cart.length) return;
    if (!allProducts || !allProducts.length) {
        allProducts = await fetchProducts();
    }
    // Example customer info (replace with real form data if available)
    const customer_name = localStorage.getItem('customer_name') || '';
    const customer_phone = localStorage.getItem('customer_phone') || '';
    const customer_email = localStorage.getItem('customer_email') || '';
    const delivery_address = localStorage.getItem('delivery_address') || '';
    const delivery_date = localStorage.getItem('delivery_date') || '';
    const delivery_charge = 0; // Set as needed
    const order_id = 'ORD-' + Date.now() + '-' + Math.floor(Math.random() * 10000);
    const order_number = order_id;
    const items = cart.map(item => {
        const product = allProducts.find(p => p.id == item.id);
        if (!product) return null;
        return {
            product_id: product.id,
            product_name: product.name,
            price: product.price,
            quantity: item.quantity,
            image_url: product.image_url || '',
        };
    }).filter(Boolean);
    const total_amount = items.reduce((sum, item) => sum + item.price * item.quantity, 0) + delivery_charge;
    const orderData = {
        customer_name,
        customer_phone,
        customer_email,
        delivery_address,
        delivery_date,
        delivery_charge,
        order_id,
        order_number,
        items,
        total_amount
    };
    sessionStorage.setItem('orderData', JSON.stringify(orderData));
    localStorage.setItem('orderData', JSON.stringify(orderData));
}


function buyNow() {
    alert('✓ Proceeding to checkout...');
    closeProductModal();
    window.location.href = 'orders.html';
}

function addProductQuick(productId) {
    let cart = JSON.parse(localStorage.getItem('cart') || '[]');
    let found = false;
    for (let item of cart) {
        if (item.id === productId) {
            item.quantity += 1;
            found = true;
            break;
        }
    }
    if (!found) {
        cart.push({ id: productId, quantity: 1 });
    }
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCountBadge();
    alert('✓ 1 item added to cart!');
    // Redirect to payment page after 1 second
    setTimeout(async () => {
        await buildAndStoreOrderData();
        window.location.href = 'payment.html';
    }, 1000);
}

// Order Now from Collection Section
async function orderNowFromCollection(productId) {
    try {
        const products = await fetchProducts();
        const product = products.find(p => p.id == productId);
        
        if (!product) {
            alert('Product not found');
            return;
        }

        // Create order data with single product
        const subtotal = product.price;
        const deliveryCharge = 50; // Default delivery charge
        const totalAmount = subtotal + deliveryCharge;

        const orderData = {
            items: [
                {
                    id: product.id,
                    product_name: product.name,
                    name: product.name,
                    price: product.price,
                    quantity: 1,
                    qty: 1,
                    description: product.description,
                    image_url: product.image_url
                }
            ],
            subtotal: subtotal,
            delivery_charge: deliveryCharge,
            total_amount: totalAmount,
            total: totalAmount,
            order_number: 'ORDER-' + Date.now(),
            timestamp: new Date().toISOString()
        };

        // Store in sessionStorage for payment page to access
        sessionStorage.setItem('orderData', JSON.stringify(orderData));
        sessionStorage.setItem('cartItems', JSON.stringify(orderData.items));

        // Show success message and redirect
        alert('✓ Proceeding to checkout...');
        window.location.href = 'payment.html';
    } catch (error) {
        console.error('Error in orderNowFromCollection:', error);
        alert('Error processing order. Please try again.');
    }
}

function updateCartCountBadge() {
    const badge = document.getElementById('cartCountBadge');
    if (!badge) return;
    let cartItems = [];
    try {
        cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
    } catch {}
    const count = cartItems.reduce((sum, item) => sum + (item.qty || 1), 0);
    badge.textContent = count;
    badge.style.display = count > 0 ? 'inline-block' : 'none';
}
// Update badge on page load and when storage changes (multi-tab)
window.addEventListener('storage', function(e) {
    if (e.key === 'cart') updateCartCountBadge();
});

async function loadGallery() {
    try {
        const gallery = await fetchGallery();
        displayGallery(gallery);
    } catch (error) {
        console.error('Error loading gallery:', error);
    }
}

function displayGallery(items) {
    const container = document.getElementById('galleryContainer');
    if (!items || items.length === 0) {
        container.innerHTML = '<p>No gallery items found</p>';
        return;
    }

    container.innerHTML = items.map((item, index) => `
        <div class="gallery-item ${(item.category || 'all').toLowerCase()}">
            ${item.image_url ? 
                `<img src="${item.image_url}" alt="Gallery ${index + 1}" loading="lazy">` :
                `<div class="image-placeholder"><i class="fas fa-image"></i></div>`
            }
        </div>
    `).join('');
}

function filterGallery(category) {
    document.querySelectorAll('.gallery-item').forEach(item => {
        if (category === 'all' || item.classList.contains(category.toLowerCase())) {
            item.style.display = 'block';
            setTimeout(() => {
                item.style.opacity = '1';
                item.style.transform = 'scale(1)';
            }, 10);
        } else {
            item.style.opacity = '0';
            item.style.transform = 'scale(0.9)';
            setTimeout(() => {
                item.style.display = 'none';
            }, 300);
        }
    });
}

function subscribeNewsletter() {
    const email = document.getElementById('newsletterEmail');
    if (email && email.value) {
        if (validateEmail(email.value)) {
            alert('✓ Thank you for subscribing! Check your email for exclusive offers.');
            email.value = '';
        } else {
            alert('Please enter a valid email address');
        }
    }
}

async function handleContactSubmit(e) {
    e.preventDefault();
    
    try {
        const formElements = document.getElementById('contactForm').elements;
        const name = formElements[0].value;
        const email = formElements[1].value;
        const subject = formElements[2].value;
        const message = formElements[3].value;
        
        // Validate
        if (!name || !email || !message) {
            alert('Please fill all required fields');
            return;
        }
        
        // Save to Supabase
        const supabaseClient = window.supabaseClient;
        if (supabaseClient) {
            const { error } = await supabaseClient
                .from('messages')
                .insert([{
                    name,
                    email,
                    subject,
                    message
                }]);
            
            if (error) {
                alert('Error saving message: ' + error.message);
                return;
            }
        }
        
        alert('✓ Thank you for your message! We will get back to you soon.');
        document.getElementById('contactForm').reset();
    } catch (error) {
        console.error('Error in handleContactSubmit:', error);
        alert('Error sending message: ' + error.message);
    }
}

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// Fetch products from Supabase
async function fetchProducts() {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('products')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching products:', error);
            return [];
        }
        return data || [];
    } catch (error) {
        console.error('Error in fetchProducts:', error);
        return [];
    }
}

async function fetchProductImages(productId) {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('product_images')
            .select('*')
            .eq('product_id', productId)
            .order('image_order', { ascending: true });

        if (error) {
            console.error('Error fetching product images:', error);
            return [];
        }
        return data || [];
    } catch (error) {
        console.error('Error in fetchProductImages:', error);
        return [];
    }
}

async function fetchGallery() {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('gallery')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching gallery:', error);
            return [];
        }
        return data || [];
    } catch (error) {
        console.error('Error in fetchGallery:', error);
        return [];
    }
}

// Add smooth scroll behavior
document.addEventListener('click', (e) => {
    if (e.target.tagName === 'A' && e.target.getAttribute('href').startsWith('#')) {
        e.preventDefault();
        const target = document.querySelector(e.target.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    }
});
