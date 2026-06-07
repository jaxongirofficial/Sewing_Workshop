import { body, query } from 'express-validator';

export const paymentHistoryValidator = [
  query('workerId').optional().isMongoId(),
  query('from').optional().isISO8601().toDate(),
  query('to').optional().isISO8601().toDate(),
];

export const recordPaymentValidator = [
  body('workerId').isMongoId().withMessage('Worker id must be a valid Mongo id'),
  body('amount').isFloat({ min: 0 }).withMessage('Amount must be zero or greater'),
  body('paymentDate').optional().isISO8601().toDate(),
];
