import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsInt,
  IsNotEmpty,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

export class PrescriptionItemDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  medicine_id!: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  quantity!: number;
}

export class CreatePrescriptionDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  patient_id!: number;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => PrescriptionItemDto)
  items!: PrescriptionItemDto[];
}
