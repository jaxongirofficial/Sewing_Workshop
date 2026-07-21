import { z } from 'zod';

import { paginationQuerySchema } from '../../../shared/pagination';
import { objectIdSchema } from '../../../shared/validators/object-id';

export const paymentHistoryQuerySchema = paginationQuerySchema.extend({
  workerId: objectIdSchema.optional(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
});

export const recordPaymentBodySchema = z.object({
  workerId: objectIdSchema,
  amount: z.number().min(0),
  paymentDate: z.coerce.date().optional(),
});

export type PaymentHistoryQuery = z.infer<typeof paymentHistoryQuerySchema>;
export type RecordPaymentBody = z.infer<typeof recordPaymentBodySchema>;
