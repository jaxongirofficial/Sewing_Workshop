import { buildApp } from './app';
import { env } from './config/env';
import { connectDatabase, disconnectDatabase } from './database/mongoose';

const startServer = async (): Promise<void> => {
  const app = await buildApp();
  await connectDatabase();

  await app.listen({ port: env.port, host: '0.0.0.0' });

  const shutdown = async (signal: NodeJS.Signals): Promise<void> => {
    app.log.info(`${signal} received. Shutting down API server.`);
    await app.close();
    await disconnectDatabase();
    process.exit(0);
  };

  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));
};

void startServer().catch((error) => {
  console.error('Failed to start API server', error);
  process.exit(1);
});
