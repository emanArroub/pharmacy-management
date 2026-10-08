import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateMedicineDto } from './dto/create-medicine.dto.js';
import { MedicinesService } from './medicines.service.js';

@Controller('medicines')
export class MedicinesController {
  constructor(private readonly service: MedicinesService) {}

  @Post()
  create(@Body() dto: CreateMedicineDto) {
    return this.service.create(dto.name);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }
}
