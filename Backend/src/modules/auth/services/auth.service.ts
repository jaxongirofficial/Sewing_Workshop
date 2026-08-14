import bcrypt from 'bcrypt';
import crypto from 'crypto';
import jwt, { type SignOptions } from 'jsonwebtoken';

import { env } from '../../../config/env';
import { HttpError } from '../../../shared/errors/http-error';
import { authRepository, type AuthRepository } from '../repositories/auth.repository';
import { UserRole, type IUserDocument } from '../models/user.model';

export interface RegisterInput {
  fullName: string;
  email: string;
  phone: string;
  password: string;
}

export interface LoginInput {
  phone: string;
  password: string;
}

export interface AuthUserResponse {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  role: UserRole;
}

export interface AuthSessionResponse {
  user: AuthUserResponse;
  accessToken: string;
  refreshToken: string;
}

interface RefreshPayload {
  userId: string;
  tokenHash: string;
  type: 'refresh';
}

type JwtExpiresIn = NonNullable<SignOptions['expiresIn']>;

const toSeconds = (value: string): number => {
  const match = value.match(/^(\d+)([smhd])?$/);
  if (!match) return 7 * 24 * 60 * 60;

  const amount = Number(match[1]);
  const unit = match[2] ?? 's';
  const multipliers: Record<string, number> = {
    s: 1,
    m: 60,
    h: 60 * 60,
    d: 24 * 60 * 60,
  };
  return amount * multipliers[unit];
};

export class AuthService {
  constructor(private readonly repository: AuthRepository = authRepository) {}

  async register(input: RegisterInput): Promise<AuthSessionResponse> {
    const existing = await this.repository.findUserByEmail(input.email);
    if (existing) {
      throw new HttpError(409, 'Email is already registered', 'EMAIL_ALREADY_REGISTERED');
    }
    const existingPhone = await this.repository.findUserByPhone(input.phone);
    if (existingPhone) {
      throw new HttpError(409, 'Phone is already registered', 'PHONE_ALREADY_REGISTERED');
    }

    const password = await bcrypt.hash(input.password, env.bcryptSaltRounds);
    const user = await this.repository.createUser({
      fullName: input.fullName.trim(),
      email: input.email.toLowerCase().trim(),
      phone: input.phone.trim(),
      password,
      role: UserRole.Staff,
    });

    return this.createSession(user);
  }

  async login(input: LoginInput): Promise<AuthSessionResponse> {
    const user = await this.repository.findUserByPhone(input.phone, true);
    if (!user) {
      throw new HttpError(401, 'Invalid phone or password', 'INVALID_CREDENTIALS');
    }

    const isValid = await bcrypt.compare(input.password, user.password);
    if (!isValid) {
      throw new HttpError(401, 'Invalid phone or password', 'INVALID_CREDENTIALS');
    }

    return this.createSession(user);
  }

  async refresh(refreshToken: string): Promise<AuthSessionResponse> {
    const payload = this.verifyRefreshToken(refreshToken);
    const storedToken = await this.repository.findActiveRefreshToken(payload.tokenHash);
    if (!storedToken) {
      throw new HttpError(401, 'Refresh token is invalid or expired', 'INVALID_REFRESH_TOKEN');
    }

    const user = await this.repository.findUserById(payload.userId);
    if (!user) {
      throw new HttpError(401, 'Refresh token user no longer exists', 'INVALID_REFRESH_TOKEN');
    }

    await this.repository.revokeRefreshToken(payload.tokenHash);
    return this.createSession(user);
  }

  async logout(refreshToken: string): Promise<void> {
    const payload = this.verifyRefreshToken(refreshToken);
    await this.repository.revokeRefreshToken(payload.tokenHash);
  }

  async getCurrentUser(userId: string): Promise<AuthUserResponse> {
    const user = await this.repository.findUserById(userId);
    if (!user) {
      throw new HttpError(404, 'User not found', 'USER_NOT_FOUND');
    }
    return this.mapUser(user);
  }

  private async createSession(user: IUserDocument): Promise<AuthSessionResponse> {
    const tokenHash = crypto.randomBytes(32).toString('hex');
    const accessToken = this.signAccessToken(user);
    const refreshToken = this.signRefreshToken(user, tokenHash);

    await this.repository.createRefreshToken({
      userId: user._id.toString(),
      tokenHash,
      expiresAt: new Date(Date.now() + toSeconds(env.jwtRefreshExpiresIn) * 1000),
    });

    return {
      user: this.mapUser(user),
      accessToken,
      refreshToken,
    };
  }

  private signAccessToken(user: IUserDocument): string {
    const options: SignOptions = { expiresIn: env.jwtAccessExpiresIn as JwtExpiresIn };
    return jwt.sign(
      {
        userId: user._id.toString(),
        role: user.role,
        type: 'access',
      },
      env.jwtAccessSecret,
      options,
    );
  }

  private signRefreshToken(user: IUserDocument, tokenHash: string): string {
    const options: SignOptions = { expiresIn: env.jwtRefreshExpiresIn as JwtExpiresIn };
    return jwt.sign(
      {
        userId: user._id.toString(),
        tokenHash,
        type: 'refresh',
      },
      env.jwtRefreshSecret,
      options,
    );
  }

  private verifyRefreshToken(refreshToken: string): RefreshPayload {
    try {
      const payload = jwt.verify(refreshToken, env.jwtRefreshSecret) as RefreshPayload;
      if (payload.type !== 'refresh') {
        throw new HttpError(401, 'Invalid refresh token', 'INVALID_REFRESH_TOKEN');
      }
      return payload;
    } catch (error) {
      throw error instanceof HttpError
        ? error
        : new HttpError(401, 'Invalid refresh token', 'INVALID_REFRESH_TOKEN');
    }
  }

  private mapUser(user: IUserDocument): AuthUserResponse {
    return {
      id: user._id.toString(),
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role,
    };
  }
}

export const authService = new AuthService();
