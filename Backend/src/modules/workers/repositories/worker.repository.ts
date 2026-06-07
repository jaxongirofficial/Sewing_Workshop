import type { FilterQuery, UpdateQuery } from 'mongoose';

import {
  WorkerModel,
  WorkerStatus,
  type IWorker,
  type IWorkerDocument,
} from '../models/worker.model';

export interface WorkerListQuery {
  search?: string;
  status?: WorkerStatus;
}

export class WorkerRepository {
  findAll(query: WorkerListQuery = {}): Promise<IWorkerDocument[]> {
    const filter: FilterQuery<IWorkerDocument> = {};

    if (query.status) {
      filter.status = query.status;
    }

    if (query.search?.trim()) {
      filter.$text = { $search: query.search.trim() };
    }

    return WorkerModel.find(filter).sort({ createdAt: -1 }).exec();
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
