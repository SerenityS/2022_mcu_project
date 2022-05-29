import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcu/screen/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '열공 무드등',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          toolbarTextStyle: const TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ).bodyText2,
          titleTextStyle: const TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ).headline6,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        primarySwatch: Colors.grey,
        primaryIconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
