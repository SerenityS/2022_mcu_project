import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcu/const/theme_data.dart';
import 'package:mcu/screen/alarm_screen.dart';

Widget customCard(context, text, targetScreen) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => const AlarmScreen());
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Center(child: Text(text)),
        ),
      ),
    ),
  );
}

Widget customGradientCard(context, text, targetScreen) {
  return GestureDetector(
    onTap: () {
      Get.to(targetScreen);
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: GradientTemplate.gradientTemplate[1].colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child: Center(child: Text(text)),
        ),
      ),
    ),
  );
}
