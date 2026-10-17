import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';

class RecordAppLaunch {
  RecordAppLaunch(this._repository, this._clock);

  final AppStatusRepository _repository;
  final Clock _clock;

  Future<AppStatus> call() => _repository.recordLaunch(_clock().toUtc());
}
