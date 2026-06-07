import { Router } from 'express';

import { authenticate } from '../../../middlewares/auth.middleware';
import { validateRequest } from '../../../middlewares/validate-request';
import { paymentController } from '../controllers/payment.controller';
import { paymentHistoryValidator, recordPaymentValidator } from '../validators/payment.validator';

export const paymentRouter = Router();

paymentRouter.use(authenticate);

paymentRouter.get('/', paymentHistoryValidator, validateRequest, paymentController.history);
paymentRouter.post('/', recordPaymentValidator, validateRequest, paymentController.record);
