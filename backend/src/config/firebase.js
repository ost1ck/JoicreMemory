const admin = require('firebase-admin');
const path = require('path');
const env = require('./env');

let app = null;

function getFirebaseApp() {
  if (app) {
    return app;
  }

  const hasInlineCredentials =
    env.firebase.projectId &&
    env.firebase.clientEmail &&
    env.firebase.privateKey &&
    !env.firebase.privateKey.includes('YOUR_KEY');

  if (env.firebase.serviceAccountPath) {
    const serviceAccountPath = path.isAbsolute(env.firebase.serviceAccountPath)
      ? env.firebase.serviceAccountPath
      : path.resolve(process.cwd(), env.firebase.serviceAccountPath);

    const serviceAccount = require(serviceAccountPath);

    app = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: serviceAccount.project_id || env.firebase.projectId
    });

    return app;
  }

  if (hasInlineCredentials) {
    app = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.firebase.projectId,
        clientEmail: env.firebase.clientEmail,
        privateKey: env.firebase.privateKey
      })
    });

    return app;
  }

  if (!env.firebase.projectId || env.firebase.projectId.startsWith('your-')) {
    return null;
  }

  app = admin.initializeApp({
    projectId: env.firebase.projectId
  });

  return app;
}

module.exports = {
  admin,
  getFirebaseApp
};
