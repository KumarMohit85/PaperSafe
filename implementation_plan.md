# PaperSafe v2.0 – Master Implementation Plan

> **Current codebase baseline:** Flutter (Dart 3.4+) client with Dio, shared_preferences, image_picker, share_plus, flutter_screenutil. Node.js / Express server on MongoDB + Cloudinary. Auth via email OTP. Documents stored: Aadhaar, PAN, X/XII marksheets, movie tickets.

---

## Architecture Overview

```
PaperSafe v2.0
├── client/                        ← Flutter (Material 3, Riverpod state)
│   ├── lib/
│   │   ├── core/                  ← theme, router, di, constants
│   │   ├── features/              ← feature-first folder structure
│   │   │   ├── auth/
│   │   │   ├── biometric/
│   │   │   ├── documents/
│   │   │   ├── scanner/
│   │   │   ├── ai/
│   │   │   ├── qr/
│   │   │   ├── nearby_sharing/
│   │   │   ├── search/
│   │   │   ├── maps/
│   │   │   ├── notifications/
│   │   │   └── dashboard/
│   │   └── shared/                ← reusable widgets, models, utils
└── server/                        ← Node.js / Express
    └── src/
        ├── controllers/           ← HTTP layer (existing + new)
        ├── services/              ← business logic (existing + new)
        ├── models/                ← Mongoose schemas (existing + new)
        ├── routes/v1/             ← REST routes
        ├── middlewares/           ← auth JWT + upload (extend)
        ├── utils/                 ← OCR, AI, push, QR helpers (new)
        └── config/                ← env, DB, cloud, AI keys
```

### State Management Migration
| Current | v2.0 |
|---------|------|
| `UserManager` (singleton + StreamController) | **Riverpod** (AsyncNotifierProvider) |
| `DocumentManager` singleton | **Riverpod** StateNotifierProvider |
| No DI | `flutter_riverpod` + `riverpod_annotation` |

---

## Decisions Made

| Question | Decision |
|----------|----------|
| AI Provider | ✅ **Client-side** – Gemini 1.5 Flash called directly from Flutter |
| Target Platforms | ✅ **Android + iOS** – both supported |
| JWT Auth | ✅ **Yes** – JWT + refresh tokens added in Phase 0 |
| Package Rename | ✅ **Yes** – `_first_one` → `com.papersafe.app` in Phase 0 |
| Nearby Sharing (iOS) | ℹ️ `nearby_connections` is Android only; iOS will use `flutter_p2p_connection` or `MultipeerConnectivity` – handled in Phase 2-A |

---

## Proposed Changes by Phase

---

## PHASE 0 – Foundation & Cleanup (Pre-requisite for all phases)
*Do this before any feature. Establishes clean architecture.*

---

### Flutter Client – Core Architecture

#### [MODIFY] pubspec.yaml
Add all new dependencies in one shot:
```yaml
# State Management
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
go_router: ^14.2.7

# UI / Design
google_fonts: ^6.2.1
animate_do: ^3.3.2
shimmer: ^3.0.0
lottie: ^3.1.2
flutter_animate: ^4.5.0

# Biometrics
local_auth: ^2.3.0

# OCR / ML Kit
google_mlkit_text_recognition: ^0.13.0
google_mlkit_document_scanner: ^0.1.0

# AI
google_generative_ai: ^0.4.6

# QR
mobile_scanner: ^5.2.3
qr_flutter: ^4.1.0

# Nearby Sharing
nearby_connections: ^4.1.0

# Maps
google_maps_flutter: ^2.9.0
geolocator: ^12.0.0

# Notifications
flutter_local_notifications: ^17.2.2
flutter_timezone: ^2.1.0
workmanager: ^0.5.2   # background tasks for expiry checks

# Search / SQLite
sqflite: ^2.3.3+1
flutter_secure_storage: ^9.2.2

# PDF
syncfusion_flutter_pdf: ^26.2.14
syncfusion_flutter_pdfviewer: ^26.2.14

# Files & Misc
file_picker: ^8.1.2
open_filex: ^4.5.0
permission_handler: ^11.3.1
connectivity_plus: ^6.0.5
package_info_plus: ^8.1.1
```

#### [NEW] `lib/core/theme/app_theme.dart`
- Material 3 `ThemeData` with custom `ColorScheme` (deep indigo + violet accent, glassmorphic surface tints)
- Dark + Light themes
- Custom typography using `google_fonts` (Inter)
- Shared border radius, shadow, gradient tokens

#### [NEW] `lib/core/router/app_router.dart`
- `GoRouter` with named routes, route guards (auth check, biometric check)
- Redirect unauthenticated users to `/login`

#### [NEW] `lib/core/di/providers.dart`
- All Riverpod providers in one file (later split per feature)

#### [MODIFY] `lib/main.dart`
- Wrap with `ProviderScope`
- Switch to `GoRouter`
- Load theme from provider

#### [RENAME] Package `_first_one` → `com.papersafe.app`
- Update `pubspec.yaml`, `android/app/build.gradle`, `AndroidManifest.xml`

---

### Server – JWT Auth Middleware

#### [NEW] `src/middlewares/authMiddleware.js`
- Verify `Bearer <token>` header using `jsonwebtoken`
- Attach `req.user` for downstream controllers

#### [MODIFY] `src/services/userService.js`
- `verifyOTP()` now returns a signed JWT + refresh token
- Add `refreshToken()` method

#### [MODIFY] `src/controllers/userController.js`
- `otpVerification` returns `{ token, refreshToken, user }`

#### [MODIFY] `src/routes/v1/userRoutes.js`
- Add `POST /refreshToken` endpoint
- Add `authMiddleware` to all protected routes

---

## PHASE 1-A – UI Redesign (Material 3 + Glassmorphism)
*Highest visual impact; done early so all future screens follow the design system.*

### Client Only

#### [MODIFY] All view files (13 views)
- **`login_signup.dart`** → Beautiful email entry screen with animated logo, gradient background, glassmorphic card
- **`mobile_otp.dart`** → OTP input with auto-focus, resend countdown timer, success animation
- **`tell_more.dart`** → Profile onboarding with animated step indicator
- **`homepage.dart`** → New bottom navigation bar (Documents, Search, QR, Maps, Settings), skeleton loaders on initial load
- **`your_documents.dart`** → Card-grid layout with Hero animations, category chips, quick-action FAB
- **`categories.dart`** → Animated category tiles with gradient icons
- **`favourites.dart`** → Filtered view with shimmer loading
- **`view_documents.dart`** → Full-screen document viewer with pinch-zoom
- **`add_document.dart`** / **`add_documents.dart`** → Redesigned bottom sheet flow
- **`delete_documents.dart`** → Modern confirmation bottom sheet
- **`settings.dart`** → Profile card + settings tiles with icons

#### [NEW] `lib/core/widgets/`
- `glass_card.dart` – reusable glassmorphic container
- `gradient_button.dart` – animated gradient CTA button  
- `skeleton_loader.dart` – shimmer placeholder
- `document_card.dart` – card with icon, title, category badge, quick actions
- `custom_bottom_nav.dart` – Material 3 NavigationBar
- `animated_app_bar.dart` – collapsible app bar with blur

---

## PHASE 1-B – Biometric Authentication

### Client

#### [NEW] `lib/features/biometric/biometric_service.dart`
- `canAuthenticate()` → check hardware support
- `authenticate(reason)` → trigger local_auth
- `setBiometricEnabled(bool)` → store in `flutter_secure_storage`
- `isBiometricEnabled()` → read preference

#### [MODIFY] `lib/core/router/app_router.dart`
- On app resume from background (> 5 min idle), redirect to `/biometric-lock`
- Before opening sensitive doc, gate behind biometric check

#### [NEW] `lib/features/biometric/biometric_lock_screen.dart`
- Fingerprint / Face ID prompt UI
- Fallback PIN entry

#### [MODIFY] `lib/views/settings.dart`
- Toggle: "Enable Biometric Lock"
- Toggle: "Lock on sensitive documents"
- Slider: "Auto-lock after X minutes"

### Server – No changes needed for Phase 1-B

---

## PHASE 1-C – OCR Smart Document Scanner

### Client

#### [NEW] `lib/features/scanner/scanner_screen.dart`
- Camera live preview using `google_mlkit_document_scanner`
- Auto edge detection overlay (draw bounding polygon)
- Capture → crop → run `google_mlkit_text_recognition`
- Show "Scanning…" Lottie animation

#### [NEW] `lib/features/scanner/ocr_service.dart`
- `recognizeText(InputImage image) → RecognizedText`
- `detectDocumentType(String text) → DocumentType` (regex patterns for Aadhaar 12-digit, PAN 10-char alphanumeric, etc.)
- `extractAadhaarDetails(String text) → Map` (name, dob, gender, number)
- `extractPANDetails(String text) → Map` (name, dob, number)

#### [MODIFY] `lib/views/add_document.dart`
- Add "Scan Document" button that opens `ScannerScreen`
- On scan complete → auto-fill form fields from extracted data
- User can review and confirm before upload

### Server – No changes needed for Phase 1-C (OCR is client-side via ML Kit)

---

## PHASE 1-D – AI Assistant (Gemini API)

### Client

#### [NEW] `lib/features/ai/ai_service.dart`
- Initialize `GenerativeModel` with Gemini 1.5 Flash
- `summarizeDocument(String ocrText) → String`
- `chatWithDocument(String ocrText, String question) → String` (multi-turn)
- `categorizeDocument(String ocrText) → DocumentCategory`
- `extractExpiryDate(String ocrText) → DateTime?`

#### [NEW] `lib/features/ai/ai_assistant_screen.dart`
- Floating AI chat bubble on document view screen
- Chat UI (messages list, input bar, send button)
- "Summarize this document" quick action
- "When does this expire?" quick action

#### [NEW] `lib/features/ai/document_summary_card.dart`
- Widget showing AI-generated summary below document viewer
- Expandable "Key Facts" section

### Server – AI Categorization Endpoint (optional server-side)

#### [NEW] `src/utils/ai/geminiHelper.js`
- Wraps Google Generative AI Node.js SDK
- `categorizeDocument(text)` → returns category label
- Used by upload endpoint to auto-tag documents server-side

#### [MODIFY] Upload controllers (all)
- After saving image, extract text from Cloudinary-returned URL via OCR (or accept OCR text from client)
- Save `category`, `aiSummary`, `expiryDate` to MongoDB document schema

---

## PHASE 1-E – QR Code Features

### Client

#### [NEW] `lib/features/qr/qr_scanner_screen.dart`
- `mobile_scanner` live camera view
- Parse QR → detect type (URL, WiFi, Text, UPI, Ticket)
- Show parsed result card with action buttons (open URL, connect WiFi, copy text)

#### [NEW] `lib/features/qr/qr_generator_screen.dart`
- Select document → generate QR with `qr_flutter`
- QR encodes a secure shareable link (signed URL from server)
- Share / download QR image

#### [NEW] `src/utils/qr/qrLinkGenerator.js`  *(Server)*
- `generateSignedUrl(userId, docType, expiresInMinutes)` → short-lived signed URL
- `verifySignedUrl(token)` → returns document data

#### [NEW] `src/routes/v1/shareRoutes.js`  *(Server)*
- `POST /api/v1/share/generate` → returns signed URL
- `GET /api/v1/share/:token` → returns document (no auth required, time-limited)

---

## PHASE 2-A – Nearby Sharing (Bluetooth + WiFi)

### Client

#### [NEW] `lib/features/nearby_sharing/nearby_service.dart`
- Wrap `nearby_connections` package
- `startAdvertising()` – device is sender
- `startDiscovery()` – device is receiver
- `sendPayload(Payload)` → send file bytes
- `listenForPayload()` → receive file, save to temp dir

#### [NEW] `lib/features/nearby_sharing/nearby_screen.dart`
- Discovery list: nearby devices with animated pulse indicator
- Transfer progress: circular progress + file name
- Receive confirmation dialog
- Success/fail animation

### Server – No changes needed for Phase 2-A

---

## PHASE 2-B – Google Maps Integration

### Client

#### [NEW] `lib/features/maps/maps_screen.dart`
- `google_maps_flutter` map with current location marker
- Bottom sheet with category tabs: Passport Office | RTO | Bank | Hospital
- Tap on marker → show info card (name, distance, directions button)

#### [NEW] `lib/features/maps/places_service.dart`
- Use Google Places API (Nearby Search) via `dio`
- `searchNearby(LatLng position, String type) → List<PlaceResult>`

### Server

#### [NEW] `src/utils/maps/placesHelper.js`
- Proxy for Google Places API (keep API key server-side)
- `GET /api/v1/places/nearby?lat=&lng=&type=` endpoint

---

## PHASE 2-C – Smart Search

### Client

#### [NEW] `lib/features/search/search_service.dart`
- Local SQLite index (`sqflite`) storing `(docId, docType, ocrText, category, uploadDate)`
- `search(String query) → List<SearchResult>` (full-text match on ocrText)
- `filter(category?, dateRange?, isFavorite?) → List<SearchResult>`

#### [NEW] `lib/features/search/search_screen.dart`
- Search bar with animated expand
- Filter chips (category, date, favourite)
- Result list with highlighted matched text
- Recent searches history

---

## PHASE 2-D – Smart Notifications

### Client

#### [NEW] `lib/features/notifications/notification_service.dart`
- Initialize `flutter_local_notifications`
- `scheduleExpiryReminder(String docId, DateTime expiryDate)`
- `cancelReminder(String docId)`
- `showImmediateNotification(String title, String body)`

#### [NEW] `lib/features/notifications/expiry_checker.dart`
- `WorkManager` background task that runs daily
- Fetch all docs with `expiryDate` from local DB
- Schedule notifications 30/7/1 day before expiry

---

## PHASE 3-A – Dashboard Analytics

### Client

#### [NEW] `lib/features/dashboard/dashboard_screen.dart`
- Storage ring chart (Cloudinary usage)
- Document count by category (bar chart using `fl_chart`)
- Recently accessed timeline
- Trash bin with restore option

#### [MODIFY] `lib/views/homepage.dart`
- Replace static home with new dashboard as default tab

---

## PHASE 3-B – PDF Support

### Client

#### [MODIFY] All upload flows
- Accept PDF via `file_picker`
- Preview PDF via `syncfusion_flutter_pdfviewer`

### Server

#### [MODIFY] Upload controllers + Multer config
- Allow `application/pdf` MIME type
- Store PDFs on Cloudinary as raw files

---

## PHASE 3-C – Activity Timeline & Trash

### Client

#### [NEW] `lib/features/documents/activity_timeline.dart`
- List of timestamped events (uploaded, viewed, shared, deleted)
- Stored locally in SQLite

#### [NEW] `lib/features/documents/trash_screen.dart`
- Soft-delete: move to trash (keep in DB with `deletedAt`)
- Restore or permanently delete
- Auto-purge after 30 days

### Server

#### [MODIFY] All document schemas
- Add `deletedAt: { type: Date, default: null }`
- Soft-delete routes: `PATCH /api/v1/:docType/trash/:id`
- Restore: `PATCH /api/v1/:docType/restore/:id`

---

## Verification Plan

### Automated Tests
```bash
# Flutter unit tests
flutter test

# Flutter integration test (auth flow)
flutter test integration_test/auth_test.dart

# Server unit tests
cd server && npm test
```

### Manual Verification per Phase
| Phase | Verification |
|-------|-------------|
| 0 – Foundation | App builds, existing auth & document upload/view still work |
| 1-A – UI | All screens visually reviewed on Android emulator |
| 1-B – Biometric | Fingerprint lock/unlock on physical Android device |
| 1-C – OCR | Scan Aadhaar image → fields auto-filled correctly |
| 1-D – AI | Tap "Summarize" on document → AI summary appears |
| 1-E – QR | Scan QR ticket → type detected; generate QR → another device views doc |
| 2-A – Nearby | Two Android devices transfer a document successfully |
| 2-B – Maps | Current location shown; nearby banks visible |
| 2-C – Search | Search by Aadhaar number (from OCR text) returns result |
| 2-D – Notifications | Set expiry date → notification fires at correct time |
| 3-A – Dashboard | Storage stats and chart rendered correctly |
| 3-B – PDF | Upload + preview PDF document |
| 3-C – Timeline | Upload doc → event appears in timeline |

---

## Implementation Order Summary

```
Phase 0  →  Phase 1-A  →  Phase 1-B  →  Phase 1-C  →  Phase 1-D  →  Phase 1-E
  ↓
Phase 2-A  →  Phase 2-B  →  Phase 2-C  →  Phase 2-D
  ↓
Phase 3-A  →  Phase 3-B  →  Phase 3-C
```

Each phase is self-contained and the app is **shippable after each phase completes**.
