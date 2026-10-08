import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class MedicinesService {
  constructor(private readonly prisma: PrismaService) {}

  create(name: string) {
    return this.prisma.medicines.create({ data: { name } });
  }

  findAll() {
    return this.prisma.medicines.findMany({ orderBy: { medicine_id: 'asc' } });
  }
}

