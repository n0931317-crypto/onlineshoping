# Nepo Online stores - Storage Buckets Setup Guide

## Overview
This guide explains how to create and configure storage buckets in Supabase for storing images and files for the Nepo Online stores e-commerce platform.

## Required Storage Buckets

### 1. **product-images**
- **Purpose**: Store product photos for catalog
- **Access**: Public read, Authenticated write
- **Max Size**: 50MB per file
- **Use Cases**: Product pictures shown in catalog

### 2. **gallery-images**
- **Purpose**: Fashion gallery and showcase images
- **Access**: Public read, Authenticated write
- **Max Size**: 100MB per file
- **Use Cases**: Collection photos, seasonal displays

### 3. **admin-files**
- **Purpose**: Admin document uploads and reports
- **Access**: Authenticated only
- **Max Size**: 200MB per file
- **Use Cases**: Invoice PDFs, reports, documents

### 4. **category-images**
- **Purpose**: Category thumbnails and headers
- **Access**: Public read, Authenticated write
- **Max Size**: 50MB per file
- **Use Cases**: Sarees, Suits, Lehengas category images

### 5. **thumbnail-images**
- **Purpose**: Product thumbnail previews
- **Access**: Public read, Authenticated write
- **Max Size**: 10MB per file
- **Use Cases**: Quick loading thumbnails for lists

## Steps to Create Buckets in Supabase

### Via Supabase Dashboard

1. **Login to Supabase Console**
   - Go to https://app.supabase.com
   - Select your project

2. **Navigate to Storage**
   - Click "Storage" in left sidebar
   - Click "New Bucket"

3. **Create product-images Bucket**
   - Name: `product-images`
   - Public bucket: ✓ Check
   - Click "Create bucket"

4. **Create gallery-images Bucket**
   - Name: `gallery-images`
   - Public bucket: ✓ Check
   - Click "Create bucket"

5. **Create admin-files Bucket**
   - Name: `admin-files`
   - Public bucket: ✗ Uncheck (private)
   - Click "Create bucket"

6. **Create category-images Bucket**
   - Name: `category-images`
   - Public bucket: ✓ Check
   - Click "Create bucket"

7. **Create thumbnail-images Bucket**
   - Name: `thumbnail-images`
   - Public bucket: ✓ Check
   - Click "Create bucket"

## Setting Up Storage Policies (RLS)

After creating buckets, configure Row Level Security policies:

### For Public Read Buckets (product-images, gallery-images, category-images, thumbnail-images)

#### Policy 1: Allow public read
```sql
CREATE POLICY "Public Read" ON storage.objects
FOR SELECT
USING (
  bucket_id IN ('product-images', 'gallery-images', 'category-images', 'thumbnail-images')
);
```

#### Policy 2: Allow authenticated write
```sql
CREATE POLICY "Authenticated Write" ON storage.objects
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id IN ('product-images', 'gallery-images', 'category-images', 'thumbnail-images')
);
```

#### Policy 3: Allow authenticated update
```sql
CREATE POLICY "Authenticated Update" ON storage.objects
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND bucket_id IN ('product-images', 'gallery-images', 'category-images', 'thumbnail-images')
);
```

#### Policy 4: Allow authenticated delete
```sql
CREATE POLICY "Authenticated Delete" ON storage.objects
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND bucket_id IN ('product-images', 'gallery-images', 'category-images', 'thumbnail-images')
);
```

### For Private Bucket (admin-files)

#### Policy 1: Allow authenticated all operations
```sql
CREATE POLICY "Admin Authenticated All" ON storage.objects
FOR ALL
USING (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
)
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
);
```

## Uploading Files via JavaScript

### Example: Upload Product Image

```javascript
// Initialize Supabase (in supabase-new.js)
const SUPABASE_URL = 'https://gqzajmxtkfnvfceokwip.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';

const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Upload function
async function uploadProductImage(file, productId) {
  try {
    const fileName = `product-${productId}-${Date.now()}.jpg`;
    
    const { data, error } = await supabaseClient
      .storage
      .from('product-images')
      .upload(fileName, file);
    
    if (error) {
      console.error('Upload error:', error);
      return null;
    }
    
    // Get public URL
    const { data: publicUrl } = supabaseClient
      .storage
      .from('product-images')
      .getPublicUrl(fileName);
    
    return publicUrl.publicUrl;
  } catch (error) {
    console.error('Upload failed:', error);
    return null;
  }
}
```

### Example: Upload Gallery Image

```javascript
async function uploadGalleryImage(file, category) {
  try {
    const fileName = `${category}-${Date.now()}.jpg`;
    
    const { data, error } = await supabaseClient
      .storage
      .from('gallery-images')
      .upload(fileName, file);
    
    if (error) throw error;
    
    const { data: { publicUrl } } = supabaseClient
      .storage
      .from('gallery-images')
      .getPublicUrl(fileName);
    
    return publicUrl;
  } catch (error) {
    console.error('Gallery upload failed:', error);
    return null;
  }
}
```

### Example: Upload Thumbnail

```javascript
async function uploadThumbnail(file, productId) {
  try {
    const fileName = `thumb-${productId}-${Date.now()}.jpg`;
    
    const { data, error } = await supabaseClient
      .storage
      .from('thumbnail-images')
      .upload(fileName, file);
    
    if (error) throw error;
    
    const { data: { publicUrl } } = supabaseClient
      .storage
      .from('thumbnail-images')
      .getPublicUrl(fileName);
    
    return publicUrl;
  } catch (error) {
    console.error('Thumbnail upload failed:', error);
    return null;
  }
}
```

## Image Organization Structure

```
product-images/
├── product-1-1704369600000.jpg
├── product-1-1704369610000.jpg
├── product-2-1704369620000.jpg
└── product-3-1704369630000.jpg

gallery-images/
├── Sarees-1704369600000.jpg
├── Ladies-Suits-1704369610000.jpg
├── Lehengas-1704369620000.jpg
├── Boots-Shoes-1704369630000.jpg
└── Readymade-1704369640000.jpg

category-images/
├── sarees-header.jpg
├── suits-header.jpg
├── lehengas-header.jpg
├── boots-header.jpg
└── readymade-header.jpg

thumbnail-images/
├── thumb-1.jpg
├── thumb-2.jpg
├── thumb-3.jpg
└── thumb-4.jpg

admin-files/
├── invoices/
│   ├── invoice-001.pdf
│   └── invoice-002.pdf
└── reports/
    ├── sales-report-jan.pdf
    └── inventory-report.pdf
```

## File Size Limits

- **Product Images**: 50MB each
- **Gallery Images**: 100MB each
- **Thumbnails**: 10MB each
- **Admin Files**: 200MB each
- **Total Bucket Size**: 5GB per bucket

## Best Practices

1. **Naming Convention**
   - Use descriptive names: `product-123-variant-color.jpg`
   - Include timestamp to avoid conflicts
   - Use lowercase and hyphens (no spaces)

2. **Image Optimization**
   - Resize large images before upload
   - Use compressed formats (WebP, JPEG)
   - Optimize for web (72 DPI)
   - Max dimensions: 1920x1920px

3. **Backup**
   - Keep backup copies locally
   - Document all image URLs
   - Version control image metadata

4. **Security**
   - Never expose admin bucket to public
   - Validate file types before upload
   - Scan for malicious files
   - Implement file size limits

5. **Performance**
   - Use CDN for public buckets
   - Enable image compression
   - Implement lazy loading
   - Cache frequently accessed images

## Troubleshooting

### Issue: Bucket Already Exists
**Solution**: Use existing bucket or rename your new bucket

### Issue: Upload Failed - Permission Denied
**Solution**: 
- Check ANON_KEY is correct
- Verify RLS policies are set
- Ensure user is authenticated

### Issue: Public URL Returns 403
**Solution**:
- Verify bucket is public
- Check file exists in bucket
- Verify storage policies allow read

### Issue: Large Files Won't Upload
**Solution**:
- Check file size limit
- Compress image before upload
- Use chunked upload for large files

## SQL Queries for File Management

```sql
-- Monitor storage usage
SELECT 
    bucket_id,
    COUNT(*) as file_count,
    ROUND(SUM(metadata->>'size')::BIGINT / 1048576.0, 2) as size_mb
FROM storage.objects
GROUP BY bucket_id;

-- Get all files in a bucket
SELECT name, created_at, metadata->>'size' as size
FROM storage.objects
WHERE bucket_id = 'product-images'
ORDER BY created_at DESC;

-- Find old/unused files
SELECT name, created_at
FROM storage.objects
WHERE bucket_id = 'product-images'
AND created_at < NOW() - INTERVAL '90 days'
ORDER BY created_at ASC;
```

## Integration with Admin Panel

The admin panel includes file upload sections:

1. **Product Management** → Upload product images
2. **Gallery Management** → Upload gallery photos
3. **Admin Files** → Upload documents/reports
4. **Settings** → Upload logo/branding

All uploads automatically:
- Validate file type
- Compress images
- Generate thumbnails
- Create database records
- Generate public URLs

## Next Steps

1. ✅ Create all 5 buckets in Supabase
2. ✅ Set up RLS policies
3. ✅ Test upload functionality
4. ✅ Configure image optimization
5. ✅ Set up backup system
6. ✅ Monitor storage usage

---

**Status**: Ready for implementation
**Last Updated**: January 2026
