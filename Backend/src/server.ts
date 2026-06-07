import { app } from './app';
import { env } from './config/env';
import { connectDatabase, disconnectDatabase } from './database/mongoose';

const startServer = async (): Promise<void> => {
  await connectDatabase();

  const server = app.listen(env.port, () => {
    console.log(`Sewing Workshop API running on port ${env.port}`);
  });

  const shutdown = async (signal: NodeJS.Signals): Promise<void> => {
    console.log(`${signal} received. Shutting down API server.`);
    server.close(async () => {
      await disconnectDatabase();
      process.exit(0);
    });
  };

  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
};

void startServer().catch((error) => {
  console.error('Failed to start API server', error);
  process.exit(1);
});
