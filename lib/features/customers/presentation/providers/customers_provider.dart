import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/dto/customer_dto.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/services/customer_api_service.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerApiServiceProvider));
});

final customersProvider =
    StateNotifierProvider<CustomersNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  return CustomersNotifier(
    repository: ref.watch(customerRepositoryProvider),
    readAccessToken: () => ref.read(authNotifierProvider).accessToken,
  );
});

final class CustomersNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  CustomersNotifier({
    required CustomerRepository repository,
    required String? Function() readAccessToken,
  })  : _repository = repository,
        _readAccessToken = readAccessToken,
        super(const AsyncValue.data([]));

  final CustomerRepository _repository;
  final String? Function() _readAccessToken;

  Future<void> load({String? search}) async {
    final token = _requireAccessToken();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.listCustomers(
        accessToken: token,
        search: search,
      ),
    );
  }

  Future<void> create(CustomerRequestDto dto) async {
    final token = _requireAccessToken();
    try {
      final customer = await _repository.createCustomer(
        accessToken: token,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <CustomerModel>[];
      state = AsyncValue.data([customer, ...previous]);
    } catch (error, stackTrace) {
      debugPrint('create customer failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update(String customerId, CustomerUpdateDto dto) async {
    final token = _requireAccessToken();
    try {
      final customer = await _repository.updateCustomer(
        accessToken: token,
        customerId: customerId,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <CustomerModel>[];
      state = AsyncValue.data([
        for (final item in previous)
          if (item.id == customer.id) customer else item,
      ]);
    } catch (error, stackTrace) {
      debugPrint('update customer failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String customerId) async {
    final token = _requireAccessToken();
    try {
      await _repository.deleteCustomer(
        accessToken: token,
        customerId: customerId,
      );
      final previous = state.valueOrNull ?? const <CustomerModel>[];
      state = AsyncValue.data(
        previous
            .where((customer) => customer.id != customerId)
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      debugPrint('delete customer failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  String _requireAccessToken() {
    final token = _readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Customers API requires an authenticated backend session');
    }
    return token;
  }
}
