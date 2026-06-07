import { body, param, query } from 'express-validator';

export const customerIdValidator = [
  param('customerId').isMongoId().withMessage('Customer id must be a valid Mongo id'),
];

export const listCustomersValidator = [
  query('search').optional().isString().trim().isLength({ max: 120 }),
];

export const createCustomerValidator = [
  body('fullName')
    .isString()
    .trim()
    .isLength({ min: 2, max: 120 })
    .withMessage('Full name must be between 2 and 120 characters'),
  body('phone').isString().trim().isLength({ min: 7, max: 32 }),
  body('address').isString().trim().isLength({ min: 2, max: 240 }),
];

export const updateCustomerValidator = [
  ...customerIdValidator,
  body('fullName').optional().isString().trim().isLength({ min: 2, max: 120 }),
  body('phone').optional().isString().trim().isLength({ min: 7, max: 32 }),
  body('address').optional().isString().trim().isLength({ min: 2, max: 240 }),
];
