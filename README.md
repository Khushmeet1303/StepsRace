# Step Race 🏁

A cross-platform Flutter app where you race friends along a visual track using real daily step counts.

## Features
- **Live race track** — animated stick figures advance proportionally to each person's goal progress
- **Real step counting** — uses native sensors (Android `TYPE_STEP_COUNTER`, iOS CoreMotion)
- **Group racing** — invite friends via 6-character code; real-time Firestore sync
- **Leaderboard** — ranked by % of daily goal completed
- **History & streaks** — 30-day calendar with streak tracking
- **Profile** — custom name, avatar color, adjustable daily goal

---

## Setup Instructions

### 1. Install Flutter
Download from https://flutter.dev/docs/get-started/install  
Add `flutter/bin` to your PATH.

### 2. Firebase Setup (Required for Auth + Sync)

#### Create a Firebase project
1. Go to https://console.firebase.google.com
2. Create a new project (e.g., `step-race`)
3. Enable **Authentication** → Sign-in methods → Email/Password + Google
4. Enable **Cloud Firestore** → Start in test mode (then deploy `firestore.rules`)

#### Android
1. In Firebase Console → Project Settings → Add app → Android  
   Package name: `com.example.step_race`
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`

#### iOS
1. In Firebase Console → Project Settings → Add app → iOS  
   Bundle ID: `com.example.stepRace`
2. Download `GoogleService-Info.plist`
3. Replace `ios/Runner/GoogleService-Info.plist` (the current one is a placeholder)

#### Update `lib/firebase_options.dart`
Fill in the API keys/IDs from Firebase Console → Project Settings → General.

**Or** use the FlutterFire CLI (recommended — auto-generates the file):
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Google Sign-In (Android)
Add your SHA-1 fingerprint to Firebase Console → Project Settings → Android app:
```bash
cd android && ./gradlew signingReport
```

### 4. Deploy Firestore Security Rules
```bash
firebase deploy --only firestore:rules
```

### 5. Run the App
```bash
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # Shell + bottom nav
├── firebase_options.dart  # ⚠️ Fill in your Firebase keys
├── core/
│   ├── theme.dart         # Colors, fonts, Material 3 theme
│   ├── constants.dart     # Magic-number-free constants
│   └── utils.dart         # formatSteps, initials, dateKey, etc.
├── models/                # UserProfile, Group, DayRecord
├── services/              # StepService, AuthService, FirestoreService, PermissionService
├── providers/             # AuthProvider, StepProvider, GroupProvider
├── screens/
│   ├── onboarding/        # PermissionScreen, AuthScreen
│   ├── track/             # TrackScreen + TrackPainter (CustomPainter)
│   ├── leaderboard/       # LeaderboardScreen
│   ├── history/           # HistoryScreen
│   └── profile/           # ProfileScreen
└── widgets/               # GroupJoinDialog, PermissionBanner
```

---

## Firestore Data Schema

```
users/{uid}/
  name: string
  color: string          # 'coral' | 'leaf' | 'amber' | 'teal' | 'purple'
  goal: number
  dailySteps/{YYYY-MM-DD}/
    steps: number
    goalHit: boolean
    updatedAt: timestamp

groups/{groupId}/
  name: string
  inviteCode: string     # 6-char uppercase
  memberIds: string[]
```

---

## Android Permissions
- `ACTIVITY_RECOGNITION` — step counting (Android 10+)
- `INTERNET` — Firebase sync
- `FOREGROUND_SERVICE` — background step tracking

## iOS Entitlements
- `NSMotionUsageDescription` — CoreMotion step counting

---

## Notes
- **iOS background step counting**: iOS caches steps via CMPedometer; the app reads the cached total when opened. A banner informs users of this limitation.
- **Midnight reset**: Steps reset automatically at local midnight. The service compares `DateTime.now()` to the stored `lastResetDate` on each step event.
- **Demo mode**: On emulators (no real sensors), step counting shows 0. Use `StepProvider.simulateSteps()` in debug builds.
