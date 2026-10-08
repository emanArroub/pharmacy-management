import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

async login(email: string, password: string) {
  const user = await this.prisma.users.findUnique({
    where: { email },
  });

  if (!user) {
    throw new UnauthorizedException('Invalid email or password');
  }

  const passwordMatch = await bcrypt.compare(password, user.password);

  if (!passwordMatch) {
    throw new UnauthorizedException('Invalid email or password');
  }

  const payload = {
    sub: user.user_id,
    email: user.email,
  };

  return {
    access_token: await this.jwtService.signAsync(payload),
  };
}
}
