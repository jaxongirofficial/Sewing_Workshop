# Sewing Workshop

## Backend connection

The Flutter app now connects to the API in `Backend/` for phone authentication and worker records; its UI has not been redesigned.

1. Copy `Backend/.env.example` to `Backend/.env` and replace both JWT secrets.
2. Start MongoDB locally (or update `MONGODB_URI`).
3. In `Backend`, run `npm install`, `npm run seed:admin`, then `npm run dev`.

The seeded development login is `998901112233` / `ChangeMe123!`.

For an Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

For a physical phone, use your computer's LAN IP instead of `10.0.2.2`. Local HTTP is enabled for Android development only; use HTTPS for production.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
