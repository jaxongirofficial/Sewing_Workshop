import type { QueryFilter } from 'mongoose';

import { PaymentModel, type IPayment, type IPaymentDocument } from '../models/payment.model';

export interface PaymentHistoryQuery {
  workerId?: string;
  from?: Date;
  to?: Date;
  page: number;
  limit: number;
}

export interface PaymentListResult {
  items: IPaymentDocument[];
  total: number;
}

export class PaymentRepository {
  async findAll(query: PaymentHistoryQuery): Promise<PaymentListResult> {
    const filter: QueryFilter<IPaymentDocument> = {};

    if (query.workerId) {
      filter.workerId = query.workerId;
    }

    if (query.from || query.to) {
      filter.paymentDate = {
        ...(query.from ? { $gte: query.from } : {}),
        ...(query.to ? { $lte: query.to } : {}),
      };
    }

    const skip = (query.page - 1) * query.limit;

    const [items, total] = await Promise.all([
      PaymentModel.find(filter).sort({ paymentDate: -1, createdAt: -1 }).skip(skip).limit(query.limit).exec(),
      PaymentModel.countDocuments(filter).exec(),
    ]);

    return { items, total };
  }

  create(payment: IPayment): Promise<IPaymentDocument> {
    return PaymentModel.create(payment);
  }
}

export const paymentRepository = new PaymentRepository();
