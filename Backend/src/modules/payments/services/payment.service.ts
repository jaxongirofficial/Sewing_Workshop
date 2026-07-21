import { Types } from 'mongoose';

import { HttpError } from '../../../shared/errors/http-error';
import { buildPaginationMeta, type PaginatedResult } from '../../../shared/pagination';
import { workerRepository, type WorkerRepository } from '../../workers/repositories/worker.repository';
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
  constructor(
    private readonly repository: PaymentRepository = paymentRepository,
    private readonly workers: WorkerRepository = workerRepository,
  ) {}

  async history(query: PaymentHistoryQuery): Promise<PaginatedResult<PaymentResponse>> {
    const { items, total } = await this.repository.findAll(query);
    return {
      items: items.map((payment) => this.mapPayment(payment)),
      pagination: buildPaginationMeta(query.page, query.limit, total),
    };
  }

  async record(input: RecordPaymentInput): Promise<PaymentResponse> {
    const worker = await this.workers.findById(input.workerId);
    if (!worker) {
      throw new HttpError(404, 'Worker not found', 'WORKER_NOT_FOUND');
    }

    const payment = await this.repository.create({
      workerId: new Types.ObjectId(input.workerId),
      amount: input.amount,
      paymentDate: input.paymentDate ? new Date(input.paymentDate) : new Date(),
    });

    return this.mapPayment(payment);
  }

  private mapPayment(payment: IPaymentDocument): PaymentResponse {
    return {
      id: payment._id.toString(),
      workerId: payment.workerId.toString(),
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
    };
  }
}

export const paymentService = new PaymentService();
