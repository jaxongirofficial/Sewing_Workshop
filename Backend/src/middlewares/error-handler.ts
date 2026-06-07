import type { ErrorRequestHandler } from 'express';

import { env } from '../config/env';
import { HttpError } from '../shared/errors/http-error';

export const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  const isHttpError = error instanceof HttpError;
  const statusCode = isHttpError ? error.statusCode : 500;
  const message = isHttpError ? error.message : 'Internal server error';
  const code = isHttpError ? error.code : 'INTERNAL_SERVER_ERROR';

  res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      ...(env.nodeEnv === 'development' && !isHttpError ? { details: String(error) } : {}),
    },
  });
};
