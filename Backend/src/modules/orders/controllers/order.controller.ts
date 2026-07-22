import type { FastifyReply, FastifyRequest } from 'fastify';

import { successResponse } from '../../../shared/http-response';
import { orderService, type OrderService } from '../services/order.service';
import type {
  CreateOrderBody,
  ListOrdersQuery,
  OrderIdParams,
  UpdateOrderBody,
  UpdateOrderStatusBody,
} from '../validators/order.validator';

export class OrderController {
  constructor(private readonly service: OrderService = orderService) {}

  list = async (
    request: FastifyRequest<{ Querystring: ListOrdersQuery }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const result = await this.service.list(request.query);
    reply.send(successResponse(result, 'Orders fetched successfully'));
  };

  getById = async (
    request: FastifyRequest<{ Params: OrderIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const order = await this.service.getById(request.params.orderId);
    reply.send(successResponse({ order }, 'Order fetched successfully'));
  };

  create = async (
    request: FastifyRequest<{ Body: CreateOrderBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const order = await this.service.create(request.body);
    reply.status(201).send(successResponse({ order }, 'Order created successfully'));
  };

  update = async (
    request: FastifyRequest<{ Params: OrderIdParams; Body: UpdateOrderBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const order = await this.service.update(request.params.orderId, request.body);
    reply.send(successResponse({ order }, 'Order updated successfully'));
  };

  updateStatus = async (
    request: FastifyRequest<{ Params: OrderIdParams; Body: UpdateOrderStatusBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const order = await this.service.updateStatus(request.params.orderId, request.body.status);
    reply.send(successResponse({ order }, 'Order status updated successfully'));
  };

  delete = async (
    request: FastifyRequest<{ Params: OrderIdParams }>,
    reply: FastifyReply,
  ): Promise<void> => {
    await this.service.delete(request.params.orderId);
    reply.status(204).send();
  };
}

export const orderController = new OrderController();
