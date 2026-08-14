import { Schema, model, type Document, type Model } from 'mongoose';

export enum UserRole {
  Admin = 'admin',
  Manager = 'manager',
  Staff = 'staff',
}

export interface IUser {
  fullName: string;
  email: string;
  phone: string;
  password: string;
  role: UserRole;
}

export interface IUserDocument extends IUser, Document {
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUserDocument>(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 120,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      maxlength: 160,
      index: true,
    },
    phone: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      match: /^998\d{9}$/,
      index: true,
    },
    password: {
      type: String,
      required: true,
      select: false,
      minlength: 8,
    },
    role: {
      type: String,
      enum: Object.values(UserRole),
      default: UserRole.Staff,
      required: true,
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

export const UserModel: Model<IUserDocument> = model<IUserDocument>('User', userSchema);
