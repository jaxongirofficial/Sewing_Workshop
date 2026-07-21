import type { QueryFilter, UpdateQuery } from 'mongoose';

import { OrderModel, OrderStatus, type IOrder, type IOrderDocument } from '../models/order.model';

export interface OrderListQuery {
  customerId?: string;
  status?: OrderStatus;
  page: number;
  limit: number;
}

export interface OrderListResult {
  items: IOrderDocument[];
  total: number;
}

export class OrderRepository {
  async findAll(query: OrderListQuery): Promise<OrderListResult> {
    const filter: QueryFilter<IOrderDocument> = {};

    if (query.customerId) {
      filter.customerId = query.customerId;
    }

    if (query.status) {
      filter.status = query.status;
    }

    const skip = (query.page - 1) * query.limit;

    const [items, total] = await Promise.all([
      OrderModel.find(filter).sort({ deadline: 1, createdAt: -1 }).skip(skip).limit(query.limit).exec(),
      OrderModel.countDocuments(filter).exec(),
    ]);

    return { items, total };
  }

  findById(orderId: string): Promise<IOrderDocument | null> {
    return OrderModel.findById(orderId).exec();
  }

  findByOrderNumber(orderNumber: string): Promise<IOrderDocument | null> {
    return OrderModel.findOne({ orderNumber: orderNumber.trim().toUpperCase() }).exec();
  }

  create(order: IOrder): Promise<IOrderDocument> {
    return OrderModel.create(order);
  }

  update(orderId: string, order: UpdateQuery<IOrder>): Promise<IOrderDocument | null> {
    return OrderModel.findByIdAndUpdate(orderId, order, {
      new: true,
      runValidators: true,
    }).exec();
  }

  delete(orderId: string): Promise<IOrderDocument | null> {
    return OrderModel.findByIdAndDelete(orderId).exec();
  }
}

export const orderRepository = new OrderRepository();
