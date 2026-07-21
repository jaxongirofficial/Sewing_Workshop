import type { FastifyReply, FastifyRequest } from 'fastify';

import { successResponse } from '../../../shared/http-response';
import { customerService, type CustomerService } from '../services/customer.service';
import type {
  CreateCustomerBody,
  CustomerIdParams,
  ListCustomersQuery,
  UpdateCustomerBody,
} from '../validators/customer.validator';

export class CustomerController {
  constructor(private readonly service: CustomerService = customerService) {}

  list = async (
    request: FastifyRequest<{ Querystring: ListCustomersQuery }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const result = await this.service.list(request.query);

    reply.send(successResponse(result, 'Customers fetched successfully'));
  };

  getById = async (
    request: FastifyRequest<{ Params: CustomerIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const customer = await this.service.getById(request.params.customerId);

    reply.send(successResponse({ customer }, 'Customer fetched successfully'));
  };

  create = async (
    request: FastifyRequest<{ Body: CreateCustomerBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const customer = await this.service.create(request.body);

    reply.status(201).send(successResponse({ customer }, 'Customer created successfully'));
  };

  update = async (
    request: FastifyRequest<{ Params: CustomerIdParams; Body: UpdateCustomerBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const customer = await this.service.update(request.params.customerId, request.body);

    reply.send(successResponse({ customer }, 'Customer updated successfully'));
  };

  delete = async (
    request: FastifyRequest<{ Params: CustomerIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    await this.service.delete(request.params.customerId);

    reply.status(204).send();
  };
}

export const customerController = new CustomerController();