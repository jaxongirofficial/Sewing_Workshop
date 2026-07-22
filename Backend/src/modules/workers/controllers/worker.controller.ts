import type { FastifyReply, FastifyRequest } from 'fastify';

import { successResponse } from '../../../shared/http-response';
import { workerService, type WorkerService } from '../services/worker.service';
import type {
  CreateWorkerBody,
  ListWorkersQuery,
  UpdateWorkerBody,
  WorkerIdParams,
} from '../validators/worker.validator';

export class WorkerController {
  constructor(private readonly service: WorkerService = workerService) {}

  list = async (
    request: FastifyRequest<{ Querystring: ListWorkersQuery }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const result = await this.service.list(request.query);
    reply.send(successResponse(result, 'Workers fetched successfully'));
  };

  getById = async (
    request: FastifyRequest<{ Params: WorkerIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const worker = await this.service.getById(request.params.workerId);
    reply.send(successResponse({ worker }, 'Worker fetched successfully'));
  };

  create = async (
    request: FastifyRequest<{ Body: CreateWorkerBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const worker = await this.service.create(request.body);
    reply.status(201).send(successResponse({ worker }, 'Worker created successfully'));
  };

  update = async (
    request: FastifyRequest<{ Params: WorkerIdParams; Body: UpdateWorkerBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const worker = await this.service.update(request.params.workerId, request.body);
    reply.send(successResponse({ worker }, 'Worker updated successfully'));
  };

  delete = async (
    request: FastifyRequest<{ Params: WorkerIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    await this.service.delete(request.params.workerId);
    reply.status(204).send();
  };
}

export const workerController = new WorkerController();
