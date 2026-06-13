// Admin Panel JavaScript for Supabase
// Always use the global Supabase client from supabase-new.js
function getClient() {
    if (window.supabaseClient) return window.supabaseClient;
    if (typeof window.getClient === 'function') return window.getClient();
    console.error('Supabase client not initialized.');
    return null;
}

// Global variables
let currentEditId = null;
let isEditing = false;

// Admin Credentials
const ADMIN_CREDENTIALS = {
    email: 'admin@nepoonline.com',
    password: 'nepostores@121'
};

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', async function() {
    // Always clear login on page load - require fresh login
    localStorage.removeItem('adminLoggedIn');
    
    // Show login page
    const loginPage = document.getElementById('login-page');
    const adminPanel = document.getElementById('admin-panel');
    if (loginPage) loginPage.style.display = 'flex';
    if (adminPanel) adminPanel.style.display = 'none';
    
    setupLoginEventListener();
});

// Setup Login Form Event Listener
function setupLoginEventListener() {
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLoginSubmit);
    }
}

// Handle Login Form Submission
function handleLoginSubmit(e) {
    e.preventDefault();
    
    const emailInput = document.getElementById('admin-email');
    const passwordInput = document.getElementById('admin-password');
    const errorElement = document.getElementById('login-error');
    
    if (!emailInput || !passwordInput) {
        console.error('Login form elements not found');
        return;
    }
    
    const email = emailInput.value.trim();
    const password = passwordInput.value;
    
    // Validate credentials
    if (email === ADMIN_CREDENTIALS.email && password === ADMIN_CREDENTIALS.password) {
        // Login successful
        localStorage.setItem('adminLoggedIn', 'true');
        localStorage.setItem('adminEmail', email);
        
        // Set admin username in header
        const usernameElement = document.getElementById('admin-username');
        if (usernameElement) {
            usernameElement.textContent = email.split('@')[0] || 'Admin';
        }
        
        // Hide login page and show admin panel
        const loginPage = document.getElementById('login-page');
        const adminPanel = document.getElementById('admin-panel');
        if (loginPage) loginPage.style.display = 'none';
        if (adminPanel) adminPanel.style.display = 'flex';
        
        // Initialize admin panel
        initializeAdminPanel();
        
        // Clear form and error
        document.getElementById('login-form').reset();
        if (errorElement) errorElement.style.display = 'none';
    } else {
        // Login failed
        if (errorElement) {
            errorElement.textContent = 'Invalid email or password. Please try again.';
            errorElement.style.display = 'block';
        }
        if (emailInput) emailInput.focus();
    }
}

// Handle Logout
function handleLogout(event) {
    event.preventDefault();
    
    if (confirm('Are you sure you want to logout?')) {
        // Clear login status
        localStorage.removeItem('adminLoggedIn');
        
        // Hide admin panel and show login page
        const loginPage = document.getElementById('login-page');
        const adminPanel = document.getElementById('admin-panel');
        if (adminPanel) adminPanel.style.display = 'none';
        if (loginPage) loginPage.style.display = 'flex';
        
        // Reset login form
        document.getElementById('login-form').reset();
        const errorElement = document.getElementById('login-error');
        if (errorElement) errorElement.style.display = 'none';
    }
}

async function initializeAdminPanel() {
    try {
        console.log('Initializing admin panel...');
        
        // Wait for Supabase to initialize
        let attempts = 0;
        while (!window.supabaseClient && attempts < 20) {
            await new Promise(resolve => setTimeout(resolve, 100));
            attempts++;
        }
        
        if (!window.supabaseClient) {
            console.error('Supabase failed to initialize after 2 seconds');
            showNotification('Database connection failed. Please check your Supabase setup.', 'error');
            return;
        }
        
        console.log('✅ Supabase client ready, loading admin panel...');
        
        await loadDashboardStats();
        await loadAdminOffers();
        await loadCategories();
        await loadServices();
        await loadProducts();
        await loadOrders();
        await loadAdminMessages();
        await loadGallery();
        await loadHomeVideo();
        await loadPaymentConfiguration();
        await loadSettings();
        await loadPaymentQRs();
        setupEventListeners();
        console.log('✅ Admin panel initialized successfully');
        
        // Show setup reminder if needed
        const client = getClient();
        if (client) {
            const { data: tables } = await client
                .from('home_video')
                .select('count', { count: 'exact' })
                .limit(1);
            
            if (tables === null || tables?.count === undefined) {
                console.log('⚠️  Database tables may not be fully set up');
            }
        }
    } catch (error) {
        console.error('❌ Error initializing admin panel:', error);
        showNotification('Error initializing admin panel: ' + error.message, 'error');
    }
}

// Setup all event listeners
function setupEventListeners() {
    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-toggle');
    const sidebar = document.querySelector('.sidebar');
    const adminNav = document.querySelector('.admin-nav');
    
    if (mobileMenuBtn && adminNav) {
        mobileMenuBtn.addEventListener('click', function() {
            adminNav.classList.toggle('active');
            mobileMenuBtn.classList.toggle('active');
        });
        
        // Close menu when clicking on a link
        document.querySelectorAll('.admin-nav a').forEach(link => {
            link.addEventListener('click', function() {
                adminNav.classList.remove('active');
                mobileMenuBtn.classList.remove('active');
            });
        });
        
        // Close menu when clicking outside
        document.addEventListener('click', function(event) {
            if (!sidebar.contains(event.target) && !mobileMenuBtn.contains(event.target)) {
                adminNav.classList.remove('active');
                mobileMenuBtn.classList.remove('active');
            }
        });
    }
    
    // Navigation
    document.querySelectorAll('.admin-nav a').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelectorAll('.admin-nav a').forEach(l => l.classList.remove('active'));
            this.classList.add('active');
            
            const target = this.getAttribute('href').substring(1);
            showSection(target);
        });
    });
    
    // Offer form
    const offerForm = document.getElementById('offer-form');
    if (offerForm) {
        offerForm.addEventListener('submit', saveOffer);
    }
    
    // Service form
    document.getElementById('service-form').addEventListener('submit', handleServiceSubmit);
    
    // Category form
    document.getElementById('category-form').addEventListener('submit', handleCategorySubmit);
    
    // Product form
    document.getElementById('product-form').addEventListener('submit', handleProductSubmit);
    
    // Gallery form
    document.getElementById('gallery-form').addEventListener('submit', handleGallerySubmit);
    
    // Gallery upload
    const uploadArea = document.getElementById('upload-area');
    const fileInput = document.getElementById('gallery-upload');
    
    uploadArea.addEventListener('click', () => fileInput.click());
    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.style.borderColor = '#4a6fa5';
        uploadArea.style.backgroundColor = '#f8f9fa';
    });
    uploadArea.addEventListener('dragleave', () => {
        uploadArea.style.borderColor = '#ddd';
        uploadArea.style.backgroundColor = 'white';
    });
    uploadArea.addEventListener('drop', async (e) => {
        e.preventDefault();
        uploadArea.style.borderColor = '#ddd';
        uploadArea.style.backgroundColor = 'white';
        
        const files = e.dataTransfer.files;
        await handleGalleryFileUpload(files);
    });
    
    fileInput.addEventListener('change', async (e) => {
        await handleGalleryFileUpload(e.target.files);
    });
    
    // Settings forms
    document.getElementById('business-hours-form').addEventListener('submit', saveBusinessHours);
    // Save business hours handler (fix ReferenceError)
    async function saveBusinessHours(e) {
        e.preventDefault();
        const submitBtn = this.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        try {
            submitBtn.textContent = 'Saving...';
            submitBtn.disabled = true;
            
            const openingTime = document.getElementById('opening-time').value;
            const closingTime = document.getElementById('closing-time').value;
            
            // Validate times
            if (!openingTime || !closingTime) throw new Error('Both opening and closing times are required');
            
            const hours = {
                opening: openingTime,
                closing: closingTime
            };
            
            console.log('📝 Saving business hours:', hours);
            await saveSetting('business_hours', hours);
            
            showNotification('✅ Business hours saved successfully! Your changes are now stored.', 'success');
            console.log('✅ Business hours verified in database');
            
        } catch (error) {
            console.error('❌ Error saving business hours:', error);
            const errorMsg = error.message || error.toString();
            showNotification(`❌ Failed to save: ${errorMsg}`, 'error');
        } finally {
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    }
    document.getElementById('contact-form').addEventListener('submit', saveContactInfo);
    document.getElementById('admin-settings-form').addEventListener('submit', saveAdminSettings);
    
    // Image preview handlers
    document.getElementById('service-image-file').addEventListener('change', function(e) {
        previewImage(e.target.files[0], 'service-image-preview');
    });
    
    document.getElementById('product-image-file').addEventListener('change', function(e) {
        previewImage(e.target.files[0], 'product-image-preview');
    });
}

function previewImage(file, previewId) {
    if (!file) return;
    
    const reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById(previewId).innerHTML = 
            `<img src="${e.target.result}" alt="Preview" style="max-width: 100%; max-height: 200px;">`;
    };
    reader.readAsDataURL(file);
}

// Show specific section
function showSection(sectionId) {
    document.querySelectorAll('.management-section').forEach(section => {
        section.style.display = 'none';
    });
    document.getElementById(sectionId).style.display = 'block';
}

// Load Dashboard Statistics
async function loadDashboardStats() {
    try {
        console.log('Loading dashboard stats...');
        const stats = await fetchDashboardStats();
        
        console.log('✅ Stats received:', stats);
        
        const todayAppts = document.getElementById('today-appointments');
        const totalSrvcs = document.getElementById('total-services');
        const totalPrds = document.getElementById('total-products');
        const pendingOrds = document.getElementById('pending-orders');
        const todayRev = document.getElementById('today-revenue');
        
        if (todayAppts) {
            todayAppts.textContent = stats.todayAppointments || 0;
        }
        if (totalSrvcs) {
            totalSrvcs.textContent = stats.totalServices || 0;
        }
        if (totalPrds) {
            totalPrds.textContent = stats.totalProducts || 0;
        }
        if (pendingOrds) {
            pendingOrds.textContent = stats.pendingOrders || 0;
        }
        if (todayRev) {
            todayRev.textContent = `Rs. ${(stats.todayRevenue || 0).toFixed(2)}`;
        }
        
        console.log('✅ Dashboard stats updated successfully');
    } catch (error) {
        console.error('❌ Error loading dashboard stats:', error);
        showNotification('Error loading dashboard statistics', 'error');
    }
}

// Services Management
async function loadServices() {
    try {
        const services = await fetchServices();
        const servicesList = document.getElementById('services-list');
        servicesList.innerHTML = '';
        
        if (services.length === 0) {
            servicesList.innerHTML = `
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">
                        No services found. Add your first service!
                    </td>
                </tr>
            `;
            return;
        }
        
        services.forEach(service => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>
                    ${service.image_url 
                        ? `<img src="${service.image_url}" alt="${service.title}" 
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;">`
                        : '<i class="fas fa-spa" style="font-size: 24px; color: #ccc;"></i>'
                    }
                </td>
                <td>${service.title}</td>
                <td title="${service.description}">${service.description.substring(0, 50)}...</td>
                <td>Rs. ${service.price}</td>
                <td>${service.duration_hours} hours</td>
                <td>
                    <span class="status-badge ${service.is_active ? 'confirmed' : 'cancelled'}">
                        ${service.is_active ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit-btn" onclick="editService('${service.id}'); return false;">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button class="action-btn delete-btn" onclick="deleteServiceConfirm('${service.id}'); return false;">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </div>
                </td>
            `;
            servicesList.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading services:', error);
        showNotification('Error loading services', 'error');
    }
}

// Open Service Modal
async function openServiceModal(service = null) {
    const modal = document.getElementById('service-modal');
    const form = document.getElementById('service-form');
    
    if (service) {
        isEditing = true;
        currentEditId = service.id;
        document.getElementById('service-id').value = service.id;
        document.getElementById('service-name').value = service.title;
        document.getElementById('service-description').value = service.description;
        document.getElementById('service-price').value = service.price;
        document.getElementById('service-duration').value = service.duration_hours;
        document.getElementById('service-image-url').value = service.image_url || '';
        document.getElementById('service-status').value = service.is_active.toString();
        
        const preview = document.getElementById('service-image-preview');
        if (service.image_url) {
            preview.innerHTML = `<img src="${service.image_url}" alt="Preview" style="max-width: 100%; max-height: 200px;">`;
        }
    } else {
        isEditing = false;
        currentEditId = null;
        form.reset();
        document.getElementById('service-image-preview').innerHTML = '';
        document.getElementById('service-status').value = 'true';
    }
    
    modal.style.display = 'flex';
}

// Close Service Modal
function closeServiceModal() {
    document.getElementById('service-modal').style.display = 'none';
    document.getElementById('service-form').reset();
    currentEditId = null;
    isEditing = false;
}

// Handle Service Form Submission
async function handleServiceSubmit(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Saving...';
        submitBtn.disabled = true;
        
        let imageUrl = document.getElementById('service-image-url').value;
        
        // Upload image file if provided
        const imageFile = document.getElementById('service-image-file').files[0];
        if (imageFile) {
            imageUrl = await uploadFile(imageFile, 'service-images');
        }
        
        const serviceData = {
            title: document.getElementById('service-name').value,
            description: document.getElementById('service-description').value,
            price: parseFloat(document.getElementById('service-price').value),
            duration_hours: parseFloat(document.getElementById('service-duration').value),
            image_url: imageUrl || null,
            is_active: document.getElementById('service-status').value === 'true'
        };
        
        if (isEditing && currentEditId) {
            await saveService({ ...serviceData, id: currentEditId });
            showNotification('Service updated successfully!');
        } else {
            await saveService(serviceData);
            showNotification('Service created successfully!');
        }
        
        closeServiceModal();
        await loadServices();
        await loadDashboardStats();
        
    } catch (error) {
        console.error('Error saving service:', error);
        const errorMsg = error?.message || error?.details?.message || 'Unknown error. Check RLS policies.';
        showNotification('Error saving service: ' + errorMsg, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

// Edit Service
async function editService(id) {
    try {
        const services = await fetchServices();
        const service = services.find(s => s.id === id);
        if (service) {
            openServiceModal(service);
        }
    } catch (error) {
        console.error('Error loading service:', error);
        showNotification('Error loading service', 'error');
    }
}

// Delete Service
async function deleteServiceConfirm(id) {
    if (confirm('Are you sure you want to delete this service? This action cannot be undone.')) {
        try {
            await deleteService(id);
            showNotification('Service deleted successfully!');
            await loadServices();
            await loadDashboardStats();
        } catch (error) {
            console.error('Error deleting service:', error);
            const errorMsg = error?.message || error?.details?.message || 'Unknown error. Check RLS policies.';
            showNotification('Error deleting service: ' + errorMsg, 'error');
        }
    }
}

// Products Management


// ============================================================
// MESSAGES MANAGEMENT FUNCTIONS
// ============================================================

// Load all messages for admin
async function loadAdminMessages() {
    try {
        const supabase = getClient();
        if (!supabase) return;
        
        const { data: messages, error } = await supabase
            .from('messages')
            .select('*')
            .order('created_at', { ascending: false });
        
        if (error) {
            console.error('Error loading messages:', error);
            return;
        }
        
        displayAdminMessages(messages);
        
        // Update total messages count in dashboard
        const totalMessagesElement = document.getElementById('total-messages');
        if (totalMessagesElement) {
            totalMessagesElement.textContent = messages ? messages.length : 0;
        }
    } catch (error) {
        console.error('Error in loadAdminMessages:', error);
    }
}

// Display messages in admin table
function displayAdminMessages(messages) {
    const tbody = document.getElementById('messages-list');
    if (!tbody) return;
    
    if (!messages || messages.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">No messages found</td></tr>';
        return;
    }
    
    tbody.innerHTML = messages.map(msg => {
        const date = new Date(msg.created_at).toLocaleDateString();
        const time = new Date(msg.created_at).toLocaleTimeString();
        const messagePreview = msg.message.substring(0, 50) + (msg.message.length > 50 ? '...' : '');
        
        return `
            <tr>
                <td><strong>${msg.name}</strong></td>
                <td>${msg.email}</td>
                <td>${msg.subject || 'N/A'}</td>
                <td title="${msg.message}">${messagePreview}</td>
                <td>${date} ${time}</td>
                <td>
                    <button class="btn-small" onclick="viewMessage(${msg.id})" title="View">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-small btn-danger" onclick="deleteMessage(${msg.id})" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    }).join('');
}

// View message details
async function viewMessage(messageId) {
    try {
        const supabase = getClient();
        if (!supabase) return;
        
        const { data: message, error } = await supabase
            .from('messages')
            .select('*')
            .eq('id', messageId)
            .single();
        
        if (error) {
            alert('Error loading message: ' + error.message);
            return;
        }
        
        const fullMessage = `
Name: ${message.name}
Email: ${message.email}
Subject: ${message.subject || 'N/A'}
Date: ${new Date(message.created_at).toLocaleString()}

Message:
${message.message}
        `;
        
        alert(fullMessage);
        
        // Mark as read
        if (!message.is_read) {
            await supabase
                .from('messages')
                .update({ is_read: true })
                .eq('id', messageId);
            
            await loadAdminMessages();
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// Delete message
async function deleteMessage(messageId) {
    if (!confirm('Are you sure you want to delete this message?')) return;
    
    try {
        const supabase = getClient();
        if (!supabase) {
            alert('Supabase client not initialized');
            return;
        }
        
        const { error } = await supabase
            .from('messages')
            .delete()
            .eq('id', messageId);
        
        if (error) {
            alert('Error deleting message: ' + error.message);
            return;
        }
        
        alert('Message deleted successfully!');
        await loadAdminMessages();
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// ============================================================
// OFFERS MANAGEMENT FUNCTIONS
// ============================================================

// Load all offers for admin
async function loadAdminOffers() {
    try {
        const supabase = getClient();
        if (!supabase) return;
        
        const { data: offers, error } = await supabase
            .from('offers')
            .select('*')
            .order('created_at', { ascending: false });
        
        if (error) {
            console.error('Error loading offers:', error);
            return;
        }
        
        displayAdminOffers(offers);
    } catch (error) {
        console.error('Error in loadAdminOffers:', error);
    }
}

// Display offers in admin table
function displayAdminOffers(offers) {
    const tbody = document.getElementById('offers-list');
    if (!tbody) return;
    
    if (!offers || offers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">No offers found</td></tr>';
        return;
    }
    
    tbody.innerHTML = offers.map(offer => {
        const startDate = new Date(offer.start_date).toLocaleDateString();
        const endDate = new Date(offer.end_date).toLocaleDateString();
        const isExpired = new Date(offer.end_date) < new Date();
        const status = offer.is_active && !isExpired ? 'Active' : 'Inactive';
        
        return `
            <tr>
                <td><strong>${offer.title}</strong></td>
                <td>${offer.discount_percentage}%</td>
                <td>${startDate}</td>
                <td>${endDate}</td>
                <td>
                    <span class="status-badge ${status.toLowerCase()}">
                        ${status}
                    </span>
                </td>
                <td>
                    <button class="btn-small" onclick="editOffer(${offer.id})" title="Edit">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-small btn-danger" onclick="deleteOffer(${offer.id})" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    }).join('');
}

// Open Offer Modal
async function openOfferModal(offerId = null) {
    const modal = document.getElementById('offer-modal');
    const form = document.getElementById('offer-form');
    
    if (offerId) {
        // Edit mode - fetch the offer
        isEditing = true;
        currentEditId = offerId;
        
        try {
            const supabase = getClient();
            const { data: offer, error } = await supabase
                .from('offers')
                .select('*')
                .eq('id', offerId)
                .single();
            
            if (error) {
                alert('Error loading offer: ' + error.message);
                return;
            }
            
            document.getElementById('offer-id').value = offer.id;
            document.getElementById('offer-title').value = offer.title;
            document.getElementById('offer-description').value = offer.description || '';
            document.getElementById('offer-discount-percentage').value = offer.discount_percentage;
            document.getElementById('offer-discount-amount').value = offer.discount_amount || '';
            document.getElementById('offer-image-url').value = offer.image_url || '';
            document.getElementById('offer-status').value = offer.is_active.toString();
            
            // Format dates for input
            const startDate = new Date(offer.start_date);
            const endDate = new Date(offer.end_date);
            document.getElementById('offer-start-date').value = startDate.toISOString().slice(0, 16);
            document.getElementById('offer-end-date').value = endDate.toISOString().slice(0, 16);
            
            const preview = document.getElementById('offer-image-preview');
            if (offer.image_url) {
                preview.innerHTML = `<img src="${offer.image_url}" alt="Preview" style="max-width: 100%; max-height: 200px;">`;
            }
        } catch (error) {
            alert('Error: ' + error.message);
            return;
        }
    } else {
        // New offer mode
        isEditing = false;
        currentEditId = null;
        form.reset();
        document.getElementById('offer-image-preview').innerHTML = '';
        document.getElementById('offer-status').value = 'true';
        
        // Set default dates
        const now = new Date();
        const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
        document.getElementById('offer-start-date').value = now.toISOString().slice(0, 16);
        document.getElementById('offer-end-date').value = tomorrow.toISOString().slice(0, 16);
    }
    
    modal.style.display = 'flex';
}

// Close Offer Modal
function closeOfferModal() {
    document.getElementById('offer-modal').style.display = 'none';
    document.getElementById('offer-form').reset();
}

// Save Offer (Create or Update)
async function saveOffer(event) {
    event.preventDefault();
    
    try {
        const supabase = getClient();
        if (!supabase) {
            alert('Supabase client not initialized');
            return;
        }
        
        const offerId = document.getElementById('offer-id').value;
        const title = document.getElementById('offer-title').value;
        const description = document.getElementById('offer-description').value;
        const discountPercentage = parseFloat(document.getElementById('offer-discount-percentage').value);
        const discountAmount = document.getElementById('offer-discount-amount').value ? parseFloat(document.getElementById('offer-discount-amount').value) : null;
        const imageUrl = document.getElementById('offer-image-url').value;
        const startDate = new Date(document.getElementById('offer-start-date').value).toISOString();
        const endDate = new Date(document.getElementById('offer-end-date').value).toISOString();
        const isActive = document.getElementById('offer-status').value === 'true';
        
        // Validate
        if (!title || !description || !discountPercentage || !endDate) {
            alert('Please fill all required fields');
            return;
        }
        
        if (new Date(endDate) <= new Date(startDate)) {
            alert('End date must be after start date');
            return;
        }
        
        const offerData = {
            title,
            description,
            discount_percentage: discountPercentage,
            discount_amount: discountAmount,
            image_url: imageUrl,
            start_date: startDate,
            end_date: endDate,
            is_active: isActive
        };
        
        let result;
        if (isEditing && offerId) {
            // Update existing offer
            result = await supabase
                .from('offers')
                .update(offerData)
                .eq('id', offerId);
        } else {
            // Insert new offer
            result = await supabase
                .from('offers')
                .insert([{
                    ...offerData,
                    created_by: ADMIN_CREDENTIALS.email
                }]);
        }
        
        if (result.error) {
            alert('Error saving offer: ' + result.error.message);
            return;
        }
        
        alert(isEditing ? 'Offer updated successfully!' : 'Offer created successfully!');
        closeOfferModal();
        await loadAdminOffers();
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// Edit Offer
async function editOffer(offerId) {
    await openOfferModal(offerId);
}

// Delete Offer
async function deleteOffer(offerId) {
    if (!confirm('Are you sure you want to delete this offer?')) return;
    
    try {
        const supabase = getClient();
        if (!supabase) {
            alert('Supabase client not initialized');
            return;
        }
        
        const { error } = await supabase
            .from('offers')
            .delete()
            .eq('id', offerId);
        
        if (error) {
            alert('Error deleting offer: ' + error.message);
            return;
        }
        
        alert('Offer deleted successfully!');
        await loadAdminOffers();
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// Category Management Functions

// Open Category Modal
async function openCategoryModal(category = null) {
    const modal = document.getElementById('category-modal');
    const form = document.getElementById('category-form');
    
    if (category) {
        isEditing = true;
        currentEditId = category.id;
        document.getElementById('category-id').value = category.id;
        document.getElementById('category-name').value = category.name;
        document.getElementById('category-description').value = category.description;
        document.getElementById('category-image-url').value = category.image_url || '';
        document.getElementById('category-status').value = category.is_active.toString();
        
        const preview = document.getElementById('category-image-preview');
        if (category.image_url) {
            preview.innerHTML = `<img src="${category.image_url}" alt="Preview" style="max-width: 100%; max-height: 200px;">`;
        }
    } else {
        isEditing = false;
        currentEditId = null;
        form.reset();
        document.getElementById('category-image-preview').innerHTML = '';
        document.getElementById('category-status').value = 'true';
    }
    
    modal.style.display = 'flex';
}

// Close Category Modal
function closeCategoryModal() {
    document.getElementById('category-modal').style.display = 'none';
    document.getElementById('category-form').reset();
    currentEditId = null;
    isEditing = false;
}

// ============================================================
// SLIDING IMAGES MANAGEMENT
// ============================================================

// Load Categories
async function loadCategories() {
    try {
        const client = getClient();
        const { data, error } = await client
            .from('categories')
            .select('*')
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        const tbody = document.getElementById('categories-list');
        if (!tbody) return;
        
        tbody.innerHTML = '';
        
        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: #999;">No categories found</td></tr>';
            return;
        }
        
        data.forEach(category => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>
                    ${category.image_url ? `<img src="${category.image_url}" alt="${category.name}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;">` : '<span style="color: #999;">No image</span>'}
                </td>
                <td><strong>${category.name}</strong></td>
                <td>${(category.description || '').substring(0, 50)}...</td>
                <td>
                    <span class="status-badge" style="background: ${category.is_active ? '#28a745' : '#dc3545'}; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85em;">
                        ${category.is_active ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <button class="btn btn-small" onclick="editCategory('${category.id}')" style="background: #007bff; margin-right: 5px;">Edit</button>
                    <button class="btn btn-small btn-danger" onclick="deleteCategoryConfirm('${category.id}')">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading categories:', error);
        showNotification('Error loading categories', 'error');
    }
}

// Handle Category Form Submission
async function handleCategorySubmit(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Saving...';
        submitBtn.disabled = true;
        
        let imageUrl = document.getElementById('category-image-url').value;
        
        // Upload image file if provided
        const imageFile = document.getElementById('category-image-file').files[0];
        if (imageFile) {
            imageUrl = await uploadFile(imageFile, 'category-images');
        }
        
        const categoryData = {
            name: document.getElementById('category-name').value,
            description: document.getElementById('category-description').value,
            image_url: imageUrl || null,
            is_active: document.getElementById('category-status').value === 'true'
        };
        
        const client = getClient();
        
        if (isEditing && currentEditId) {
            const { error } = await client
                .from('categories')
                .update(categoryData)
                .eq('id', currentEditId);
            
            if (error) throw error;
            showNotification('Category updated successfully!');
        } else {
            const { error } = await client
                .from('categories')
                .insert([categoryData]);
            
            if (error) throw error;
            showNotification('Category created successfully!');
        }
        
        closeCategoryModal();
        await loadCategories();
        
    } catch (error) {
        console.error('Error saving category:', error);
        const errorMsg = error?.message || error?.details?.message || 'Unknown error';
        showNotification('Error saving category: ' + errorMsg, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

// Edit Category
async function editCategory(id) {
    try {
        const client = getClient();
        const { data, error } = await client
            .from('categories')
            .select('*')
            .eq('id', id)
            .single();
        
        if (error) throw error;
        if (data) {
            openCategoryModal(data);
        }
    } catch (error) {
        console.error('Error loading category:', error);
        showNotification('Error loading category', 'error');
    }
}

// Delete Category
async function deleteCategoryConfirm(id) {
    if (confirm('Are you sure you want to delete this category? This action cannot be undone.')) {
        try {
            const client = getClient();
            const { error } = await client
                .from('categories')
                .delete()
                .eq('id', id);
            
            if (error) throw error;
            showNotification('Category deleted successfully!');
            await loadCategories();
        } catch (error) {
            console.error('Error deleting category:', error);
            const errorMsg = error?.message || error?.details?.message || 'Unknown error';
            showNotification('Error deleting category: ' + errorMsg, 'error');
        }
    }
}

// Products Management
async function loadProducts() {
    try {
        const products = await fetchProducts();
        const productsList = document.getElementById('products-list');
        productsList.innerHTML = '';
        
        if (products.length === 0) {
            productsList.innerHTML = `
                <tr>
                    <td colspan="8" style="text-align: center; padding: 40px;">
                        No products found. Add your first product!
                    </td>
                </tr>
            `;
            return;
        }
        
        products.forEach(product => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>
                    ${product.image_url 
                        ? `<img src="${product.image_url}" alt="${product.name}" 
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;">`
                        : '<i class="fas fa-shopping-bag" style="font-size: 24px; color: #ccc;"></i>'
                    }
                </td>
                <td>${product.name}</td>
                <td title="${product.description}">${product.description.substring(0, 50)}...</td>
                <td>Rs. ${product.price}</td>
                <td>${product.stock_quantity}</td>
                <td>${product.category}</td>
                <td>
                    <span class="status-badge ${product.is_active ? 'confirmed' : 'cancelled'}">
                        ${product.is_active ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit-btn" onclick="editProduct('${product.id}'); return false;">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button class="action-btn delete-btn" onclick="deleteProductConfirm('${product.id}'); return false;">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </div>
                </td>
            `;
            productsList.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading products:', error);
        showNotification('Error loading products', 'error');
    }
}

// Product Modal Functions
async function openProductModal(product = null) {
    const modal = document.getElementById('product-modal');
    const form = document.getElementById('product-form');
    
    if (product) {
        isEditing = true;
        currentEditId = product.id;
        document.getElementById('product-id').value = product.id;
        document.getElementById('product-name').value = product.name;
        document.getElementById('product-description').value = product.description;
        document.getElementById('product-price').value = product.price;
        document.getElementById('product-stock').value = product.stock_quantity;
        document.getElementById('product-category').value = product.category;
        document.getElementById('product-image-url').value = product.image_url || '';
        document.getElementById('product-status').value = product.is_active.toString();
        
        const preview = document.getElementById('product-image-preview');
        if (product.image_url) {
            preview.innerHTML = `<img src="${product.image_url}" alt="Preview" style="max-width: 100%; max-height: 200px;">`;
        }
    } else {
        isEditing = false;
        currentEditId = null;
        form.reset();
        document.getElementById('product-image-preview').innerHTML = '';
        document.getElementById('product-status').value = 'true';
    }
    
    modal.style.display = 'flex';
}

function closeProductModal() {
    document.getElementById('product-modal').style.display = 'none';
    document.getElementById('product-form').reset();
    currentEditId = null;
    isEditing = false;
}

async function handleProductSubmit(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Saving...';
        submitBtn.disabled = true;
        
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized');
        }
        
        let imageUrl = document.getElementById('product-image-url').value.trim();
        
        // Upload image file if provided
        const imageFile = document.getElementById('product-image-file').files[0];
        if (imageFile) {
            console.log('Uploading image file:', imageFile.name);
            imageUrl = await uploadFile(imageFile, 'product-images');
        }
        
        // Collect and validate product data
        const nameInput = document.getElementById('product-name');
        const priceInput = document.getElementById('product-price');
        const stockInput = document.getElementById('product-stock');
        const categoryInput = document.getElementById('product-category');
        const statusInput = document.getElementById('product-status');
        const descriptionInput = document.getElementById('product-description');

        if (!nameInput || !priceInput || !stockInput) {
            throw new Error('Required form fields missing from DOM');
        }

        // Validate inputs
        const name = nameInput.value?.trim();
        const price = parseFloat(priceInput.value);
        const stock = parseInt(stockInput.value);
        const category = categoryInput?.value?.trim() || 'Uncategorized';
        const status = statusInput?.value || 'true';
        const description = descriptionInput?.value?.trim() || '';

        if (!name) throw new Error('Product name is required');
        if (isNaN(price) || price < 0) throw new Error('Valid price is required');
        if (isNaN(stock) || stock < 0) throw new Error('Valid stock quantity is required');

        const productData = {
            name: name,
            description: description,
            price: price,
            stock_quantity: stock,
            category: category,
            image_url: imageUrl || null,
            is_active: status === 'true'
        };
        
        if (isEditing && currentEditId) {
            // UPDATE existing product
            console.log(`Updating product ${currentEditId}...`);
            const { data, error } = await client
                .from('products')
                .update(productData)
                .eq('id', currentEditId)
                .select()
                .single();  // Returns the updated row

            if (error) {
                handleSupabaseError(error, 'updating product');
                throw error;
            }

            if (!data) {
                throw new Error('Product update succeeded but no data returned. Check RLS policies.');
            }

            console.log('✓ Product updated:', data);
            showNotification('Product updated successfully!', 'success');
        } else {
            // INSERT new product
            console.log('Creating new product...');
            const { data, error } = await client
                .from('products')
                .insert([productData])
                .select()
                .single();  // Returns the created row

            if (error) {
                handleSupabaseError(error, 'creating product');
                throw error;
            }

            if (!data) {
                throw new Error('Product creation succeeded but no data returned. Check RLS policies.');
            }

            console.log('✓ Product created:', data);
            showNotification('Product added successfully!', 'success');
        }
        
        closeProductModal();
        await loadProducts();
        await loadDashboardStats();
        
    } catch (error) {
        console.error('Error saving product:', error);
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error saving product: ${errorMsg}`, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

/**
 * ============================================================================
 * PRODUCT MANAGEMENT - Enhanced Delete & Edit with FK Constraint Handling
 * ============================================================================
 * 
 * These functions implement safe product deletion and editing with:
 * - Proper FK constraint handling (deletes dependent order_items first)
 * - Retry logic for transient network errors
 * - Production-ready error messages
 * - Validation and null checks
 * ============================================================================
 */

/**
 * Edit product - Load product data and open modal
 * Fetches specific product by ID (optimized with .eq() and .single())
 */
async function editProduct(id) {
    try {
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized. Check your configuration.');
        }

        // Validate product ID
        if (!id || typeof id !== 'string' && typeof id !== 'number') {
            throw new Error('Invalid product ID provided');
        }

        // Fetch specific product (optimized - don't load all products)
        const { data: product, error } = await client
            .from('products')
            .select('*')
            .eq('id', id)
            .single();  // Expects single row

        if (error) {
            if (error.code === 'PGRST116') {
                throw new Error('Product not found');
            }
            handleSupabaseError(error, 'loading product');
            throw error;
        }

        if (!product) {
            throw new Error('Product not found');
        }

        openProductModal(product);
    } catch (error) {
        console.error('Error loading product:', error);
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error loading product: ${errorMsg}`, 'error');
    }
}

/**
 * Delete product safely by removing dependent order_items first
 * Handles both CASCADE and manual deletion strategies
 * 
 * Strategy: Delete order_items → Delete product
 * Works even without CASCADE constraint (for audit trail control)
 */
async function deleteProduct(id) {
    try {
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized. Check your configuration.');
        }

        // Validate product ID
        if (!id || (typeof id !== 'string' && typeof id !== 'number')) {
            throw new Error('Invalid product ID provided');
        }

        // Step 1: Check and delete dependent order_items
        // This prevents FK constraint violation
        const { data: orderItems, error: fetchError } = await client
            .from('order_items')
            .select('id')
            .eq('product_id', id);

        if (fetchError) {
            handleSupabaseError(fetchError, 'fetching dependent order items');
            throw fetchError;
        }

        // Delete order_items if any exist
        if (orderItems && orderItems.length > 0) {
            console.log(`Found ${orderItems.length} order item(s) referencing product ${id}. Deleting them first...`);
            
            const { error: deleteItemsError } = await client
                .from('order_items')
                .delete()
                .eq('product_id', id);

            if (deleteItemsError) {
                handleSupabaseError(deleteItemsError, 'deleting dependent order items');
                throw deleteItemsError;
            }
            
            console.log(`✓ Deleted ${orderItems.length} order item(s)`);
        } else {
            console.log(`No dependent order items for product ${id}`);
        }

        // Step 2: Now safe to delete the product itself
        const { error: deleteProductError } = await client
            .from('products')
            .delete()
            .eq('id', id);

        if (deleteProductError) {
            handleSupabaseError(deleteProductError, 'deleting product');
            throw deleteProductError;
        }

        console.log(`✓ Product ${id} deleted successfully`);
    } catch (error) {
        console.error('Error deleting product:', error);
        throw error;
    }
}

/**
 * Confirm and delete product with user confirmation
 * Provides user feedback during deletion process
 */
async function deleteProductConfirm(id) {
    // User confirmation
    if (!confirm('Are you sure you want to delete this product?\n\nThis will also remove any associated orders.')) {
        return;
    }

    // Find and disable the delete button
    const deleteButton = event?.target;
    const wasDisabled = deleteButton?.disabled;
    const originalText = deleteButton?.textContent;

    if (deleteButton) {
        deleteButton.disabled = true;
        deleteButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
    }

    try {
        await deleteProduct(id);
        showNotification('Product deleted successfully!', 'success');
        await loadProducts();
        await loadDashboardStats();
    } catch (error) {
        console.error('Error deleting product:', error);
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error deleting product: ${errorMsg}`, 'error');
    } finally {
        // Restore button state
        if (deleteButton) {
            deleteButton.disabled = wasDisabled || false;
            deleteButton.innerHTML = originalText || '<i class="fas fa-trash"></i> Delete';
        }
    }
}

/**
 * Format Supabase errors into user-friendly messages
 * Detects common issues and provides actionable feedback
 */
function formatSupabaseError(error) {
    if (!error) return 'Unknown error occurred';

    // FK constraint violation (23503)
    if (error.code === '23503') {
        return 'Cannot delete: this product has associated orders. The order items should have been deleted automatically. Check your database or RLS policies.';
    }

    // RLS policy rejection
    if (error.message?.includes('RLS') || error.message?.includes('policy') || error.code === '42501') {
        return 'Permission denied by Row Level Security (RLS) policy. Check Supabase dashboard > Authentication > Policies.';
    }

    // Unique constraint violation
    if (error.code === '23505') {
        return 'This record already exists. Please check your data for duplicates.';
    }

    // Network/DNS error
    if (error.message?.includes('ERR_NAME_NOT_RESOLVED') || error.message?.includes('ENOTFOUND')) {
        return 'Network error: Cannot reach Supabase. Check your connection and verify the Supabase URL is correct.';
    }

    // Authentication error
    if (error.status === 401 || error.message?.includes('unauthorized') || error.code === '42P01') {
        return 'Unauthorized: Check your Supabase anonymous key and JWT token.';
    }

    // Generic database error
    if (error.message?.includes('permission')) {
        return 'Permission denied. Check RLS policies and authentication.';
    }

    // Return best available message
    return error.details?.message || error.message || 'Unknown error';
}

/**
 * Handle Supabase errors with detailed logging
 * Logs error details for debugging and identifies configuration issues
 */
function handleSupabaseError(error, context = '') {
    const fullContext = context ? `[${context}]` : '[Supabase Error]';
    
    console.error(`${fullContext} Supabase error:`, {
        code: error?.code,
        status: error?.status,
        message: error?.message,
        details: error?.details,
        hint: error?.hint,
        line: error?.line
    });

    // Check for common configuration issues
    if (error?.message?.includes('ERR_NAME_NOT_RESOLVED') || error?.message?.includes('ENOTFOUND')) {
        console.error('⚠️ CONFIGURATION ISSUE: Supabase URL may be invalid or CDN is blocked. Verify:');
        console.error('   1. Supabase project URL is correct (e.g., https://your-project.supabase.co)');
        console.error('   2. Network/firewall allows access to Supabase domains');
        console.error('   3. Try accessing from a different network (VPN, mobile hotspot)');
    }
    
    if (error?.status === 401 || error?.message?.includes('unauthorized')) {
        console.error('⚠️ CONFIGURATION ISSUE: Supabase anonymous key may be invalid. Verify:');
        console.error('   1. Anon key is correct from Project Settings > API Keys');
        console.error('   2. Anon key matches the Supabase URL');
        console.error('   3. Try regenerating the key in Supabase dashboard');
    }
}

// Gallery Management
async function loadGallery() {
    try {
        const gallery = await fetchGallery();
        const galleryContainer = document.getElementById('admin-gallery');
        galleryContainer.innerHTML = '';
        
        if (gallery.length === 0) {
            galleryContainer.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                    No gallery items found. Upload your first image/video!
                </div>
            `;
            return;
        }
        
        gallery.forEach(item => {
            const galleryItem = document.createElement('div');
            galleryItem.className = 'gallery-item';
            galleryItem.innerHTML = `
                ${item.image_type === 'image' 
                    ? `<img src="${item.image_url}" alt="${item.title}">`
                    : `<video><source src="${item.image_url}" type="video/mp4"></video>`
                }
                <div class="gallery-item-overlay">
                    <p>${item.title}</p>
                        <button class="btn btn-danger" onclick="deleteGalleryItemConfirm('${item.id}')">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </div>
            `;
            galleryContainer.appendChild(galleryItem);
        });
    } catch (error) {
        console.error('Error loading gallery:', error);
        showNotification('Error loading gallery', 'error');
    }
}

async function handleGalleryFileUpload(files) {
    if (!files || files.length === 0) return;
    
    const uploadProgress = document.getElementById('upload-progress');
    const progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    
    uploadProgress.style.display = 'block';
    
    try {
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const isImage = file.type.startsWith('image/');
            
            // Calculate progress
            const progress = ((i + 1) / files.length) * 100;
            progressFill.style.width = progress + '%';
            progressText.textContent = Math.round(progress) + '%';
            
            // Upload to Supabase Storage
            const url = await uploadFile(file, 'gallery');
            
            // Create gallery item in database
            await saveGalleryItem({
                title: file.name.split('.')[0],
                image_url: url,
                image_type: isImage ? 'image' : 'video'
            });
        }
        
        showNotification(`${files.length} file(s) uploaded successfully!`);
        await loadGallery();
        
    } catch (error) {
        console.error('Error uploading files:', error);
        showNotification('Error uploading files: ' + error.message, 'error');
    } finally {
        setTimeout(() => {
            uploadProgress.style.display = 'none';
            progressFill.style.width = '0%';
            progressText.textContent = '0%';
        }, 1000);
    }
}

function openGalleryModal() {
    document.getElementById('gallery-modal').style.display = 'flex';
}

function closeGalleryModal() {
    document.getElementById('gallery-modal').style.display = 'none';
    document.getElementById('gallery-form').reset();
}

async function handleGallerySubmit(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Adding...';
        submitBtn.disabled = true;
        
        const galleryData = {
            title: document.getElementById('gallery-title').value,
            image_type: document.getElementById('gallery-type').value,
            image_url: document.getElementById('gallery-url').value
        };
        
        await saveGalleryItem(galleryData);
        
        showNotification('Gallery item added successfully!');
        closeGalleryModal();
        await loadGallery();
        
    } catch (error) {
        console.error('Error adding gallery item:', error);
        showNotification('Error adding gallery item: ' + error.message, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

async function deleteGalleryItemConfirm(id) {
    if (confirm('Are you sure you want to delete this gallery item?')) {
        try {
            await deleteGalleryItem(id);
            showNotification('Gallery item deleted successfully!');
            await loadGallery();
        } catch (error) {
            console.error('Error deleting gallery item:', error);
            showNotification('Error deleting gallery item', 'error');
        }
    }
}

// Appointments Management
// Edit appointment as message
async function editAppointmentMessage(id) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');
        const { data: appointment, error } = await client.from('appointments').select('*').eq('id', id).single();
        if (error || !appointment) throw error || new Error('Appointment not found');
        // Show modal or prompt for editing message
        const newMessage = prompt('Edit appointment message:', appointment.message || '');
        if (newMessage !== null) {
            const { error: updateError } = await client.from('appointments').update({ message: newMessage }).eq('id', id);
            if (updateError) throw updateError;
            showNotification('Appointment message updated!');
            await loadAppointments();
        }
    } catch (error) {
        console.error('Error editing appointment message:', error);
        showNotification('Error editing appointment message', 'error');
    }
}
async function loadAppointments() {
    try {
        const dateInput = document.getElementById('appointment-date');
        const date = dateInput?.value || new Date().toISOString().split('T')[0];
        const status = document.getElementById('appointment-status-filter')?.value || 'all';
        
        // Set the date input if not already set
        if (dateInput && !dateInput.value) {
            dateInput.value = date;
        }
        
        const appointments = await fetchAppointments(date, status);
        const appointmentsList = document.getElementById('appointments-list');
        appointmentsList.innerHTML = '';
        
        if (appointments.length === 0) {
            appointmentsList.innerHTML = `
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        No appointments found for selected criteria.
                    </td>
                </tr>
            `;
            return;
        }
        
        appointments.forEach(appointment => {
            const row = document.createElement('tr');
            const appointmentDate = new Date(appointment.appointment_date);
            const serviceName = appointment.services?.name || 'Service not found';
            
            row.innerHTML = `
                <td>${appointment.customer_name}</td>
                <td>${serviceName}</td>
                <td>${appointmentDate.toLocaleDateString()} ${appointment.appointment_time}</td>
                <td>${appointment.customer_phone}</td>
                <td>
                    <span class="status-badge ${appointment.status}">
                        ${appointment.status}
                    </span>
                </td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn btn-success" onclick="updateAppointmentStatusConfirm('${appointment.id}', 'confirmed')" 
                                ${appointment.status === 'confirmed' || appointment.status === 'cancelled' ? 'disabled' : ''}>
                            Confirm
                        </button>
                        <button class="action-btn btn-danger" onclick="updateAppointmentStatusConfirm('${appointment.id}', 'cancelled')"
                                ${appointment.status === 'cancelled' ? 'disabled' : ''}>
                            Cancel
                        </button>
                        <button class="action-btn delete-btn" onclick="deleteAppointmentConfirm('${appointment.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;
            appointmentsList.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading appointments:', error);
        showNotification('Error loading appointments', 'error');
    }
}

// Load ALL appointments regardless of date
async function loadAllAppointments() {
    try {
        const supabase = window.supabaseClient || getClient();
        if (!supabase) {
            showNotification('Supabase not connected', 'error');
            return;
        }
        
        // Fetch all appointments
        const { data: appointments, error } = await supabase
            .from('appointments')
            .select('*, services(id, title, price)')
            .order('appointment_date', { ascending: false });
        
        if (error) {
            console.error('Error fetching all appointments:', error);
            showNotification('Error loading appointments', 'error');
            return;
        }
        
        const appointmentsList = document.getElementById('appointments-list');
        appointmentsList.innerHTML = '';
        
        if (!appointments || appointments.length === 0) {
            appointmentsList.innerHTML = `
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        No appointments found in the database.
                    </td>
                </tr>
            `;
            return;
        }
        
        console.log('✅ Loaded', appointments.length, 'total appointments');
        
        appointments.forEach(appointment => {
            const row = document.createElement('tr');
            const appointmentDate = new Date(appointment.appointment_date);
            const serviceName = appointment.services?.name || 'Service not found';
            
            row.innerHTML = `
                <td>${appointment.customer_name}</td>
                <td>${serviceName}</td>
                <td>${appointmentDate.toLocaleDateString()} ${appointment.appointment_time}</td>
                <td>${appointment.customer_phone}</td>
                <td>
                    <span class="status-badge ${appointment.status}">
                        ${appointment.status}
                    </span>
                </td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn btn-success" onclick="updateAppointmentStatusConfirm('${appointment.id}', 'confirmed')" 
                                ${appointment.status === 'confirmed' || appointment.status === 'cancelled' ? 'disabled' : ''}>
                            Confirm
                        </button>
                        <button class="action-btn btn-danger" onclick="updateAppointmentStatusConfirm('${appointment.id}', 'cancelled')"
                                ${appointment.status === 'cancelled' ? 'disabled' : ''}>
                            Cancel
                        </button>
                        <button class="action-btn delete-btn" onclick="deleteAppointmentConfirm('${appointment.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;
            appointmentsList.appendChild(row);
        });
    } catch (error) {
        console.error('Error in loadAllAppointments:', error);
        showNotification('Error loading appointments', 'error');
    }
}

async function updateAppointmentStatusConfirm(id, status) {
    if (confirm(`Are you sure you want to mark this appointment as ${status}?`)) {
        try {
            const supabase = getSupabaseClient();
            const { error } = await supabase
                .from('appointments')
                .update({ status })
                .eq('id', id);
            
            if (error) throw error;
            showNotification(`✅ Appointment marked as ${status}`, 'success');
            await loadAppointments();
            await loadDashboardStats();
        } catch (error) {
            console.error('Error updating appointment:', error);
            showNotification('❌ Error updating appointment', 'error');
        }
    }
}

async function deleteAppointmentConfirm(id) {
    if (confirm('Are you sure you want to delete this appointment?')) {
        try {
            const supabase = getSupabaseClient();
            const { error } = await supabase
                .from('appointments')
                .delete()
                .eq('id', id);
            
            if (error) throw error;
            
            showNotification('✅ Appointment deleted!', 'success');
            await loadAppointments();
            await loadDashboardStats();
        } catch (error) {
            console.error('Error deleting appointment:', error);
            showNotification('❌ Error deleting appointment', 'error');
        }
    }
}

// Settings Functions
async function loadSettings() {
    try {
        // Load business hours
        const businessHours = await getSetting('business_hours');
        if (businessHours) {
            document.getElementById('opening-time').value = businessHours.opening || '09:00';
            document.getElementById('closing-time').value = businessHours.closing || '19:00';
        }
        
        // Load contact info
        const contactInfo = await getSetting('contact_info');
        if (contactInfo) {
            document.getElementById('contact-phone').value = contactInfo.phone || '033590207';
            document.getElementById('contact-email').value = contactInfo.email || '';
            document.getElementById('contact-address').value = contactInfo.address || 'Khaireni, Gulmi, Nepal';
        }
        
        // Load admin settings
        const adminSettings = await getSetting('admin_settings');
        if (adminSettings) {
            document.getElementById('business-name').value = adminSettings.businessName || 'Nepo Online stores & Cosmetic Center';
            document.getElementById('instagram-url').value = adminSettings.instagramUrl || '';
            document.getElementById('facebook-url').value = adminSettings.facebookUrl || '';
        }
    } catch (error) {
        console.error('Error loading settings:', error);
    }
}

// Save settings to Supabase
async function saveSetting(settingKey, settingValue) {
    const client = getClient();
    if (!client) throw new Error('Supabase client not initialized');
    
    try {
        // Try to update existing setting first
        const { data: existingData, error: fetchError } = await client
            .from('admin_settings')
            .select('id')
            .eq('setting_key', settingKey)
            .single();
        
        let result;
        
        if (existingData) {
            // Update existing record
            result = await client
                .from('admin_settings')
                .update({
                    setting_value: JSON.stringify(settingValue),
                    updated_at: new Date().toISOString()
                })
                .eq('setting_key', settingKey)
                .select();
        } else {
            // Insert new record
            result = await client
                .from('admin_settings')
                .insert({
                    setting_key: settingKey,
                    setting_value: JSON.stringify(settingValue)
                })
                .select();
        }
        
        const { data, error } = result;
        if (error) throw error;
        
        if (!data || data.length === 0) {
            throw new Error('Failed to save setting - no data returned');
        }
        
        // Verify data was saved by fetching it back
        const { data: verifyData, error: verifyError } = await client
            .from('admin_settings')
            .select('setting_value')
            .eq('setting_key', settingKey)
            .single();
        
        if (verifyError) {
            throw new Error(`Failed to verify save: ${verifyError.message}`);
        }
        
        if (!verifyData) {
            throw new Error('Setting was not saved to database');
        }
        
        const savedValue = JSON.parse(verifyData.setting_value);
        
        // Verify content matches what was saved
        if (JSON.stringify(savedValue) !== JSON.stringify(settingValue)) {
            throw new Error('Saved data does not match input data - corruption detected');
        }
        
        console.log('✅ Setting saved and verified successfully:', settingKey);
        return { success: true, data };
        
    } catch (error) {
        console.error('❌ Error saving setting:', settingKey, error);
        throw error;
    }
}

async function saveContactInfo(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Saving...';
        submitBtn.disabled = true;
        
        const contactInfo = {
            phone: document.getElementById('contact-phone').value,
            email: document.getElementById('contact-email').value,
            address: document.getElementById('contact-address').value
        };
        
        // Validate inputs
        if (!contactInfo.phone?.trim()) throw new Error('Phone number is required');
        if (!contactInfo.email?.trim()) throw new Error('Email is required');
        if (!contactInfo.address?.trim()) throw new Error('Address is required');
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contactInfo.email)) throw new Error('Invalid email format');
        
        console.log('📝 Saving contact info:', contactInfo);
        await saveSetting('contact_info', contactInfo);
        
        showNotification('✅ Contact information saved successfully! Your changes are now stored.', 'success');
        console.log('✅ Contact info verified in database');
        
    } catch (error) {
        console.error('❌ Error saving contact info:', error);
        const errorMsg = error.message || error.toString();
        showNotification(`❌ Failed to save: ${errorMsg}`, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

async function saveAdminSettings(e) {
    e.preventDefault();
    
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    
    try {
        submitBtn.textContent = 'Saving...';
        submitBtn.disabled = true;
        
        const adminSettings = {
            businessName: document.getElementById('business-name').value,
            instagramUrl: document.getElementById('instagram-url').value,
            facebookUrl: document.getElementById('facebook-url').value
        };
        
        // Validate inputs
        if (!adminSettings.businessName?.trim()) throw new Error('Business name is required');
        
        // Validate URLs if provided
        if (adminSettings.instagramUrl?.trim()) {
            if (!isValidUrl(adminSettings.instagramUrl)) throw new Error('Instagram URL is invalid');
        }
        if (adminSettings.facebookUrl?.trim()) {
            if (!isValidUrl(adminSettings.facebookUrl)) throw new Error('Facebook URL is invalid');
        }
        
        console.log('📝 Saving admin settings:', adminSettings);
        await saveSetting('admin_settings', adminSettings);
        
        showNotification('✅ Settings saved successfully! Your changes are now stored.', 'success');
        console.log('✅ Admin settings verified in database');
        
    } catch (error) {
        console.error('❌ Error saving settings:', error);
        const errorMsg = error.message || error.toString();
        showNotification(`❌ Failed to save: ${errorMsg}`, 'error');
    } finally {
        submitBtn.textContent = originalText;
        submitBtn.disabled = false;
    }
}

// Show notification
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <span>${message}</span>
        <button onclick="this.parentElement.remove()">&times;</button>
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 300);
    }, 5000);
}

// Add to admin.css:
// .notification {
//     position: fixed;
//     top: 20px;
//     right: 20px;
//     padding: 15px 20px;
//     border-radius: 5px;
//     color: white;
//     z-index: 10000;
//     transform: translateX(100%);
//     transition: transform 0.3s ease;
// }
// .notification.show { transform: translateX(0); }
// .notification.success { background: #28a745; }
// .notification.error { background: #dc3545; }

// ============================================================
// ORDERS MANAGEMENT
// ============================================================

// Fetch orders from Supabase
async function fetchOrders(statusFilter = '') {
    try {
        const client = getClient();
        if (!client) return [];

        let query = client.from('orders').select('*');
        
        if (statusFilter) {
            query = query.eq('status', statusFilter);
        }
        
        const { data, error } = await query.order('created_at', { ascending: false });
        
        if (error) {
            console.error('Error fetching orders:', error);
            return [];
        }
        
        return data || [];
    } catch (error) {
        console.error('Error in fetchOrders:', error);
        return [];
    }
}

// Fetch order items
async function fetchOrderItems(orderId) {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('order_items')
            .select('*')
            .eq('order_id', orderId);
        
        if (error) {
            console.error('Error fetching order items:', error);
            return [];
        }
        
        return data || [];
    } catch (error) {
        console.error('Error in fetchOrderItems:', error);
        return [];
    }
}

// Load orders into table
async function loadOrders(statusFilter = '') {
    try {
        const orders = statusFilter 
            ? await fetchOrders(statusFilter) 
            : await fetchOrders();
        
        const ordersList = document.getElementById('orders-list');
        if (!ordersList) return;
        
        ordersList.innerHTML = '';
        
        if (orders.length === 0) {
            ordersList.innerHTML = `
                <tr>
                    <td colspan="8" style="text-align: center; padding: 40px; color: #999;">
                        No orders found.
                    </td>
                </tr>
            `;
            return;
        }
        
        orders.forEach(order => {
            const row = document.createElement('tr');
            const orderDate = new Date(order.created_at).toLocaleDateString('en-IN');
            const statusBadgeClass = {
                'pending_verification': 'pending',
                'verified': 'processing',
                'confirmed': 'confirmed',
                'processing': 'processing',
                'ready_for_delivery': 'processing',
                'shipped': 'processing',
                'delivered': 'confirmed',
                'cancelled': 'cancelled'
            }[order.status] || 'pending';
            
            const statusLabel = order.status
                .split('_')
                .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                .join(' ');
            
            row.innerHTML = `
                <td><strong>${order.order_number || 'N/A'}</strong></td>
                <td>${order.customer_name || 'N/A'}</td>
                <td>${order.customer_email || 'N/A'}</td>
                <td>${order.customer_phone || 'N/A'}</td>
                <td>Rs. ${(order.total_amount || 0).toFixed(2)}</td>
                <td>
                    <span class="status-badge ${statusBadgeClass}">
                        ${statusLabel}
                    </span>
                </td>
                <td>${orderDate}</td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit-btn" onclick="viewOrderDetails(${order.id})" style="padding: 5px 10px; margin-right: 5px;">
                            <i class="fas fa-eye"></i> View
                        </button>
                        <button class="action-btn edit-btn" onclick="openUpdateStatusModal(${order.id}, '${order.status}')" style="padding: 5px 10px; margin-right: 5px;">
                            <i class="fas fa-sync"></i> Update
                        </button>
                        <button class="action-btn delete-btn" onclick="confirmDeleteOrder(${order.id})" style="padding: 5px 10px;">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </div>
                </td>
            `;
            ordersList.appendChild(row);
        });
    } catch (error) {
        console.error('Error loading orders:', error);
        showNotification('Error loading orders', 'error');
    }
}

// Filter orders by status
function filterOrders() {
    const filterSelect = document.getElementById('orders-filter');
    const status = filterSelect ? filterSelect.value : '';
    loadOrders(status);
}

// View order details in modal
async function viewOrderDetails(orderId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        // Fetch order
        const { data: order, error: orderError } = await client
            .from('orders')
            .select('*')
            .eq('id', orderId)
            .single();
        
        if (orderError) throw orderError;
        if (!order) {
            showNotification('Order not found', 'error');
            return;
        }
        
        // Debug logging
        console.log('Order data loaded:', order);
        console.log('Transaction screenshot URL:', order.transaction_screenshot);
        
        // Fetch order items
        const { data: items, error: itemsError } = await client
            .from('order_items')
            .select('*')
            .eq('order_id', orderId);
        
        if (itemsError) console.warn('Error fetching items:', itemsError);
        
        const modal = document.getElementById('order-details-modal');
        const content = document.getElementById('order-details-content');
        
        if (!modal || !content) {
            showNotification('Modal not found', 'error');
            return;
        }
        
        const orderDate = new Date(order.created_at).toLocaleDateString('en-IN');
        const statusLabel = order.status
            .split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
        
        let itemsHTML = '';
        if (items && items.length > 0) {
            items.forEach(item => {
                itemsHTML += `
                    <tr>
                        <td>${item.product_name || 'N/A'}</td>
                        <td>${item.quantity || 0}</td>
                        <td>Rs. ${(item.price || 0).toFixed(2)}</td>
                        <td>Rs. ${(item.quantity * item.price || 0).toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            itemsHTML = '<tr><td colspan="4" style="text-align: center;">No items in this order</td></tr>';
        }
        
        // Build transaction proof HTML
        let transactionProofHTML = '';
        if (order.transaction_code || order.transaction_screenshot) {
            // Escape URL for safe embedding in onclick
            const screenshotUrl = order.transaction_screenshot ? order.transaction_screenshot.replace(/'/g, "\\'") : '';
            
            console.log('Transaction details:', {
                code: order.transaction_code,
                screenshot: order.transaction_screenshot,
                notes: order.transaction_notes
            });
            
            transactionProofHTML = `
                <div style="background: linear-gradient(135deg, #fff9e6 0%, #ffe8cc 100%); padding: 20px; border-radius: 8px; margin: 20px 0; border: 2px solid #ff9800; box-shadow: 0 4px 12px rgba(255, 152, 0, 0.15);">
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                        <i class="fas fa-receipt" style="font-size: 24px; color: #ff6f00;"></i>
                        <h3 style="margin: 0; color: #333; font-size: 18px;">Transaction Proof & Verification</h3>
                    </div>
                    
                    <div style="display: grid; gap: 15px;">
                        ${order.transaction_code ? `
                            <div style="background: white; padding: 12px 15px; border-radius: 6px; border-left: 4px solid #ff9800;">
                                <p style="margin: 0 0 5px 0; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 600;">Transaction Code</p>
                                <p style="margin: 0; font-family: 'Courier New', monospace; font-size: 16px; font-weight: bold; color: #1a1a2e; background: #f5f5f5; padding: 10px; border-radius: 4px; word-break: break-all;">
                                    ${order.transaction_code}
                                    <button onclick="window.copyToClipboard('${order.transaction_code.replace(/'/g, "\\'")}')" style="margin-left: 10px; background: #ff9800; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; font-size: 12px; transition: all 0.3s ease;" onmouseover="this.style.background='#ff7f00'" onmouseout="this.style.background='#ff9800'">
                                        <i class="fas fa-copy"></i> Copy
                                    </button>
                                </p>
                            </div>
                        ` : ''}
                        
                        ${order.transaction_notes ? `
                            <div style="background: white; padding: 12px 15px; border-radius: 6px; border-left: 4px solid #4CAF50;">
                                <p style="margin: 0 0 5px 0; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 600;">Transaction Notes</p>
                                <p style="margin: 0; color: #333; line-height: 1.5;">${order.transaction_notes}</p>
                            </div>
                        ` : ''}
                        
                        ${order.transaction_screenshot && order.transaction_screenshot.trim() !== '' ? `
                            <div style="background: white; padding: 15px; border-radius: 6px; border: 2px dashed #ff9800;">
                                <p style="margin: 0 0 10px 0; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 600;">
                                    <i class="fas fa-image"></i> Payment Screenshot/Proof
                                </p>
                                <div style="position: relative; border-radius: 6px; overflow: hidden; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); padding: 10px; margin-bottom: 10px; min-height: 100px; display: flex; align-items: center; justify-content: center;">
                                    <img src="${order.transaction_screenshot}" alt="Transaction Screenshot" style="max-width: 100%; max-height: 300px; width: 100%; border-radius: 4px; display: block; cursor: pointer; transition: transform 0.3s ease; object-fit: contain;" onclick="window.openScreenshotModalAdmin('${screenshotUrl}')" onmouseover="this.style.transform='scale(1.02)'" onmouseout="this.style.transform='scale(1)'" onerror="this.parentElement.innerHTML='<div style=\"color: #d32f2f; text-align: center;\"><i class=\"fas fa-exclamation-circle\"></i><p>Failed to load image</p></div>'">
                                </div>
                                <button onclick="window.openScreenshotModalAdmin('${screenshotUrl}')" style="width: 100%; background: linear-gradient(135deg, #ff9800 0%, #ff6f00 100%); color: white; border: none; padding: 12px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all 0.3s ease;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 20px rgba(255, 152, 0, 0.3)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none'">
                                    <i class="fas fa-search-plus"></i> View Full Screenshot
                                </button>
                            </div>
                        ` : !order.transaction_screenshot ? `
                            <div style="background: #fff3cd; padding: 15px; border-radius: 6px; border-left: 4px solid #ffc107; text-align: center;">
                                <p style="margin: 0; color: #856404;"><i class="fas fa-exclamation-triangle"></i> No screenshot uploaded yet</p>
                            </div>
                        ` : ''}
                    </div>
                </div>
            `;
        }
        
        // Helper function to copy to clipboard
        window.copyToClipboard = function(text) {
            const textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
            showNotification('Transaction code copied to clipboard!', 'success');
        };
        
        // Helper function for opening screenshot modal
        window.openScreenshotModalAdmin = function(screenshotUrl) {
            // Unescape the URL
            const unescapedUrl = screenshotUrl.replace(/\\'/g, "'");
            openScreenshotModal(unescapedUrl);
        };

        
        // Build delivery address HTML
        let deliveryAddressHTML = '';
        if (order.street_address || order.city) {
            const fullAddress = `${order.street_address || ''}, ${order.city || ''}, ${order.state || ''} ${order.postal_code || ''}`;
            deliveryAddressHTML = `
                <div style="background: #e8f4f8; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #2196F3;">
                    <h4 style="margin: 0 0 10px 0; color: #333;"><i class="fas fa-map-marker-alt"></i> Delivery Address</h4>
                    <p style="margin: 0 0 5px 0;"><strong>${order.street_address || 'N/A'}</strong></p>
                    <p style="margin: 0 0 10px 0;">${order.city || 'N/A'}, ${order.state || 'N/A'} ${order.postal_code || ''}</p>
                    ${order.delivery_instructions ? `<p style="margin: 0 0 10px 0;"><strong>Special Instructions:</strong><br>${order.delivery_instructions}</p>` : ''}
                    <button onclick="viewAddressOnMap('${fullAddress.replace(/'/g, "\\'")}', '${order.customer_name || 'Customer'}')" style="background: #2196F3; color: white; border: none; padding: 8px 15px; border-radius: 5px; cursor: pointer; font-size: 14px;">
                        <i class="fas fa-map"></i> View on Map
                    </button>
                </div>
            `;
        }
        
        content.innerHTML = `
            <div style="padding: 20px;">
                <!-- Customer Info Section -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                    <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; border-left: 4px solid #4CAF50;">
                        <h4 style="margin: 0 0 10px 0; color: #333;"><i class="fas fa-user"></i> Customer Information</h4>
                        <p style="margin: 5px 0;"><strong>Name:</strong> ${order.customer_name || 'N/A'}</p>
                        <p style="margin: 5px 0;"><strong>Email:</strong> <a href="mailto:${order.customer_email}" style="color: #2196F3;">${order.customer_email || 'N/A'}</a></p>
                        <p style="margin: 5px 0;"><strong>Phone:</strong> <a href="tel:${order.customer_phone}" style="color: #2196F3;">${order.customer_phone || 'N/A'}</a></p>
                    </div>
                    <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; border-left: 4px solid #2196F3;">
                        <h4 style="margin: 0 0 10px 0; color: #333;"><i class="fas fa-info-circle"></i> Order Information</h4>
                        <p style="margin: 5px 0;"><strong>Order #:</strong> <code>${order.order_number || 'N/A'}</code></p>
                        <p style="margin: 5px 0;"><strong>Status:</strong> <span class="status-badge confirmed">${statusLabel}</span></p>
                        <p style="margin: 5px 0;"><strong>Order Date:</strong> ${orderDate}</p>
                        <p style="margin: 5px 0;"><strong>Amount:</strong> <span style="color: #4CAF50; font-weight: bold; font-size: 16px;">Rs. ${(order.total_amount || 0).toFixed(2)}</span></p>
                    </div>
                </div>
                
                <!-- Delivery Address -->
                ${deliveryAddressHTML}
                
                <!-- Transaction Proof -->
                ${transactionProofHTML}
                
                <!-- Order Items -->
                <h4 style="margin: 20px 0 10px 0; color: #333;"><i class="fas fa-shopping-cart"></i> Order Items</h4>
                <div style="border: 1px solid #ddd; border-radius: 5px; overflow: hidden;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8f9fa; border-bottom: 2px solid #ddd;">
                                <th style="padding: 12px; text-align: left;">Product</th>
                                <th style="padding: 12px; text-align: center;">Quantity</th>
                                <th style="padding: 12px; text-align: right;">Price</th>
                                <th style="padding: 12px; text-align: right;">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${itemsHTML}
                        </tbody>
                    </table>
                </div>
                
                <!-- Total Section -->
                <div style="background: #2196F3; color: white; padding: 15px; border-radius: 5px; text-align: right; margin: 20px 0;">
                    <p style="margin: 0; font-size: 14px;">Total Amount</p>
                    <h3 style="margin: 5px 0 0 0;">Rs. ${(order.total_amount || 0).toFixed(2)}</h3>
                </div>
                
                <!-- Payment Method -->
                ${order.payment_method ? `
                    <div style="background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #4CAF50;">
                        <p style="margin: 0;"><strong>Payment Method:</strong> ${order.payment_method}</p>
                    </div>
                ` : ''}
                
                <!-- Admin Notes -->
                ${order.admin_notes ? `
                    <div style="background: #fff3cd; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #ff9800;">
                        <h4 style="margin: 0 0 10px 0; color: #333;"><i class="fas fa-sticky-note"></i> Admin Notes</h4>
                        <p style="margin: 0;">${order.admin_notes}</p>
                    </div>
                ` : ''}
                
                <!-- Confirmed By Admin -->
                ${order.confirmed_by_admin ? `
                    <div style="background: #c8e6c9; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #4CAF50;">
                        <p style="margin: 0;"><strong><i class="fas fa-check-circle"></i> Confirmed by Admin</strong> on ${new Date(order.confirmed_at).toLocaleDateString('en-IN')}</p>
                    </div>
                ` : ''}
                
                <!-- Action Buttons -->
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; display: flex; gap: 10px;">
                    <button onclick="openUpdateStatusModal(${order.id}, '${order.status}')" class="action-btn edit-btn" style="flex: 1;">
                        <i class="fas fa-sync"></i> Update Status
                    </button>
                    <button onclick="closeOrderDetailsModal()" class="action-btn" style="background: #999; flex: 1;">
                        <i class="fas fa-times"></i> Close
                    </button>
                </div>
            </div>
        `;
        
        modal.style.display = 'block';
    } catch (error) {
        console.error('Error viewing order details:', error);
        showNotification('Error loading order details: ' + error.message, 'error');
    }
}

// Close order details modal
function closeOrderDetailsModal() {
    const modal = document.getElementById('order-details-modal');
    if (modal) modal.style.display = 'none';
}

// Open status update modal
function openUpdateStatusModal(orderId, currentStatus) {
    const statusOptions = [
        { value: 'pending_verification', label: 'Pending Verification' },
        { value: 'verified', label: 'Verified' },
        { value: 'confirmed', label: 'Confirmed' },
        { value: 'processing', label: 'Processing' },
        { value: 'ready_for_delivery', label: 'Ready for Delivery' },
        { value: 'shipped', label: 'Shipped' },
        { value: 'delivered', label: 'Delivered' },
        { value: 'cancelled', label: 'Cancelled' }
    ];
    
    const modal = document.createElement('div');
    modal.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 10000;';
    modal.id = 'status-update-modal';
    
    let statusOptionsHTML = '';
    statusOptions.forEach(option => {
        statusOptionsHTML += `<option value="${option.value}" ${option.value === currentStatus ? 'selected' : ''}>${option.label}</option>`;
    });
    
    modal.innerHTML = `
        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); max-width: 400px; width: 90%;">
            <h3 style="margin-top: 0;">Update Order Status</h3>
            <label style="display: block; margin: 15px 0 5px 0;">New Status</label>
            <select id="new-status-select" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px;">
                ${statusOptionsHTML}
            </select>
            
            <label style="display: block; margin: 15px 0 5px 0;">Admin Notes</label>
            <textarea id="admin-notes-textarea" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; min-height: 100px; resize: vertical;"></textarea>
            
            <div style="margin-top: 20px; text-align: right;">
                <button onclick="document.getElementById('status-update-modal').remove()" class="action-btn" style="background: #999; margin-right: 10px;">Cancel</button>
                <button onclick="submitStatusUpdate(${orderId})" class="action-btn edit-btn">Update Status</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
}

// Submit status update
async function submitStatusUpdate(orderId) {
    try {
        const newStatus = document.getElementById('new-status-select').value;
        const adminNotes = document.getElementById('admin-notes-textarea').value;
        
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        // First, fetch the order to get customer email
        const { data: orderData, error: fetchError } = await client
            .from('orders')
            .select('*')
            .eq('id', orderId)
            .single();
        
        if (fetchError) throw fetchError;

        const { error } = await client
            .from('orders')
            .update({
                status: newStatus,
                admin_notes: adminNotes,
                confirmed_by_admin: true,
                updated_at: new Date().toISOString()
            })
            .eq('id', orderId);
        
        if (error) throw error;
        
        // Send email to customer about order status update
        console.log('📧 Sending order update email to customer');
        if (typeof sendOrderUpdateEmail === 'function' && orderData) {
            await sendOrderUpdateEmail(orderData, newStatus);
        }
        
        // Remove modal
        const modal = document.getElementById('status-update-modal');
        if (modal) modal.remove();
        
        showNotification('Order status updated successfully and customer notified', 'success');
        closeOrderDetailsModal();
        await loadOrders();
    } catch (error) {
        console.error('Error updating order status:', error);
        showNotification('Error updating order status: ' + error.message, 'error');
    }
}

// View address on map
function viewAddressOnMap(street, city, state, postalCode) {
    const address = `${street}, ${city}, ${state} ${postalCode}`;
    const mapUrl = `https://www.google.com/maps/search/${encodeURIComponent(address)}`;
    window.open(mapUrl, '_blank');
}

// Confirm delete order
async function confirmDeleteOrder(orderId) {
    if (confirm('Are you sure you want to delete this order? This action cannot be undone.')) {
        try {
            const client = getClient();
            if (!client) throw new Error('Supabase client not initialized');

            // Delete order items first
            await client.from('order_items').delete().eq('order_id', orderId);
            
            // Delete order
            const { error } = await client
                .from('orders')
                .delete()
                .eq('id', orderId);
            
            if (error) throw error;
            
            showNotification('Order deleted successfully', 'success');
            await loadOrders();
        } catch (error) {
            console.error('Error deleting order:', error);
            showNotification('Error deleting order: ' + error.message, 'error');
        }
    }
}

// ============================================================
// HOME VIDEO MANAGEMENT
// ============================================================

async function loadHomeVideo() {
    try {
        const client = getClient();
        if (!client) return;
        const { data, error } = await client.from('home_video').select('*').eq('is_active', true).single();
        if (error) {
            if (error.code === 'PGRST116') {
                console.log('No home video set yet');
            } else {
                console.error('Error loading video:', error);
            }
            return;
        }
        if (data) {
            displayHomeVideo(data);
        }
    } catch (error) {
        console.error('Error loading home video:', error);
    }
}

function displayHomeVideo(videoData) {
    const container = document.getElementById('current-video-container');
    
    if (videoData.video_url.includes('youtube.com') || videoData.video_url.includes('youtu.be')) {
        // YouTube embed
        const videoId = videoData.video_url.includes('youtu.be') 
            ? videoData.video_url.split('youtu.be/')[1] 
            : videoData.video_url.split('v=')[1];
        
        container.innerHTML = `
            <div style="text-align: center;">
                <h4 style="margin-bottom: 15px;">${videoData.title || 'Home Video'}</h4>
                <iframe width="100%" height="300" 
                    src="https://www.youtube.com/embed/${videoId}" 
                    frameborder="0" allowfullscreen style="border-radius: 8px;"></iframe>
            </div>
        `;
    } else {
        // Direct video file
        container.innerHTML = `
            <div style="text-align: center;">
                <h4 style="margin-bottom: 15px;">${videoData.title || 'Home Video'}</h4>
                <video width="100%" height="300" controls style="border-radius: 8px;">
                    <source src="${videoData.video_url}" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div>
        `;
    }
}

async function saveHomeVideo() {
    try {
        const videoUrl = document.getElementById('video-url').value.trim();
        const videoFile = document.getElementById('video-file').files[0];
        const statusDiv = document.getElementById('video-upload-status');

        // Validate input - must have either URL or file
        if (!videoUrl && !videoFile) {
            alert('❌ Please enter a video URL or upload a file');
            return;
        }

        // Show loading
        statusDiv.style.display = 'block';
        statusDiv.style.background = '#cce5ff';
        statusDiv.style.color = '#004085';
        statusDiv.textContent = '⏳ Processing video...';

        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        let finalVideoUrl = videoUrl;

        // If file is provided, upload it
        if (videoFile) {
            console.log('Uploading video file:', videoFile.name);
            statusDiv.textContent = '⏳ Uploading file...';

            // Validate file type
            const validTypes = ['video/mp4', 'video/webm', 'video/ogg'];
            if (!validTypes.includes(videoFile.type)) {
                throw new Error('Invalid file type. Please upload MP4, WebM, or OGG');
            }

            // Upload to storage
            const fileName = `hero-video-${Date.now()}.mp4`;
            const { data, error: uploadError } = await client
                .storage
                .from('videos')
                .upload(`hero/${fileName}`, videoFile);

            if (uploadError) {
                throw new Error('Upload failed: ' + uploadError.message);
            }

            // Get public URL
            const { data: publicData } = await client
                .storage
                .from('videos')
                .getPublicUrl(`hero/${fileName}`);

            finalVideoUrl = publicData.publicUrl;
            console.log('File uploaded, URL:', finalVideoUrl);
        } else {
            // Validate URL format
            if (!finalVideoUrl.startsWith('https://')) {
                throw new Error('Video URL must start with https://');
            }
            console.log('Using provided URL:', finalVideoUrl);
        }

        statusDiv.textContent = '⏳ Saving to database...';

        // Save to settings table
        const { error: updateError } = await client
            .from('settings')
            .update({ 
                hero_video_url: finalVideoUrl,
                updated_at: new Date().toISOString()
            })
            .eq('key', 'hero_video');

        if (updateError) {
            console.log('Update failed (row might not exist):', updateError.message);
            
            // Try insert if update failed
            const { error: insertError } = await client
                .from('settings')
                .insert({
                    key: 'hero_video',
                    hero_video_url: finalVideoUrl,
                    description: 'Hero section background video'
                });

            if (insertError) {
                throw insertError;
            }
        }

        // Verify it was saved
        const { data: verifyData } = await client
            .from('settings')
            .select('hero_video_url')
            .eq('key', 'hero_video');

        console.log('Verified saved URL:', verifyData);

        // Success message
        statusDiv.style.background = '#d4edda';
        statusDiv.style.color = '#155724';
        statusDiv.textContent = '✅ Video saved successfully!';
        
        // Clear form
        setTimeout(() => {
            document.getElementById('video-url').value = '';
            document.getElementById('video-file').value = '';
            statusDiv.textContent = '✅ Complete! Refresh home page (Ctrl+F5) to see your video.';
            
            setTimeout(() => {
                statusDiv.style.display = 'none';
            }, 4000);
        }, 1000);

    } catch (error) {
        console.error('Error saving video:', error);
        const statusDiv = document.getElementById('video-upload-status');
        statusDiv.style.display = 'block';
        statusDiv.style.background = '#f8d7da';
        statusDiv.style.color = '#721c24';
        statusDiv.textContent = '❌ Error: ' + (error.message || 'Unknown error');
        statusDiv.style.padding = '15px';
        statusDiv.style.borderRadius = '8px';
        statusDiv.style.marginTop = '15px';
    }
}

async function deleteHomeVideo() {
    if (!confirm('Are you sure you want to delete this video?')) return;

    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        const { error } = await client
            .from('home_video')
            .delete()
            .eq('is_active', true);

        if (error) throw error;

        document.getElementById('current-video-container').innerHTML = '<p style="color: #999;">No video uploaded yet</p>';
        showNotification('Video deleted successfully', 'success');
    } catch (error) {
        console.error('Error deleting video:', error);
        showNotification('Error deleting video', 'error');
    }
}

// ============================================================
// PAYMENT CONFIGURATION
// ============================================================

async function loadPaymentConfiguration() {
    try {
        const client = getClient();
        if (!client) return;

        const { data, error } = await client
            .from('payment_configuration')
            .select('*')
            .eq('is_active', true)
            .single();

        if (error) {
            if (error.code === 'PGRST116') {
                console.log('No payment configuration set yet');
            } else {
                console.error('Error loading payment config:', error);
            }
            return;
        }

        if (data) {
            document.getElementById('esewa-number').value = data.esewa_number || '';
            document.getElementById('esewa-name').value = data.esewa_name || '';
            document.getElementById('esewa-status').value = data.esewa_active ? 'true' : 'false';

            document.getElementById('khalti-number').value = data.khalti_number || '';
            document.getElementById('khalti-name').value = data.khalti_name || '';
            document.getElementById('khalti-status').value = data.khalti_active ? 'true' : 'false';

            document.getElementById('bank-name').value = data.bank_name || '';
            document.getElementById('bank-account').value = data.bank_account || '';
            document.getElementById('bank-holder').value = data.bank_holder || '';
            document.getElementById('bank-code').value = data.bank_code || '';
            document.getElementById('bank-status').value = data.bank_active ? 'true' : 'false';
        }
    } catch (error) {
        console.error('Error loading payment configuration:', error);
    }
}

async function savePaymentConfig(type) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        let configData = {};

        if (type === 'esewa') {
            configData = {
                esewa_number: document.getElementById('esewa-number').value,
                esewa_name: document.getElementById('esewa-name').value,
                esewa_active: document.getElementById('esewa-status').value === 'true'
            };
        } else if (type === 'khalti') {
            configData = {
                khalti_number: document.getElementById('khalti-number').value,
                khalti_name: document.getElementById('khalti-name').value,
                khalti_active: document.getElementById('khalti-status').value === 'true'
            };
        } else if (type === 'bank') {
            configData = {
                bank_name: document.getElementById('bank-name').value,
                bank_account: document.getElementById('bank-account').value,
                bank_holder: document.getElementById('bank-holder').value,
                bank_code: document.getElementById('bank-code').value,
                bank_active: document.getElementById('bank-status').value === 'true'
            };
        }

        // Check if config exists
        const { data: existingConfig, error: queryError } = await client
            .from('payment_configuration')
            .select('id')
            .eq('is_active', true)
            .single();

        configData.is_active = true;
        configData.updated_at = new Date().toISOString();

        if (existingConfig) {
            // Update existing
            const { error: updateError } = await client
                .from('payment_configuration')
                .update(configData)
                .eq('id', existingConfig.id);

            if (updateError) throw updateError;
        } else {
            // Insert new
            configData.created_at = new Date().toISOString();
            const { error: insertError } = await client
                .from('payment_configuration')
                .insert([configData]);

            if (insertError) throw insertError;
        }

        showNotification(`${type.charAt(0).toUpperCase() + type.slice(1)} payment details saved successfully`, 'success');
    } catch (error) {
        console.error('Error saving payment config:', error);
        showNotification(`Error saving payment details: ${error.message}`, 'error');
    }
}

// View Order Address on Google Maps
function viewAddressOnMap(address, customerName) {
    const mapModal = document.getElementById('map-modal');
    if (!mapModal) {
        showNotification('Map modal not found', 'error');
        return;
    }
    
    const mapFrame = document.getElementById('address-map-iframe');
    if (!mapFrame) {
        showNotification('Map frame not found', 'error');
        return;
    }
    
    // Create Google Maps embed URL
    const encodedAddress = encodeURIComponent(address.trim());
    const googleMapsUrl = `https://www.google.com/maps/embed/v1/place?key=AIzaSyDx_6AWkiNv4wWNjvvfddA4sHhk8p5B64g&q=${encodedAddress}`;
    
    mapFrame.src = googleMapsUrl;
    mapModal.style.display = 'block';
}

// Close Map Modal
function closeMapModal() {
    const mapModal = document.getElementById('map-modal');
    if (mapModal) {
        mapModal.style.display = 'none';
    }
}

// Open Screenshot Modal for Larger View
function openScreenshotModal(screenshotUrl) {
    // Debug logging
    console.log('Opening screenshot modal with URL:', screenshotUrl);
    
    if (!screenshotUrl || screenshotUrl.trim() === '') {
        showNotification('Screenshot URL is empty', 'error');
        return;
    }
    
    const screenshotModal = document.createElement('div');
    screenshotModal.id = 'screenshot-modal';
    screenshotModal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.85);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        padding: 20px;
        backdrop-filter: blur(4px);
        animation: fadeIn 0.3s ease;
    `;
    
    screenshotModal.innerHTML = `
        <style>
            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }
            @keyframes slideUp {
                from { transform: translateY(50px); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }
            #screenshot-container {
                animation: slideUp 0.4s ease;
            }
            .screenshot-loading {
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 300px;
                color: #999;
            }
            .screenshot-img {
                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
                border-radius: 8px;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            }
            .screenshot-error {
                color: #d32f2f;
                padding: 20px;
                text-align: center;
                background: #ffebee;
            }
        </style>
        <div id="screenshot-container" style="
            position: relative;
            max-width: 95%;
            max-height: 90vh;
            background: white;
            border-radius: 12px;
            overflow: auto;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
            display: flex;
            flex-direction: column;
        ">
            <!-- Header -->
            <div style="
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 3px solid #ff9800;
            ">
                <div>
                    <h2 style="margin: 0; font-size: 20px; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-receipt"></i> Transaction Proof Screenshot
                    </h2>
                    <p style="margin: 5px 0 0 0; opacity: 0.9; font-size: 13px;">View payment verification</p>
                </div>
                <button onclick="document.getElementById('screenshot-modal').remove()" style="
                    background: rgba(255, 255, 255, 0.2);
                    color: white;
                    border: 2px solid white;
                    width: 45px;
                    height: 45px;
                    border-radius: 50%;
                    font-size: 28px;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                " onmouseover="this.style.background='rgba(255, 255, 255, 0.3); this.style.transform='scale(1.1)'" onmouseout="this.style.background='rgba(255, 255, 255, 0.2); this.style.transform='scale(1)'">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <!-- Image Container -->
            <div id="image-container" style="
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                padding: 30px;
                overflow: auto;
            ">
                <div class="screenshot-loading">
                    <span><i class="fas fa-spinner" style="animation: spin 1s linear infinite; display: inline-block;"></i> Loading image...</span>
                </div>
            </div>
            
            <!-- Footer with Actions -->
            <div style="
                background: #f8f9fa;
                padding: 15px 20px;
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                border-top: 1px solid #e0e0e0;
            ">
                <a href="${screenshotUrl}" download="transaction-proof.jpg" style="
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 6px;
                    cursor: pointer;
                    font-size: 14px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    text-decoration: none;
                    transition: all 0.3s ease;
                " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 5px 15px rgba(102, 126, 234, 0.3)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none'">
                    <i class="fas fa-download"></i> Download
                </a>
                <button onclick="document.getElementById('screenshot-modal').remove()" style="
                    background: #6c757d;
                    color: white;
                    border: none;
                    padding: 10px 20px;
                    border-radius: 6px;
                    cursor: pointer;
                    font-size: 14px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    transition: all 0.3s ease;
                " onmouseover="this.style.background='#5a6268'; this.style.transform='translateY(-2px)'" onmouseout="this.style.background='#6c757d'; this.style.transform='translateY(0)'">
                    <i class="fas fa-times"></i> Close
                </button>
            </div>
        </div>
        <style>
            @keyframes spin {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }
        </style>
    `;
    
    // Close when clicking outside the modal
    screenshotModal.addEventListener('click', function(e) {
        if (e.target === this) {
            this.remove();
        }
    });
    
    document.body.appendChild(screenshotModal);
    
    // Load the image
    const img = new Image();
    img.onload = function() {
        console.log('Image loaded successfully');
        const container = document.getElementById('image-container');
        if (container) {
            container.innerHTML = `<img src="${screenshotUrl}" alt="Transaction Screenshot" class="screenshot-img" style="transition: transform 0.3s ease; cursor: zoom-in;" onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">`;
        }
    };
    img.onerror = function() {
        console.error('Failed to load image:', screenshotUrl);
        const container = document.getElementById('image-container');
        if (container) {
            container.innerHTML = `<div class="screenshot-error"><i class="fas fa-exclamation-triangle"></i><p>Failed to load image</p><p style="font-size: 12px; color: #999;">URL: ${screenshotUrl}</p></div>`;
        }
    };
    img.src = screenshotUrl;
}

// =====================================================
// REVIEW MANAGEMENT FUNCTIONS
// =====================================================

let allReviews = [];
let currentReviewFilter = 'all';

// Load and display reviews
async function loadAdminReviews() {
    try {
        console.log('Loading reviews for admin...');
        
        // Get all reviews (pending, approved, rejected)
        const pending = await fetchAllReviews('pending');
        const approved = await fetchAllReviews('approved');
        const rejected = await fetchAllReviews('rejected');

        allReviews = [
            ...(pending || []),
            ...(approved || []),
            ...(rejected || [])
        ];

        console.log('Total reviews loaded:', allReviews.length);

        // Update stats
        const totalElement = document.getElementById('totalCount');
        const pendingElement = document.getElementById('pendingCount');
        const approvedElement = document.getElementById('approvedCount');
        const rejectedElement = document.getElementById('rejectedCount');
        
        if (totalElement) totalElement.textContent = allReviews.length;
        if (pendingElement) pendingElement.textContent = pending?.length || 0;
        if (approvedElement) approvedElement.textContent = approved?.length || 0;
        if (rejectedElement) rejectedElement.textContent = rejected?.length || 0;

        // Display reviews
        displayReviewsAdmin(allReviews);
    } catch (error) {
        console.error('Error loading reviews:', error);
        const reviewsList = document.getElementById('reviews-list');
        if (reviewsList) {
            reviewsList.innerHTML = `
                <tr><td colspan="7" style="text-align: center; color: #dc3545; padding: 30px;">
                    <i class="fas fa-exclamation-circle"></i> Error loading reviews: ${error.message}
                </td></tr>
            `;
        }
        showNotification('Error loading reviews: ' + error.message, 'error');
    }
}

// Display reviews in table
function displayReviewsAdmin(reviews) {
    if (!reviews || reviews.length === 0) {
        document.getElementById('reviews-list').innerHTML = `
            <tr><td colspan="7" style="text-align: center; color: #999; padding: 30px;">No reviews found.</td></tr>
        `;
        return;
    }

    const html = reviews.map(review => `
        <tr>
            <td><span style="color: #ffc107; font-size: 16px;">${'★'.repeat(review.rating)}${'☆'.repeat(5 - review.rating)}</span></td>
            <td>
                <strong>${escapeHtml(review.review_title || 'No Title')}</strong><br>
                <small style="color: #666;">${escapeHtml(review.review_text.substring(0, 50))}${review.review_text.length > 50 ? '...' : ''}</small>
            </td>
            <td>${escapeHtml(review.customer_name)}<br><small>${escapeHtml(review.customer_email)}</small></td>
            <td>#${review.product_id}</td>
            <td>
                <span style="display: inline-block; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; 
                    background: ${review.status === 'pending' ? '#fff3cd' : review.status === 'approved' ? '#d4edda' : '#f8d7da'};
                    color: ${review.status === 'pending' ? '#856404' : review.status === 'approved' ? '#155724' : '#721c24'};">
                    ${review.status.toUpperCase()}
                </span>
            </td>
            <td>${new Date(review.created_at).toLocaleDateString()}</td>
            <td>
                <div style="display: flex; gap: 8px;">
                    ${review.status !== 'approved' ? `
                        <button class="btn-small" onclick="adminApproveReviewFunc(${review.id}, this)" style="background: #28a745; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;">Approve</button>
                    ` : ''}
                    ${review.status !== 'rejected' ? `
                        <button class="btn-small" onclick="adminRejectReviewFunc(${review.id}, this)" style="background: #dc3545; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;">Reject</button>
                    ` : ''}
                    <button class="btn-small" onclick="adminDeleteReviewFunc(${review.id}, this)" style="background: #6c757d; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;">Delete</button>
                </div>
            </td>
        </tr>
    `).join('');

    document.getElementById('reviews-list').innerHTML = html;
}

// Filter reviews
function filterReviewsAdmin(status) {
    // Update active button
    event.target.parentElement.querySelectorAll('.btn').forEach(btn => btn.classList.remove('btn-active'));
    event.target.classList.add('btn-active');

    // Filter and display
    currentReviewFilter = status;
    const filtered = status === 'all' ? allReviews : allReviews.filter(r => r.status === status);
    displayReviewsAdmin(filtered);
}

// Approve review
async function adminApproveReviewFunc(reviewId, button) {
    button.disabled = true;
    button.textContent = 'Approving...';

    try {
        const result = await approveReview(reviewId);
        if (result) {
            console.log('✅ Review approved');
            button.textContent = 'Approved ✓';
            button.style.background = '#6c757d';
            setTimeout(() => {
                loadAdminReviews();
            }, 500);
        } else {
            throw new Error('Failed to approve review');
        }
    } catch (error) {
        console.error('Error approving review:', error);
        showNotification('Error approving review: ' + error.message, 'error');
        button.disabled = false;
        button.textContent = 'Approve';
    }
}

// Reject review
async function adminRejectReviewFunc(reviewId, button) {
    button.disabled = true;
    button.textContent = 'Rejecting...';

    try {
        const result = await rejectReview(reviewId);
        if (result) {
            console.log('✅ Review rejected');
            button.textContent = 'Rejected ✗';
            button.style.background = '#6c757d';
            setTimeout(() => {
                loadAdminReviews();
            }, 500);
        } else {
            throw new Error('Failed to reject review');
        }
    } catch (error) {
        console.error('Error rejecting review:', error);
        showNotification('Error rejecting review: ' + error.message, 'error');
        button.disabled = false;
        button.textContent = 'Reject';
    }
}

// Delete review
async function adminDeleteReviewFunc(reviewId, button) {
    if (!confirm('Are you sure you want to delete this review?')) return;

    button.disabled = true;
    button.textContent = 'Deleting...';

    try {
        const result = await deleteReview(reviewId);
        if (result) {
            console.log('✅ Review deleted');
            showNotification('Review deleted successfully', 'success');
            setTimeout(() => {
                loadAdminReviews();
            }, 500);
        } else {
            throw new Error('Failed to delete review');
        }
    } catch (error) {
        console.error('Error deleting review:', error);
        showNotification('Error deleting review: ' + error.message, 'error');
        button.disabled = false;
        button.textContent = 'Delete';
    }
}

// Utility: Escape HTML
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Load reviews when admin panel is shown
document.addEventListener('DOMContentLoaded', function() {
    const originalShowPanel = window.showAdminPanel;
    window.showAdminPanel = function() {
        if (originalShowPanel) originalShowPanel();
        // Load reviews after a short delay
        setTimeout(() => {
            if (typeof fetchAllReviews === 'function') {
                loadAdminReviews();
            }
        }, 500);
    };
});

// Auto-refresh reviews every 30 seconds
setInterval(() => {
    if (document.getElementById('reviews-management')?.offsetParent !== null) {
        // Only refresh if reviews section is visible
        loadAdminReviews();
    }
}, 30000);

// ============================================================
// HELPER FUNCTIONS FOR SETTINGS VALIDATION
// ============================================================

function isValidUrl(url) {
    try {
        if (!url) return true; // Empty URLs are allowed
        new URL(url);
        return true;
    } catch (error) {
        return false;
    }
}

// ============================================================
// PAYMENT QR CODES MANAGEMENT
// ============================================================

// Store QR files temporarily before uploading
const qrFileStore = {
    esewa: null,
    khalti: null,
    bank: null
};

// Handle drag over
function handleDragOver(e) {
    e.preventDefault();
    e.stopPropagation();
    const area = e.currentTarget;
    area.classList.add('dragover');
}

// Handle drag leave
function handleDragLeave(e) {
    e.preventDefault();
    e.stopPropagation();
    const area = e.currentTarget;
    area.classList.remove('dragover');
}

// Handle QR drop
function handleQRDrop(e, method) {
    e.preventDefault();
    e.stopPropagation();
    const area = e.currentTarget;
    area.classList.remove('dragover');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        const file = files[0];
        if (file.type.startsWith('image/')) {
            displayQRPreview(file, method);
        } else {
            showNotification('❌ Please upload an image file', 'error');
        }
    }
}

// Handle QR file selection
function handleQRSelect(e, method) {
    const file = e.target.files[0];
    if (file) {
        displayQRPreview(file, method);
    }
}

// Display QR preview
function displayQRPreview(file, method) {
    const reader = new FileReader();
    reader.onload = function(e) {
        const preview = document.getElementById(`${method}-qr-preview`);
        preview.innerHTML = `<img src="${e.target.result}" alt="${method} QR">`;
        qrFileStore[method] = {
            file: file,
            dataUrl: e.target.result
        };
    };
    reader.readAsDataURL(file);
    console.log(`📸 QR preview loaded for ${method}`);
}

// Save payment QR to Supabase
async function savePaymentQR(method) {
    try {
        const qrData = qrFileStore[method];
        if (!qrData) {
            showNotification(`❌ Please select a ${method} QR code image first`, 'error');
            return;
        }

        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        console.log(`📱 Uploading ${method} QR code...`);

        // Show loading status
        const statusDiv = document.createElement('div');
        statusDiv.className = 'qr-status loading';
        statusDiv.textContent = `⏳ Uploading ${method} QR code...`;
        const qrArea = document.getElementById(`${method}-qr-area`);
        if (qrArea) qrArea.appendChild(statusDiv);

        // Convert QR image to base64
        console.log(`📤 Converting ${method} QR image to base64...`);
        
        const reader = new FileReader();
        
        return new Promise((resolve, reject) => {
            reader.onload = async function(e) {
                try {
                    const base64Data = e.target.result;
                    console.log(`✅ QR image converted to base64, length: ${base64Data.length}`);

                    // Data to save
                    const qrData_tosave = {
                        payment_method: method,
                        file_path: base64Data,
                        is_active: true,
                        updated_at: new Date().toISOString()
                    };

                    console.log(`📋 Attempting to save ${method} QR to database...`);

                    // Try to get existing record
                    const { data: existingQR, error: fetchError } = await client
                        .from('payment_qr_images')
                        .select('id')
                        .eq('payment_method', method)
                        .single();

                    let dbError;
                    let qrRecord;

                    if (existingQR) {
                        // Update existing
                        console.log(`📝 Updating existing ${method} QR record...`);
                        const { data: updateData, error: updateErr } = await client
                            .from('payment_qr_images')
                            .update(qrData_tosave)
                            .eq('payment_method', method)
                            .select();
                        
                        qrRecord = updateData;
                        dbError = updateErr;
                        console.log(`Update result:`, { data: updateData, error: updateErr });
                    } else {
                        // Insert new
                        console.log(`✏️ Creating new ${method} QR record...`);
                        const { data: insertData, error: insertErr } = await client
                            .from('payment_qr_images')
                            .insert([qrData_tosave])
                            .select();
                        
                        qrRecord = insertData;
                        dbError = insertErr;
                        console.log(`Insert result:`, { data: insertData, error: insertErr });
                    }

                    if (dbError) {
                        console.error(`❌ DB Error:`, dbError);
                        throw new Error(`Failed to save QR: ${dbError.message}`);
                    }

                    if (!qrRecord || qrRecord.length === 0) {
                        throw new Error('No records returned after save operation');
                    }

                    console.log(`✅ QR code saved successfully:`, qrRecord);

                    // Update status
                    if (statusDiv) {
                        statusDiv.className = 'qr-status success';
                        statusDiv.innerHTML = `<i class="fas fa-check-circle"></i> ✅ Successfully uploaded ${method} QR code!`;
                        setTimeout(() => statusDiv.remove(), 3000);
                    }

                    showNotification(`✅ ${method.toUpperCase()} QR code uploaded successfully!`, 'success');

                    // Refresh QR display
                    await loadPaymentQRs();

                    resolve(true);
                } catch (error) {
                    console.error(`❌ Error saving ${method} QR:`, error);
                    console.error(`Stack trace:`, error.stack);
                    
                    if (statusDiv) {
                        statusDiv.className = 'qr-status error';
                        statusDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i> ❌ ${error.message}`;
                        setTimeout(() => statusDiv.remove(), 5000);
                    }

                    showNotification(`❌ Error saving ${method} QR: ${error.message}`, 'error');
                    reject(error);
                }
            };

            reader.onerror = function(error) {
                console.error(`❌ FileReader error:`, error);
                reject(new Error('Failed to read file'));
            };

            reader.readAsDataURL(qrData.file);
        });
    } catch (error) {
        console.error(`❌ Error saving ${method} QR:`, error);
        showNotification(`❌ Error: ${error.message}`, 'error');
    }
}

// Delete payment QR
async function deletePaymentQR(method) {
    if (!confirm(`Are you sure you want to delete the ${method} QR code?`)) {
        return;
    }

    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        console.log(`🗑️ Deleting ${method} QR code...`);

        // Get current file path
        const { data: qrData, error: fetchError } = await client
            .from('payment_qr_images')
            .select('file_path')
            .eq('payment_method', method)
            .single();

        if (fetchError) {
            throw new Error(`Could not find ${method} QR: ${fetchError.message}`);
        }

        if (qrData && qrData.file_path) {
            // Extract filename from URL
            const fileName = qrData.file_path.split('/').pop();
            
            // Delete from storage
            const { error: deleteError } = await client
                .storage
                .from('payment-qr-images')
                .remove([fileName]);

            if (deleteError) {
                console.warn('⚠️ File deletion warning:', deleteError);
            }
        }

        // Delete metadata record
        const { error: dbError } = await client
            .from('payment_qr_images')
            .delete()
            .eq('payment_method', method);

        if (dbError) throw dbError;

        // Clear preview
        document.getElementById(`${method}-qr-preview`).innerHTML = '';
        qrFileStore[method] = null;

        showNotification(`✅ ${method.toUpperCase()} QR code deleted successfully!`, 'success');
        console.log(`✅ ${method} QR deleted from database`);

    } catch (error) {
        console.error(`❌ Error deleting ${method} QR:`, error);
        showNotification(`❌ Error deleting ${method} QR: ${error.message}`, 'error');
    }
}

// Load payment QRs when admin panel opens
async function loadPaymentQRs() {
    try {
        const client = getClient();
        if (!client) return;

        console.log('📥 Loading payment QR codes from database...');

        const { data: qrCodes, error } = await client
            .from('payment_qr_images')
            .select('*')
            .eq('is_active', true);

        if (error && error.code !== 'PGRST116') {
            console.warn('⚠️ Could not load payment QRs:', error);
            return;
        }

        if (qrCodes) {
            qrCodes.forEach(qr => {
                if (qr.file_path) {
                    const preview = document.getElementById(`${qr.payment_method}-qr-preview`);
                    if (preview) {
                        preview.innerHTML = `<img src="${qr.file_path}" alt="${qr.payment_method} QR">`;
                    }
                }
            });
            console.log(`✅ Loaded ${qrCodes.length} payment QR codes`);
        }

    } catch (error) {
        console.error('❌ Error loading payment QRs:', error);
    }
}

