import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { startCamundaWorker } from './camunda_worker/start_camunda_worker';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  startCamundaWorker(app);
  await app.listen(3002);
}
bootstrap();
