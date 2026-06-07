import type { FilterQuery, UpdateQuery } from 'mongoose';

import { CustomerModel, type ICustomer, type ICustomerDocument } from '../models/customer.model';

export interface CustomerListQuery {
  search?: string;
}

export class CustomerRepository {
  findAll(query: CustomerListQuery = {}): Promise<ICustomerDocument[]> {
    const filter: FilterQuery<ICustomerDocument> = {};

    if (query.search?.trim()) {
      filter.$text = { $search: query.search.trim() };
    }

    return CustomerModel.find(filter).sort({ createdAt: -1 }).exec();
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
