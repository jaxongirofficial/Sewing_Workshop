import '../../domain/repositories/worker_repository.dart';
import '../dto/worker_dto.dart';
import '../models/worker_model.dart';
import '../services/worker_api_service.dart';

final class WorkerRepositoryImpl implements WorkerRepository {
  const WorkerRepositoryImpl(this._apiService);

  final WorkerApiService _apiService;

  @override
  Future<List<WorkerModel>> listWorkers({
    required String accessToken,
    String? search,
    String? status,
  }) {
    return _apiService.list(
      accessToken: accessToken,
      search: search,
      status: status,
    );
  }

  @override
  Future<WorkerModel> createWorker({
    required String accessToken,
    required WorkerRequestDto dto,
  }) {
    return _apiService.create(accessToken: accessToken, dto: dto);
  }

  @override
  Future<WorkerModel> updateWorker({
    required String accessToken,
    required String workerId,
    required WorkerUpdateDto dto,
  }) {
    return _apiService.update(
      accessToken: accessToken,
      workerId: workerId,
      dto: dto,
    );
  }

  @override
  Future<void> deleteWorker({
    required String accessToken,
    required String workerId,
  }) {
    return _apiService.delete(accessToken: accessToken, workerId: workerId);
  }
}
