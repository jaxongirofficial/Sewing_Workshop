import type { FastifyReply, FastifyRequest } from 'fastify';

import { successResponse } from '../../../shared/http-response';
import { paymentService, type PaymentService } from '../services/payment.service';
import type { PaymentHistoryQuery, RecordPaymentBody } from '../validators/payment.validator';

export class PaymentController {
  constructor(private readonly service: PaymentService = paymentService) {}

  history = async (
    request: FastifyRequest<{ Querystring: PaymentHistoryQuery }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const result = await this.service.history(request.query);
    reply.send(successResponse(result, 'Payments fetched successfully'));
  };

  record = async (
    request: FastifyRequest<{ Body: RecordPaymentBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const payment = await this.service.record(request.body);
    reply.status(201).send(successResponse({ payment }, 'Payment recorded successfully'));
  };
}

export const paymentController = new PaymentController();
