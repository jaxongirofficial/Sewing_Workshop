import type { RequestHandler } from 'express';
import { validationResult } from 'express-validator';

import { HttpError } from '../shared/errors/http-error';

export const validateRequest: RequestHandler = (req, _res, next) => {
  const result = validationResult(req);
  if (result.isEmpty()) {
    next();
    return;
  }

  next(new HttpError(422, 'Validation failed', 'VALIDATION_ERROR'));
};
