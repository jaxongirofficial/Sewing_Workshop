import '../../data/dto/worker_dto.dart';
import '../../data/models/worker_model.dart';

abstract interface class WorkerRepository {
  Future<List<WorkerModel>> listWorkers({
    required String accessToken,
    String? search,
    String? status,
  });

  Future<WorkerModel> createWorker({
    required String accessToken,
    required WorkerRequestDto dto,
  });

  Future<WorkerModel> updateWorker({
    required String accessToken,
    required String workerId,
    required WorkerUpdateDto dto,
  });

  Future<void> deleteWorker({
    required String accessToken,
    required String workerId,
  });
}
