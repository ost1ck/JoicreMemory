const app = require('./app');
const env = require('./config/env');

app.listen(env.port, () => {
  console.log(`JoicreMemory API running on http://localhost:${env.port}`);
  console.log(`Swagger UI available at http://localhost:${env.port}/docs`);
});


// Runs while this service is awake; a sweep also runs when chat lists are read.
const lifecycle = require('./services/eventLifecycleService');
const sweep = () => lifecycle.cleanup().catch(() => console.error('Event lifecycle sweep failed; will retry'));
sweep();
setInterval(sweep, 60_000).unref();
