import type { FilterQuery } from 'mongoose';

import { PaymentModel, type IPayment, type IPaymentDocument } from '../models/payment.model';

export interface PaymentHistoryQuery {
  workerId?: string;
  from?: Date;
  to?: Date;
}

export class PaymentRepository {
  findAll(query: PaymentHistoryQuery = {}): Promise<IPaymentDocument[]> {
    const filter: FilterQuery<IPaymentDocument> = {};

    if (query.workerId) {
      filter.workerId = query.workerId;
    }

    if (query.from || query.to) {
      filter.paymentDate = {
        ...(query.from ? { $gte: query.from } : {}),
        ...(query.to ? { $lte: query.to } : {}),
      };
    }

    return PaymentModel.find(filter).sort({ paymentDate: -1, createdAt: -1 }).exec();
  }

  create(payment: IPayment): Promise<IPaymentDocument> {
    return PaymentModel.create(payment);
  }
}

export const paymentRepository = new PaymentRepository();
