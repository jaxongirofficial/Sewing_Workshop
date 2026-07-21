import type { UserRole } from '../modules/auth/models/user.model';

export interface AuthUserPayload {
  userId: string;
  role: UserRole;
}

declare module 'fastify' {
  interface FastifyRequest {
    user?: AuthUserPayload;
  }
}
