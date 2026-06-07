import type { Response } from 'express';

import { asyncHandler } from '../../../shared/utils/async-handler';
import type { AuthenticatedRequest } from '../../../types/auth-request';
import { authService, type AuthService } from '../services/auth.service';

export class AuthController {
  constructor(private readonly service: AuthService = authService) {}

  register = asyncHandler(async (req, res) => {
    const session = await this.service.register(req.body);
    this.sendSession(res, session, 201);
  });

  login = asyncHandler(async (req, res) => {
    const session = await this.service.login(req.body);
    this.sendSession(res, session);
  });

  refresh = asyncHandler(async (req, res) => {
    const session = await this.service.refresh(req.body.refreshToken);
    this.sendSession(res, session);
  });

  logout = asyncHandler(async (req, res) => {
    await this.service.logout(req.body.refreshToken);
    res.status(204).send();
  });

  me = asyncHandler(async (req, res) => {
    const authReq = req as AuthenticatedRequest;
    const user = await this.service.getCurrentUser(authReq.user!.userId);
    res.json({
      success: true,
      data: { user },
    });
  });

  private sendSession(
    res: Response,
    session: Awaited<ReturnType<AuthService['login']>>,
    statusCode = 200,
  ): void {
    res.status(statusCode).json({
      success: true,
      data: session,
    });
  }
}

export const authController = new AuthController();
