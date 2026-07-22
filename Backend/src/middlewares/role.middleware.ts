import type { FastifyReply, FastifyRequest } from 'fastify';

import { HttpError } from '../shared/errors/http-error';
import type { UserRole } from '../modules/auth/models/user.model';

// authenticate middleware ishlatilgandan keyin ishlatilishi kerak, chunki
// bu request.user ga tayanadi.
export const requireRole = (...roles: UserRole[]) => {
  return async (request: FastifyRequest, _reply: FastifyReply): Promise<void> => {
    if (!request.user) {
      throw new HttpError(401, 'Authentication token is required', 'AUTH_TOKEN_REQUIRED');
    }

    if (!roles.includes(request.user.role)) {
      throw new HttpError(403, 'You do not have permission to perform this action', 'FORBIDDEN');
    }
  };
};
