import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
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

  server.get(
    '/',
    { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], querystring: listWorkersQuerySchema } },
    workerController.list,
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

  server.delete(
    '/:workerId',
    { schema: { tags: ['Workers'], security: [{ bearerAuth: [] }], params: workerIdParamsSchema } },
    workerController.delete,
  );
};
