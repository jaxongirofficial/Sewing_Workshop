import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { authController } from '../controllers/auth.controller';
import {
  loginBodySchema,
  logoutBodySchema,
  refreshTokenBodySchema,
  registerBodySchema,
} from '../validators/auth.validator';

export const authRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.post('/register', { schema: { tags: ['Auth'], body: registerBodySchema } }, authController.register);

  server.post('/login', { schema: { tags: ['Auth'], body: loginBodySchema } }, authController.login);

  server.post(
    '/refresh-token',
    { schema: { tags: ['Auth'], body: refreshTokenBodySchema } },
    authController.refresh,
  );

  server.post('/logout', { schema: { tags: ['Auth'], body: logoutBodySchema } }, authController.logout);

  server.get(
    '/me',
    {
      preHandler: [authenticate],
      schema: { tags: ['Auth'], security: [{ bearerAuth: [] }] },
    },
    authController.me,
  );
};
