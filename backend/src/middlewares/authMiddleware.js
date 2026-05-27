const env = require('../config/env');
const { getFirebaseApp } = require('../config/firebase');
const ApiError = require('../utils/apiError');

async function authenticate(req, res, next) {
  try {
    const authorization = req.headers.authorization || '';
    const token = authorization.startsWith('Bearer ')
      ? authorization.slice('Bearer '.length)
      : null;

    if (token) {
      const firebaseApp = getFirebaseApp();

      if (!firebaseApp) {
        throw new ApiError(500, 'Firebase credentials are not configured');
      }

      const decodedToken = await firebaseApp.auth().verifyIdToken(token);
      req.auth = {
        firebaseUid: decodedToken.uid,
        email: decodedToken.email,
        fullName: decodedToken.name || decodedToken.email || 'JoicreMemory User'
      };
      return next();
    }

    if (env.authDevMode) {
      const firebaseUid = req.headers['x-dev-firebase-uid'];

      if (!firebaseUid) {
        throw new ApiError(
          401,
          'Missing auth. Use Bearer Firebase token or x-dev-firebase-uid in AUTH_DEV_MODE.'
        );
      }

      req.auth = {
        firebaseUid,
        email: req.headers['x-dev-email'] || `${firebaseUid}@example.com`,
        fullName: req.headers['x-dev-name'] || 'Dev User'
      };
      return next();
    }

    throw new ApiError(401, 'Unauthorized');
  } catch (error) {
    if (error instanceof ApiError) {
      return next(error);
    }

    console.error('Firebase token verification failed', {
      code: error.code,
      message: error.message
    });

    return next(new ApiError(401, 'Invalid or expired Firebase token'));
  }
}

module.exports = {
  authenticate
};
