import { z } from 'zod';

export const registerBodySchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  email: z.string().trim().toLowerCase().email(),
  phone: z.string().regex(/^998\d{9}$/, 'Phone must use the 998XXXXXXXXX format'),
  password: z.string().min(8).max(128),
});

export const loginBodySchema = z.object({
  phone: z.string().regex(/^998\d{9}$/, 'Phone must use the 998XXXXXXXXX format'),
  password: z.string().min(1),
});

export const refreshTokenBodySchema = z.object({
  refreshToken: z.string().min(1),
});

export const logoutBodySchema = refreshTokenBodySchema;

export type RegisterBody = z.infer<typeof registerBodySchema>;
export type LoginBody = z.infer<typeof loginBodySchema>;
export type RefreshTokenBody = z.infer<typeof refreshTokenBodySchema>;
