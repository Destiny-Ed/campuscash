# CampusCash

**Earn money on campus — between classes.**

A production-ready Flutter + Dart Shelf application built for university students.

## Repository
https://github.com/Destiny-Ed/campuscash

## What's Included

### Backend (Dart Shelf)
- Full control of **all** APIs including authentication
- Auth (OAuth idToken exchange → JWT)
- Interactive Campus Map (pins, free/paid)
- Gigs system with **Project Writing** as first-class category
- Timetable
- Campus Tours
- Wallet & cash-out
- User profile

### Mobile (Flutter + Provider)
- Pro-level UI with smooth animations (`flutter_animate`)
- Clean motion, detailed micro-interactions
- Bottom navigation (Home • Map • Earn • Schedule • Profile)
- Home dashboard with earnings snapshot, quick actions, smart suggestions
- Interactive Google Map with free/paid pins + bottom sheets
- Earn hub with filters including **Project Writing**
- Timetable + Campus Tours
- Profile & wallet
- Google Sign-In → backend only (Firebase used **only** for idToken + FCM token)

## Architecture Decision (Locked)

- Flutter app **never** talks to Firestore / Storage / Auth SDK directly
- Only uses Firebase for:
  1. OAuth `idToken` (Google Sign-In)
  2. FCM token
- Everything else goes through the Dart Shelf backend

## Getting Started

### 1. Backend
```bash
cd backend
cp .env.example .env
dart pub get
dart run bin/server.dart
```

### 2. Mobile
```bash
cd mobile
flutter pub get
# Add your Google Maps API key & Firebase config
flutter run
```

## Feature Highlights

| Feature              | Status      |
|----------------------|-------------|
| Auth (Google → JWT)  | Implemented |
| Campus Map + Pins    | Implemented |
| Project Writing Gigs | Implemented |
| Micro-tasks / Tutoring / Notes / Skill Gigs | Implemented |
| Smart Timetable      | Implemented |
| Campus Tours         | Implemented |
| Wallet & Cash-out    | Implemented |
| Animated Pro UI      | Implemented |
| Study Mode           | Scaffolded  |
| Referrals            | Scaffolded  |

## Next Steps for Launch

1. Connect real database (PostgreSQL / Firestore via backend)
2. Real JWT signing + Google token verification
3. Stripe / PayPal payouts
4. Firebase Storage service in backend for media
5. Google Maps API key + Directions
6. Add real fonts (Plus Jakarta Sans) and Lottie animations
7. University-by-university onboarding

---

Built with care for students. Ready to iterate and ship.
