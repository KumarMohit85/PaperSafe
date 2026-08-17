# 🛡️ PaperSafe v2.0 – Complete Feature & Testing Guide

Welcome to the comprehensive testing manual for **PaperSafe v2.0**, an AI-powered secure document wallet built with Flutter, Node.js, Express, MongoDB, Google ML Kit, Gemini AI, SQLite, and Nearby Connections.

---

## 📋 Table of Contents
1. [Prerequisites & Setup](#1-prerequisites--setup)
2. [Step-by-Step Feature Testing Guide](#2-step-by-step-feature-testing-guide)
   - [Test 1: JWT Authentication & Onboarding](#test-1-jwt-authentication--onboarding)
   - [Test 2: Biometric App Lock Protection](#test-2-biometric-app-lock-protection)
   - [Test 3: Smart OCR Scanner (ML Kit)](#test-3-smart-ocr-scanner-ml-kit)
   - [Test 4: Gemini AI Document Assistant](#test-4-gemini-ai-document-assistant)
   - [Test 5: Nearby File Sharing (P2P Multi-file)](#test-5-nearby-file-sharing-p2p-multi-file)
   - [Test 6: Google Maps Document Center Locator](#test-6-google-maps-document-center-locator)
   - [Test 7: SQLite Indexed Smart Search](#test-7-sqlite-indexed-smart-search)
   - [Test 8: Smart Expiry Notifications](#test-8-smart-expiry-notifications)
   - [Test 9: PDF Document Viewer & Share](#test-9-pdf-document-viewer--share)
   - [Test 10: Vault Analytics, Trash & Activity Timeline](#test-10-vault-analytics-trash--activity-timeline)
3. [Troubleshooting & Pro Tips](#3-troubleshooting--pro-tips)

---

## 1. Prerequisites & Setup

### A. Backend Server (Node.js & MongoDB)
1. Open terminal and navigate to server directory:
   ```bash
   cd c:/FlutterProjects/PaperSafe/server
   ```
2. Ensure dependencies are installed:
   ```bash
   npm install
   ```
3. Start the Node.js Express server:
   ```bash
   npm start
   ```
   *Expected Output*: Server running on `http://localhost:5000` (or specified PORT) with MongoDB connected.

### B. Flutter Client
1. Open a new terminal and navigate to client directory:
   ```bash
   cd c:/FlutterProjects/PaperSafe/client
   ```
2. Get all dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on Android emulator or connected device:
   ```bash
   flutter run
   ```

---

## 2. Step-by-Step Feature Testing Guide

---

### Test 1: JWT Authentication & Onboarding
* **Goal**: Verify user authentication, OTP verification, and JWT token persistence.
* **Steps**:
  1. Launch the app. If not logged in, the `LoginPage` appears.
  2. Enter mobile number / email address and tap **Get OTP**.
  3. Enter the verification OTP on `MobileOtpPage`.
  4. Fill in user details on `UserInformation` page.
  5. Tap **Continue**.
* **Expected Result**: User receives JWT access token & refresh token stored securely in `FlutterSecureStorage`. User is redirected to `HomePage`.

---

### Test 2: Biometric App Lock Protection
* **Goal**: Test vault locking using Fingerprint / Face ID.
* **Steps**:
  1. Navigate to **Settings** tab.
  2. Toggle **Biometric App Lock** to **ON**.
  3. Confirm biometric authentication prompt when enabling.
  4. Minimize or close the app and reopen it.
* **Expected Result**: `BiometricLockScreen` locks the vault automatically. Tapping **Unlock Vault** prompts for fingerprint/Face ID. Successful authentication unlocks the app.

---

### Test 3: Smart OCR Scanner (ML Kit)
* **Goal**: Test camera scanner, document classification, and regex field extraction.
* **Steps**:
  1. Open **Scanner** from action button or navigation menu.
  2. Point camera at an **Aadhaar Card**, **PAN Card**, **Passport**, or **Driving License** (or pick an image from Gallery using the photo icon).
  3. Tap the round **Capture** button.
  4. Review the extracted results in the bottom modal sheet.
* **Expected Result**: ML Kit detects text, classifies document type (e.g. *Aadhaar Card*), extracts the 12-digit number / DOB, and provides **Copy** & **Use Extracted Data** buttons.

---

### Test 4: Gemini AI Document Assistant
* **Goal**: Test real-time AI conversation and document analysis.
* **Steps**:
  1. Navigate to **AI Assistant** tab (`/ai-chat`).
  2. Type a question such as: *"How should I organize my passport and visa documents?"* or *"What is required for Aadhaar update?"*
  3. Tap **Send**.
* **Expected Result**: Client invokes Google Generative AI (`google_generative_ai`) and renders response in a chat bubble.

---

### Test 5: Nearby File Sharing (P2P Multi-file)
* **Goal**: Verify offline peer-to-peer file sharing with toggle discovery.
* **Steps**:
  1. Navigate to **Nearby** tab (`/nearby-share`).
  2. Toggle **Discovery** switch to **ON**.
  3. Tap **Pick Files** and select multiple files from your device.
  4. Select a discovered device endpoint from the list card.
  5. Tap **Send**.
* **Expected Result**: Discovery starts only when toggled ON. Multiple files are packaged and transferred via `NearbyService`.

---

### Test 6: Google Maps Document Center Locator
* **Goal**: Locate nearby Passport Seva Kendras, Aadhaar Kendras, RTOs, and print shops.
* **Steps**:
  1. Navigate to **Maps** page (`/maps`).
  2. Observe map markers around your location.
  3. Filter by chips (*Aadhaar*, *Passport*, *RTO*, *Printing*).
  4. Tap on any marker to view distance, rating, address, and **Get Directions** button.
* **Expected Result**: Google Maps displays interactive markers and detail card.

---

### Test 7: SQLite Indexed Smart Search
* **Goal**: Verify full-text search across titles, categories, OCR text, and tags.
* **Steps**:
  1. Navigate to **Search** tab (`/search`).
  2. Type keywords like `"Aadhaar"`, `"IRCTC"`, or `"Credit Card"`.
  3. Tap category filter chips (*Identity*, *Education*, *Financial*, *Travel*).
  4. Tap on recent search history chips to re-execute queries.
* **Expected Result**: Results update in real-time backed by SQLite `SearchService`.

---

### Test 8: Smart Expiry Notifications
* **Goal**: Test automated document expiration alerts.
* **Steps**:
  1. Ensure local notifications permission is allowed.
  2. Background expiry checker runs `checkAndScheduleExpiries()`.
* **Expected Result**: Scheduled notifications fire at 30 days, 7 days, and 1 day ("Expires Tomorrow") before document expiration.

---

### Test 9: PDF Document Viewer & Share
* **Goal**: Test built-in PDF viewer with search and zoom.
* **Steps**:
  1. Tap on any `.pdf` document or navigate to `PdfViewerPage`.
  2. Pinch-to-zoom or use bottom zoom controls (`+` / `-`).
  3. Tap search icon and search text inside the PDF.
  4. Tap share icon to export via `share_plus`.
* **Expected Result**: `SfPdfViewer` renders pages smoothly with search highlight and share action.

---

### Test 10: Vault Analytics, Trash & Activity Timeline
* **Goal**: Test dashboard storage breakdown, soft-delete recovery, and audit logs.
* **Steps**:
  1. Open **Categories** or **Settings** to inspect `DashboardAnalyticsWidget` progress bar.
  2. Open **Recycle Bin / Trash** (`/trash`) to inspect soft-deleted items, 30-day purge countdown, and **Restore** / **Delete Permanently** buttons.
  3. Open **Activity Timeline** (`/activity-timeline`) to view chronological audit logs of all actions.

---

## 3. Troubleshooting & Pro Tips

* **Hot Reloading / Restarting**: Use `r` (hot reload) or `R` (hot restart) in terminal.
* **Biometric Emulator Testing**: On Android Emulator, configure fingerprint via *Settings > Security > Fingerprint*, then use emulator extended controls to simulate touch.
* **Permission Dialogs**: Make sure Location and Bluetooth permissions are accepted when testing Nearby Sharing and Maps.

---
*Created for PaperSafe v2.0 — All code committed & pushed to GitHub.*
