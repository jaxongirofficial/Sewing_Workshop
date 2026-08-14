import type { FastifyInstance, FastifyRequest } from 'fastify';
import { Schema, Types, model } from 'mongoose';

import { authenticate } from '../../../middlewares/auth.middleware';
import { UserModel } from '../../auth/models/user.model';
import { WorkerModel, WorkerStatus } from '../../workers/models/worker.model';
import { successResponse } from '../../../shared/http-response';
import { HttpError } from '../../../shared/errors/http-error';

type WarehouseCategory = 'clothing' | 'material' | 'accessory' | 'other';
type MovementType = 'stockIn' | 'stockOut' | 'adjust';

interface WarehouseItem {
  name: string;
  quantity: number;
  unit: string;
  category: WarehouseCategory;
  pricePerUnit?: number;
  addedBy?: string;
}

interface WarehouseMovement {
  productId: Types.ObjectId;
  productName: string;
  quantity: number;
  unit: string;
  type: MovementType;
  performedBy: string;
  at: Date;
}

interface WorkshopTask {
  productName: string;
  targetQty: number;
  doneQty: number;
  assigneeId: string;
  assigneeName: string;
  deadline?: Date;
  note?: string;
  pricePerUnit?: number;
}

interface AttendanceRecord {
  workerId: string;
  name: string;
  dateKey: string;
  present: boolean;
  checkInTime?: string;
}

const warehouseItemSchema = new Schema<WarehouseItem>({
  name: { type: String, required: true, trim: true, maxlength: 120 },
  quantity: { type: Number, required: true, min: 0 },
  unit: { type: String, required: true, trim: true, maxlength: 32 },
  category: { type: String, required: true, enum: ['clothing', 'material', 'accessory', 'other'] },
  pricePerUnit: { type: Number, min: 0 },
  addedBy: { type: String, trim: true, maxlength: 120 },
}, { timestamps: true, versionKey: false });

const warehouseMovementSchema = new Schema<WarehouseMovement>({
  productId: { type: Schema.Types.ObjectId, required: true, index: true },
  productName: { type: String, required: true },
  quantity: { type: Number, required: true },
  unit: { type: String, required: true },
  type: { type: String, required: true, enum: ['stockIn', 'stockOut', 'adjust'] },
  performedBy: { type: String, required: true },
  at: { type: Date, required: true, default: Date.now },
}, { timestamps: false, versionKey: false });

const taskSchema = new Schema<WorkshopTask>({
  productName: { type: String, required: true, trim: true, maxlength: 120 },
  targetQty: { type: Number, required: true, min: 1 },
  doneQty: { type: Number, required: true, min: 0, default: 0 },
  assigneeId: { type: String, required: true, index: true },
  assigneeName: { type: String, required: true, trim: true },
  deadline: { type: Date },
  note: { type: String, trim: true, maxlength: 1000 },
  pricePerUnit: { type: Number, min: 0 },
}, { timestamps: true, versionKey: false });

const attendanceSchema = new Schema<AttendanceRecord>({
  workerId: { type: String, required: true, index: true },
  name: { type: String, required: true },
  dateKey: { type: String, required: true, index: true },
  present: { type: Boolean, required: true, default: false },
  checkInTime: { type: String },
}, { timestamps: true, versionKey: false });
attendanceSchema.index({ workerId: 1, dateKey: 1 }, { unique: true });

const WarehouseItemModel = model<WarehouseItem>('WarehouseItem', warehouseItemSchema);
const WarehouseMovementModel = model<WarehouseMovement>('WarehouseMovement', warehouseMovementSchema);
const WorkshopTaskModel = model<WorkshopTask>('WorkshopTask', taskSchema);
const AttendanceModel = model<AttendanceRecord>('AttendanceRecord', attendanceSchema);

const todayKey = (): string => new Date().toISOString().slice(0, 10);
const hhmm = (): string => new Date().toTimeString().slice(0, 5);
const id = (value: string): Types.ObjectId => {
  if (!Types.ObjectId.isValid(value)) throw new HttpError(422, 'Invalid record id', 'INVALID_ID');
  return new Types.ObjectId(value);
};
const number = (value: unknown, field: string, minimum = 0): number => {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < minimum) {
    throw new HttpError(422, `${field} is invalid`, 'VALIDATION_ERROR');
  }
  return value;
};
const text = (value: unknown, field: string): string => {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new HttpError(422, `${field} is required`, 'VALIDATION_ERROR');
  }
  return value.trim();
};

export const workshopRoutes = async (app: FastifyInstance): Promise<void> => {
  app.addHook('preHandler', authenticate);

  app.get('/warehouse', async () => {
    const items = await WarehouseItemModel.find().sort({ createdAt: -1 }).lean();
    return successResponse({ items: items.map((item) => ({ ...item, id: item._id.toString() })) });
  });

  app.post('/warehouse', async (request: FastifyRequest<{ Body: Partial<WarehouseItem> }>) => {
    const body = request.body;
    const user = await UserModel.findById(request.user!.userId).lean();
    const item = await WarehouseItemModel.create({
      name: text(body.name, 'name'),
      quantity: number(body.quantity, 'quantity'),
      unit: text(body.unit, 'unit'),
      category: body.category ?? 'other',
      ...(body.pricePerUnit == null ? {} : { pricePerUnit: number(body.pricePerUnit, 'pricePerUnit') }),
      addedBy: user?.fullName ?? 'System',
    });
    await WarehouseMovementModel.create({
      productId: item._id,
      productName: item.name,
      quantity: item.quantity,
      unit: item.unit,
      type: 'stockIn',
      performedBy: item.addedBy ?? 'System',
      at: new Date(),
    });
    return successResponse({ item: { ...item.toObject(), id: item._id.toString() } }, 'Warehouse item created');
  });

  app.patch('/warehouse/:itemId', async (request: FastifyRequest<{ Params: { itemId: string }; Body: Partial<WarehouseItem> }>) => {
    const body = request.body;
    const update = {
      ...(body.name == null ? {} : { name: text(body.name, 'name') }),
      ...(body.unit == null ? {} : { unit: text(body.unit, 'unit') }),
      ...(body.category == null ? {} : { category: body.category }),
      ...(body.pricePerUnit == null ? {} : { pricePerUnit: number(body.pricePerUnit, 'pricePerUnit') }),
    };
    const item = await WarehouseItemModel.findByIdAndUpdate(id(request.params.itemId), update, { new: true, runValidators: true });
    if (!item) throw new HttpError(404, 'Warehouse item not found', 'WAREHOUSE_ITEM_NOT_FOUND');
    return successResponse({ item: { ...item.toObject(), id: item._id.toString() } });
  });

  app.post('/warehouse/:itemId/movements', async (request: FastifyRequest<{ Params: { itemId: string }; Body: { quantity: number; type: MovementType } }>) => {
    const item = await WarehouseItemModel.findById(id(request.params.itemId));
    if (!item) throw new HttpError(404, 'Warehouse item not found', 'WAREHOUSE_ITEM_NOT_FOUND');
    const quantity = number(request.body.quantity, 'quantity', 1);
    const type = request.body.type;
    if (!['stockIn', 'stockOut', 'adjust'].includes(type)) throw new HttpError(422, 'Movement type is invalid', 'VALIDATION_ERROR');
    const delta = type === 'stockOut' ? -quantity : quantity;
    if (item.quantity + delta < 0) throw new HttpError(422, 'Not enough stock', 'INSUFFICIENT_STOCK');
    item.quantity += delta;
    await item.save();
    const user = await UserModel.findById(request.user!.userId).lean();
    const performedBy = user?.fullName ?? 'System';
    const movement = await WarehouseMovementModel.create({ productId: item._id, productName: item.name, quantity: delta, unit: item.unit, type, performedBy, at: new Date() });
    return successResponse({ item: { ...item.toObject(), id: item._id.toString() }, movement: { ...movement.toObject(), id: movement._id.toString() } });
  });

  app.delete('/warehouse/:itemId', async (request: FastifyRequest<{ Params: { itemId: string } }>) => {
    const removed = await WarehouseItemModel.findByIdAndDelete(id(request.params.itemId));
    if (!removed) throw new HttpError(404, 'Warehouse item not found', 'WAREHOUSE_ITEM_NOT_FOUND');
    return successResponse({});
  });

  app.get('/warehouse/history', async () => {
    const items = await WarehouseMovementModel.find().sort({ at: -1 }).limit(300).lean();
    return successResponse({ items: items.map((item) => ({ ...item, id: item._id.toString(), productId: item.productId.toString() })) });
  });

  app.get('/tasks', async () => {
    const items = await WorkshopTaskModel.find().sort({ createdAt: -1 }).lean();
    return successResponse({ items: items.map((item) => ({ ...item, id: item._id.toString() })) });
  });

  app.post('/tasks', async (request: FastifyRequest<{ Body: Partial<WorkshopTask> }>) => {
    const body = request.body;
    const task = await WorkshopTaskModel.create({ productName: text(body.productName, 'productName'), targetQty: number(body.targetQty, 'targetQty', 1), doneQty: body.doneQty == null ? 0 : number(body.doneQty, 'doneQty'), assigneeId: text(body.assigneeId, 'assigneeId'), assigneeName: text(body.assigneeName, 'assigneeName'), ...(body.deadline == null ? {} : { deadline: new Date(body.deadline) }), ...(body.note == null ? {} : { note: body.note.trim() }), ...(body.pricePerUnit == null ? {} : { pricePerUnit: number(body.pricePerUnit, 'pricePerUnit') }) });
    return successResponse({ task: { ...task.toObject(), id: task._id.toString() } }, 'Task created');
  });

  app.patch('/tasks/:taskId', async (request: FastifyRequest<{ Params: { taskId: string }; Body: Partial<WorkshopTask> }>) => {
    const body = request.body;
    const update = { ...(body.productName == null ? {} : { productName: text(body.productName, 'productName') }), ...(body.targetQty == null ? {} : { targetQty: number(body.targetQty, 'targetQty', 1) }), ...(body.doneQty == null ? {} : { doneQty: number(body.doneQty, 'doneQty') }), ...(body.assigneeId == null ? {} : { assigneeId: text(body.assigneeId, 'assigneeId') }), ...(body.assigneeName == null ? {} : { assigneeName: text(body.assigneeName, 'assigneeName') }), ...(body.deadline == null ? {} : { deadline: new Date(body.deadline) }), ...(body.note == null ? {} : { note: body.note }), ...(body.pricePerUnit == null ? {} : { pricePerUnit: number(body.pricePerUnit, 'pricePerUnit') }) };
    const task = await WorkshopTaskModel.findByIdAndUpdate(id(request.params.taskId), update, { new: true, runValidators: true });
    if (!task) throw new HttpError(404, 'Task not found', 'TASK_NOT_FOUND');
    return successResponse({ task: { ...task.toObject(), id: task._id.toString() } });
  });

  app.delete('/tasks/:taskId', async (request: FastifyRequest<{ Params: { taskId: string } }>) => {
    const removed = await WorkshopTaskModel.findByIdAndDelete(id(request.params.taskId));
    if (!removed) throw new HttpError(404, 'Task not found', 'TASK_NOT_FOUND');
    return successResponse({});
  });

  app.get('/attendance', async (request: FastifyRequest<{ Querystring: { date?: string } }>) => {
    const dateKey = request.query.date ?? todayKey();
    const [workers, records] = await Promise.all([WorkerModel.find({ status: WorkerStatus.Active }).sort({ fullName: 1 }).lean(), AttendanceModel.find({ dateKey }).lean()]);
    const recordsByWorker = new Map(records.map((record) => [record.workerId, record]));
    const items = workers.map((worker) => {
      const record = recordsByWorker.get(worker._id.toString());
      return { id: worker._id.toString(), name: worker.fullName, present: record?.present ?? false, checkInTime: record?.checkInTime };
    });
    return successResponse({ items });
  });

  app.put('/attendance/:workerId', async (request: FastifyRequest<{ Params: { workerId: string }; Body: { present: boolean; date?: string } }>) => {
    if (typeof request.body.present !== 'boolean') throw new HttpError(422, 'present is required', 'VALIDATION_ERROR');
    const worker = await WorkerModel.findById(id(request.params.workerId)).lean();
    if (!worker) throw new HttpError(404, 'Worker not found', 'WORKER_NOT_FOUND');
    const dateKey = request.body.date ?? todayKey();
    const record = await AttendanceModel.findOneAndUpdate({ workerId: worker._id.toString(), dateKey }, { name: worker.fullName, present: request.body.present, checkInTime: request.body.present ? hhmm() : undefined }, { upsert: true, new: true, setDefaultsOnInsert: true });
    return successResponse({ item: { id: worker._id.toString(), name: worker.fullName, present: record.present, checkInTime: record.checkInTime } });
  });
};
