import { Types } from 'mongoose';

import { HttpError } from '../../../shared/errors/http-error';
import { buildPaginationMeta, type PaginatedResult } from '../../../shared/pagination';
import { customerRepository, type CustomerRepository } from '../../customers/repositories/customer.repository';
import { OrderStatus, type IOrderDocument } from '../models/order.model';
import {
  orderRepository,
  type OrderListQuery,
  type OrderRepository,
} from '../repositories/order.repository';

export interface CreateOrderInput {
  orderNumber: string;
  customerId: string;
  quantity: number;
  totalPrice: number;
  deadline: string | Date;
  status?: OrderStatus;
}

export type UpdateOrderInput = Partial<CreateOrderInput>;

export interface OrderResponse {
  id: string;
  orderNumber: string;
  customerId: string;
  quantity: number;
  totalPrice: number;
  deadline: Date;
  status: OrderStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class OrderService {
  constructor(
    private readonly repository: OrderRepository = orderRepository,
    private readonly customers: CustomerRepository = customerRepository,
  ) {}

  async list(query: OrderListQuery): Promise<PaginatedResult<OrderResponse>> {
    const { items, total } = await this.repository.findAll(query);
    return {
      items: items.map((order) => this.mapOrder(order)),
      pagination: buildPaginationMeta(query.page, query.limit, total),
    };
  }

  async create(input: CreateOrderInput): Promise<OrderResponse> {
    const orderNumber = input.orderNumber.trim().toUpperCase();
    const existing = await this.repository.findByOrderNumber(orderNumber);
    if (existing) {
      throw new HttpError(409, 'Order number already exists', 'ORDER_NUMBER_EXISTS');
    }

    await this.assertCustomerExists(input.customerId);

    const order = await this.repository.create({
      orderNumber,
      customerId: this.toObjectId(input.customerId),
      quantity: input.quantity,
      totalPrice: input.totalPrice,
      deadline: new Date(input.deadline),
      status: input.status ?? OrderStatus.Pending,
    });

    return this.mapOrder(order);
  }

  async update(orderId: string, input: UpdateOrderInput): Promise<OrderResponse> {
    if (input.customerId != null) {
      await this.assertCustomerExists(input.customerId);
    }

    const update = {
      ...(input.orderNumber != null ? { orderNumber: input.orderNumber.trim().toUpperCase() } : {}),
      ...(input.customerId != null ? { customerId: this.toObjectId(input.customerId) } : {}),
      ...(input.quantity != null ? { quantity: input.quantity } : {}),
      ...(input.totalPrice != null ? { totalPrice: input.totalPrice } : {}),
      ...(input.deadline != null ? { deadline: new Date(input.deadline) } : {}),
      ...(input.status != null ? { status: input.status } : {}),
    };

    if (input.orderNumber != null) {
      const existing = await this.repository.findByOrderNumber(input.orderNumber);
      if (existing && existing._id.toString() !== orderId) {
        throw new HttpError(409, 'Order number already exists', 'ORDER_NUMBER_EXISTS');
      }
    }

    const order = await this.repository.update(orderId, update);
    if (!order) {
      throw new HttpError(404, 'Order not found', 'ORDER_NOT_FOUND');
    }

    return this.mapOrder(order);
  }

  async updateStatus(orderId: string, status: OrderStatus): Promise<OrderResponse> {
    const order = await this.repository.update(orderId, { status });
    if (!order) {
      throw new HttpError(404, 'Order not found', 'ORDER_NOT_FOUND');
    }

    return this.mapOrder(order);
  }

  async delete(orderId: string): Promise<void> {
    const order = await this.repository.delete(orderId);
    if (!order) {
      throw new HttpError(404, 'Order not found', 'ORDER_NOT_FOUND');
    }
  }

  private async assertCustomerExists(customerId: string): Promise<void> {
    const customer = await this.customers.findById(customerId);
    if (!customer) {
      throw new HttpError(404, 'Customer not found', 'CUSTOMER_NOT_FOUND');
    }
  }

  private toObjectId(value: string): Types.ObjectId {
    return new Types.ObjectId(value);
  }

  private mapOrder(order: IOrderDocument): OrderResponse {
    return {
      id: order._id.toString(),
      orderNumber: order.orderNumber,
      customerId: order.customerId.toString(),
      quantity: order.quantity,
      totalPrice: order.totalPrice,
      deadline: order.deadline,
      status: order.status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    };
  }
}

export const orderService = new OrderService();
