import type { FastifyReply, FastifyRequest } from 'fastify';

import { successResponse } from '../../../shared/http-response';
import { authService, type AuthService } from '../services/auth.service';
import type { LoginBody, RefreshTokenBody, RegisterBody } from '../validators/auth.validator';

export class AuthController {
  constructor(private readonly service: AuthService = authService) {}

  register = async (
    request: FastifyRequest<{ Body: RegisterBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const session = await this.service.register(request.body);
    reply.status(201).send(successResponse(session, 'Registered successfully'));
  };

  login = async (request: FastifyRequest<{ Body: LoginBody }>, reply: FastifyReply): Promise<void> => {
    const session = await this.service.login(request.body);
    reply.send(successResponse(session, 'Logged in successfully'));
  };

  refresh = async (
    request: FastifyRequest<{ Body: RefreshTokenBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    const session = await this.service.refresh(request.body.refreshToken);
    reply.send(successResponse(session, 'Token refreshed successfully'));
  };

  logout = async (
    request: FastifyRequest<{ Body: RefreshTokenBody }>,
    reply: FastifyReply,
  ): Promise<void> => {
    await this.service.logout(request.body.refreshToken);
    reply.status(204).send();
  };

  me = async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    const user = await this.service.getCurrentUser(request.user!.userId);
    reply.send(successResponse({ user }, 'Current user fetched successfully'));
  };
}

export const authController = new AuthController();
