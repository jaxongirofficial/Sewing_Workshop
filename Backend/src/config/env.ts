import dotenv from 'dotenv';

// quiet: true - dotenv'ning konsolga chiqaradigan reklama/tip xabarlarini o'chiradi.
dotenv.config({ quiet: true });

const readEnv = (key: string, fallback?: string): string => {
  const value = process.env[key] ?? fallback;
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
};

const readNumberEnv = (key: string, fallback: number): number => {
  const value = process.env[key];
  if (!value) return fallback;
  const parsed = Number(value);
  if (Number.isNaN(parsed)) {
    throw new Error(`Environment variable ${key} must be a number`);
  }
  return parsed;
};

export const env = {
  nodeEnv: readEnv('NODE_ENV', 'development'),
  port: readNumberEnv('PORT', 5000),
  mongoUri: readEnv('MONGODB_URI', 'mongodb://127.0.0.1:27017/sewing_workshop'),
  clientOrigin: readEnv('CLIENT_ORIGIN', 'http://localhost:3000'),
  jwtAccessSecret: readEnv('JWT_ACCESS_SECRET'),
  jwtRefreshSecret: readEnv('JWT_REFRESH_SECRET'),
  jwtAccessExpiresIn: readEnv('JWT_ACCESS_EXPIRES_IN', '15m'),
  jwtRefreshExpiresIn: readEnv('JWT_REFRESH_EXPIRES_IN', '7d'),
  bcryptSaltRounds: readNumberEnv('BCRYPT_SALT_ROUNDS', 12),
};
