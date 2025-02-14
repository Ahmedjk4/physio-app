import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/features/body_part_selector/data/models/body_parts_model.dart';
import 'package:physio_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(BodyPartsHiveWrapperAdapter());
  await Hive.openBox('settings');
  await Hive.openBox<BodyPartsHiveWrapper>('bodyPartsBox');
  await Hive.openBox<List<String>>('diet');
  await Supabase.initialize(
    url: 'https://lohceeqayhjedlmvdrcv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvaGNlZXFheWhqZWRsbXZkcmN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0NTQ4NTYsImV4cCI6MjA1NDAzMDg1Nn0.4ERoH6ElqH4M5y3QJFrEJ7AaOLD9qI-DH6dmfA3t_PA',
  );
  setupServiceLocator();
  runApp(const PhysioApp());
}

class PhysioApp extends StatelessWidget {
  const PhysioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          title: 'Physio App',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.mainColor,
          ),
        );
      },
    );
  }
}
