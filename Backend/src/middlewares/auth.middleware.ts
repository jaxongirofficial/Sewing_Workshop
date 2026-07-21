import jwt from 'jsonwebtoken';
import type { FastifyReply, FastifyRequest } from 'fastify';

import { env } from '../config/env';
import { HttpError } from '../shared/errors/http-error';
import type { AuthUserPayload } from '../types/auth-request';

interface AccessTokenPayload extends AuthUserPayload {
  type: 'access';
}

export const authenticate = async (request: FastifyRequest, _reply: FastifyReply): Promise<void> => {
  const header = request.headers.authorization;
  const token = header?.startsWith('Bearer ') ? header.slice(7) : undefined;

  if (!token) {
    throw new HttpError(401, 'Authentication token is required', 'AUTH_TOKEN_REQUIRED');
  }

  try {
    const payload = jwt.verify(token, env.jwtAccessSecret) as AccessTokenPayload;
    if (payload.type !== 'access') {
      throw new HttpError(401, 'Invalid authentication token', 'INVALID_AUTH_TOKEN');
    }
    request.user = {
      userId: payload.userId,
      role: payload.role,
    };
  } catch (error) {
    throw error instanceof HttpError
      ? error
      : new HttpError(401, 'Invalid authentication token', 'INVALID_AUTH_TOKEN');
  }
};
