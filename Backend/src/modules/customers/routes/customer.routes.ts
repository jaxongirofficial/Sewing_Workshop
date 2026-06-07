import { Router } from 'express';

import { authenticate } from '../../../middlewares/auth.middleware';
import { validateRequest } from '../../../middlewares/validate-request';
import { customerController } from '../controllers/customer.controller';
import {
  createCustomerValidator,
  customerIdValidator,
  listCustomersValidator,
  updateCustomerValidator,
} from '../validators/customer.validator';

export const customerRouter = Router();

customerRouter.use(authenticate);

customerRouter.get('/', listCustomersValidator, validateRequest, customerController.list);
customerRouter.post('/', createCustomerValidator, validateRequest, customerController.create);
customerRouter.patch('/:customerId', updateCustomerValidator, validateRequest, customerController.update);
customerRouter.delete('/:customerId', customerIdValidator, validateRequest, customerController.delete);
