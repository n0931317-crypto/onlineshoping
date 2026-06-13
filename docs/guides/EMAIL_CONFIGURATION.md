# Email Configuration Reference Card

## 📧 Business Email Accounts

### Email Addresses

| Email | Purpose | Used In |
|-------|---------|---------|
| **contact@nepoonline.com** | General customer inquiries | Contact Form, Footer, About Us |
| **sales@nepoonline.com** | Sales and product inquiries | Footer Links, Future Sales Page |
| **admin@nepoonline.com** | Admin communications | Admin Panel, Founder Contact, Settings |
| **noreply@nepoonline.com** | System notifications | Reserved for automated emails |

## 📍 Location Details

**Business Address:**
```
Mirchaiya Bazar
Sirha, Nepal
```

**Map Coordinates:** 26.13872°N, 86.32895°E

**Embedded In:**
- Contact section of home page (interactive Google Map)
- About Us page
- Footer of all pages

## 🔗 Where Emails Appear

### 1. **index.html**
- **Contact Section:** contact@nepoonline.com (clickable)
- **Footer Contact Info:**
  - contact@nepoonline.com
  - sales@nepoonline.com
  - admin@nepoonline.com

### 2. **about-us.html**
- **Founder Section:** admin@nepoonline.com (social link)
- **Contact Methods Section:**
  - Email: contact@nepoonline.com
  - Social: admin@nepoonline.com

### 3. **Footer (All Pages)**
```
Customer Service
├── Support
├── Sales Inquiry (sales@nepoonline.com)
└── Admin (admin@nepoonline.com)

Contact Info
├── Location: Mirchaiya Bazar, Sirha, Nepal
└── Email: contact@nepoonline.com
```

## 🛠️ Setting Up Email Forwarding

If you have a domain registered, you can:

1. **Create Mailboxes** on your hosting:
   - contact@nepoonline.com
   - sales@nepoonline.com
   - admin@nepoonline.com
   - noreply@nepoonline.com

2. **Set Up Forwarding** (optional):
   - All emails → Your main inbox
   - Or distribute by function

3. **Email Service** Options:
   - Gmail Business (Google Workspace)
   - ProtonMail
   - Outlook
   - Your hosting provider's email service

## 📋 Email Templates for Auto-Replies

### Contact Form Auto-Reply
```
Subject: Thank you for contacting Nepo Online Stores

Dear Customer,

Thank you for reaching out to us! We've received your message and 
will get back to you within 24 hours.

Best regards,
Nepo Online Stores Team
contact@nepoonline.com
```

### Sales Inquiry Auto-Reply
```
Subject: Sales Inquiry Received

Dear Customer,

Thank you for your sales inquiry. Our team will review your request 
and respond shortly.

Sales Team
sales@nepoonline.com
```

## 🔐 Email Security Best Practices

1. ✅ Use SPF records for your domain
2. ✅ Set up DKIM signing
3. ✅ Configure DMARC policy
4. ✅ Use TLS encryption
5. ✅ Never expose email addresses in source code comments
6. ✅ Validate all form submissions server-side

## 📊 Email Integration Checklist

- [x] Contact page form linked to contact@nepoonline.com
- [x] All emails visible in footer
- [x] About Us page has admin email
- [x] Emails are clickable (mailto links)
- [x] noreply email reserved for system use
- [ ] Email accounts actually created (ACTION REQUIRED)
- [ ] SPF/DKIM records configured (ACTION REQUIRED)
- [ ] Auto-reply templates set up (OPTIONAL)

## 💡 Usage Guidelines

**Contact Form (index.html):**
- Saves messages to Supabase database
- User sees: "Thank you for your message! We will get back to you soon."
- Admin reviews in admin panel → Messages section

**Sales Inquiries:**
- Direct email link in footer
- Opens default email client
- Should forward to sales team

**Admin Communications:**
- For business owner/admin contact
- Found in About Us page
- Used for official business matters

**System Notifications:**
- Reserved for automated emails
- Not currently in use
- Available for future implementation

---

**Last Updated:** January 5, 2026
**Status:** Configuration Complete ✅
