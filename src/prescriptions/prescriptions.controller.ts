import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';
import { CreatePrescriptionDto } from './dto/create-prescription.dto.js';
import { PrescriptionsService } from './prescriptions.service.js';

@Controller('prescriptions')
export class PrescriptionsController {
  constructor(private readonly service: PrescriptionsService) {}

  @Post()
  create(@Body() dto: CreatePrescriptionDto) {
    return this.service.create(dto);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/dispense')
  dispense(@Param('id', ParseIntPipe) id: number) {
    return this.service.dispense(id);
  }
}
