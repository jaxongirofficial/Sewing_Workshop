import { asyncHandler } from '../../../shared/utils/async-handler';
import { customerService, type CustomerService } from '../services/customer.service';

export class CustomerController {
  constructor(private readonly service: CustomerService = customerService) {}

  list = asyncHandler(async (req, res) => {
    const customers = await this.service.list({
      search: typeof req.query.search === 'string' ? req.query.search : undefined,
    });

    res.json({
      success: true,
      data: { customers },
    });
  });

  create = asyncHandler(async (req, res) => {
    const customer = await this.service.create(req.body);
    res.status(201).json({
      success: true,
      data: { customer },
    });
  });

  update = asyncHandler(async (req, res) => {
    const customer = await this.service.update(req.params.customerId, req.body);
    res.json({
      success: true,
      data: { customer },
    });
  });

  delete = asyncHandler(async (req, res) => {
    await this.service.delete(req.params.customerId);
    res.status(204).send();
  });
}

export const customerController = new CustomerController();
