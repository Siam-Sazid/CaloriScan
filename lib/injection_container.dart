import 'package:get_it/get_it.dart';
import 'data/datasources/local/meal_local_datasource.dart';
import 'data/datasources/remote/claude_ai_datasource.dart';
import 'data/repositories/food_repository_impl.dart';
import 'domain/repositories/food_repository.dart';
import 'domain/usecases/analyze_food_image_usecase.dart';
import 'domain/usecases/delete_meal_usecase.dart';
import 'domain/usecases/get_meal_history_usecase.dart';
import 'domain/usecases/save_meal_usecase.dart';
import 'presentation/blocs/food_analysis/food_analysis_bloc.dart';
import 'presentation/blocs/meal_history/meal_history_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // -----------------------------------------------------------
  // BLoCs — registered as factory so each page gets a fresh instance
  // -----------------------------------------------------------
  sl.registerFactory(
    () => FoodAnalysisBloc(analyzeFoodImageUseCase: sl()),
  );

  sl.registerFactory(
    () => MealHistoryBloc(
      getMealHistoryUseCase: sl(),
      saveMealUseCase: sl(),
      deleteMealUseCase: sl(),
    ),
  );

  // -----------------------------------------------------------
  // Use Cases
  // -----------------------------------------------------------
  sl.registerLazySingleton(() => AnalyzeFoodImageUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMealHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => SaveMealUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteMealUseCase(repository: sl()));

  // -----------------------------------------------------------
  // Repository
  // -----------------------------------------------------------
  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // -----------------------------------------------------------
  // Data Sources
  //
  // Swap ClaudeAiDataSourceStub → ClaudeAiDataSourceImpl
  // once the Anthropic API key is available.
  // -----------------------------------------------------------
  sl.registerLazySingleton<ClaudeAiDataSource>(
    () => ClaudeAiDataSourceImpl(),
  );

  sl.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSourceImpl(),
  );
}
