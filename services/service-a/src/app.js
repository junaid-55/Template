import express from 'express';
import { jwtVerify, createRemoteJWKSet } from 'jose';
import pg from 'pg';

const app = express();
app.use(express.json());

// 1. Internal DB connection for Service-A
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });

// 2. Remote Key Set: Service-A fetches public keys from Auth-Service (internal Docker URL)
// This is used to verify that the JWT was actually signed by your Auth-Service.
const JWKS = createRemoteJWKSet(new URL(process.env.AUTH_JWKS_URL));

// 3. Middleware: The Security Gatekeeper
const authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) return res.status(401).json({ error: 'Missing token' });

    const token = authHeader.split(' ')[1];

    try {
        console.log("Expected Iss:", process.env.JWT_ISSUER);
        
        const { payload } = await jwtVerify(token, JWKS, {
            issuer: process.env.JWT_ISSUER,
            audience: process.env.JWT_AUDIENCE,
        });
        console.log("Token Iss:", payload.iss);
        req.user = payload; // Attach user claims (id, email, etc.) to the request
        next();
    } catch (e) {
        return res.status(401).json({ error: 'Unauthorized: ' + e.message });
    }
};

// 4. Sample Route: Fetches data from service_a schema
app.get('/api/service-a/preferences', authenticate, async (req, res) => {
    try {
        const { rows } = await pool.query(
            'SELECT * FROM user_preferences WHERE user_id = $1', 
            [req.user.id]
        );
        res.json({ user: req.user.email, preferences: rows[0] || {} });
    } catch (err) {
        res.status(500).json({ error: 'Database error' });
    }
});

const PORT = 3001;
app.listen(PORT, () => console.log(`Service-A running on internal port ${PORT}`));