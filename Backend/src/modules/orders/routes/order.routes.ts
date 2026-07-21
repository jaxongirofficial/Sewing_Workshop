import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';

import { authenticate } from '../../../middlewares/auth.middleware';
import { orderController } from '../controllers/order.controller';
import {
  createOrderBodySchema,
  listOrdersQuerySchema,
  orderIdParamsSchema,
  updateOrderBodySchema,
  updateOrderStatusBodySchema,
} from '../validators/order.validator';

export const orderRoutes = async (app: FastifyInstance): Promise<void> => {
  const server = app.withTypeProvider<ZodTypeProvider>();

  server.addHook('preHandler', authenticate);

  server.get(
    '/',
    { schema: { tags: ['Orders'], security: [{ bearerAuth: [] }], querystring: listOrdersQuerySchema } },
    orderController.list,
  );

  server.post(
    '/',
    { schema: { tags: ['Orders'], security: [{ bearerAuth: [] }], body: createOrderBodySchema } },
    orderController.create,
  );

  server.patch(
    '/:orderId',
    {
      schema: {
        tags: ['Orders'],
        security: [{ bearerAuth: [] }],
        params: orderIdParamsSchema,
        body: updateOrderBodySchema,
      },
    },
    orderController.update,
  );

  server.patch(
    '/:orderId/status',
    {
      schema: {
        tags: ['Orders'],
        security: [{ bearerAuth: [] }],
        params: orderIdParamsSchema,
        body: updateOrderStatusBodySchema,
      },
    },
    orderController.updateStatus,
  );

  server.delete(
    '/:orderId',
    { schema: { tags: ['Orders'], security: [{ bearerAuth: [] }], params: orderIdParamsSchema } },
    orderController.delete,
  );
};
