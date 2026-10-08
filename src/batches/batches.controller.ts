import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateBatchDto } from './dto/create-batch.dto.js';
import { BatchesService } from './batches.service.js';

@Controller('batches')
export class BatchesController {
  constructor(private readonly service: BatchesService) {}

  @Post()
  create(@Body() dto: CreateBatchDto) {
    return this.service.create(dto);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }
}
