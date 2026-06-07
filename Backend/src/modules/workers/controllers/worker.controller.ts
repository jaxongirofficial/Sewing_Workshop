import { asyncHandler } from '../../../shared/utils/async-handler';
import { WorkerStatus } from '../models/worker.model';
import { workerService, type WorkerService } from '../services/worker.service';

export class WorkerController {
  constructor(private readonly service: WorkerService = workerService) {}

  list = asyncHandler(async (req, res) => {
    const workers = await this.service.list({
      search: typeof req.query.search === 'string' ? req.query.search : undefined,
      status: this.parseStatus(req.query.status),
    });

    res.json({
      success: true,
      data: { workers },
    });
  });

  create = asyncHandler(async (req, res) => {
    const worker = await this.service.create(req.body);
    res.status(201).json({
      success: true,
      data: { worker },
    });
  });

  update = asyncHandler(async (req, res) => {
    const worker = await this.service.update(req.params.workerId, req.body);
    res.json({
      success: true,
      data: { worker },
    });
  });

  delete = asyncHandler(async (req, res) => {
    await this.service.delete(req.params.workerId);
    res.status(204).send();
  });

  private parseStatus(value: unknown): WorkerStatus | undefined {
    return typeof value === 'string' && Object.values(WorkerStatus).includes(value as WorkerStatus)
      ? (value as WorkerStatus)
      : undefined;
  }
}

export const workerController = new WorkerController();
