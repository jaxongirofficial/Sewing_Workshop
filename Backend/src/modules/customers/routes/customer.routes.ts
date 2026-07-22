import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { requireRole } from '../../../middlewares/role.middleware';
import { UserRole } from '../../auth/models/user.model';
import { customerController } from '../controllers/customer.controller';
import {
  createCustomerBodySchema,
  customerIdParamsSchema,
  listCustomersQuerySchema,
  updateCustomerBodySchema,
} from '../validators/customer.validator';

export const customerRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.addHook('preHandler', authenticate);

  // Barcha customerlarni olish
  server.get(
    '/',
    {
      schema: {
        tags: ['Customers'],
        security: [{ bearerAuth: [] }],
        querystring: listCustomersQuerySchema,
      },
    },
    customerController.list,
  );

  // ID orqali bitta customer olish
  server.get(
    '/:customerId',
    {
      schema: {
        tags: ['Customers'],
        security: [{ bearerAuth: [] }],
        params: customerIdParamsSchema,
      },
    },
    customerController.getById,
  );

  // Yangi customer yaratish
  server.post(
    '/',
    {
      schema: {
        tags: ['Customers'],
        security: [{ bearerAuth: [] }],
        body: createCustomerBodySchema,
      },
    },
    customerController.create,
  );

  // Customer yangilash
  server.patch(
    '/:customerId',
    {
      schema: {
        tags: ['Customers'],
        security: [{ bearerAuth: [] }],
        params: customerIdParamsSchema,
        body: updateCustomerBodySchema,
      },
    },
    customerController.update,
  );

  // Customer o'chirish (faqat Manager/Admin) — alohida scope'da,
  // chunki inline preHandler massivi ZodTypeProvider tur xulosasi bilan
  // ziddiyatga kirib, tsc build'ida xato beradi.
  await server.register(async (adminScope) => {
    const scoped = adminScope.withTypeProvider<ZodTypeProvider>();
    scoped.addHook('preHandler', requireRole(UserRole.Admin, UserRole.Manager));

    scoped.delete(
      '/:customerId',
      {
        schema: {
          tags: ['Customers'],
          security: [{ bearerAuth: [] }],
          params: customerIdParamsSchema,
        },
      },
      customerController.delete,
    );
  });
};