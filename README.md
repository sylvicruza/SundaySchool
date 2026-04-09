# Sunday School

A Flutter app for the Opened Heavens Chapel Sunday School manual.

## Local development

```bash
flutter pub get
flutter run
```

## Web deployment

This project includes Firebase Hosting config in [`firebase.json`](./firebase.json)
and a GitHub Actions workflow in [`.github/workflows/firebase-hosting.yml`](./.github/workflows/firebase-hosting.yml).

The workflow deploys the Flutter web build whenever code is pushed to the `main` branch.

## Required GitHub secrets

Add these repository secrets before the workflow can deploy:

- `FIREBASE_PROJECT_ID`: your Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT`: the full JSON for a Firebase service account with Hosting deploy access

## Flutter build command used by CI

```bash
flutter build web --release
```
