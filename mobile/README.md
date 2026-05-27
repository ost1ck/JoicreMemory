# JoicreMemory Mobile

Flutter mobile application.

Planned structure:

```text
lib/
  core/
  features/
```

Main integrations:

- Firebase Auth for email/password login and registration.
- Google Maps for event markers.
- Stream SDK for event chats.

## Run

```bash
cp .env.example .env
flutter pub get
flutter run
```

For iOS simulator:

```text
API_BASE_URL=http://localhost:3000/api
```

For Android emulator:

```text
API_BASE_URL=http://10.0.2.2:3000/api
```

The current `.env` uses `USE_DEV_AUTH=false`, so login and registration use real Firebase Auth.

Enable Email/Password in Firebase Console:

```text
Authentication -> Sign-in method -> Email/Password
```

Password reset is handled by Firebase email reset links.

## Google Maps

Create a Google Maps API key in Google Cloud Console and enable:

- `Maps SDK for iOS`
- `Maps SDK for Android`

For local development, put the key here:

```text
ios/Flutter/GoogleMaps.xcconfig
```

```xcconfig
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

The same file is used by iOS and Android native configuration. For production,
restrict the key in Google Cloud:

- iOS restriction: bundle ID `com.joicrememory.joicrememory`
- Android restriction: package `com.joicrememory.joicrememory` plus SHA-1
