import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { paymentController } from '../controllers/payment.controller';
import { paymentHistoryQuerySchema, recordPaymentBodySchema } from '../validators/payment.validator';

export const paymentRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.addHook('preHandler', authenticate);

  server.get(
    '/',
    { schema: { tags: ['Payments'], security: [{ bearerAuth: [] }], querystring: paymentHistoryQuerySchema } },
    paymentController.history,
  );

  server.post(
    '/',
    { schema: { tags: ['Payments'], security: [{ bearerAuth: [] }], body: recordPaymentBodySchema } },
    paymentController.record,
  );
};
