import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/food_item.dart';
import '../repositories/food_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

class AnalyzeFoodImageUseCase extends UseCase<List<FoodItem>, AnalyzeFoodParams> {
  final FoodRepository _repository;

  AnalyzeFoodImageUseCase({required FoodRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<FoodItem>>> call(AnalyzeFoodParams params) =>
      _repository.analyzeFoodImage(params.imageFile);
}

class AnalyzeFoodParams extends Equatable {
  final File imageFile;
  const AnalyzeFoodParams({required this.imageFile});

  @override
  List<Object?> get props => [imageFile.path];
}
