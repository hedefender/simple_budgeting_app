import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';

class RecordStartupDuration {
  RecordStartupDuration(this._repository);

  final AppStatusRepository _repository;

  Future<void> call(Duration duration) =>
      _repository.saveStartupDuration(duration.inMilliseconds);
}
