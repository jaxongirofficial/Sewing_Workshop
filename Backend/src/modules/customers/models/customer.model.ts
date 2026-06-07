import { Schema, model, type Document, type Model } from 'mongoose';

export interface ICustomer {
  fullName: string;
  phone: string;
  address: string;
}

export interface ICustomerDocument extends ICustomer, Document {
  createdAt: Date;
  updatedAt: Date;
}

const customerSchema = new Schema<ICustomerDocument>(
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
    address: {
      type: String,
      required: true,
      trim: true,
      maxlength: 240,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

customerSchema.index({ fullName: 'text', phone: 'text', address: 'text' });

export const CustomerModel: Model<ICustomerDocument> = model<ICustomerDocument>('Customer', customerSchema);
