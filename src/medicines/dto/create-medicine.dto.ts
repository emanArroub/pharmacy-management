import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateMedicineDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;
}
