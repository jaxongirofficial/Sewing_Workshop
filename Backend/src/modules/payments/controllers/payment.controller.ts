import { asyncHandler } from '../../../shared/utils/async-handler';
import { paymentService, type PaymentService } from '../services/payment.service';

export class PaymentController {
  constructor(private readonly service: PaymentService = paymentService) {}

  history = asyncHandler(async (req, res) => {
    const payments = await this.service.history({
      workerId: typeof req.query.workerId === 'string' ? req.query.workerId : undefined,
      from: req.query.from instanceof Date ? req.query.from : undefined,
      to: req.query.to instanceof Date ? req.query.to : undefined,
    });

    res.json({
      success: true,
      data: { payments },
    });
  });

  record = asyncHandler(async (req, res) => {
    const payment = await this.service.record(req.body);
    res.status(201).json({
      success: true,
      data: { payment },
    });
  });
}

export const paymentController = new PaymentController();
