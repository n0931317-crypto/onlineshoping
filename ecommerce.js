// Advanced E-Commerce Script
let allProducts = [];
let filteredProducts = [];
let currentCategory = 'all';
let currentSortOrder = '';
let priceMin = 0;
let priceMax = 10000;
let currentProductId = null;
let currentImageIndex = 0;

// Get Supabase client
function getClient() {
    if (window.supabaseClient) {
        console.log('✅ Using window.supabaseClient');
        return window.supabaseClient;
    }
    if (typeof window.getClient === 'function') {
        return window.getClient();
    }
    console.warn('⚠️ Supabase client not yet initialized');
    return null;
}

document.addEventListener('DOMContentLoaded', async () => {
    await initializeEcommerce();
    setupEventListeners();
    await loadGallery();
});

async function initializeEcommerce() {
    try {
        console.log('Initializing advanced e-commerce...');
        allProducts = await fetchProducts();
        filteredProducts = [...allProducts];
        displayProducts(filteredProducts);
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
            document.getElementById('minDisplay').textContent = priceMin;
            applyFilters();
        });
    }

    if (priceMaxInput) {
        priceMaxInput.addEventListener('input', (e) => {
            priceMax = parseInt(e.target.value);
            document.getElementById('maxDisplay').textContent = priceMax;
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

    document.getElementById('minDisplay').textContent = '0';
    document.getElementById('maxDisplay').textContent = '10000';

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
                    <span class="price">Rs. ${product.price.toFixed(2)}</span>
                    <button class="quick-add" onclick="event.stopPropagation(); addProductQuick('${product.id}')">
                        <i class="fas fa-cart-plus"></i>
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
        document.getElementById('modalProductPrice').textContent = `Rs. ${product.price.toFixed(2)}`;
        document.getElementById('modalProductDescription').textContent = product.description;
        document.getElementById('quantityInput').value = '1';

        // Set stock status
        const stockStatus = document.getElementById('stockStatus');
        if (product.stock_quantity > 0) {
            stockStatus.textContent = 'In Stock';
            stockStatus.style.color = 'green';
        } else {
            stockStatus.textContent = 'Out of Stock';
            stockStatus.style.color = 'red';
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

        // Update thumbnail selection
        document.querySelectorAll('.carousel-thumbnails img').forEach((img, index) => {
            img.style.opacity = index === currentImageIndex ? '1' : '0.5';
            img.style.border = index === currentImageIndex ? '2px solid var(--primary)' : 'none';
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
                 style="cursor: pointer; width: 80px; height: 80px; object-fit: cover; border-radius: 4px; border: ${index === 0 ? '2px solid var(--primary)' : 'none'}; opacity: ${index === 0 ? '1' : '0.5'};">
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
        console.log('🔷 addToCart function called');
        console.log('🔷 currentProductId:', currentProductId);
        
        if (!currentProductId) {
            alert('Product not found. Please select a product first.');
            console.error('❌ No currentProductId');
            return;
        }

        const quantityInput = document.getElementById('quantityInput');
        const quantity = quantityInput ? parseInt(quantityInput.value) || 1 : 1;
        console.log('🔷 Quantity:', quantity);

        // Get product details
        const products = await fetchProducts();
        console.log('🔷 All products:', products.length);
        
        const product = products.find(p => p.id == currentProductId);
        console.log('🔷 Found product:', product);

        if (!product) {
            alert('Product not found');
            console.error('❌ Product not found with ID:', currentProductId);
            return;
        }

        // Get existing cart
        let cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
        console.log('🛒 Existing cart items before add:', cartItems);
        
        // Check if product already in cart
        const existingItem = cartItems.find(item => item.id === product.id);
        
        if (existingItem) {
            // Increase quantity if already in cart
            existingItem.qty += quantity;
            console.log(`✅ Updated ${product.name} quantity to ${existingItem.qty}`);
        } else {
            // Add new item to cart with actual product data
            cartItems.push({
                id: product.id,
                name: product.name,
                price: product.price,
                qty: quantity,
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
        
        console.log('💾 Data saved to sessionStorage:');
        console.log('  - cartItems:', JSON.parse(sessionStorage.getItem('cartItems')));
        console.log('  - totalAmount:', sessionStorage.getItem('totalAmount'));
        console.log('  - orderId:', sessionStorage.getItem('orderId'));

        // Close modal first
        closeProductModal();
        
        // Show success message and proceed to payment
        alert(`✅ ${product.name} added to cart! Proceeding to payment...`);

        // Navigate to payment page with order summary
        setTimeout(() => {
            console.log('🔷 Navigating to payment.html');
            window.location.href = 'payment.html';
        }, 300);
    } catch (error) {
        console.error('❌ Error in addToCart:', error);
        alert('Error adding to cart: ' + error.message);
    }
}

function buyNow() {
    alert('Proceeding to checkout...');
    closeProductModal();
    // Redirect to orders page
    window.location.href = 'orders.html';
}

function navigateToPayment() {
    // Get cart items from session storage
    const cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
    
    console.log('🛒 navigateToPayment called');
    console.log('📦 Current cart items:', cartItems);
    
    if (!cartItems || cartItems.length === 0) {
        alert('⚠️ Your cart is empty. Please add items to your cart first.');
        console.warn('Cart is empty');
        return;
    }
    
    console.log('✅ Navigating to payment with', cartItems.length, 'items');
    // Navigate to payment page
    window.location.href = 'payment.html';
}

function addProductQuick(productId) {
    alert('Product added to cart!');
}

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
        } else {
            item.style.display = 'none';
        }
    });
}

function subscribeNewsletter() {
    const email = document.getElementById('newsletterEmail');
    if (email && email.value) {
        alert('Thank you for subscribing! Check your email for exclusive offers.');
        email.value = '';
    }
}

function handleContactSubmit(e) {
    e.preventDefault();
    alert('Thank you for your message! We will get back to you soon.');
    document.getElementById('contactForm').reset();
}

// Fetch products from Supabase (from supabase-new.js)
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
