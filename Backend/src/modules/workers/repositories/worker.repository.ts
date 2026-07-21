import type { QueryFilter, UpdateQuery } from 'mongoose';

import {
  WorkerModel,
  WorkerStatus,
  type IWorker,
  type IWorkerDocument,
} from '../models/worker.model';

export interface WorkerListQuery {
  search?: string;
  status?: WorkerStatus;
  page: number;
  limit: number;
}

export interface WorkerListResult {
  items: IWorkerDocument[];
  total: number;
}

export class WorkerRepository {
  async findAll(query: WorkerListQuery): Promise<WorkerListResult> {
    const filter: QueryFilter<IWorkerDocument> = {};

    if (query.status) {
      filter.status = query.status;
    }

    if (query.search?.trim()) {
      filter.$text = { $search: query.search.trim() };
    }

    const skip = (query.page - 1) * query.limit;

    const [items, total] = await Promise.all([
      WorkerModel.find(filter).sort({ createdAt: -1 }).skip(skip).limit(query.limit).exec(),
      WorkerModel.countDocuments(filter).exec(),
    ]);

    return { items, total };
  }

  findById(workerId: string): Promise<IWorkerDocument | null> {
    return WorkerModel.findById(workerId).exec();
  }

  create(worker: IWorker): Promise<IWorkerDocument> {
    return WorkerModel.create(worker);
  }

  update(workerId: string, worker: UpdateQuery<IWorker>): Promise<IWorkerDocument | null> {
    return WorkerModel.findByIdAndUpdate(workerId, worker, {
      new: true,
      runValidators: true,
    }).exec();
  }

  delete(workerId: string): Promise<IWorkerDocument | null> {
    return WorkerModel.findByIdAndDelete(workerId).exec();
  }
}

export const workerRepository = new WorkerRepository();
