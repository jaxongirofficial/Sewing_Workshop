import { body, param, query } from 'express-validator';

import { WorkerStatus } from '../models/worker.model';

export const workerIdValidator = [
  param('workerId').isMongoId().withMessage('Worker id must be a valid Mongo id'),
];

export const listWorkersValidator = [
  query('search').optional().isString().trim().isLength({ max: 120 }),
  query('status').optional().isIn(Object.values(WorkerStatus)),
];

export const createWorkerValidator = [
  body('fullName')
    .isString()
    .trim()
    .isLength({ min: 2, max: 120 })
    .withMessage('Full name must be between 2 and 120 characters'),
  body('phone').isString().trim().isLength({ min: 7, max: 32 }),
  body('position').isString().trim().isLength({ min: 2, max: 80 }),
  body('salary').isFloat({ min: 0 }).withMessage('Salary must be zero or greater'),
  body('status').optional().isIn(Object.values(WorkerStatus)),
];

export const updateWorkerValidator = [
  ...workerIdValidator,
  body('fullName').optional().isString().trim().isLength({ min: 2, max: 120 }),
  body('phone').optional().isString().trim().isLength({ min: 7, max: 32 }),
  body('position').optional().isString().trim().isLength({ min: 2, max: 80 }),
  body('salary').optional().isFloat({ min: 0 }),
  body('status').optional().isIn(Object.values(WorkerStatus)),
];
