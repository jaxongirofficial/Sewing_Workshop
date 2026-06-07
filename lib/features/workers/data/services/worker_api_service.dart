import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_paths.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_headers.dart';
import '../../../../services/api_service.dart';
import '../dto/worker_dto.dart';
import '../models/worker_model.dart';

final workerApiServiceProvider = Provider<WorkerApiService>((ref) {
  return WorkerApiService(ref.watch(apiServiceProvider));
});

final class WorkerApiService {
  const WorkerApiService(this._apiService);

  final ApiService _apiService;

  Future<List<WorkerModel>> list({
    required String accessToken,
    String? search,
    String? status,
  }) async {
    final response = await _apiService.get(
      ApiPaths.workers,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
      },
      options: AuthHeaders.bearer(accessToken),
    );

    return ApiResponseParser.list(response.data, key: 'workers', context: 'Workers')
        .map(WorkerModel.fromJson)
        .toList(growable: false);
  }

  Future<WorkerModel> create({
    required String accessToken,
    required WorkerRequestDto dto,
  }) async {
    final response = await _apiService.post(
      ApiPaths.workers,
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readWorker(response.data);
  }

  Future<WorkerModel> update({
    required String accessToken,
    required String workerId,
    required WorkerUpdateDto dto,
  }) async {
    final response = await _apiService.patch(
      ApiPaths.workerById(workerId),
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readWorker(response.data);
  }

  Future<void> delete({
    required String accessToken,
    required String workerId,
  }) async {
    await _apiService.delete(
      ApiPaths.workerById(workerId),
      options: AuthHeaders.bearer(accessToken),
    );
  }

  WorkerModel _readWorker(Map<String, dynamic>? response) {
    return WorkerModel.fromJson(
      ApiResponseParser.object(response, key: 'worker', context: 'Worker'),
    );
  }
}
