import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { requireRole } from '../../../middlewares/role.middleware';
import { UserRole } from '../../auth/models/user.model';
import { workerController } from '../controllers/worker.controller';
import {
  createWorkerBodySchema,
  listWorkersQuerySchema,
  updateWorkerBodySchema,
  workerIdParamsSchema,
} from '../validators/worker.validator';

export const workerRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.addHook('preHandler', authenticate);
  // Xodimlar ma'lumoti (ish haqi kabi) sezgir bo'lgani uchun faqat
  // Manager va Admin rollariga ruxsat beriladi.
  server.addHook('preHandler', requireRole(UserRole.Admin, UserRole.Manager));

  server.get(
    '/',
    { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], querystring: listWorkersQuerySchema } },
    workerController.list,
  );

  server.get(
    '/:workerId',
    { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], params: workerIdParamsSchema } },
    workerController.getById,
  );

  server.post(
    '/',
    { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], body: createWorkerBodySchema } },
    workerController.create,
  );

  server.patch(
    '/:workerId',
    {
      schema: {
        tags: ['Workers'],
        security: [{ bearerAuth: [] }],
        params: workerIdParamsSchema,
        body: updateWorkerBodySchema,
      },
    },
    workerController.update,
  );

  // Xodimni o'chirish faqat Admin uchun — alohida scope'da, chunki inline
  // preHandler massivi ZodTypeProvider tur xulosasi bilan ziddiyatga kirib,
  // tsc build'ida xato beradi.
  await server.register(async (adminScope) => {
    const scoped = adminScope.withTypeProvider<ZodTypeProvider>();
    scoped.addHook('preHandler', requireRole(UserRole.Admin));

    scoped.delete(
      '/:workerId',
      { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], params: workerIdParamsSchema } },
      workerController.delete,
    );
  });
};
