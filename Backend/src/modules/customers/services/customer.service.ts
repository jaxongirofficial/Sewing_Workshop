import { HttpError } from '../../../shared/errors/http-error';
import type { ICustomerDocument } from '../models/customer.model';
import {
  customerRepository,
  type CustomerListQuery,
  type CustomerRepository,
} from '../repositories/customer.repository';

export interface CreateCustomerInput {
  fullName: string;
  phone: string;
  address: string;
}

export type UpdateCustomerInput = Partial<CreateCustomerInput>;

export interface CustomerResponse {
  id: string;
  fullName: string;
  phone: string;
  address: string;
  createdAt: Date;
  updatedAt: Date;
}

export class CustomerService {
  constructor(private readonly repository: CustomerRepository = customerRepository) {}

  async list(query: CustomerListQuery): Promise<CustomerResponse[]> {
    const customers = await this.repository.findAll(query);
    return customers.map((customer) => this.mapCustomer(customer));
  }

  async create(input: CreateCustomerInput): Promise<CustomerResponse> {
    const customer = await this.repository.create({
      fullName: input.fullName.trim(),
      phone: input.phone.trim(),
      address: input.address.trim(),
    });

    return this.mapCustomer(customer);
  }

  async update(customerId: string, input: UpdateCustomerInput): Promise<CustomerResponse> {
    const update = {
      ...(input.fullName != null ? { fullName: input.fullName.trim() } : {}),
      ...(input.phone != null ? { phone: input.phone.trim() } : {}),
      ...(input.address != null ? { address: input.address.trim() } : {}),
    };

    const customer = await this.repository.update(customerId, update);
    if (!customer) {
      throw new HttpError(404, 'Customer not found', 'CUSTOMER_NOT_FOUND');
    }

    return this.mapCustomer(customer);
  }

  async delete(customerId: string): Promise<void> {
    const customer = await this.repository.delete(customerId);
    if (!customer) {
      throw new HttpError(404, 'Customer not found', 'CUSTOMER_NOT_FOUND');
    }
  }

  private mapCustomer(customer: ICustomerDocument): CustomerResponse {
    return {
      id: customer.id,
      fullName: customer.fullName,
      phone: customer.phone,
      address: customer.address,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    };
  }
}

export const customerService = new CustomerService();
