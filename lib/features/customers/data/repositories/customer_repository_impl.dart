import '../../domain/repositories/customer_repository.dart';
import '../dto/customer_dto.dart';
import '../models/customer_model.dart';
import '../services/customer_api_service.dart';

final class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl(this._apiService);

  final CustomerApiService _apiService;

  @override
  Future<List<CustomerModel>> listCustomers({
    required String accessToken,
    String? search,
  }) {
    return _apiService.list(accessToken: accessToken, search: search);
  }

  @override
  Future<CustomerModel> createCustomer({
    required String accessToken,
    required CustomerRequestDto dto,
  }) {
    return _apiService.create(accessToken: accessToken, dto: dto);
  }

  @override
  Future<CustomerModel> updateCustomer({
    required String accessToken,
    required String customerId,
    required CustomerUpdateDto dto,
  }) {
    return _apiService.update(
      accessToken: accessToken,
      customerId: customerId,
      dto: dto,
    );
  }

  @override
  Future<void> deleteCustomer({
    required String accessToken,
    required String customerId,
  }) {
    return _apiService.delete(
      accessToken: accessToken,
      customerId: customerId,
    );
  }
}
