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

  _addTime() async {
    TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    await sendSocketData(
        '{"cmd":"add_alarm", "time": "${NumberFormat("00").format(timeOfDay?.hour)}:${NumberFormat("00").format(timeOfDay?.minute)}"}');
    setState(() {});
  }

  _setSleepTime(alarm) async {
    TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: alarm[1], useRootNavigator: false);
    if (timeOfDay == null) {
      timeOfDay = TimeOfDay.now();
    } else if (timeOfDay != alarm[1] && timeOfDay != alarm[1]) {
      alarm[1] = timeOfDay;
      await sendSocketData(
          '{"cmd": "set_alarm", "index": ${alarm[0]}, "time": "${NumberFormat("00").format(alarm[1].hour)}:${NumberFormat("00").format(alarm[1].minute)}", "sleep": "Y"}');
      setState(() {});
    }
  }

  _setTime(alarm) async {
    TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: alarm[1], useRootNavigator: false);
    if (timeOfDay == null) {
      timeOfDay = TimeOfDay.now();
    } else if (timeOfDay != alarm[1] && timeOfDay != alarm[1]) {
      alarm[1] = timeOfDay;
      await sendSocketData(
          '{"cmd": "set_alarm", "index": ${alarm[0]}, "time": "${NumberFormat("00").format(alarm[1].hour)}:${NumberFormat("00").format(alarm[1].minute)}", "sleep": "N"}');
      setState(() {});
    }
  }

  _deleteAlarm(alarm) async {
    await sendSocketData('{"cmd": "remove_alarm", "index": ${alarm[0]}}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: FutureBuilder(
          future: sendSocketData('{"cmd": "get_alarm"}'),
          builder: (contexts, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
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
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              _setTime(alarmList[0]);
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Center(
                                child: Text(
                                  " ${NumberFormat("00").format(alarmList[0][1].hour)}:${NumberFormat("00").format(alarmList[0][1].minute)}(Sleep)",
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 1; i < alarmList.length; i++)
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                _setTime(alarmList[i]);
                              },
                              onLongPress: () {
                                _deleteAlarm(alarmList[i]);
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.1,
                                child: Center(
                                  child: Text(
                                    "${NumberFormat("00").format(alarmList[i][1].hour)}:${NumberFormat("00").format(alarmList[i][1].minute)}",
                                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTime(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
