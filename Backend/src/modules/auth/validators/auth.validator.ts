import { body } from 'express-validator';

import { UserRole } from '../models/user.model';

export const registerValidator = [
  body('fullName')
    .isString()
    .trim()
    .isLength({ min: 2, max: 120 })
    .withMessage('Full name must be between 2 and 120 characters'),
  body('email').isEmail().normalizeEmail().withMessage('A valid email is required'),
  body('password')
    .isString()
    .isLength({ min: 8, max: 128 })
    .withMessage('Password must be between 8 and 128 characters'),
  body('role')
    .optional()
    .isIn(Object.values(UserRole))
    .withMessage('Role must be admin, manager, or staff'),
];

export const loginValidator = [
  body('email').isEmail().normalizeEmail().withMessage('A valid email is required'),
  body('password').isString().notEmpty().withMessage('Password is required'),
];

export const refreshTokenValidator = [
  body('refreshToken').isString().notEmpty().withMessage('Refresh token is required'),
];

export const logoutValidator = refreshTokenValidator;
