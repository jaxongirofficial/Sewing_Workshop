import jwt from 'jsonwebtoken';
import type { RequestHandler } from 'express';

import { env } from '../config/env';
import { HttpError } from '../shared/errors/http-error';
import type { AuthUserPayload, AuthenticatedRequest } from '../types/auth-request';

interface AccessTokenPayload extends AuthUserPayload {
  type: 'access';
}

export const authenticate: RequestHandler = (req, _res, next) => {
  const authReq = req as AuthenticatedRequest;
  const header = req.headers.authorization;
  const token = header?.startsWith('Bearer ') ? header.slice(7) : undefined;

  if (!token) {
    next(new HttpError(401, 'Authentication token is required', 'AUTH_TOKEN_REQUIRED'));
    return;
  }

  try {
    const payload = jwt.verify(token, env.jwtAccessSecret) as AccessTokenPayload;
    if (payload.type !== 'access') {
      throw new HttpError(401, 'Invalid authentication token', 'INVALID_AUTH_TOKEN');
    }
    authReq.user = {
      userId: payload.userId,
      role: payload.role,
    };
    next();
  } catch (error) {
    next(error instanceof HttpError ? error : new HttpError(401, 'Invalid authentication token', 'INVALID_AUTH_TOKEN'));
  }
};
