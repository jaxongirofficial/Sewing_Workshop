import { body, param, query } from 'express-validator';

import { OrderStatus } from '../models/order.model';

export const orderIdValidator = [
  param('orderId').isMongoId().withMessage('Order id must be a valid Mongo id'),
];

export const listOrdersValidator = [
  query('customerId').optional().isMongoId(),
  query('status').optional().isIn(Object.values(OrderStatus)),
];

export const createOrderValidator = [
  body('orderNumber').isString().trim().isLength({ min: 2, max: 40 }),
  body('customerId').isMongoId().withMessage('Customer id must be a valid Mongo id'),
  body('quantity').isInt({ min: 1 }),
  body('totalPrice').isFloat({ min: 0 }),
  body('deadline').isISO8601().toDate(),
  body('status').optional().isIn(Object.values(OrderStatus)),
];

export const updateOrderValidator = [
  ...orderIdValidator,
  body('orderNumber').optional().isString().trim().isLength({ min: 2, max: 40 }),
  body('customerId').optional().isMongoId(),
  body('quantity').optional().isInt({ min: 1 }),
  body('totalPrice').optional().isFloat({ min: 0 }),
  body('deadline').optional().isISO8601().toDate(),
  body('status').optional().isIn(Object.values(OrderStatus)),
];

export const updateOrderStatusValidator = [
  ...orderIdValidator,
  body('status').isIn(Object.values(OrderStatus)),
];
