import { Type } from 'class-transformer';
import { IsDateString, IsInt, Max, Min } from 'class-validator';

export class CreateBatchDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  medicine_id!: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  quantity!: number;

  @IsDateString()
  expire_date!: string;
}
