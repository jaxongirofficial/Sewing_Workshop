import { z } from 'zod';

import { paginationQuerySchema } from '../../../shared/pagination';
import { objectIdSchema } from '../../../shared/validators/object-id';
import { OrderStatus } from '../models/order.model';

const orderStatusEnum = z.nativeEnum(OrderStatus);

export const orderIdParamsSchema = z.object({
  orderId: objectIdSchema,
});

export const listOrdersQuerySchema = paginationQuerySchema.extend({
  customerId: objectIdSchema.optional(),
  status: orderStatusEnum.optional(),
});

export const createOrderBodySchema = z.object({
  orderNumber: z.string().trim().min(2).max(40),
  customerId: objectIdSchema,
  quantity: z.number().int().min(1),
  totalPrice: z.number().min(0),
  deadline: z.coerce.date(),
  status: orderStatusEnum.optional(),
});

export const updateOrderBodySchema = createOrderBodySchema.partial();

export const updateOrderStatusBodySchema = z.object({
  status: orderStatusEnum,
});

export type OrderIdParams = z.infer<typeof orderIdParamsSchema>;
export type ListOrdersQuery = z.infer<typeof listOrdersQuerySchema>;
export type CreateOrderBody = z.infer<typeof createOrderBodySchema>;
export type UpdateOrderBody = z.infer<typeof updateOrderBodySchema>;
export type UpdateOrderStatusBody = z.infer<typeof updateOrderStatusBodySchema>;
