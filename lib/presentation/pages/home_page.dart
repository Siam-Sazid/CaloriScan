import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../injection_container.dart';
import '../blocs/food_analysis/food_analysis_bloc.dart';
import '../blocs/food_analysis/food_analysis_event.dart';
import '../blocs/meal_history/meal_history_bloc.dart';
import '../blocs/meal_history/meal_history_event.dart';
import '../blocs/meal_history/meal_history_state.dart';
import 'history_page.dart';
import 'result_page.dart';

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
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(AppStrings.appName, style: AppTextStyles.heading1),
                const SizedBox(height: 6),
                Text(AppStrings.tagline, style: AppTextStyles.body2),
                const SizedBox(height: 48),
                _HeroScanCard(onCamera: () => _pickImage(ImageSource.camera)),
                const SizedBox(height: 16),
                _GalleryButton(
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 36),
                Text(AppStrings.todaySummary, style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                const _TodaySummaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  final VoidCallback onCamera;
  const _HeroScanCard({required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCamera,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.camera_alt_rounded,
                size: 160,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text('AI Powered',
                            style: AppTextStyles.chip
                                .copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.takePhoto,
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.background),
                  ),
                  Text(
                    'Point camera at your meal',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.background.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(AppStrings.chooseFromGallery, style: AppTextStyles.body1),
          ],
        ),
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealHistoryBloc, MealHistoryState>(
      builder: (context, state) {
        double todayCalories = 0;
        if (state is MealHistoryLoaded || state is MealSaveSuccess) {
          final meals =
              state is MealHistoryLoaded ? state.meals : (state as MealSaveSuccess).meals;
          final today = DateTime.now();
          todayCalories = meals
              .where((m) =>
                  m.timestamp.year == today.year &&
                  m.timestamp.month == today.month &&
                  m.timestamp.day == today.day)
              .fold(0, (sum, m) => sum + m.totalCalories);
        }

        const double dailyGoal = 2000;
        final percent = (todayCalories / dailyGoal).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${todayCalories.toStringAsFixed(0)} kcal',
                        style: AppTextStyles.calorieSmall,
                      ),
                      Text(
                        'of ${dailyGoal.toStringAsFixed(0)} ${AppStrings.dailyGoal}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
