import type { QueryFilter, UpdateWriteOpResult } from 'mongoose';

import { RefreshTokenModel, type IRefreshTokenDocument } from '../models/refresh-token.model';
import { UserModel, type IUser, type IUserDocument } from '../models/user.model';

export interface CreateRefreshTokenInput {
  userId: string;
  tokenHash: string;
  expiresAt: Date;
}

export class AuthRepository {
  findUserByEmail(email: string, includePassword = false): Promise<IUserDocument | null> {
    const query = UserModel.findOne({ email: email.toLowerCase().trim() });
    return includePassword ? query.select('+password').exec() : query.exec();
  }

  findUserById(userId: string): Promise<IUserDocument | null> {
    return UserModel.findById(userId).exec();
  }

  createUser(user: IUser): Promise<IUserDocument> {
    return UserModel.create(user);
  }

  createRefreshToken(input: CreateRefreshTokenInput): Promise<IRefreshTokenDocument> {
    return RefreshTokenModel.create(input);
  }

  findActiveRefreshToken(tokenHash: string): Promise<IRefreshTokenDocument | null> {
    const filter: QueryFilter<IRefreshTokenDocument> = {
      tokenHash,
      revokedAt: null,
      expiresAt: { $gt: new Date() },
    };
    return RefreshTokenModel.findOne(filter).exec();
  }

  revokeRefreshToken(tokenHash: string): Promise<IRefreshTokenDocument | null> {
    return RefreshTokenModel.findOneAndUpdate(
      { tokenHash, revokedAt: null },
      { revokedAt: new Date() },
      { new: true },
    ).exec();
  }

  revokeUserRefreshTokens(userId: string): Promise<UpdateWriteOpResult> {
    return RefreshTokenModel.updateMany(
      { userId, revokedAt: null },
      { revokedAt: new Date() },
    ).exec();
  }
}

export const authRepository = new AuthRepository();
