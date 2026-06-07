import { Router } from 'express';

import { authenticate } from '../../../middlewares/auth.middleware';
import { validateRequest } from '../../../middlewares/validate-request';
import { authController } from '../controllers/auth.controller';
import {
  loginValidator,
  logoutValidator,
  refreshTokenValidator,
  registerValidator,
} from '../validators/auth.validator';

export const authRouter = Router();

authRouter.post('/register', registerValidator, validateRequest, authController.register);
authRouter.post('/login', loginValidator, validateRequest, authController.login);
authRouter.post('/refresh-token', refreshTokenValidator, validateRequest, authController.refresh);
authRouter.post('/logout', logoutValidator, validateRequest, authController.logout);
authRouter.get('/me', authenticate, authController.me);
