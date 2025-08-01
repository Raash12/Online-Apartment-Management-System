# 🏢 Online Apartment Management System

## 📌 Overview
The **Online Apartment Management System** is a cross-platform solution designed to simplify property management for **Admins (Property Managers)** and **Residents**.  
It allows **online apartment rentals**, **rent payments**, **maintenance requests**, **notice board management**, **visitor tracking**, and more — all in one platform.

---

## 🚀 Key Features
### 👤 Resident Portal
- View apartment details and lease info.
- Submit maintenance requests.
- View notices and announcements.
- Manage visitor entries.
- Submit feedback and ratings.

### 🛠️ Admin Dashboard
- Add, edit, and remove apartments.
- Approve or reject lease requests.
- Manage residents and their leases.
- Handle maintenance requests.
- Post announcements and notices.
- View analytics and reports.

### 💰 Online Rent Payments
- Pay rent using Mobile Money (EVC Plus, GCash, etc.) or credit card.
- Receive digital receipts instantly.
- Auto-payment reminders.

### 📝 Document Management
- Upload and download lease agreements and related documents.

### 📢 Notices & Announcements
- Centralized board for important updates.
- Notifications to residents when a new notice is posted.



### 🌟 Feedback & Ratings
- Residents can rate and review apartments/services.
- Admins can view feedback analytics.

---

## 🧠 Business Logic Highlights
1. **Single Active Lease per User** – Prevents multiple active rentals by the same user.
2. **Prevent Renting Already Rented Apartments** – Apartment status changes to "rented" until lease expiry.
3. **Automatic Lease Expiry Handling** – Cron job/webhook updates lease and apartment statuses.
4. **Notifications** – Alerts before lease expiry or pending maintenance.
5. **Maintenance Request Throttling** – One active request at a time per user.
6. **Admin Approval Flow** – Optional lease request review process.
7. **Document Verification** – Upload ID proof or signed contracts.
8. **RBAC (Role-Based Access Control)** – Separate permissions for Admins and Residents.
9. **Soft Delete** – Archive apartments and leases instead of deleting.
10. **Admin Analytics Dashboard** – Monthly income, total apartments, active residents.

---

## 🏗️ Tech Stack
**Frontend:** Flutter  
**Backend:*  firebase  



