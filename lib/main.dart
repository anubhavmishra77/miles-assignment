import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'view_models/todo_view_model.dart';
import 'views/todo_list_view.dart';
import 'views/login_view.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAFM0JvxKQ_5oOjHYVY7tUV7z_7o2uR1oM',
      appId: '1:257737311538:ios:146107da0b656427f3432b',
      messagingSenderId: '257737311538',
      projectId: 'todo-shared-app',
      storageBucket: 'todo-shared-app.firebasestorage.app',
      iosBundleId: 'com.example.todoSharedApp',
    ),
  );

  // Initialize GetX dependencies
  Get.put(FirebaseService());
  Get.put(TodoController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LoginView()),
        GetPage(name: '/todos', page: () => const TodoListView()),
      ],
    );
  }
}
