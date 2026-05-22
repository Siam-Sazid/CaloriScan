import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('meal_logs');
  await di.initDependencies();
  runApp(const CaloriScanApp());
}

class CaloriScanApp extends StatelessWidget {
  const CaloriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaloriScan',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
