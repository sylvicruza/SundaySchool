# FaithFoundation

FaithFoundation is the digital edition of the Opened Heavens Chapel Bible Study Manual 2026. It is designed to support structured Bible study, lesson preparation, reflection, and prayer in a clean and accessible format.

## Local development

```bash
flutter pub get
flutter run
```

## Web Deployment

This project includes Firebase Hosting config in [`firebase.json`](./firebase.json)
and a GitHub Actions workflow in [`.github/workflows/firebase-hosting.yml`](./.github/workflows/firebase-hosting.yml).

The workflow deploys the Flutter web build whenever code is pushed to the `main` branch.

## Required GitHub Secrets

Add these repository secrets before the workflow can deploy:

- `FIREBASE_PROJECT_ID`: your Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT`: the full JSON for a Firebase service account with Hosting deploy access

## Flutter Build Command Used by CI

```bash
flutter build web --release
```
