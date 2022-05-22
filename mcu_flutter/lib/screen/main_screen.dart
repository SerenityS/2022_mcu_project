import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcu/screen/alarm_screen.dart';
import 'package:mcu/widget/custom_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("열공 무드등")),
      body: Center(
        child: Column(
          children: [customCard(context, "알람", AlarmScreen())],
        ),
      ),
    );
  }
}
