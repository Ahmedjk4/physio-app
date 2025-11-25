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
    url: 'https://srvxqsjzggfirmmufpkz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNydnhxc2p6Z2dmaXJtbXVmcGt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwMjAwODAsImV4cCI6MjA3OTU5NjA4MH0.OPun0JQ-NHpaoZhgj-qOLv7inEoxQtyH1ql6PSDpwTs',
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
