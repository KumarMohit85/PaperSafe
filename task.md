# PaperSafe v2.0 – Task Tracker

## PHASE 0 – Foundation & Cleanup
### 0.1 Package Rename (Flutter)
- [x] Rename `_first_one` → `com.papersafe.app` in `pubspec.yaml`
- [x] Update `android/app/build.gradle` applicationId
- [x] Update `android/app/src/main/AndroidManifest.xml` package
- [x] Update all `import 'package:_first_one/...'` → `package:papersafe/...`
- [ ] Rename `android/app/src/main/kotlin/com/_first_one/` folder structure
- [ ] Update `ios/Runner.xcodeproj` Bundle Identifier

### 0.2 Dependencies (pubspec.yaml)
- [x] Add all v2.0 packages (Riverpod, GoRouter, ML Kit, Gemini, etc.)
- [/] Run `flutter pub get` (in progress)

### 0.3 Core Architecture (Flutter)
- [x] Create `lib/core/theme/app_colors.dart` (color palette)
- [x] Create `lib/core/theme/app_theme.dart` (Material 3 ColorScheme, typography)
- [x] Create `lib/core/theme/theme_provider.dart` (Riverpod dark/light toggle)
- [x] Create `lib/core/router/app_router.dart` (GoRouter with guards)
- [x] Create `lib/core/providers/auth_provider.dart` (Riverpod auth state)
- [x] Create `lib/core/services/secure_storage_service.dart` (JWT + user storage)
- [x] Create `lib/core/constants/` (colors, strings, dimensions)
- [ ] Migrate `UserManager` singleton → Riverpod AsyncNotifierProvider
- [ ] Migrate `DocumentManager` singleton → Riverpod StateNotifierProvider
- [x] Update `lib/main.dart` (ProviderScope, GoRouter)

### 0.4 JWT Auth (Server)
- [x] Install `jsonwebtoken` npm package
- [x] Create `src/middlewares/authMiddleware.js`
- [x] Create `src/utils/helper/jwtHelper.js`
- [x] Modify `src/services/userService.js` → `verifyOTP` returns JWT
- [x] Modify `src/controllers/userController.js` → return token in response
- [x] Add `POST /api/v1/refreshToken` route
- [x] Protect all document routes with `authMiddleware`

### 0.5 Flutter JWT Integration
- [x] Modify `ApiService` → attach `Authorization: Bearer <token>` header
- [x] Store token in `flutter_secure_storage` (not SharedPreferences)
- [x] Implement token refresh interceptor in Dio

---

## PHASE 1-A – UI Redesign
### 1-A.1 Design System
- [ ] `lib/core/theme/app_theme.dart` – full Material 3 theme
- [ ] `lib/core/theme/app_colors.dart` – palette tokens
- [ ] `lib/core/widgets/glass_card.dart`
- [ ] `lib/core/widgets/gradient_button.dart`
- [ ] `lib/core/widgets/skeleton_loader.dart`
- [ ] `lib/core/widgets/document_card.dart`
- [ ] `lib/core/widgets/custom_bottom_nav.dart`
- [ ] `lib/core/widgets/animated_app_bar.dart`

### 1-A.2 Screens
- [ ] Redesign `login_signup.dart`
- [ ] Redesign `mobile_otp.dart`
- [ ] Redesign `tell_more.dart` (onboarding)
- [ ] Redesign `homepage.dart` → new bottom nav shell
- [ ] Redesign `your_documents.dart` → card grid + Hero
- [ ] Redesign `categories.dart`
- [ ] Redesign `favourites.dart`
- [ ] Redesign `view_documents.dart` → pinch zoom
- [ ] Redesign `add_document.dart` / `add_documents.dart`
- [ ] Redesign `delete_documents.dart` → bottom sheet
- [ ] Redesign `settings.dart`

---

## PHASE 1-B – Biometric Authentication
- [ ] Create `lib/features/biometric/biometric_service.dart`
- [ ] Create `lib/features/biometric/biometric_lock_screen.dart`
- [ ] Add biometric toggle in settings
- [ ] Add auto-lock timer (inactivity detection)
- [ ] Add biometric gate before sensitive document view
- [ ] Update router guards for biometric lock

---

## PHASE 1-C – OCR Scanner
- [ ] Create `lib/features/scanner/scanner_screen.dart`
- [ ] Create `lib/features/scanner/ocr_service.dart`
- [ ] Implement document type detection (Aadhaar / PAN / etc.)
- [ ] Implement field extraction per document type
- [ ] Integrate auto-fill into `add_document.dart`

---

## PHASE 1-D – AI Assistant
- [ ] Create `lib/features/ai/ai_service.dart` (Gemini client)
- [ ] Create `lib/features/ai/ai_assistant_screen.dart` (chat UI)
- [ ] Create `lib/features/ai/document_summary_card.dart`
- [ ] Add AI categorization on upload
- [ ] Add expiry date extraction + store locally

---

## PHASE 1-E – QR Features
- [ ] Create `lib/features/qr/qr_scanner_screen.dart`
- [ ] Create `lib/features/qr/qr_generator_screen.dart`
- [ ] Create `src/utils/qr/qrLinkGenerator.js` (server)
- [ ] Create `src/routes/v1/shareRoutes.js` (server)

---

## PHASE 2-A – Nearby Sharing
- [ ] Create `lib/features/nearby_sharing/nearby_service.dart`
- [ ] Create `lib/features/nearby_sharing/nearby_screen.dart`
- [ ] Handle Android (nearby_connections) + iOS (flutter_p2p_connection)

---

## PHASE 2-B – Google Maps
- [ ] Create `lib/features/maps/maps_screen.dart`
- [ ] Create `lib/features/maps/places_service.dart`
- [ ] Create `src/utils/maps/placesHelper.js` + route (server)

---

## PHASE 2-C – Smart Search
- [ ] Create `lib/features/search/search_service.dart` (SQLite index)
- [ ] Create `lib/features/search/search_screen.dart`
- [ ] Index OCR text on scan/upload

---

## PHASE 2-D – Smart Notifications
- [ ] Create `lib/features/notifications/notification_service.dart`
- [ ] Create `lib/features/notifications/expiry_checker.dart`
- [ ] Schedule background WorkManager task

---

## PHASE 3-A – Dashboard Analytics
- [ ] Create `lib/features/dashboard/dashboard_screen.dart`
- [ ] Integrate `fl_chart` for category bar chart
- [ ] Add storage ring chart

---

## PHASE 3-B – PDF Support
- [ ] Add `file_picker` PDF support to upload flows
- [ ] Add `syncfusion_flutter_pdfviewer` to view screen
- [ ] Update Multer on server to accept PDF MIME type

---

## PHASE 3-C – Activity Timeline & Trash
- [ ] Create `lib/features/documents/activity_timeline.dart`
- [ ] Create `lib/features/documents/trash_screen.dart`
- [ ] Add `deletedAt` field to all MongoDB schemas
- [ ] Add soft-delete routes on server
