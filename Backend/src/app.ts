import cookieParser from 'cookie-parser';
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env';
import { errorHandler } from './middlewares/error-handler';
import { authRouter } from './modules/auth/routes/auth.routes';
import { customerRouter } from './modules/customers/routes/customer.routes';
import { orderRouter } from './modules/orders/routes/order.routes';
import { paymentRouter } from './modules/payments/routes/payment.routes';
import { workerRouter } from './modules/workers/routes/worker.routes';

export const app = express();

app.use(helmet());
app.use(
  cors({
    origin: env.clientOrigin,
    credentials: true,
  }),
);
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

if (env.nodeEnv !== 'test') {
  app.use(morgan('dev'));
}

app.get('/api/health', (_req, res) => {
  res.json({
    success: true,
    data: {
      service: 'sewing-workshop-api',
      status: 'ok',
    },
  });
});

app.use('/api/auth', authRouter);
app.use('/api/customers', customerRouter);
app.use('/api/orders', orderRouter);
app.use('/api/payments', paymentRouter);
app.use('/api/workers', workerRouter);
app.use(errorHandler);
