import '../../data/dto/customer_dto.dart';
import '../../data/models/customer_model.dart';

abstract interface class CustomerRepository {
  Future<List<CustomerModel>> listCustomers({
    required String accessToken,
    String? search,
  });

  Future<CustomerModel> createCustomer({
    required String accessToken,
    required CustomerRequestDto dto,
  });

  Future<CustomerModel> updateCustomer({
    required String accessToken,
    required String customerId,
    required CustomerUpdateDto dto,
  });

  Future<void> deleteCustomer({
    required String accessToken,
    required String customerId,
  });
}
