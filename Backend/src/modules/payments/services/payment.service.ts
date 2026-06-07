import { Types } from 'mongoose';

import type { IPaymentDocument } from '../models/payment.model';
import {
  paymentRepository,
  type PaymentHistoryQuery,
  type PaymentRepository,
} from '../repositories/payment.repository';

export interface RecordPaymentInput {
  workerId: string;
  amount: number;
  paymentDate?: string | Date;
}

export interface PaymentResponse {
  id: string;
  workerId: string;
  amount: number;
  paymentDate: Date;
  createdAt: Date;
  updatedAt: Date;
}

export class PaymentService {
  constructor(private readonly repository: PaymentRepository = paymentRepository) {}

  async history(query: PaymentHistoryQuery): Promise<PaymentResponse[]> {
    const payments = await this.repository.findAll(query);
    return payments.map((payment) => this.mapPayment(payment));
  }

  async record(input: RecordPaymentInput): Promise<PaymentResponse> {
    const payment = await this.repository.create({
      workerId: new Types.ObjectId(input.workerId),
      amount: input.amount,
      paymentDate: input.paymentDate ? new Date(input.paymentDate) : new Date(),
    });

    return this.mapPayment(payment);
  }

  private mapPayment(payment: IPaymentDocument): PaymentResponse {
    return {
      id: payment.id,
      workerId: payment.workerId.toString(),
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
    };
  }
}

export const paymentService = new PaymentService();
