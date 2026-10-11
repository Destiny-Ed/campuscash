# CampusCash

**Earn money on campus — between classes.**

CampusCash is a pro-level Flutter + Dart Shelf application that helps university students earn real money through micro-tasks, peer tutoring, notes marketplace, campus gigs (including **Project Writing**), skill gigs, an interactive campus map, smart timetable, and guided campus tours.

## Key Features

- **Interactive Campus Map** — Pin free/paid locations, get walking directions, community contributions
- **Smart Timetable** — Class schedule + free-slot earning suggestions + conflict detection
- **Campus Tours** — Guided pin-by-pin tours for freshers
- **Earn Hub**
  - Micro-tasks
  - Peer Tutoring (course-code matched)
  - Notes & Study Materials Marketplace
  - Campus Gigs
  - **Project Writing** (essays, reports, research papers, proposals)
  - Skill Gigs (design, coding, writing, video, etc.)
- **Wallet & Instant Payouts**
- **Study Mode**, Ratings, Escrow, Referrals

## Architecture

- **Mobile**: Flutter + Provider
- **Backend**: Dart Shelf (owns **all** APIs including auth)
- **Firebase**: Used **only** for OAuth `idToken` and FCM token
- **Storage**: Handled by backend (Firebase Storage wrapper, swappable later)
- **Maps**: Google Maps Flutter + Directions API

## Project Structure

```
campuscash/
├── backend/                 # Dart Shelf API
├── mobile/                  # Flutter app
├── landing/                 # Pro marketing site (coming)
└── docs/
```

## Getting Started

### Backend
```bash
cd backend
dart pub get
dart run bin/server.dart
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

## Status

This repository contains a launch-ready, highly polished implementation with professional animations, detailed UI, and complete feature coverage.

Built for real students. Designed to ship.
