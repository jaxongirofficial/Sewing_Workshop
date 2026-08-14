import cookie from '@fastify/cookie';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import multipart from '@fastify/multipart';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import Fastify, { type FastifyInstance } from 'fastify';
import {
  jsonSchemaTransform,
  serializerCompiler,
  validatorCompiler,
  type ZodTypeProvider,
} from 'fastify-type-provider-zod';

import { env } from './config/env';
import { registerErrorHandler } from './middlewares/error-handler';
import { authRoutes } from './modules/auth/routes/auth.routes';
import { customerRoutes } from './modules/customers/routes/customer.routes';
import { orderRoutes } from './modules/orders/routes/order.routes';
import { paymentRoutes } from './modules/payments/routes/payment.routes';
import { workerRoutes } from './modules/workers/routes/worker.routes';
import { workshopRoutes } from './modules/workshop/routes/workshop.routes';
import { successResponse } from './shared/http-response';

export const buildApp = async (): Promise<FastifyInstance> => {
  const app = Fastify({
    logger: {
      level: env.nodeEnv === 'production' ? 'info' : 'debug',
      transport: env.nodeEnv === 'production' ? undefined : { target: 'pino-pretty' },
    },
  }).withTypeProvider<ZodTypeProvider>();

  // Zod becomes Fastify's schema validator/serializer, replacing express-validator.
  // Route schemas (added per-module in later steps) are plain Zod objects.
  app.setValidatorCompiler(validatorCompiler);
  app.setSerializerCompiler(serializerCompiler);

  await app.register(helmet);
  await app.register(cors, {
    origin: env.clientOrigin === '*' ? true : env.clientOrigin,
    credentials: true,
  });
  await app.register(cookie);
  await app.register(multipart);
  await app.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
  });

  await app.register(swagger, {
    openapi: {
      info: {
        title: 'Sewing Workshop API',
        description: 'Backend API for the Sewing Workshop Management System.',
        version: '1.0.0',
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
          },
        },
      },
    },
    transform: jsonSchemaTransform,
  });
  await app.register(swaggerUi, {
    routePrefix: '/docs',
  });

  registerErrorHandler(app);

  app.get('/api/health', async () =>
    successResponse({ service: 'sewing-workshop-api', status: 'ok' }, 'Service is healthy'),
  );

  // Module routes are registered here module-by-module, so each migration
  // stays reviewable on its own instead of landing as one large diff.
  await app.register(authRoutes, { prefix: '/api/auth' });
  await app.register(customerRoutes, { prefix: '/api/customers' });
  await app.register(orderRoutes, { prefix: '/api/orders' });
  await app.register(paymentRoutes, { prefix: '/api/payments' });
  await app.register(workerRoutes, { prefix: '/api/workers' });
  await app.register(workshopRoutes, { prefix: '/api' });

  return app;
};
