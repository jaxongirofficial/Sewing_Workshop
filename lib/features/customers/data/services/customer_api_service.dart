import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_paths.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_headers.dart';
import '../../../../services/api_service.dart';
import '../dto/customer_dto.dart';
import '../models/customer_model.dart';

final customerApiServiceProvider = Provider<CustomerApiService>((ref) {
  return CustomerApiService(ref.watch(apiServiceProvider));
});

final class CustomerApiService {
  const CustomerApiService(this._apiService);

  final ApiService _apiService;

  Future<List<CustomerModel>> list({
    required String accessToken,
    String? search,
  }) async {
    final response = await _apiService.get(
      ApiPaths.customers,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      options: AuthHeaders.bearer(accessToken),
    );

    return ApiResponseParser.list(response.data, key: 'customers', context: 'Customers')
        .map(CustomerModel.fromJson)
        .toList(growable: false);
  }

  Future<CustomerModel> create({
    required String accessToken,
    required CustomerRequestDto dto,
  }) async {
    final response = await _apiService.post(
      ApiPaths.customers,
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readCustomer(response.data);
  }

  Future<CustomerModel> update({
    required String accessToken,
    required String customerId,
    required CustomerUpdateDto dto,
  }) async {
    final response = await _apiService.patch(
      ApiPaths.customerById(customerId),
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readCustomer(response.data);
  }

  Future<void> delete({
    required String accessToken,
    required String customerId,
  }) async {
    await _apiService.delete(
      ApiPaths.customerById(customerId),
      options: AuthHeaders.bearer(accessToken),
    );
  }

  CustomerModel _readCustomer(Map<String, dynamic>? response) {
    return CustomerModel.fromJson(
      ApiResponseParser.object(response, key: 'customer', context: 'Customer'),
    );
  }
}
