import type { Request } from 'express';

import type { UserRole } from '../modules/auth/models/user.model';

export interface AuthUserPayload {
  userId: string;
  role: UserRole;
}

export interface AuthenticatedRequest extends Request {
  user?: AuthUserPayload;
}
