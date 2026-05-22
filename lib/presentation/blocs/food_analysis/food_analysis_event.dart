import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FoodAnalysisEvent extends Equatable {
  const FoodAnalysisEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeFoodImageEvent extends FoodAnalysisEvent {
  final File imageFile;
  const AnalyzeFoodImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile.path];
}

class UpdateFoodPortionEvent extends FoodAnalysisEvent {
  final String itemId;
  final double newPortionSize;
  const UpdateFoodPortionEvent({
    required this.itemId,
    required this.newPortionSize,
  });

  @override
  List<Object?> get props => [itemId, newPortionSize];
}

class RemoveFoodItemEvent extends FoodAnalysisEvent {
  final String itemId;
  const RemoveFoodItemEvent({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ResetAnalysisEvent extends FoodAnalysisEvent {
  const ResetAnalysisEvent();
}
