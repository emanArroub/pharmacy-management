import { Injectable, BadRequestException, NotFoundException} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreatePrescriptionDto } from './dto/create-prescription.dto.js';

@Injectable()
export class PrescriptionsService {
  constructor(private readonly prisma: PrismaService) {}

  create(data: CreatePrescriptionDto) {
    return this.prisma.prescriptions.create({
      data: {
        patient_id: data.patient_id,
        prescription_items: {
          create: data.items.map((item) => ({
            medicine_id: item.medicine_id,
            quantity: item.quantity,
          })),
        },
      },
      include: {
        patients: true,
        prescription_items: {
          include: { medicines: true },
        },
      },
    });
  }

  findAll() {
    return this.prisma.prescriptions.findMany({
      include: {
        patients: true,
        prescription_items: {
          include: {
            medicines: true,
          },
        },
      },
    });
  }

async dispense(prescriptionId: number) {
  try {
    const result = await this.prisma.$queryRaw<
      { result: string }[]
    > `SELECT dispense_prescription(${prescriptionId}) AS result`;

    return result[0].result;
  } catch (error: any) {
    if (error?.code === 'P2010') {
      const message =
        error?.meta?.driverAdapterError?.cause?.originalMessage;

      if (message) {
        throw new BadRequestException(message);
      }
    }

    throw error;
  }
}
}
