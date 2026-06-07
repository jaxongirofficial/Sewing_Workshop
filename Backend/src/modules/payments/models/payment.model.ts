import { Schema, model, Types, type Document, type Model } from 'mongoose';

export interface IPayment {
  workerId: Types.ObjectId;
  amount: number;
  paymentDate: Date;
}

export interface IPaymentDocument extends IPayment, Document {
  createdAt: Date;
  updatedAt: Date;
}

const paymentSchema = new Schema<IPaymentDocument>(
  {
    workerId: {
      type: Schema.Types.ObjectId,
      ref: 'Worker',
      required: true,
      index: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    paymentDate: {
      type: Date,
      required: true,
      default: Date.now,
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

paymentSchema.index({ workerId: 1, paymentDate: -1 });

export const PaymentModel: Model<IPaymentDocument> = model<IPaymentDocument>('Payment', paymentSchema);
