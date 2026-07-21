import type { FastifyError, FastifyInstance } from 'fastify';
import { ZodError } from 'zod';

import { HttpError } from '../shared/errors/http-error';
import { errorResponse } from '../shared/http-response';

const isZodError = (error: unknown): error is ZodError => error instanceof ZodError;

const isFastifyValidationError = (
  error: unknown,
): error is FastifyError & { validation: Array<{ message?: string }> } =>
  typeof error === 'object' &&
  error !== null &&
  'validation' in error &&
  Array.isArray((error as FastifyError).validation);

export const registerErrorHandler = (app: FastifyInstance): void => {
  app.setErrorHandler((error, request, reply) => {
    if (error instanceof HttpError) {
      reply.status(error.statusCode).send(errorResponse(error.message, error.details));
      return;
    }

    if (isZodError(error)) {
      const messages = error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`);
      reply.status(422).send(errorResponse('Validation failed', messages));
      return;
    }

    if (isFastifyValidationError(error)) {
      const messages = error.validation.map((issue) => issue.message ?? 'Invalid input');
      reply.status(422).send(errorResponse('Validation failed', messages));
      return;
    }

    request.log.error(error);
    reply.status(500).send(errorResponse('Internal server error'));
  });

  app.setNotFoundHandler((_request, reply) => {
    reply.status(404).send(errorResponse('Route not found'));
  });
};
