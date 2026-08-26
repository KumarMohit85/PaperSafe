# PaperSafe v2.0 – Feature Implementation Roadmap

> **How to use this file**: We implement **one phase at a time**. When a phase is done, mark it `[x]`. Never start the next phase until the current one is stable and tested.

---

## Status Legend
- `[ ]` — Not started
- `[/]` — In progress
- `[x]` — Done and tested

---

## Phase 0 – Foundation (COMPLETE)

Everything below is already implemented and working:

- [x] **Riverpod** state management (flutter_riverpod ^2.5.1)
  - authProvider (AsyncNotifierProvider)
  - biometricEnabledProvider (StateNotifierProvider)
  - isAppLockedProvider (StateProvider)
  - themeModeProvider (StateProvider)
- [x] **GoRouter** navigation with auth + biometric guards
  - ShellRoute for bottom nav (5 tabs)
  - Path params: /otp/:email, /tell-more/:email
  - Redirect logic: unauth to /login, locked to /biometric-lock
- [x] **Material 3 Theme** (dark + light) with AppColors + AppTheme
- [x] **SecureStorageService** — JWT + user stored encrypted
- [x] **Mock backend mode** (useMockBackend = true in ApiService)
- [x] **ScreenUtil** responsive sizing (390x844 baseline)
- [x] All service stubs: BiometricService, OCRService, NearbyService, SearchService, NotificationService, ExpiryCheckerService, AIService

---

## Phase 1 – Core Document Screens

### Phase 1-A: Document Vault (your_documents.dart)

**Goal**: Main home screen showing all stored documents beautifully.

**Files to modify/create**:
- [ ] lib/views/your_documents.dart — full redesign
- [ ] lib/Widgets/document_card.dart — premium card widget

**Checklist**:
- [ ] Animated header with user greeting + avatar
- [ ] Stats row: total docs, categories count
- [ ] Category filter chips (All / Identity / Education / Tickets)
- [ ] Document grid (GridView.builder) with Hero animation on tap
- [ ] Shimmer skeleton loading state
- [ ] Pull-to-refresh (RefreshIndicator)
- [ ] Empty state with illustration + CTA button
- [ ] FAB to navigate to add document

**Dart concepts**: FutureBuilder, GridView.builder, Hero, RefreshIndicator, Shimmer, AnimatedSwitcher

**Acceptance Criteria**:
- [ ] Documents load from DocumentManager on init
- [ ] Category chip filters the grid
- [ ] Tap opens document with Hero animation
- [ ] Pull-to-refresh re-downloads documents
- [ ] Empty state shows when no documents exist

---

### Phase 1-B: Document Upload (add_document.dart)

**Goal**: Smooth guided document upload flow.

**Files to modify/create**:
- [ ] lib/views/add_document.dart — redesign
- [ ] lib/views/add_documents.dart — batch flow

**Checklist**:
- [ ] Document type selector (bottom sheet with animated options)
- [ ] Image source picker: Camera vs Gallery
- [ ] Image preview with retake option
- [ ] Number field for Aadhaar/PAN number
- [ ] Upload button with animated loading progress
- [ ] Success animation (Lottie or AnimatedCheckmark)
- [ ] Error handling with retry

**Dart concepts**: image_picker, FormData/MultipartFile via Dio, AnimatedContainer, showModalBottomSheet, setState for loading state

**Acceptance Criteria**:
- [ ] Pick image from camera and gallery
- [ ] Preview shown before upload
- [ ] Upload shows progress indicator
- [ ] Success message after upload
- [ ] Document appears in vault after upload

---

### Phase 1-C: Biometric Lock Screen (biometric_lock_screen.dart)

**Goal**: Fingerprint/Face ID gate on app open.

**Files to modify/create**:
- [ ] lib/views/biometric_lock_screen.dart — redesign
- [ ] lib/views/settings.dart — biometric toggle section

**Checklist**:
- [ ] Logo + locked UI design
- [ ] Fingerprint icon button triggers BiometricService.authenticate()
- [ ] Animated unlock transition on success
- [ ] Settings toggle: Enable Biometric Lock
- [ ] Auto-prompt on screen open (initState)

**Dart concepts**: local_auth, WidgetsBindingObserver, isAppLockedProvider, AnimatedOpacity

**Acceptance Criteria**:
- [ ] App locks when minimized
- [ ] Biometric prompt on lock screen open
- [ ] Auth success navigates to vault
- [ ] Toggle in settings persists across restarts
- [ ] PIN fallback works

---

## Phase 2 – Smart Features

### Phase 2-A: OCR Document Scanner (scanner_page.dart)

**Goal**: Point camera at document, auto-detect type, extract fields.

**Files to modify/create**:
- [ ] lib/views/scanner_page.dart — complete implementation
- [ ] lib/core/services/ocr_service.dart — wire to UI

**Checklist**:
- [ ] Camera live preview (camera plugin)
- [ ] Capture button with shutter animation
- [ ] Scanning Lottie animation overlay
- [ ] Run OCRService.processImage() on captured image
- [ ] Result card: detected type + extracted fields
- [ ] Use this document button → pre-filled upload form
- [ ] Retake option

**Dart concepts**: camera plugin, CameraController, CameraPreview, google_mlkit_text_recognition, InputImage.fromFilePath, Stack widget for overlay

**Acceptance Criteria**:
- [ ] Camera opens with live preview
- [ ] Capture takes photo
- [ ] OCR shows raw text + detected type
- [ ] Aadhaar number extracted from Aadhaar card
- [ ] PAN number extracted from PAN card

---

### Phase 2-B: Smart Search (search_page.dart)

**Goal**: Find any document by name, category, or OCR text.

**Files to modify/create**:
- [ ] lib/views/search_page.dart — complete implementation
- [ ] lib/core/services/search_service.dart — wire indexing to uploads

**Checklist**:
- [ ] Animated search bar (expands on focus)
- [ ] Category filter chips
- [ ] Real-time search results as user types (debounced 300ms)
- [ ] Result cards with matched text highlighted
- [ ] Recent searches list from SQLite
- [ ] Clear history button
- [ ] Empty search state

**Dart concepts**: sqflite LIKE queries, TextEditingController + addListener, Timer for debounce, TextSpan for text highlighting, AnimatedList

**Acceptance Criteria**:
- [ ] Search bar auto-focuses on open
- [ ] Typing shows matching documents
- [ ] Category filter narrows results
- [ ] Recent searches shown on empty query
- [ ] Tapping result opens document

---

### Phase 2-C: QR Scanner + Generator

**Goal**: Scan any QR code + generate shareable document QR codes.

**Files to modify/create**:
- [ ] lib/views/qr_scanner_page.dart — complete implementation
- [ ] lib/views/qr_generator_page.dart — complete implementation

**QR Scanner Checklist**:
- [ ] mobile_scanner live view with scan frame overlay
- [ ] Detect type: URL / text / UPI / barcode
- [ ] Result card with action buttons (Open URL / Copy / Pay)
- [ ] Flashlight toggle
- [ ] Scan history (last 5)

**QR Generator Checklist**:
- [ ] Document selector from vault
- [ ] QrImageView from qr_flutter
- [ ] Share QR as image via share_plus
- [ ] Size/error correction options

**Dart concepts**: mobile_scanner, MobileScannerController, qr_flutter, url_launcher, share_plus, RepaintBoundary for image capture

**Acceptance Criteria**:
- [ ] Scanner reads QR live
- [ ] URL detected → Open in Browser button
- [ ] Generator creates QR for document
- [ ] QR shareable via OS share sheet

---

## Phase 3 – Advanced Features

### Phase 3-A: AI Assistant (ai_assistant_page.dart)

**Goal**: Chat with Gemini AI about your documents.

**Files to modify/create**:
- [ ] lib/views/ai_assistant_page.dart — complete implementation
- [ ] lib/core/services/ai_service.dart — enhance for chat context

**Checklist**:
- [ ] Chat UI: messages list (ListView reversed), input bar, send button
- [ ] User bubble (right-aligned gradient) + AI bubble (left-aligned card)
- [ ] Quick action chips: Summarize Aadhaar / Check expiry / List documents
- [ ] Loading typing indicator (animated dots)
- [ ] AIService.sendPrompt() with document context
- [ ] Gemini API key setup prompt
- [ ] Error state for API failures

**Dart concepts**: google_generative_ai, ListView.builder reverse:true, TextEditingController, ScrollController for auto-scroll, streaming responses

**Acceptance Criteria**:
- [ ] Chat opens with welcome + quick chips
- [ ] User types and sends messages
- [ ] AI responds
- [ ] Quick chips produce relevant AI summary
- [ ] Loading indicator shows while waiting

---

### Phase 3-B: Nearby Sharing (nearby_sharing_page.dart)

**Goal**: P2P document transfer between Android devices.

**Files to modify/create**:
- [ ] lib/views/nearby_sharing_page.dart — complete implementation
- [ ] lib/core/services/nearby_service.dart — wire to UI

**Checklist**:
- [ ] Mode toggle: Send / Receive
- [ ] Send: discover devices → list with pulse animation → connect → pick doc → send
- [ ] Receive: advertise → show Waiting → accept file → save to vault
- [ ] Transfer progress indicator (circular)
- [ ] Success / Fail animations
- [ ] Permission check (Location + Nearby Devices)

**Dart concepts**: nearby_connections, startDiscovery, startAdvertising, sendFilePayload, StreamBuilder, permission_handler, AnimationController for pulse

**Acceptance Criteria**:
- [ ] Two devices discover each other
- [ ] File sent and received successfully
- [ ] Progress shown during transfer
- [ ] Works on Android physical devices

---

### Phase 3-C: Google Maps (maps_page.dart)

**Goal**: Find nearby passport offices, RTOs, banks.

**Files to modify/create**:
- [ ] lib/views/maps_page.dart — complete implementation
- [ ] lib/core/services/places_service.dart — complete implementation

**Checklist**:
- [ ] Google Maps widget with current location marker
- [ ] Bottom sheet with category tabs: Passport / RTO / Bank / Hospital
- [ ] Fetch via Google Places API Nearby Search
- [ ] Custom markers per category
- [ ] Tap marker → info card with Get Directions button
- [ ] Directions via url_launcher (Google Maps deep link)
- [ ] Loading skeleton while fetching

**Dart concepts**: google_maps_flutter, GoogleMap widget, Marker, geolocator, DraggableScrollableSheet, BitmapDescriptor, url_launcher

**Acceptance Criteria**:
- [ ] Map shows current location
- [ ] Category tab shows nearby markers
- [ ] Tap marker → info card
- [ ] Directions opens Google Maps
- [ ] Error handled when location denied

---

## Phase 4 – Polish and Analytics

### Phase 4-A: Document Expiry Notifications

**Goal**: Auto-remind before documents expire.

**Files to modify/create**:
- [ ] lib/main.dart — init NotificationService on startup
- [ ] lib/views/add_document.dart — add expiry date field
- [ ] lib/core/services/expiry_checker_service.dart — wire to uploads

**Checklist**:
- [ ] Init NotificationService in main()
- [ ] Expiry date field in upload forms
- [ ] Schedule notifications on upload: 30 / 7 / 1 day before
- [ ] Expired badge in vault grid
- [ ] Settings: Expiry Reminders toggle

**Dart concepts**: flutter_local_notifications, zonedSchedule, timezone package, workmanager background task, notification channels

**Acceptance Criteria**:
- [ ] Service init without crash
- [ ] Expiry date sets notification
- [ ] Notification fires at correct time
- [ ] Expired docs show warning badge

---

### Phase 4-B: Activity Timeline (activity_timeline_page.dart)

**Goal**: Audit log of document interactions.

**Files to modify/create**:
- [ ] lib/views/activity_timeline_page.dart — complete implementation
- [ ] Add activity logging to DocumentManager actions

**Checklist**:
- [ ] SQLite table: activity_log (id, docTitle, action, timestamp)
- [ ] Log: Uploaded / Viewed / Shared / Deleted / Scanned
- [ ] Timeline UI: vertical line + event cards
- [ ] Date grouping: Today / Yesterday / This Week / Older
- [ ] Filter by action type chips
- [ ] Swipe to delete log entry

**Dart concepts**: sqflite, CustomPainter for timeline line, Dismissible for swipe-delete, intl DateFormat relative timestamps, ListView.separated

**Acceptance Criteria**:
- [ ] Events logged to SQLite
- [ ] Timeline in reverse chronological order
- [ ] Date grouping correct
- [ ] Filter chips work
- [ ] Swipe deletes entry

---

### Phase 4-C: Trash and Soft Delete (trash_screen.dart)

**Goal**: Recycle bin with restore option.

**Files to modify/create**:
- [ ] lib/views/trash_screen.dart — complete implementation
- [ ] lib/models/documents_manager.dart — add soft-delete logic

**Checklist**:
- [ ] Soft-delete: mark with deletedAt timestamp locally
- [ ] Trash screen: list with restore / delete buttons
- [ ] Restore → back to vault
- [ ] Delete Forever → call server delete API
- [ ] Auto-purge warning: Items deleted after 30 days
- [ ] Empty trash state

**Dart concepts**: SharedPreferences or SQLite deleted_docs table, Timer for auto-purge, Slidable for swipe actions, ConfirmationDialog, AnimatedList

**Acceptance Criteria**:
- [ ] Delete moves to trash (not permanent)
- [ ] Appears in trash screen
- [ ] Restore returns to vault
- [ ] Delete Forever removes + calls API
- [ ] 30-day countdown shown

---

## Shared UI Patterns

These patterns are used across ALL phases. Implement once, reuse everywhere.

### Glass Card
`
Container with:
  color: Colors.white.withOpacity(0.08)
  border: Colors.white.withOpacity(0.15)
  borderRadius: 20
  BackdropFilter: ImageFilter.blur(sigmaX:10, sigmaY:10)
`

### Gradient Button
`
Container with AppColors.brandGradient
+ InkWell with borderRadius
+ padding: 16.h vertical, 24.w horizontal
`

### Shimmer Skeleton
`
Shimmer.fromColors(
  baseColor: AppColors.surfaceCard,
  highlightColor: AppColors.surface,
  child: Container(height: 120.h, rounded corners)
)
`

---

## Phase Progression

Phase 0 (Done) → Phase 1-A → 1-B → 1-C → Phase 2-A → 2-B → 2-C → Phase 3-A → 3-B → 3-C → Phase 4-A → 4-B → 4-C

**Rule**: Never skip ahead. Confirm before starting each new phase.

---

## Testing Checklist (after every phase)

- [ ] App builds: flutter build apk --debug
- [ ] No console errors on hot restart
- [ ] New screen navigates correctly
- [ ] Back button works
- [ ] Dark mode correct
- [ ] Light mode correct
- [ ] No layout overflow on 360px width screen
- [ ] Mock backend still works

---

Last updated: 2026-08-25 | PaperSafe v2.0
