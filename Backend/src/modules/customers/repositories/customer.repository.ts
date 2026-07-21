import type { QueryFilter, UpdateQuery } from 'mongoose';

import { CustomerModel, type ICustomer, type ICustomerDocument } from '../models/customer.model';

export interface CustomerListQuery {
  search?: string;
  page: number;
  limit: number;
}

export interface CustomerListResult {
  items: ICustomerDocument[];
  total: number;
}

export class CustomerRepository {
  async findAll(query: CustomerListQuery): Promise<CustomerListResult> {
    const filter: QueryFilter<ICustomerDocument> = {};

    if (query.search?.trim()) {
      filter.$text = { $search: query.search.trim() };
    }

    const skip = (query.page - 1) * query.limit;

    const [items, total] = await Promise.all([
      CustomerModel.find(filter).sort({ createdAt: -1 }).skip(skip).limit(query.limit).exec(),
      CustomerModel.countDocuments(filter).exec(),
    ]);

    return { items, total };
  }

  findById(customerId: string): Promise<ICustomerDocument | null> {
    return CustomerModel.findById(customerId).exec();
  }

  create(customer: ICustomer): Promise<ICustomerDocument> {
    return CustomerModel.create(customer);
  }

  update(customerId: string, customer: UpdateQuery<ICustomer>): Promise<ICustomerDocument | null> {
    return CustomerModel.findByIdAndUpdate(customerId, customer, {
      new: true,
      runValidators: true,
    }).exec();
  }

  delete(customerId: string): Promise<ICustomerDocument | null> {
    return CustomerModel.findByIdAndDelete(customerId).exec();
  }
}

export const customerRepository = new CustomerRepository();
