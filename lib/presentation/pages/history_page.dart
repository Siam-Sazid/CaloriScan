import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/meal_log.dart';
import '../../injection_container.dart';
import '../blocs/meal_history/meal_history_bloc.dart';
import '../blocs/meal_history/meal_history_event.dart';
import '../blocs/meal_history/meal_history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MealHistoryBloc>()..add(const LoadMealHistoryEvent()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.history)),
      body: BlocBuilder<MealHistoryBloc, MealHistoryState>(
        builder: (context, state) {
          if (state is MealHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MealHistoryError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.body1),
            );
          }

          final meals = switch (state) {
            MealHistoryLoaded(meals: final m) => m,
            MealSaveSuccess(meals: final m) => m,
            _ => <MealLog>[],
          };

          if (meals.isEmpty) {
            return _EmptyHistory();
          }

          // Group meals by date for section headers — O(n) pass
          final grouped = _groupByDate(meals);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped[index];
              if (entry is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
                  child: Text(entry, style: AppTextStyles.label),
                );
              }
              return _MealLogCard(
                meal: entry as MealLog,
                onDelete: () {
                  context
                      .read<MealHistoryBloc>()
                      .add(DeleteMealEvent(mealId: (entry).id));
                },
              );
            },
          );
        },
      ),
    );
  }

  // Returns a flat list interleaving String date headers with MealLog items
  List<dynamic> _groupByDate(List<MealLog> meals) {
    final result = <dynamic>[];
    String? lastDateKey;

    for (final meal in meals) {
      final key = _dateKey(meal.timestamp);
      if (key != lastDateKey) {
        result.add(key);
        lastDateKey = key;
      }
      result.add(meal);
    }
    return result;
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, yyyy').format(dt);
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_menu_rounded,
              size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Text(
            AppStrings.noHistory,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MealLogCard extends StatelessWidget {
  final MealLog meal;
  final VoidCallback onDelete;

  const _MealLogCard({required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ImageThumb(imagePath: meal.imagePath),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meal.foodItems.length} item${meal.foodItems.length > 1 ? 's' : ''}',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.foodItems
                          .take(2)
                          .map((e) => e.name)
                          .join(', '),
                      style: AppTextStyles.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('h:mm a').format(meal.timestamp),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.totalCalories.toStringAsFixed(0)}',
                    style: AppTextStyles.calorieSmall,
                  ),
                  Text('kcal', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String? imagePath;
  const _ImageThumb({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 60,
        height: 60,
        child: imagePath != null && File(imagePath!).existsSync()
            ? Image.file(File(imagePath!), fit: BoxFit.cover)
            : Container(
                color: AppColors.cardElevated,
                child: const Icon(Icons.restaurant_menu_rounded,
                    color: AppColors.textSecondary),
              ),
      ),
    );
  }
}
