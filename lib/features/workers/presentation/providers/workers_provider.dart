import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/dto/worker_dto.dart';
import '../../data/models/worker_model.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../data/services/worker_api_service.dart';
import '../../domain/repositories/worker_repository.dart';

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  return WorkerRepositoryImpl(ref.watch(workerApiServiceProvider));
});

final workersProvider =
    StateNotifierProvider<WorkersNotifier, AsyncValue<List<WorkerModel>>>((ref) {
  return WorkersNotifier(
    repository: ref.watch(workerRepositoryProvider),
    readAccessToken: () => ref.read(authNotifierProvider).accessToken,
  );
});

final class WorkersNotifier extends StateNotifier<AsyncValue<List<WorkerModel>>> {
  WorkersNotifier({
    required WorkerRepository repository,
    required String? Function() readAccessToken,
  })  : _repository = repository,
        _readAccessToken = readAccessToken,
        super(const AsyncValue.data([]));

  final WorkerRepository _repository;
  final String? Function() _readAccessToken;

  Future<void> load({String? search, String? status}) async {
    final token = _requireAccessToken();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.listWorkers(
        accessToken: token,
        search: search,
        status: status,
      ),
    );
  }

  Future<void> create(WorkerRequestDto dto) async {
    final token = _requireAccessToken();
    try {
      final worker = await _repository.createWorker(
        accessToken: token,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <WorkerModel>[];
      state = AsyncValue.data([worker, ...previous]);
    } catch (error, stackTrace) {
      debugPrint('create worker failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update(String workerId, WorkerUpdateDto dto) async {
    final token = _requireAccessToken();
    try {
      final worker = await _repository.updateWorker(
        accessToken: token,
        workerId: workerId,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <WorkerModel>[];
      state = AsyncValue.data([
        for (final item in previous) if (item.id == worker.id) worker else item,
      ]);
    } catch (error, stackTrace) {
      debugPrint('update worker failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String workerId) async {
    final token = _requireAccessToken();
    try {
      await _repository.deleteWorker(accessToken: token, workerId: workerId);
      final previous = state.valueOrNull ?? const <WorkerModel>[];
      state = AsyncValue.data(
        previous.where((worker) => worker.id != workerId).toList(growable: false),
      );
    } catch (error, stackTrace) {
      debugPrint('delete worker failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  String _requireAccessToken() {
    final token = _readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Workers API requires an authenticated backend session');
    }
    return token;
  }
}
