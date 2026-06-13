// Order Tracking JavaScript
let supabaseClient = null;

// Initialize
document.addEventListener('DOMContentLoaded', async function() {
    const client = await waitForSupabaseClient();
    if (client) {
        supabaseClient = client;
        console.log('Supabase initialized for order tracking');
    }

    // Mobile menu toggle
    const menuBtn = document.querySelector('.mobile-menu-btn');
    if (menuBtn) {
        menuBtn.addEventListener('click', function() {
            document.querySelector('.nav-menu ul').classList.toggle('show');
        });
    }

    // Close menu on link click
    document.querySelectorAll('.nav-menu a').forEach(link => {
        link.addEventListener('click', () => {
            document.querySelector('.nav-menu ul').classList.remove('show');
        });
    });
});

// Wait for Supabase to initialize
function waitForSupabaseClient() {
    return new Promise((resolve) => {
        let attempts = 0;
        const checkInterval = setInterval(() => {
            if (window.supabaseClient) {
                clearInterval(checkInterval);
                resolve(window.supabaseClient);
            } else if (attempts > 20) {
                clearInterval(checkInterval);
                resolve(null);
            }
            attempts++;
        }, 100);
    });
}

// Switch between search tabs
function switchTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.search-content').forEach(tab => {
        tab.classList.remove('active');
    });

    // Deactivate all buttons
    document.querySelectorAll('.search-tab').forEach(tab => {
        tab.classList.remove('active');
    });

    // Show selected tab
    document.getElementById(tabName).classList.add('active');

    // Activate selected button
    event.target.closest('.search-tab').classList.add('active');
}

// Search by Order ID
async function searchByOrderId() {
    const orderId = document.getElementById('search-order-id').value.trim();

    if (!orderId) {
        showError('Please enter an Order ID');
        return;
    }

    await searchOrder('order_number', orderId);
}

// Search by Phone
async function searchByPhone() {
    const phone = document.getElementById('search-phone').value.trim();

    if (!phone) {
        showError('Please enter a phone number');
        return;
    }

    await searchOrder('customer_phone', phone);
}

// Search by Email
async function searchByEmail() {
    const email = document.getElementById('search-email').value.trim();

    if (!email) {
        showError('Please enter an email address');
        return;
    }

    await searchOrder('customer_email', email);
}

// Main search function
async function searchOrder(field, value) {
    if (!supabaseClient) {
        showError('System not initialized. Please refresh the page.');
        return;
    }

    try {
        showLoading(true);
        hideError();

        // Query orders table
        let query = supabaseClient
            .from('orders')
            .select('*, order_items(*)')
            .eq(field, value);

        const { data: orders, error } = await query;

        showLoading(false);

        if (error) {
            throw error;
        }

        if (!orders || orders.length === 0) {
            showNoOrder();
            return;
        }

        // Display the latest order if multiple found
        const order = orders[orders.length - 1];
        displayOrderDetails(order);

    } catch (error) {
        showLoading(false);
        console.error('Search error:', error);
        showError('Error searching order: ' + error.message);
    }
}

// Display order details
function displayOrderDetails(order) {
    // Update header information
    document.getElementById('detail-order-id').textContent = order.order_number;
    document.getElementById('detail-status').textContent = formatStatus(order.status);
    document.getElementById('detail-status').style.color = getStatusColor(order.status);
    document.getElementById('detail-amount').textContent = `Rs. ${order.total_amount.toFixed(2)}`;

    // Update delivery information
    document.getElementById('detail-name').textContent = order.customer_name;
    document.getElementById('detail-phone').textContent = order.customer_phone;
    document.getElementById('detail-email').textContent = order.customer_email;
    document.getElementById('detail-address').textContent = order.delivery_address || 'Not specified';
    document.getElementById('detail-delivery-date').textContent = order.delivery_date 
        ? formatDate(order.delivery_date) 
        : 'As soon as possible';

    // Update order notes if available
    if (order.notes) {
        document.getElementById('order-notes-section').style.display = 'block';
        document.getElementById('detail-notes').textContent = order.notes;
    } else {
        document.getElementById('order-notes-section').style.display = 'none';
    }

    // Display status timeline
    displayStatusTimeline(order.status, order.created_at);

    // Display order items
    displayOrderItems(order.order_items);

    // Show order details section
    document.getElementById('order-details').classList.add('active');
    document.getElementById('no-order').style.display = 'none';

    // Scroll to details
    document.getElementById('order-details').scrollIntoView({ behavior: 'smooth' });
}

// Display order items
function displayOrderItems(items) {
    if (!items || items.length === 0) {
        document.getElementById('order-items-list').innerHTML = '<p>No items found</p>';
        return;
    }

    const itemsHtml = items.map(item => `
        <div class="order-item">
            <div class="item-info">
                <div class="item-name">${item.product_name}</div>
                <div class="item-qty">Quantity: ${item.quantity}</div>
            </div>
            <div class="item-price">Rs. ${(item.quantity * item.price).toFixed(2)}</div>
        </div>
    `).join('');

    document.getElementById('order-items-list').innerHTML = itemsHtml;
}

// Display status timeline
function displayStatusTimeline(status, createdAt) {
    const statuses = [
        { key: 'pending_verification', label: 'Order Received', icon: 'fa-clipboard-check', description: 'Your order has been received' },
        { key: 'verified', label: 'Payment Verified', icon: 'fa-check-circle', description: 'Payment verification in progress' },
        { key: 'confirmed', label: 'Order Confirmed', icon: 'fa-thumbs-up', description: 'Your order has been confirmed' },
        { key: 'processing', label: 'Processing', icon: 'fa-box', description: 'Preparing your items' },
        { key: 'ready_for_delivery', label: 'Ready for Delivery', icon: 'fa-check', description: 'Order is ready to ship' },
        { key: 'shipped', label: 'Shipped', icon: 'fa-truck', description: 'Order is on the way' },
        { key: 'delivered', label: 'Delivered', icon: 'fa-home', description: 'Order has been delivered' }
    ];

    const timelineHtml = statuses.map((s, index) => {
        const isCompleted = isStatusCompleted(s.key, status);
        const isActive = s.key === status;

        return `
            <div class="timeline-item ${isCompleted ? 'completed' : ''} ${isActive ? 'active' : ''}">
                <div class="timeline-icon">
                    <i class="fas ${s.icon}"></i>
                </div>
                <div class="timeline-content">
                    <div class="timeline-title">${s.label}</div>
                    <div class="timeline-description">${s.description}</div>
                    <div class="timeline-date">${getStatusDate(s.key, createdAt)}</div>
                </div>
            </div>
        `;
    }).join('');

    document.getElementById('status-timeline').innerHTML = timelineHtml;
}

// Check if status is completed
function isStatusCompleted(checkStatus, currentStatus) {
    const statusOrder = ['pending_verification', 'verified', 'confirmed', 'processing', 'ready_for_delivery', 'shipped', 'delivered'];
    const currentIndex = statusOrder.indexOf(currentStatus);
    const checkIndex = statusOrder.indexOf(checkStatus);

    return checkIndex < currentIndex;
}

// Get status color
function getStatusColor(status) {
    const colors = {
        'pending_verification': '#ffc107',
        'verified': '#667eea',
        'confirmed': '#28a745',
        'processing': '#17a2b8',
        'ready_for_delivery': '#007bff',
        'shipped': '#6610f2',
        'delivered': '#20c997',
        'cancelled': '#dc3545'
    };

    return colors[status] || '#666';
}

// Format status text
function formatStatus(status) {
    const labels = {
        'pending_verification': '⏳ Pending Verification',
        'verified': '✓ Payment Verified',
        'confirmed': '✓ Confirmed',
        'processing': '📦 Processing',
        'ready_for_delivery': '📦 Ready for Delivery',
        'shipped': '🚚 Shipped',
        'delivered': '✓ Delivered',
        'cancelled': '✗ Cancelled'
    };

    return labels[status] || status;
}

// Get status date
function getStatusDate(status, createdAt) {
    // In a real application, you would fetch the actual date from the order history
    // For now, we'll use estimated dates based on the current status
    const created = new Date(createdAt);
    const today = new Date();

    if (status === 'pending_verification') {
        return formatDate(created);
    }

    // Estimate based on status progression
    const daysToAdd = {
        'verified': 1,
        'confirmed': 2,
        'processing': 3,
        'ready_for_delivery': 4,
        'shipped': 5,
        'delivered': 7
    };

    const estimatedDate = new Date(created);
    estimatedDate.setDate(estimatedDate.getDate() + (daysToAdd[status] || 0));

    if (estimatedDate <= today) {
        return `Completed on ${formatDate(estimatedDate)}`;
    } else {
        return `Estimated: ${formatDate(estimatedDate)}`;
    }
}

// Format date
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('en-US', options);
}

// Reset search
function resetSearch() {
    document.getElementById('search-order-id').value = '';
    document.getElementById('search-phone').value = '';
    document.getElementById('search-email').value = '';
    document.getElementById('order-details').classList.remove('active');
    document.getElementById('no-order').style.display = 'none';
    document.querySelector('.search-tab').click();
    document.querySelector('.search-tab').click();
}

// Show/hide loading state
function showLoading(show) {
    document.getElementById('loading-spinner').style.display = show ? 'block' : 'none';
}

// Show error message
function showError(message) {
    const errorDiv = document.getElementById('error-message');
    errorDiv.textContent = '⚠️ ' + message;
    errorDiv.style.display = 'block';
}

// Hide error message
function hideError() {
    document.getElementById('error-message').style.display = 'none';
}

// Show no order found state
function showNoOrder() {
    document.getElementById('order-details').classList.remove('active');
    document.getElementById('no-order').style.display = 'block';
    document.getElementById('no-order').scrollIntoView({ behavior: 'smooth' });
}
