import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/app.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(GetIt.instance);
  runApp(const ProviderScope(child: BudgetApp()));
}
