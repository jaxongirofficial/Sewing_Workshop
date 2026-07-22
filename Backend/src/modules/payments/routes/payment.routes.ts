import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { requireRole } from '../../../middlewares/role.middleware';
import { UserRole } from '../../auth/models/user.model';
import { paymentController } from '../controllers/payment.controller';
import { paymentHistoryQuerySchema, recordPaymentBodySchema } from '../validators/payment.validator';

export const paymentRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.addHook('preHandler', authenticate);
  // To'lovlar moliyaviy ma'lumot bo'lgani uchun faqat Manager/Admin ko'ra oladi.
  server.addHook('preHandler', requireRole(UserRole.Admin, UserRole.Manager));

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
