import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcu/util/socket_client.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  var alarmList = [];

  TimeOfDay selectedTime = TimeOfDay.now();

  _addTime() async {
    TimeOfDay? timeOfDay =
        await showTimePicker(context: context, initialTime: selectedTime);

    await addAlarm(
        "${NumberFormat("00").format(timeOfDay?.hour)}:${NumberFormat("00").format(timeOfDay?.minute)}");
    setState(() {});
  }

  _setTime(alarm) async {
    TimeOfDay? timeOfDay =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (timeOfDay != alarm[1] && timeOfDay != alarm[1]) {
      alarm[1] = timeOfDay;
      await setAlarm(alarm[0],
          "${NumberFormat("00").format(alarm[1].hour)}:${NumberFormat("00").format(alarm[1].minute)}");
      setState(() {});
    }
  }

  _deleteAlarm(alarm) async {
    await removeAlarm(alarm[0]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알람"),
      ),
      body: FutureBuilder(
        future: getAlarm(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var alarmData = jsonDecode(snapshot.data.toString());
            alarmList = [];

            for (var alarm in alarmData) {
              int hr = int.parse(alarm[1].toString().substring(0, 2));
              int mn = int.parse(alarm[1].toString().substring(3, 5));
              alarmList.add([alarm[0], TimeOfDay(hour: hr, minute: mn)]);
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  for (var alarm in alarmList)
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              _setTime(alarm);
                            },
                            onLongPress: () {
                              _deleteAlarm(alarm);
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Center(
                                child: Text(
                                  "${NumberFormat("00").format(alarm[1].hour)}:${NumberFormat("00").format(alarm[1].minute)}",
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            _addTime();
                          },
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: const Center(
                              child: Text(
                                "알람 추가",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
