import { HttpError } from '../../../shared/errors/http-error';
import { WorkerStatus, type IWorkerDocument } from '../models/worker.model';
import {
  workerRepository,
  type WorkerListQuery,
  type WorkerRepository,
} from '../repositories/worker.repository';

export interface CreateWorkerInput {
  fullName: string;
  phone: string;
  position: string;
  salary: number;
  status?: WorkerStatus;
}

export type UpdateWorkerInput = Partial<CreateWorkerInput>;

export interface WorkerResponse {
  id: string;
  fullName: string;
  phone: string;
  position: string;
  salary: number;
  status: WorkerStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class WorkerService {
  constructor(private readonly repository: WorkerRepository = workerRepository) {}

  async list(query: WorkerListQuery): Promise<WorkerResponse[]> {
    const workers = await this.repository.findAll(query);
    return workers.map((worker) => this.mapWorker(worker));
  }

  async create(input: CreateWorkerInput): Promise<WorkerResponse> {
    const worker = await this.repository.create({
      fullName: input.fullName.trim(),
      phone: input.phone.trim(),
      position: input.position.trim(),
      salary: input.salary,
      status: input.status ?? WorkerStatus.Active,
    });

    return this.mapWorker(worker);
  }

  async update(workerId: string, input: UpdateWorkerInput): Promise<WorkerResponse> {
    const update = {
      ...(input.fullName != null ? { fullName: input.fullName.trim() } : {}),
      ...(input.phone != null ? { phone: input.phone.trim() } : {}),
      ...(input.position != null ? { position: input.position.trim() } : {}),
      ...(input.salary != null ? { salary: input.salary } : {}),
      ...(input.status != null ? { status: input.status } : {}),
    };

    const worker = await this.repository.update(workerId, update);
    if (!worker) {
      throw new HttpError(404, 'Worker not found', 'WORKER_NOT_FOUND');
    }

    return this.mapWorker(worker);
  }

  async delete(workerId: string): Promise<void> {
    const worker = await this.repository.delete(workerId);
    if (!worker) {
      throw new HttpError(404, 'Worker not found', 'WORKER_NOT_FOUND');
    }
  }

  private mapWorker(worker: IWorkerDocument): WorkerResponse {
    return {
      id: worker.id,
      fullName: worker.fullName,
      phone: worker.phone,
      position: worker.position,
      salary: worker.salary,
      status: worker.status,
      createdAt: worker.createdAt,
      updatedAt: worker.updatedAt,
    };
  }
}

export const workerService = new WorkerService();
