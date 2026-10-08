import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './auth/auth.module.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { PatientsModule } from './patients/patients.module.js';
import { BatchesModule } from './batches/batches.module.js';
import { MedicinesModule } from './medicines/medicines.module.js';
import { PrescriptionsModule } from './prescriptions/prescriptions.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    PatientsModule,
    BatchesModule,
    MedicinesModule,
    PrescriptionsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
