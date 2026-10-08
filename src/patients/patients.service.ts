import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class PatientsService {
    constructor(private readonly prisma: PrismaService) {}

    createPatient(name: string) {
        return this.prisma.patients.create({
            data: {
                name,
            },
        });
    }
    findAll(){
        return this.prisma.patients.findMany();
    }
    findOne(id: number) {
        return this.prisma.patients.findUnique({
            where: {
                patient_id : id
            },
        });
    }
}
