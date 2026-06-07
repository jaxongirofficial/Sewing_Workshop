import type { FilterQuery, UpdateQuery } from 'mongoose';

import { OrderModel, OrderStatus, type IOrder, type IOrderDocument } from '../models/order.model';

export interface OrderListQuery {
  customerId?: string;
  status?: OrderStatus;
}

export class OrderRepository {
  findAll(query: OrderListQuery = {}): Promise<IOrderDocument[]> {
    const filter: FilterQuery<IOrderDocument> = {};

    if (query.customerId) {
      filter.customerId = query.customerId;
    }

    if (query.status) {
      filter.status = query.status;
    }

    return OrderModel.find(filter).sort({ deadline: 1, createdAt: -1 }).exec();
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
