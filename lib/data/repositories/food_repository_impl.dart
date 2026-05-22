import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_log.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/local/meal_local_datasource.dart';
import '../datasources/remote/claude_ai_datasource.dart';
import '../models/meal_log_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  final ClaudeAiDataSource _remoteDataSource;
  final MealLocalDataSource _localDataSource;

  const FoodRepositoryImpl({
    required ClaudeAiDataSource remoteDataSource,
    required MealLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<FoodItem>>> analyzeFoodImage(
      File imageFile) async {
    try {
      final models = await _remoteDataSource.analyzeFoodImage(imageFile);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealLog>>> getMealHistory() async {
    try {
      final models = await _localDataSource.getMealHistory();
      return Right(models);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMeal(MealLog mealLog) async {
    try {
      await _localDataSource.saveMeal(MealLogModel.fromEntity(mealLog));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await _localDataSource.deleteMeal(mealId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
