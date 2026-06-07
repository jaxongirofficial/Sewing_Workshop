import { Router } from 'express';

import { authenticate } from '../../../middlewares/auth.middleware';
import { validateRequest } from '../../../middlewares/validate-request';
import { orderController } from '../controllers/order.controller';
import {
  createOrderValidator,
  listOrdersValidator,
  orderIdValidator,
  updateOrderStatusValidator,
  updateOrderValidator,
} from '../validators/order.validator';

export const orderRouter = Router();

orderRouter.use(authenticate);

orderRouter.get('/', listOrdersValidator, validateRequest, orderController.list);
orderRouter.post('/', createOrderValidator, validateRequest, orderController.create);
orderRouter.patch('/:orderId', updateOrderValidator, validateRequest, orderController.update);
orderRouter.patch('/:orderId/status', updateOrderStatusValidator, validateRequest, orderController.updateStatus);
orderRouter.delete('/:orderId', orderIdValidator, validateRequest, orderController.delete);
