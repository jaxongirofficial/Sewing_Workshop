import { z } from 'zod';

import { paginationQuerySchema } from '../../../shared/pagination';
import { objectIdSchema } from '../../../shared/validators/object-id';

export const customerIdParamsSchema = z.object({
  customerId: objectIdSchema,
});

export const listCustomersQuerySchema = paginationQuerySchema.extend({
  search: z.string().trim().max(120).optional(),
});

export const createCustomerBodySchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  phone: z.string().trim().min(7).max(32),
  address: z.string().trim().min(2).max(240),
});

export const updateCustomerBodySchema = createCustomerBodySchema.partial();

export type CustomerIdParams = z.infer<typeof customerIdParamsSchema>;
export type ListCustomersQuery = z.infer<typeof listCustomersQuerySchema>;
export type CreateCustomerBody = z.infer<typeof createCustomerBodySchema>;
export type UpdateCustomerBody = z.infer<typeof updateCustomerBodySchema>;
