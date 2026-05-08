# phoneapp

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

# EA_Phoneapp_Proyecto

## Environment Configuration

This project supports `API_URL` through dart defines.

- Development: `.env.development` -> `API_URL=http://localhost:1337`
- Production: `.env.production` -> `API_URL=https://ea1-api.upc.edu`

Example:

```bash
flutter run --web-port=51755 --dart-define-from-file=.env.development
```

```bash
flutter run --release --dart-define-from-file=.env.production
```
