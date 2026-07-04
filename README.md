# Nexmart

A full-featured e-commerce mobile app built from scratch with Flutter and Firebase — covering everything from product browsing and cart management to real-time order tracking and a complete admin panel.

This project was built as a structured, day-by-day learning journey focused on understanding *why* things work the way they do, not just getting features to run.

## Features

- Google Sign-In authentication
- Product browsing with category filters and live search
- Cart with quantity controls and local persistence (survives app restarts)
- Checkout flow with address form and order summary
- Real-time order tracking with a visual status tracker
- Stock validation and automatic stock deduction on purchase (using Firestore transactions)
- Order cancellation for customers
- Role-based admin panel: add, edit, and manage products; update order statuses
- User profile with editable details
- WhatsApp integration for customer support
- Smooth custom transitions, animated splash screen, and polished UI throughout

## Tech Stack

- **Flutter & Dart** — UI and app logic
- **Firebase Firestore** — real-time database
- **Firebase Authentication** — Google Sign-In
- **Riverpod** — state management (Providers, StateNotifiers, Streams)
- **go_router** — navigation and route protection
- **shared_preferences** — local cart persistence
- **cached_network_image** — image loading and caching
- **url_launcher** — WhatsApp deep linking

## Architecture

The app follows a clean, layered structure:

- `models/` — data classes with Firestore serialization
- `services/` — Firestore read/write logic, isolated per feature
- `providers/` — Riverpod providers connecting services to UI
- `features/` — screens organized by feature area

State flows one direction: UI watches providers, providers depend on services, services talk to Firestore. Real-time data (orders, user profile) uses Firestore streams; one-time reads use futures.

## Known Limitations

Some features were deliberately deferred to keep the project scoped and intentional rather than sprawling:

- Product ratings and reviews
- Image upload to Firebase Storage (currently uses image URLs)
- Pagination for product and order lists
- Search/filter within the admin order management screen

These are documented tradeoffs, not oversights — the reasoning behind each is part of what this project was built to practice.

## Getting Started

```bash
git clone https://github.com/hassanaskari113/nexmart-flutter.git
cd nexmart-flutter
flutter pub get
```

Add your own `google-services.json` (Android) and Firebase project configuration before running.

```bash
flutter run
```

## Download

A ready-to-install release APK is available here: https://drive.google.com/file/d/1B5OsoFyPkRN3pw5hoMp4u9_oXTUBEinl/view?usp=drive_link

## What I Learned

Building Nexmart end-to-end was as much about architecture and edge cases as it was about UI. Key areas I strengthened:

- Riverpod state management across sync and async data
- Firestore transactions to prevent race conditions (stock deduction)
- Handling stale data and validating business rules across multiple screens
- Route-level security with go_router redirects
- Writing defensive, mounted-safe async code in Flutter

---

Built as a personal learning project. Feedback welcome.
