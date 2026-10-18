import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';

class ListIncomeSources {
  const ListIncomeSources(this._repository);

  final IncomeRepository _repository;

  Future<List<IncomeSource>> call({bool includeArchived = false}) =>
      _repository.listSources(includeArchived: includeArchived);
}
