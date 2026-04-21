# GrabMeADeal — Project Status & Handoff Brief
**Last Updated:** April 17, 2026
**Developer:** Dean Andrew Pick | Origin Environmental, Houston TX
**Claude Session:** Multi-day build — Day 3

---

## App Identity
- **App Name:** Grab Me A Deal
- **Package:** com.grabmeadeal.app
- **Version:** 1.0.1 (build 2)
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
- [x] Google Sign-In fixed on Android — client_type 1 OAuth added for com.grabmeadeal.app
- [x] Free browsing — no login required to view deals
- [x] Auth gate — prompts sign-in only on action (wishlist, want list, puzzle)
- [x] Named routing — AppRoutes with full screen registry
- [x] Firestore security rules deployed

### Deals
- [x] Live Firestore deal stream
- [x] Featured Deal + 2-column grid layout
- [x] Deal cards with CachedNetworkImage + category emoji fallbacks
- [x] Deal card vertical layout — zero overflow
- [x] Savings badge (-X%) on deal cards
- [x] Strikethrough original price
- [x] Category chip on cards
- [x] Deal detail screen with full info
- [x] "View Deal" button with URL launcher — deal links fixed (reads `link` field)
- [x] 49 deals seeded across all categories with real Unsplash images
- [x] Grocery deals seeded — HEB, Costco, Walmart (Texas mom demographic)
- [x] Deal model `dealUrl` field reads `link` from Firestore (View Deal button active)

### Category System
- [x] 11 categories in DealCategory enum with emoji icons (grocery, electronics, gaming, tools, furniture, automotive, beauty, apparel, petSupplies, homeGoods, fitness)
- [x] Category pages loading — all categories working with Firestore queries
- [x] Category deals query fixed — removed orderBy to avoid composite index requirement
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
- [x] Puzzle rewards screen redesigned with animated wheel
- [x] Spin-to-Win roulette wheel on puzzle completion
- [x] 8 prize segments ($100-$500 gift cards, 10-20% off)
- [x] User chooses gift certificate OR % off future purchase
- [x] Prize claim flow with Firebase Phone Auth
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
- [x] Version 1.0.1 AAB built (57MB) and uploaded to Play Store Internal Testing
- [x] Tester link shared with 12 testers
- [x] Android launcher icons generated — all sizes
- [x] Play Store icon 512x512 at assets/logo/play_store_icon.png
- [x] Debug SHA-1 fingerprint registered in Firebase (7C:5A:07:9A:...)
- [x] google-services.json updated with Android OAuth client for com.grabmeadeal.app

### Web & Deployment
- [x] Flutter web build deployed to Firebase Hosting
- [x] Privacy policy HTML deployed and live
- [x] Firebase service worker configured (firebase-messaging-sw.js)
- [x] Google Sign-In OAuth client ID in web/index.html

---

## Firestore Deal Counts (as of April 17, 2026)

| Category | Count |
|----------|-------|
| grocery | 8 |
| electronics | 5 |
| petSupplies | 4 |
| beauty | 4 |
| homeGoods | 4 |
| tools | 4 |
| fitness | 4 |
| automotive | 4 |
| gaming | 4 |
| apparel | 4 |
| furniture | 4 |
| **TOTAL** | **49** |

---

## April 17 Session — Files Changed

| Commit | Files | Description |
|--------|-------|-------------|
| `8e68f93` | `android/app/google-services.json` | Added client_type 1 Android OAuth client for com.grabmeadeal.app |
| | `lib/models/deal.dart` | Fixed dealUrl to read `link` field; fixed imageUrl fallback |
| | `lib/models/deal_category.dart` | Updated enum to 11 categories matching Firestore (added grocery) |
| | `lib/screens/category_deals_screen.dart` | Removed orderBy to avoid composite index requirement |
| `d5d63ae` | `lib/screens/deals_screen.dart` | Replaced logo Image.asset with styled text (logo has baked-in background) |
| | `tools/seed_grocery.js` | Seed script for 4 grocery deals (HEB, Costco, Walmart) |
| | `tools/test_cj.js` | CJ Affiliate API connectivity test (zero dependencies) |
| `1ee1894` | `PROJECT_STATUS.md` | Day 3 progress update |

---

## File Structure
lib/
├── models/
│   ├── deal.dart                    # Core deal model with legacy field support
│   ├── deal_category.dart           # 11-category enum with emoji + label
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
│   ├── admin_deal_uploader_screen.dart  # Deal upload form (paste URL → Microlink auto-fill)
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
├── seed_grocery.js                  # Seeded 4 grocery deals (HEB, Costco, Walmart)
├── seed_extra_deals.js              # Seeded 15 deals for zero-deal categories
├── seed_balance.js                  # Balanced deal counts across categories
├── check_categories.js              # Reports Firestore category breakdown
├── test_cj.js                       # Tests CJ API connectivity
├── clean_old_deals.js               # Removed broken/empty deals
└── generate_icons.js                # Generated all Android icon sizes
web/
├── index.html                       # Google OAuth client ID meta tag
├── firebase-messaging-sw.js         # FCM service worker for web
└── privacy-policy.html              # Live privacy policy page
android/
├── app/
│   ├── build.gradle.kts             # Signed release build config
│   ├── google-services.json         # Firebase Android config (client_type 1 OAuth)
│   └── src/main/AndroidManifest.xml # Permissions + FCM config
├── key.properties                   # Keystore credentials (NOT in Git)
├── grabmeadeal-release.jks          # Release keystore (NOT in Git)
└── settings.gradle.kts              # Flutter 3.32 plugin management

---

## Known Issues & Tech Debt

| Issue | Priority | Notes |
|-------|----------|-------|
| Temp FAB admin button on deals screen | 🔴 HIGH | Remove before Play Store submission |
| Logo has baked-in background | 🟡 MED | Replaced with text in AppBar — need transparent PNG |
| CJ Affiliate API credentials missing | 🟡 MED | Sign up at cj.com — account created, apply to merchants. Test with `node tools/test_cj.js` |
| ShareASale API credentials missing | 🟡 MED | Sign up at shareasale.com |
| Geofence real-time not yet active | 🟢 LOW | Infrastructure built, needs background location handling |
| Trending section | 🟢 LOW | Build after launch when user data exists |

### Resolved (Day 3)
| Issue | Resolution |
|-------|-----------|
| Google Sign-In ApiException: 10 | Added client_type 1 OAuth client to google-services.json |
| Category pages "Failed to load" | Removed orderBy to avoid composite index requirement |
| Deal card grid overflow on mobile | Vertical layout — zero overflow |
| Package name com.example vs com.grabmeadeal.app | ✅ Fully migrated — OAuth, SHA-1, google-services.json all aligned |
| Old deals in Firestore with $0 price | ✅ Cleaned + 45 new deals seeded |
| Firestore orderBy createdAt needs index | ✅ Removed orderBy from category query — no index needed |
| View Deal button grayed out | Fixed Deal model to read `link` field for dealUrl |

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
| Phone Number Verification | ✅ Verified |
| App Listing Created | ✅ Created |
| Internal Testing Release | ✅ v1.0.1 AAB uploaded |
| Tester Link | ✅ Shared with 12 testers |
| Release AAB | ✅ Built — 57MB signed |
| App Icon 512x512 | ✅ Ready |
| Privacy Policy URL | ✅ Live |
| Play Store Screenshots | ⏳ Needed — min 2 phone screenshots |
| Short Description | ✅ Written |
| Full Description | ✅ Written |
| Content Rating | ⏳ Complete questionnaire in Play Console |

---

## Next Session Priorities

### Immediate (Do First)
1. Remove temp FAB admin button from deals screen
2. Create transparent logo PNG for AppBar
3. Add "You could save $X today" savings banner to deals screen
4. Take Play Store screenshots from S23+
5. Complete Play Store content rating questionnaire

### Short Term
6. Sign up ShareASale + Amazon Associates
7. Enter CJ API credentials in functions/.env
8. Build personalized home feed ("Deals for you" based on want list)
9. Dynamic deal count — "247 deals found today near Houston"

### Medium Term
10. Geofencing real-time alerts with background location
11. User profile screen
12. Admin dashboard with deal management
13. Trending section based on user engagement data

---

## Working Rules (Non-Negotiable)
- Full file replacements only — no partial patches
- Every file includes correct path as comment on line 1
- Production-ready, defensible code only
- Build in logical phase order
- Claude Code executes — Claude Chat architects
- 10% efficiency rule — switch tools when >10% gain available

---

## Passwords & Credentials
Store all credentials securely in a password manager.
Never commit passwords, API keys, or keystore passwords to Git.
See team password manager for keystore and API credentials.

---

*Generated by Claude Opus 4.6 — GrabMeADeal Build Session Day 3*
