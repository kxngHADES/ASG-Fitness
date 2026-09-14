# ASG Fitness

**v0.0.1**

ASG Fitness is a Flutter-based workout tracking app for planning training sessions, logging exercises, and following progress over time — all stored locally on-device.

## Features

- **Home** — quick overview and fast entry into a workout session.
- **Exercises** — browse an exercise library, view exercise details, and pick exercises to build a workout around.
- **Plans** — create and manage workout plans made up of exercises, then drill into a plan to see its details.
- **Workouts** — start a quick workout or run an active, in-progress workout session.
- **Stats** — track body stats over time and view training progression with charts.
- **Equipment** — record available equipment during onboarding or later in settings, so exercises can be matched to what you actually have.

## Tech stack

- [Flutter](https://flutter.dev/) / Dart
- [`provider`](https://pub.dev/packages/provider) for state management
- [`sqflite`](https://pub.dev/packages/sqflite) (with [`sqflite_common_ffi_web`](https://pub.dev/packages/sqflite_common_ffi_web) for web support) for local persistence
- [`fl_chart`](https://pub.dev/packages/fl_chart) for progress charts

## Project structure

```
lib/
├── data/          # Seed data for first-run setup
├── db/            # SQLite database helper
├── models/        # Data models (exercises, equipment, plans, sessions, body stats)
├── providers/      # App state (Provider-based)
├── repositories/   # Data access layer between providers and the database
└── screens/        # UI, grouped by feature (home, exercises, plans, workout, stats, equipment)
```

## Getting started

This project targets Flutter's stable channel.

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and run `flutter doctor` to confirm your setup.
2. Fetch dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run -d chrome      # Web
   flutter run                # Connected device / emulator
   ```

### Building an APK for Android

```
flutter build apk --release --split-per-abi
```

The generated APKs will be in `build/app/outputs/flutter-apk/`. Most modern phones use `app-arm64-v8a-release.apk`.

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
