import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreatePatientDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;
}
