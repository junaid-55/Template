import express from 'express';
import { betterAuth } from 'better-auth';

const app = express();
const PORT = 3000;

// 1. Initialize better-auth
const auth = betterAuth({
    // Your configuration goes here (database, providers, etc.)
    // Example:
    /* database: new Kysely({ ... }),
    socialProviders: { ... } 
    */
});

app.use(express.json());

// 2. The "Handshake" - Mount the auth handler
// This single route handles /api/auth/login, /api/auth/signup, etc.
app.all("/api/auth/*", (req) => {
    return auth.handler(req);
});

// Health check
app.get('/health', (req, res) => {
  res.json({ service: 'auth', status: 'ok' });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Auth service running on port ${PORT}`);
});