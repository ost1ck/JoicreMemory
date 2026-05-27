# JoicreMemory Backend

Node.js Express REST API.

Planned structure:

```text
src/
  config/
  controllers/
  middlewares/
  repositories/
  routes/
  services/
  utils/
```

Authentication will use Firebase ID tokens verified on the backend.

## Firebase

Local verification can run with project id only:

```env
AUTH_DEV_MODE=false
FIREBASE_PROJECT_ID=joicrememory
```

For production, use Firebase Console:

```text
Project settings -> Service accounts -> Generate new private key
```

Save the JSON in `backend/` and set:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-admin-service-account.json
```

## Run

```bash
cp .env.example .env
npm install
npm start
```

Open Swagger:

```text
http://localhost:3000/docs
```

Protected Swagger endpoints require a real Firebase ID token when:

```env
AUTH_DEV_MODE=false
```

Development header auth still exists as a fallback only if you explicitly set:

```env
AUTH_DEV_MODE=true
```
