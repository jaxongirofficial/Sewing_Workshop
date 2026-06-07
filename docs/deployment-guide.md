# Sewing Workshop Management System Deployment Guide

## Scope

This guide covers production deployment for:

- Flutter application in `lib/`, `android/`, `ios/`, and `web/`
- Node.js TypeScript API in `Backend/`
- MongoDB database

Keep frontend and backend deployments separate. The Flutter app must only call the backend through the configured API URL.

## Backend Requirements

- Node.js 20 LTS or newer
- npm or another Node package manager
- MongoDB 6 or newer
- HTTPS-capable reverse proxy such as Nginx, Caddy, or a managed load balancer
- Production secrets managed outside git

## Backend Environment

Create `Backend/.env` on the server using `Backend/.env.example` as the template.

Required variables:

```bash
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://user:password@host:27017/sewing_workshop
CLIENT_ORIGIN=https://your-frontend-domain.com
JWT_ACCESS_SECRET=replace-with-strong-secret
JWT_REFRESH_SECRET=replace-with-different-strong-secret
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
BCRYPT_SALT_ROUNDS=12
```

Use different values for `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET`. Store them in the server secret manager or deployment platform environment settings.

## Backend Build And Start

From `Backend/`:

```bash
npm install
npm run build
npm start
```

For a long-running process, use a process manager:

```bash
pm2 start dist/server.js --name sewing-workshop-api
pm2 save
```

Health check endpoint:

```text
GET /api/health
```

## Reverse Proxy

Terminate TLS at the reverse proxy and forward API traffic to port `5000`.

Example Nginx location:

```nginx
location /api/ {
  proxy_pass http://127.0.0.1:5000/api/;
  proxy_http_version 1.1;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

## MongoDB Production Notes

- Enable authentication.
- Restrict network access to the API server.
- Enable daily backups.
- Monitor storage, connections, and slow queries.
- Use a managed MongoDB provider when possible.

The API creates indexes declared in Mongoose schemas when connected. For larger production datasets, run index creation during maintenance windows.

## Flutter Web Deployment

Build with the production API URL:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-api-domain.com/api
```

Deploy `build/web` to static hosting such as Nginx, Firebase Hosting, Netlify, Vercel, or S3/CloudFront.

For single page app routing, configure the host to serve `index.html` for unknown routes.

## Flutter Android Deployment

Build with the production API URL:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api-domain.com/api
```

Upload the generated app bundle to Google Play Console.

## Flutter iOS Deployment

Build with the production API URL:

```bash
flutter build ipa --release --dart-define=API_BASE_URL=https://your-api-domain.com/api
```

Upload using Xcode Organizer or Transporter.

## Security Checklist

- Use HTTPS only.
- Never commit `.env` files or secrets.
- Use strong JWT secrets.
- Keep refresh token expiry reasonable.
- Restrict CORS with `CLIENT_ORIGIN`.
- Keep MongoDB private.
- Rotate secrets after any suspected exposure.
- Run dependency audits before release.
- Enable server logs and monitoring.

## Release Checklist

1. Backend dependencies installed.
2. Backend TypeScript build passes.
3. MongoDB connection verified.
4. `/api/health` returns success.
5. Flutter app built with production `API_BASE_URL`.
6. Login/register/refresh/logout tested.
7. Workers, customers, orders, and payments smoke tested.
8. Backups configured.
9. TLS certificate active.
10. Monitoring and log retention configured.

## Rollback Plan

- Keep the previous backend build artifact available.
- Keep the previous Flutter release available in the hosting platform.
- Roll back backend first if API compatibility breaks.
- Restore MongoDB from backup only if data corruption occurs.
- After rollback, verify `/api/health`, authentication, and core CRUD flows.
