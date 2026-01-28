import express from 'express';
import { betterAuth } from "better-auth";
import { jwt, bearer } from "better-auth/plugins"; // Import plugins
import { toNodeHandler, fromNodeHeaders } from "better-auth/node";
import pg from 'pg';

const app = express();

const auth = betterAuth({
  database: new pg.Pool({ 
        connectionString: process.env.DATABASE_URL 
    }),
  session: {
    strategy: "jwt",
  },
  plugins: [
    jwt({
      issuer: process.env.JWT_ISSUER,    // Stamped on the token
      audience: process.env.JWT_AUDIENCE, // Stamped on the token
      jwt: { expirationTime: "1h" },
    }),
    bearer(),
  ],
  emailAndPassword: { enabled: true },
});


// IMPORTANT: Auth handler must come before express.json()
app.all("/api/auth/*", toNodeHandler(auth));

app.use(express.json());

app.get("/api/me", async (req, res) => {
    const session = await auth.api.getSession({
        headers: fromNodeHeaders(req.headers)
    });
    res.json(session || { user: null });
});

app.get('/api/health', (req, res) => {
  res.json({ service: 'auth', status: 'ok' });
});

const PORT = 3000; 

app.listen(PORT, () => {
  console.log(`✅ Auth service running on port ${PORT}`);
});