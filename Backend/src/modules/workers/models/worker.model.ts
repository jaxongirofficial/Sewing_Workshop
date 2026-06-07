import { Schema, model, type Document, type Model } from 'mongoose';

export enum WorkerStatus {
  Active = 'active',
  Inactive = 'inactive',
}

export interface IWorker {
  fullName: string;
  phone: string;
  position: string;
  salary: number;
  status: WorkerStatus;
}

export interface IWorkerDocument extends IWorker, Document {
  createdAt: Date;
  updatedAt: Date;
}

const workerSchema = new Schema<IWorkerDocument>(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 120,
      index: true,
    },
    phone: {
      type: String,
      required: true,
      trim: true,
      maxlength: 32,
      index: true,
    },
    position: {
      type: String,
      required: true,
      trim: true,
      maxlength: 80,
      index: true,
    },
    salary: {
      type: Number,
      required: true,
      min: 0,
    },
    status: {
      type: String,
      enum: Object.values(WorkerStatus),
      default: WorkerStatus.Active,
      required: true,
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

workerSchema.index({ fullName: 'text', phone: 'text', position: 'text' });

export const WorkerModel: Model<IWorkerDocument> = model<IWorkerDocument>('Worker', workerSchema);
