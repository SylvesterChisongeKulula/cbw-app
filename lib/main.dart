import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/storage_service.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initServices();

  runApp(MyApp());
}

Future<void> initServices() async {
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());

  // Initialize API service
  Get.put(ApiService());

  // Initialize Socket service (will connect after user login)
  Get.put(SocketService());

  // Initialize auth controller
  Get.put(AuthController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return GetMaterialApp(
      title: 'CBW Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6C88D7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6C88D7),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
