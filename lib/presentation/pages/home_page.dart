import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/meal_log.dart';
import '../../injection_container.dart';
import '../blocs/food_analysis/food_analysis_bloc.dart';
import '../blocs/food_analysis/food_analysis_event.dart';
import '../blocs/meal_history/meal_history_bloc.dart';
import '../blocs/meal_history/meal_history_event.dart';
import '../blocs/meal_history/meal_history_state.dart';
import 'history_page.dart';
import 'result_page.dart';

const double _kCalorieGoal = 2000;
const double _kProteinGoal = 150;
const double _kCarbsGoal = 250;
const double _kFatGoal = 65;
const double _kWaterGoalL = 3.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file == null || !mounted) return;

    final imageFile = File(file.path);
    final analysisBloc = sl<FoodAnalysisBloc>();
    analysisBloc.add(AnalyzeFoodImageEvent(imageFile: imageFile));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: analysisBloc,
          child: ResultPage(imageFile: imageFile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MealHistoryBloc>()..add(const LoadMealHistoryEvent()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<MealHistoryBloc, MealHistoryState>(
            builder: (context, state) {
              List<MealLog> todayMeals = [];
              double calories = 0, protein = 0, carbs = 0, fat = 0;

              if (state is MealHistoryLoaded || state is MealSaveSuccess) {
                final allMeals = state is MealHistoryLoaded
                    ? state.meals
                    : (state as MealSaveSuccess).meals;
                final today = DateTime.now();
                todayMeals = allMeals
                    .where((m) =>
                        m.timestamp.year == today.year &&
                        m.timestamp.month == today.month &&
                        m.timestamp.day == today.day)
                    .toList();
                for (final m in todayMeals) {
                  calories += m.totalCalories;
                  protein += m.totalNutrition.protein;
                  carbs += m.totalNutrition.carbohydrates;
                  fat += m.totalNutrition.fat;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _HomeHeader(
                      onHistory: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NutrientsCard(
                      calories: calories,
                      protein: protein,
                      carbs: carbs,
                      fat: fat,
                    ),
                    const SizedBox(height: 12),
                    const _WaterIntakeCard(),
                    const SizedBox(height: 20),
                    _MealsSection(
                      meals: todayMeals,
                      onScanTap: () => _pickImage(ImageSource.camera),
                      onGalleryTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final VoidCallback onHistory;
  const _HomeHeader({required this.onHistory});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateLabel = 'Today, ${months[now.month - 1]} ${now.day}';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.restaurant_rounded,
              color: AppColors.primary, size: 19),
        ),
        const SizedBox(width: 10),
        const Expanded(
            child: Text(AppStrings.appName, style: AppTextStyles.heading3)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppColors.primary, size: 12),
              const SizedBox(width: 5),
              Text(
                dateLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onHistory,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Nutrients Indicator Card ─────────────────────────────────────────────────

class _NutrientsCard extends StatelessWidget {
  final double calories, protein, carbs, fat;
  const _NutrientsCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text(
              'NUTRIENTS INDICATOR',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _NutrientColumn(
                    label: 'Proteins',
                    current: protein,
                    goal: _kProteinGoal,
                  ),
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                Expanded(
                  child: _NutrientColumn(
                    label: 'Fats',
                    current: fat,
                    goal: _kFatGoal,
                  ),
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                Expanded(
                  child: _NutrientColumn(
                    label: 'Carbs',
                    current: carbs,
                    goal: _kCarbsGoal,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: calories.toStringAsFixed(0),
                        style: AppTextStyles.body1
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' / ${_kCalorieGoal.toStringAsFixed(0)}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Calories',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientColumn extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  const _NutrientColumn({
    required this.label,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: current.toStringAsFixed(0),
                style:
                    AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' / ${goal.toStringAsFixed(0)}',
                style: AppTextStyles.body2.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ─── Water Intake Card ────────────────────────────────────────────────────────

class _WaterIntakeCard extends StatelessWidget {
  const _WaterIntakeCard();

  @override
  Widget build(BuildContext context) {
    const double current = 0.0;
    const double fillPercent = 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WATER INTAKE',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Water', style: AppTextStyles.body1),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: current.toStringAsFixed(1),
                            style: AppTextStyles.heading3.copyWith(
                              color: const Color(0xFF4FC3F7),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' / ${_kWaterGoalL.toStringAsFixed(1)} L',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No water logged today',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _WaterGlass(fillPercent: fillPercent),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  final double fillPercent;
  const _WaterGlass({required this.fillPercent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 66,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fillPercent.clamp(0.0, 1.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x664FC3F7),
                        Color(0xAA0288D1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meals Section ────────────────────────────────────────────────────────────

class _MealsSection extends StatelessWidget {
  final List<MealLog> meals;
  final VoidCallback onScanTap;
  final VoidCallback onGalleryTap;
  const _MealsSection({
    required this.meals,
    required this.onScanTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Meals', style: AppTextStyles.heading3),
            const Spacer(),
            if (meals.isNotEmpty)
              GestureDetector(
                onTap: onScanTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Add Meal',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty) ...[
          _ScanCard(onTap: onScanTap),
          const SizedBox(height: 10),
          _GalleryRow(onTap: onGalleryTap),
        ] else ...[
          ...meals.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MealCard(meal: m),
            ),
          ),
          const SizedBox(height: 2),
          _GalleryRow(onTap: onGalleryTap),
        ],
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealLog meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final firstName =
        meal.foodItems.isNotEmpty ? meal.foodItems.first.name : 'Meal';
    final extra = meal.foodItems.length - 1;
    final title =
        extra > 0 ? '$firstName + $extra more' : firstName;

    final h = meal.timestamp.hour;
    final m = meal.timestamp.minute.toString().padLeft(2, '0');
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final timeStr = '$displayH:$m $period';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(timeStr, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '${meal.totalCalories.toStringAsFixed(0)} Cal',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan Card (shown when no meals logged) ───────────────────────────────────

class _ScanCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 148,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -12,
              child: Icon(
                Icons.camera_alt_rounded,
                size: 164,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          'AI Powered',
                          style: AppTextStyles.chip
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Scan Your First Meal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Point camera at any food',
                    style: AppTextStyles.body2
                        .copyWith(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gallery Row ──────────────────────────────────────────────────────────────

class _GalleryRow extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(AppStrings.chooseFromGallery, style: AppTextStyles.body1),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
