// ===== ADMIN PRODUCT IMAGE MANAGEMENT =====

let selectedProductId = null;
let productImagesAdmin = [];
let previewImageIndex = 0;

// Load products in the select dropdown
async function loadProductsForImageUpload() {
    try {
        const supabase = window.supabaseClient;
        if (!supabase) {
            setTimeout(loadProductsForImageUpload, 500);
            return;
        }

        const { data: products, error } = await supabase
            .from('products')
            .select('id, name')
            .eq('is_active', true)
            .order('name', { ascending: true });

        if (error) throw error;

        const select = document.getElementById('image-product-select');
        select.innerHTML = '<option value="">-- Select a Product --</option>';

        if (products && products.length > 0) {
            products.forEach(product => {
                const option = document.createElement('option');
                option.value = product.id;
                option.textContent = product.name;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading products for image upload:', error);
    }
}

// Load existing product images for admin editing
async function loadProductImagesAdmin() {
    try {
        const supabase = window.supabaseClient;
        selectedProductId = document.getElementById('image-product-select').value;

        if (!selectedProductId) {
            document.getElementById('imageUploadArea').style.display = 'none';
            return;
        }

        document.getElementById('imageUploadArea').style.display = 'block';
        previewImageIndex = 0;

        const { data: images, error } = await supabase
            .from('product_images')
            .select('*')
            .eq('product_id', selectedProductId)
            .order('image_order', { ascending: true });

        if (error) throw error;

        productImagesAdmin = images || [];

        // Display existing images
        for (let i = 1; i <= 4; i++) {
            const image = productImagesAdmin.find(img => img.image_order === i);
            const placeholder = document.querySelector(`#imageSlot${i} .image-placeholder`);
            const deleteBtn = document.getElementById(`deleteBtn${i}`);
            
            if (image) {
                placeholder.innerHTML = `<img src="${image.image_url}" alt="Product Image ${i}">`;
                deleteBtn.style.display = 'inline-block';
            } else {
                placeholder.innerHTML = `<i class="fas fa-image"></i><p>Image ${i}</p>`;
                deleteBtn.style.display = 'none';
            }
        }

        // Update preview
        updatePreviewCarousel();

    } catch (error) {
        console.error('Error loading product images:', error);
        showNotification('❌ Error loading images', 'error');
    }
}

// Trigger file input for image upload
function triggerImageUpload(imageOrder) {
    const fileInput = document.getElementById(`imageInput${imageOrder}`);
    fileInput.click();
    
    fileInput.onchange = async function(e) {
        const file = e.target.files[0];
        if (!file) return;

        // Validate file
        if (!file.type.startsWith('image/')) {
            showNotification('❌ Please select an image file', 'error');
            return;
        }

        if (file.size > 5 * 1024 * 1024) { // 5MB limit
            showNotification('❌ Image must be less than 5MB', 'error');
            return;
        }

        await uploadProductImage(file, imageOrder);
    };
}

// Upload product image to Supabase Storage
async function uploadProductImage(file, imageOrder) {
    try {
        const supabase = window.supabaseClient;
        if (!selectedProductId) {
            showNotification('❌ Please select a product first', 'error');
            return;
        }

        // Show loading state
        const imageSlot = document.querySelector(`#imageSlot${imageOrder}`);
        const placeholder = imageSlot.querySelector('.image-placeholder');
        const originalHTML = placeholder.innerHTML; // Save HTML before changing
        placeholder.innerHTML = '<i class="fas fa-spinner fa-spin"></i><p>Uploading...</p>';

        // Create unique filename
        const timestamp = Date.now();
        const filename = `product-${selectedProductId}-image-${imageOrder}-${timestamp}.jpg`;
        const filepath = `product-${selectedProductId}/${filename}`;

        // Use the main product-images bucket for all uploads
        const bucketName = `product-images`;
        
        // Upload to storage using the main bucket
        const { data: uploadData, error: uploadError } = await supabase
            .storage
            .from(bucketName)
            .upload(filepath, file, {
                cacheControl: '3600',
                upsert: false
            });

        if (uploadError) {
            console.error('Upload error:', uploadError);
            throw new Error(`Upload failed: ${uploadError.message}`);
        }

        // Get public URL
        const { data: { publicUrl } } = supabase
            .storage
            .from(bucketName)
            .getPublicUrl(filepath);

        // Save image record to database
        const existingImage = productImagesAdmin.find(img => img.image_order === imageOrder);

        if (existingImage) {
            // Update existing
            const { error: updateError } = await supabase
                .from('product_images')
                .update({ image_url: publicUrl, updated_at: new Date() })
                .eq('id', existingImage.id);

            if (updateError) throw updateError;
        } else {
            // Insert new - Simplified insert without uploaded_by
            try {
                const { error: insertError } = await supabase
                    .from('product_images')
                    .insert({
                        product_id: parseInt(selectedProductId),
                        image_url: publicUrl,
                        image_order: imageOrder
                    });

                if (insertError) {
                    console.error('Database error:', insertError);
                    throw new Error(`Database error: ${insertError.message}`);
                }
            } catch (error) {
                console.error('Insert attempt failed:', error);
                throw error;
            }
        }

        // Reload images
        await loadProductImagesAdmin();
        showNotification(`✅ Image ${imageOrder} uploaded successfully!`, 'success');

    } catch (error) {
        console.error('Error uploading image:', error);
        showNotification('❌ Error uploading image: ' + error.message, 'error');
        
        // Restore original state if placeholder still exists
        const imageSlot = document.querySelector(`#imageSlot${imageOrder}`);
        if (imageSlot) {
            const placeholder = imageSlot.querySelector('.image-placeholder');
            const deleteBtn = document.getElementById(`deleteBtn${imageOrder}`);
            if (productImagesAdmin.find(img => img.image_order === imageOrder)) {
                const image = productImagesAdmin.find(img => img.image_order === imageOrder);
                placeholder.innerHTML = `<img src="${image.image_url}" alt="Product Image ${imageOrder}">`;
                deleteBtn.style.display = 'inline-block';
            } else {
                placeholder.innerHTML = `<i class="fas fa-image"></i><p>Image ${imageOrder}</p>`;
                deleteBtn.style.display = 'none';
            }
        }
    }
}

// Delete product image
async function deleteProductImage(imageOrder) {
    try {
        if (!confirm(`Delete image ${imageOrder}?`)) return;

        const supabase = window.supabaseClient;
        const image = productImagesAdmin.find(img => img.image_order === imageOrder);

        if (!image) {
            showNotification('❌ Image not found', 'error');
            return;
        }

        // Delete from database
        const { error: deleteError } = await supabase
            .from('product_images')
            .delete()
            .eq('id', image.id);

        if (deleteError) throw deleteError;

        // Delete from storage (extract filename from URL)
        try {
            const url = new URL(image.image_url);
            // Extract the path after the bucket name
            const bucketName = `product-images-slot-${imageOrder}`;
            const filepath = url.pathname.split(`/${bucketName}/`)[1];
            
            if (filepath) {
                await supabase
                    .storage
                    .from(bucketName)
                    .remove([filepath]);
            }
        } catch (e) {
            console.log('Could not delete from storage:', e);
        }

        // Reload images
        await loadProductImagesAdmin();
        showNotification('✅ Image deleted successfully!', 'success');

    } catch (error) {
        console.error('Error deleting image:', error);
        showNotification('❌ Error deleting image: ' + error.message, 'error');
    }
}

// Update preview carousel
function updatePreviewCarousel() {
    const previewImg = document.getElementById('previewCarouselImage');
    const counter = document.getElementById('previewImageCounter');

    if (productImagesAdmin.length === 0) {
        previewImg.src = 'https://via.placeholder.com/400x300?text=No+Images';
        counter.textContent = '0 / 4';
    } else {
        // Get image at preview index (cycle through available images)
        const availableImages = productImagesAdmin.sort((a, b) => a.image_order - b.image_order);
        const displayIndex = previewImageIndex % availableImages.length;
        previewImg.src = availableImages[displayIndex].image_url;
        counter.textContent = `${displayIndex + 1} / 4`;
    }
}

// Preview previous image
function previewPrevImage() {
    if (productImagesAdmin.length === 0) return;
    previewImageIndex = (previewImageIndex - 1 + productImagesAdmin.length) % productImagesAdmin.length;
    updatePreviewCarousel();
}

// Preview next image
function previewNextImage() {
    if (productImagesAdmin.length === 0) return;
    previewImageIndex = (previewImageIndex + 1) % productImagesAdmin.length;
    updatePreviewCarousel();
}

// Initialize on admin page load
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(() => {
        loadProductsForImageUpload();
    }, 2000);
});

// Notification function (use the same one from admin.js)
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = message;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}
