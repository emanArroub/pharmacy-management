import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateBatchDto } from './dto/create-batch.dto.js';

@Injectable()
export class BatchesService {
  constructor(private readonly prisma: PrismaService) {}

  create(data: CreateBatchDto) {
    return this.prisma.batches.create({
      data: {
        medicine_id: data.medicine_id,
        quantity: data.quantity,
        expire_date: new Date(data.expire_date),
      },
    });
  }

  findAll() {
    return this.prisma.batches.findMany({
      include: { medicines: true },
      orderBy: [{ medicine_id: 'asc' }, { expire_date: 'asc' }],
    });
  }
}
