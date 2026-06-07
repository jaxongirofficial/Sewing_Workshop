import { Router } from 'express';

import { authenticate } from '../../../middlewares/auth.middleware';
import { validateRequest } from '../../../middlewares/validate-request';
import { workerController } from '../controllers/worker.controller';
import {
  createWorkerValidator,
  listWorkersValidator,
  updateWorkerValidator,
  workerIdValidator,
} from '../validators/worker.validator';

export const workerRouter = Router();

workerRouter.use(authenticate);

workerRouter.get('/', listWorkersValidator, validateRequest, workerController.list);
workerRouter.post('/', createWorkerValidator, validateRequest, workerController.create);
workerRouter.patch('/:workerId', updateWorkerValidator, validateRequest, workerController.update);
workerRouter.delete('/:workerId', workerIdValidator, validateRequest, workerController.delete);
