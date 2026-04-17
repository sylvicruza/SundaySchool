# FaithFoundation

FaithFoundation is the digital edition of the Opened Heavens Chapel Bible Study Manual 2026. It is designed to support structured Bible study, lesson preparation, reflection, and prayer in a clean and accessible format.

This repository is configured for automated web, Android, and iOS delivery flows.

## Local development

```bash
flutter pub get
flutter run
```

## Web Deployment

This project includes Firebase Hosting config in [`firebase.json`](./firebase.json) and a GitHub Actions workflow in [`.github/workflows/firebase-hosting.yml`](./.github/workflows/firebase-hosting.yml).

The workflow deploys the Flutter web build whenever code is pushed to the `main` branch.

## Android Deployment

This project also includes Play Console automation in [`.github/workflows/android-play-deploy.yml`](./.github/workflows/android-play-deploy.yml).

The Android workflow:

- builds a signed Android App Bundle on every push to `main`
- uploads it to the Google Play Console
- targets the `internal` track by default for safer continuous delivery

If you want production releases later, change `PLAY_TRACK` in the workflow after you are happy with the internal-track pipeline.

## Xcode Cloud

The iOS side is handled by Xcode Cloud, not GitHub Actions.

Apple's official workflow model is to let Xcode Cloud watch your repository for branch changes and start builds from there. Once your Xcode Cloud workflow is configured with a branch-change start condition for `main`, pushing to `main` will trigger the iOS build automatically.

Reference:

- [Configuring start conditions](https://developer.apple.com/documentation/xcode/configuring-start-conditions/)
- [Creating a workflow that builds your app for distribution](https://developer.apple.com/documentation/xcode/creating-a-workflow-that-builds-your-app-for-distribution/)

## Required GitHub Secrets

Add these repository secrets before the workflow can deploy:

- `FIREBASE_SERVICE_ACCOUNT`: the full JSON for a Firebase service account with Hosting deploy access
- `PLAY_SERVICE_ACCOUNT_JSON`: the full JSON for a Google Play Developer API service account
- `ANDROID_UPLOAD_KEYSTORE_BASE64`: base64-encoded contents of your Android upload keystore
- `ANDROID_KEYSTORE_PASSWORD`: Android keystore password
- `ANDROID_KEY_ALIAS`: Android key alias
- `ANDROID_KEY_PASSWORD`: Android key password

The Play Console service account must also be granted access to the app in Google Play Console.

## Flutter Build Command Used by CI

```bash
flutter build web --release
```
