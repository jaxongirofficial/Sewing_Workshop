import { z } from 'zod';

import { paginationQuerySchema } from '../../../shared/pagination';
import { objectIdSchema } from '../../../shared/validators/object-id';
import { WorkerStatus } from '../models/worker.model';

const workerStatusEnum = z.nativeEnum(WorkerStatus);

export const workerIdParamsSchema = z.object({
  workerId: objectIdSchema,
});

export const listWorkersQuerySchema = paginationQuerySchema.extend({
  search: z.string().trim().max(120).optional(),
  status: workerStatusEnum.optional(),
});

export const createWorkerBodySchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  phone: z.string().trim().min(7).max(32),
  position: z.string().trim().min(2).max(80),
  salary: z.number().min(0),
  status: workerStatusEnum.optional(),
});

export const updateWorkerBodySchema = createWorkerBodySchema.partial();

export type WorkerIdParams = z.infer<typeof workerIdParamsSchema>;
export type ListWorkersQuery = z.infer<typeof listWorkersQuerySchema>;
export type CreateWorkerBody = z.infer<typeof createWorkerBodySchema>;
export type UpdateWorkerBody = z.infer<typeof updateWorkerBodySchema>;
