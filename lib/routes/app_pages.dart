// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_list_controller.dart';
import '../controllers/chat_detail_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.SPLASH, page: () => SplashScreen()),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.CHAT_LIST,
      page: () => ChatListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatListController>(() => ChatListController());
      }),
    ),
    GetPage(
      name: '${AppRoutes.CHAT_DETAIL}/:id',
      page: () => ChatDetailScreen(),
      binding: BindingsBuilder(() {
        // Create and dispose controller per route, allow recreation on re-entry
        Get.lazyPut<ChatDetailController>(() => ChatDetailController(), fenix: true);
      }),
    ),
  ];
}
