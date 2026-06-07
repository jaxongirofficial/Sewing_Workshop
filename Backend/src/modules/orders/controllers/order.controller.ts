import { OrderStatus } from '../models/order.model';
import { orderService, type OrderService } from '../services/order.service';
import { asyncHandler } from '../../../shared/utils/async-handler';

export class OrderController {
  constructor(private readonly service: OrderService = orderService) {}

  list = asyncHandler(async (req, res) => {
    const orders = await this.service.list({
      customerId: typeof req.query.customerId === 'string' ? req.query.customerId : undefined,
      status: this.parseStatus(req.query.status),
    });

    res.json({
      success: true,
      data: { orders },
    });
  });

  create = asyncHandler(async (req, res) => {
    const order = await this.service.create(req.body);
    res.status(201).json({
      success: true,
      data: { order },
    });
  });

  update = asyncHandler(async (req, res) => {
    const order = await this.service.update(req.params.orderId, req.body);
    res.json({
      success: true,
      data: { order },
    });
  });

  updateStatus = asyncHandler(async (req, res) => {
    const order = await this.service.updateStatus(req.params.orderId, req.body.status);
    res.json({
      success: true,
      data: { order },
    });
  });

  delete = asyncHandler(async (req, res) => {
    await this.service.delete(req.params.orderId);
    res.status(204).send();
  });

  private parseStatus(value: unknown): OrderStatus | undefined {
    return typeof value === 'string' && Object.values(OrderStatus).includes(value as OrderStatus)
      ? (value as OrderStatus)
      : undefined;
  }
}

export const orderController = new OrderController();
