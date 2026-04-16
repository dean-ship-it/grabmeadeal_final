# GrabMeADeal — Project Status & Handoff Brief
**Last Updated:** April 16, 2026
**Developer:** Dean Andrew Pick | Origin Environmental, Houston TX
**Claude Session:** Multi-day build — Day 2

---

## App Identity
- **App Name:** Grab Me A Deal
- **Package:** com.example.grabmeadeal_final (update to com.grabmeadeal.app for Play Store)
- **Version:** 1.0.0 (build 1)
- **Framework:** Flutter (Dart SDK >=3.8, Flutter >=3.29)
- **Platform:** Android-first (Samsung S23+ tested), Web deployed
- **Backend:** Firebase (Firestore, Auth, FCM, Hosting)

---

## Live URLs
- **Web App:** https://grab-me-a-deal-e69ae.web.app
- **Privacy Policy:** https://grab-me-a-deal-e69ae.web.app/privacy-policy.html
- **Firebase Project:** grab-me-a-deal-e69ae
- **GitHub Repo:** https://github.com/dean-ship-it/grabmeadeal_final

---

## Brand Colors
| Color | Hex | Use |
|-------|-----|-----|
| Primary Blue | #0075C9 | AppBar, buttons, banners |
| Light Blue | #5BBEFF | Highlights, accents |
| Deep Blue Shadow | #004A8D | Backgrounds, depth |
| Lime Green | #A6CE39 | CTAs, success, progress |
| Olive Green | #7A9A01 | Secondary accents |

---

## Completed Features

### Core Architecture
- [x] Clean Flutter architecture — zero prop drilling
- [x] Provider state management (WishlistProvider, PuzzleProvider, WantListProvider)
- [x] Firebase Auth — Google Sign-In + Email/Password
- [x] Free browsing — no login required to view deals
- [x] Auth gate — prompts sign-in only on action (wishlist, want list, puzzle)
- [x] Named routing — AppRoutes with full screen registry
- [x] Firestore security rules deployed

### Deals
- [x] Live Firestore deal stream
- [x] Featured Deal + 2-column grid layout
- [x] Deal cards with CachedNetworkImage + category emoji fallbacks
- [x] Savings badge (-X%) on deal cards
- [x] Strikethrough original price
- [x] Category chip on cards
- [x] Deal detail screen with full info
- [x] "View Deal" button with URL launcher
- [x] 10 seeded deals with real Unsplash images

### Category System
- [x] 16 categories in DealCategory enum with emoji icons
- [x] Horizontal scrollable category banner on deals screen
- [x] Categories grid screen
- [x] Category deals screen — filtered Firestore stream per category

### Search
- [x] Search bar on deals screen
- [x] Full search results screen with Firestore client-side filtering
- [x] Real-time search as user types
- [x] Result count display

### Wishlist 2.0
- [x] Saved Deals tab — heart deals to save
- [x] Want List tab — add items by keyword, max price, category
- [x] Firestore storage per user (users/{uid}/wants/)
- [x] Toggle active/inactive on want items
- [x] Delete want items
- [x] Sign-in bottom sheet for unauthenticated users
- [x] Clear all saved deals with confirmation dialog

### Puzzle Rewards System
- [x] 8-piece circular puzzle — one piece per big ticket category
- [x] Pieces unlock when user views deal in that category
- [x] Animated piece snap into circle on unlock
- [x] Progress bar (X/8 pieces)
- [x] Spin-to-Win roulette wheel on puzzle completion
- [x] 8 prize segments ($100-$500 gift cards, 10-20% off)
- [x] User chooses gift certificate OR % off future purchase
- [x] Firestore progress tracking per user
- [x] PuzzleProvider with singleton pattern

### Notifications
- [x] FCM push notifications wired (firebase_messaging)
- [x] Android notification channel configured
- [x] Background message handler
- [x] FCM token stored in Firestore per user
- [x] Notifications screen with subscription banner
- [x] "deals_alerts" FCM topic subscription

### Want List Matching Engine
- [x] Node.js scraper in functions/
- [x] CJ Affiliate scraper (needs API credentials)
- [x] ShareASale scraper (needs API credentials)
- [x] Local/Craigslist scraper for Houston, Dallas, SA, Austin
- [x] Want matcher — checks all user wants against new deals
- [x] FCM push alert on keyword+price+category match
- [x] Notification written to Firestore on match
- [x] Scheduled Cloud Function — runs every 6 hours
- [x] HTTP trigger endpoint for manual sync

### Admin Tools
- [x] Admin upload screen — full deal upload form
- [x] Admin login screen — Google Sign-In with Firestore whitelist check
- [x] Category dropdown on upload form
- [x] Original price / current price fields
- [x] Temp FAB button on deals screen for admin access (REMOVE BEFORE LAUNCH)

### Android & Build
- [x] Running on Samsung S23+ (Android 16, API 36)
- [x] Flutter embedding v2
- [x] Gradle 8.9, AGP 8.7.3
- [x] Core library desugaring enabled
- [x] Release keystore generated (android/grabmeadeal-release.jks)
- [x] Release AAB built — 54MB at android/app/build/outputs/bundle/release/app-release.aab
- [x] Android launcher icons generated — all sizes
- [x] Play Store icon 512x512 at assets/logo/play_store_icon.png

### Web & Deployment
- [x] Flutter web build deployed to Firebase Hosting
- [x] Privacy policy HTML deployed and live
- [x] Firebase service worker configured (firebase-messaging-sw.js)
- [x] Google Sign-In OAuth client ID in web/index.html

---

## File Structure
lib/
├── models/
│   ├── deal.dart                    # Core deal model with legacy field support
│   ├── deal_category.dart           # 16-category enum with emoji + label
│   ├── puzzle_progress.dart         # Puzzle state model
│   └── want_item.dart               # Want list item model
├── providers/
│   ├── wishlist_provider.dart       # Saved deals state
│   ├── puzzle_provider.dart         # Puzzle progress + wheel segments
│   └── want_list_provider.dart      # Want list CRUD + Firestore sync
├── routes/
│   └── app_routes.dart              # All named routes registered
├── screens/
│   ├── auth_gate.dart               # Routes to MainTabController directly
│   ├── auth_screen.dart             # Email/password + Google Sign-In
│   ├── main_tab_controller.dart     # IndexedStack tab controller
│   ├── deals_screen.dart            # Home feed with category banner + search
│   ├── deal_detail_screen.dart      # Full deal view + notify me nearby
│   ├── wishlist_screen.dart         # Two-tab: Saved Deals + Want List
│   ├── categories_screen.dart       # 2-column category grid
│   ├── category_deals_screen.dart   # Filtered deals by category
│   ├── search_results_screen.dart   # Full-text client-side search
│   ├── notifications_screen.dart    # FCM notification history
│   ├── puzzle_reward_screen.dart    # Puzzle + Spin-to-Win wheel
│   ├── admin_upload_screen.dart     # Deal upload form
│   └── admin_login_screen.dart      # Admin Google Sign-In + whitelist check
├── services/
│   ├── notification_service.dart    # FCM singleton + local notifications
│   └── geofence_service.dart        # Geolocator + proximity alerts singleton
├── widgets/
│   ├── deal_card.dart               # Deal card with image fallback + savings
│   ├── search_bar.dart              # Reusable search widget
│   └── bottom_nav_bar.dart          # 3-tab bottom nav
└── main.dart                        # Firebase init + MultiProvider + MaterialApp
functions/
├── scrapers/
│   ├── cj_scraper.js               # CJ Affiliate API (needs credentials)
│   ├── shareasale_scraper.js        # ShareASale API (needs credentials)
│   ├── local_deals_scraper.js       # Craigslist TX cities scraper
│   ├── want_matcher.js              # Matches user wants to new deals
│   └── run_all.js                   # Runs all scrapers + matcher
├── firebase_init.js                 # Firebase Admin SDK init
└── index.js                         # Cloud Functions (scheduled + HTTP)
tools/
├── seed_deals.js                    # Seeded 10 deals to Firestore
├── clean_old_deals.js               # Removed broken/empty deals
└── generate_icons.js                # Generated all Android icon sizes
web/
├── index.html                       # Google OAuth client ID meta tag
├── firebase-messaging-sw.js         # FCM service worker for web
└── privacy-policy.html              # Live privacy policy page
android/
├── app/
│   ├── build.gradle.kts             # Signed release build config
│   ├── google-services.json         # Firebase Android config
│   └── src/main/AndroidManifest.xml # Permissions + FCM config
├── key.properties                   # Keystore credentials (NOT in Git)
├── grabmeadeal-release.jks          # Release keystore (NOT in Git)
└── settings.gradle.kts              # Flutter 3.32 plugin management

---

## Known Issues & Tech Debt

| Issue | Priority | Notes |
|-------|----------|-------|
| Temp FAB admin button on deals screen | 🔴 HIGH | Remove before Play Store submission |
| Package name com.example vs com.grabmeadeal.app | 🔴 HIGH | Register com.grabmeadeal.app in Firebase then update |
| Deal card grid overflow on mobile | 🟡 MED | 18px overflow in 2-col grid — reduce image/padding |
| Old deals in Firestore with $0 price | 🟡 MED | Run clean_old_deals.js to purge |
| Firestore orderBy createdAt needs index | 🟡 MED | Create composite index in Firebase console |
| CJ Affiliate API credentials missing | 🟡 MED | Sign up at cj.com — account created, apply to merchants |
| ShareASale API credentials missing | 🟡 MED | Sign up at shareasale.com |
| Geofence real-time not yet active | 🟢 LOW | Infrastructure built, needs background location handling |
| Prize claim phone verification | 🟢 LOW | Firebase Phone Auth — build when prize claim flow built |
| Trending section | 🟢 LOW | Build after launch when user data exists |

---

## Affiliate Networks — Sign Up Status

| Network | URL | Status | Priority |
|---------|-----|--------|----------|
| CJ Affiliate | cj.com | ✅ Account created | Apply to merchants |
| ShareASale | shareasale.com | ⏳ Sign up needed | High |
| Amazon Associates | affiliate-program.amazon.com | ⏳ Sign up needed | Critical |
| Rakuten Advertising | rakutenadvertising.com | ⏳ Sign up needed | Medium |
| Impact | impact.com | ⏳ Sign up needed | Medium |
| eBay Partner Network | partnernetwork.ebay.com | ⏳ Sign up needed | Low |

---

## Play Store Status

| Item | Status |
|------|--------|
| Google Play Developer Account | ✅ Created |
| Identity Verification | ✅ Verified |
| Phone Number Verification | ⏳ Pending |
| App Listing Created | ⏳ Pending — Create app button unlocks after verification |
| Release AAB | ✅ Built — 54MB signed |
| App Icon 512x512 | ✅ Ready |
| Privacy Policy URL | ✅ Live |
| Play Store Screenshots | ⏳ Needed — min 2 phone screenshots |
| Short Description | ✅ Written |
| Full Description | ✅ Written |
| Content Rating | ⏳ Complete questionnaire in Play Console |

---

## Next Session Priorities

### Immediate (Do First)
1. Fix deal card grid overflow — reduce image width 80→72, padding 12→8
2. Add "You could save $X today" savings banner to deals screen
3. Add "Notify Me Nearby" button to deal detail screen
4. Remove temp FAB admin button from deals screen
5. Create Play Store app listing and upload AAB

### Short Term
6. Register com.grabmeadeal.app in Firebase console
7. Sign up ShareASale + Amazon Associates
8. Enter CJ API credentials in functions/.env
9. Build prize claim flow with Firebase Phone Auth verification
10. Add Firestore composite index for createdAt ordering

### Medium Term
11. Personalized home feed ("Deals for you" based on want list)
12. Dynamic deal count — "247 deals found today near Houston"
13. Geofencing real-time alerts with background location
14. User profile screen
15. Admin dashboard with deal management

---

## Working Rules (Non-Negotiable)
- Full file replacements only — no partial patches
- Every file includes correct path as comment on line 1
- Production-ready, defensible code only
- Build in logical phase order
- Claude Code executes — Claude Chat architects
- 10% efficiency rule — switch tools when >10% gain available

---

## Passwords & Credentials (Store Securely — Never Commit)
- Keystore password: GrabMeADeal2026!
- Keystore alias: grabmeadeal
- Keystore file: android/grabmeadeal-release.jks
- Firebase project: grab-me-a-deal-e69ae
- CJ Account: dean@amresto.com

---

*Generated by Claude Sonnet 4.6 — GrabMeADeal Build Session*
