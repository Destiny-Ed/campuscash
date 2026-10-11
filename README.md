# CampusCash

**Earn money on campus — between classes.**

Production-ready Flutter + Dart Shelf application for university students.

**Repo:** https://github.com/Destiny-Ed/campuscash

## Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| Mobile       | Flutter + Provider                  |
| Backend      | Dart Shelf                          |
| Database     | **PostgreSQL** (real)               |
| Payments     | **Paystack** (fund + cashout)       |
| Auth         | Google Sign-In → backend JWT        |
| Maps         | Google Maps Flutter                 |

Firebase is used **only** for OAuth `idToken` and FCM token. Everything else goes through the Shelf backend.

## Features

- Interactive Campus Map (free / paid pins)
- Smart Timetable + free-slot suggestions
- Campus Tours
- Micro-tasks, Peer Tutoring, Notes Marketplace
- **Project Writing** gigs (essays, reports, research)
- Skill Gigs & Campus Gigs
- Real wallet with **Paystack** funding & bank cashout
- Ratings, escrow-ready, Study Mode, Referrals

## Setup

### 1. PostgreSQL
```bash
createdb campuscash
# or use Docker:
docker run --name campuscash-db -e POSTGRES_PASSWORD=password -e POSTGRES_DB=campuscash -p 5432:5432 -d postgres:16
```

### 2. Backend
```bash
cd backend
cp .env.example .env
# Edit .env with your DATABASE_URL, JWT_SECRET, PAYSTACK keys
dart pub get
dart run bin/server.dart
```

On first run the server automatically creates all tables.

### 3. Mobile
```bash
cd mobile
flutter pub get
# Add google-services.json / GoogleService-Info.plist
# Add Google Maps API key
flutter run
```

## Paystack Flow

1. **Fund wallet** → `POST /api/wallet/fund` → returns `authorization_url`
2. Open the URL (WebView or external browser) for the student to pay
3. After payment → `POST /api/wallet/verify` with the `reference`
4. Wallet is credited automatically

**Cashout** → student enters bank details → backend creates Paystack recipient + transfer → wallet debited.

## Environment Variables

See `backend/.env.example`.

Required:
- `DATABASE_URL`
- `JWT_SECRET`
- `PAYSTACK_SECRET_KEY`
- `PAYSTACK_PUBLIC_KEY`

## License

Private / All rights reserved.
