# JoicreMemory

JoicreMemory is a mobile platform for local social initiatives.

Project structure:

```text
backend/   Node.js Express REST API
database/  PostgreSQL schema
mobile/    Flutter application
```

The project uses Ukrainian as the app interface language.

## Local Run

Start the PostGIS database and apply the schema:

```bash
docker compose -f database/docker-compose.yml up -d
psql "postgres://postgres:postgres@localhost:5433/joicrememory" -f database/schema.sql
```

Use this backend database URL:

```env
DATABASE_URL=postgres://postgres:postgres@localhost:5433/joicrememory
```

Run backend:

```bash
cd backend
cp .env.example .env
npm install
npm start
```

Swagger UI:

```text
http://localhost:3000/docs
```

For protected Swagger endpoints, authorize with a real Firebase ID token.

Run Flutter:

```bash
cd mobile
cp .env.example .env
flutter pub get
flutter run
```

For Android emulator, set this in `mobile/.env`:

```text
API_BASE_URL=http://10.0.2.2:3000/api
```

## Firebase Auth

The app is configured for real Firebase Auth:

```text
mobile/.env: USE_DEV_AUTH=false
backend/.env: AUTH_DEV_MODE=false
```

In Firebase Console enable:

```text
Authentication -> Sign-in method -> Email/Password
```

The mobile app creates Firebase users. The backend verifies Firebase ID tokens
and stores the user profile in PostgreSQL.

For local token verification, `backend/.env` needs:

```text
FIREBASE_PROJECT_ID=joicrememory
```

For production, prefer a Firebase Admin service account JSON and set:

```text
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-admin-service-account.json
```

## Google Maps

Enable `Maps SDK for iOS` and `Maps SDK for Android` in Google Cloud Console.
Then paste the API key into:

```text
mobile/ios/Flutter/GoogleMaps.xcconfig
```

```xcconfig
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

The key is consumed by both iOS and Android native config.

## VS Code F5

Open the repository root in VS Code:

```bash
code /Users/user/Desktop/cursach_4
```

In the Run and Debug panel, select:

```text
JoicreMemory Full Stack
```

Then press `F5`. VS Code will start the backend and Flutter app together.
