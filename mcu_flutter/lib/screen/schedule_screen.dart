import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcu/model/study.dart';
import 'package:mcu/util/socket_client.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<Study> studies = <Study>[];

  Future<String> _getSchedule() async {
    var rst = await sendSocketData('{"cmd": "get_study_data"}');
    return rst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getSchedule(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            studies.clear();
            var studyData = jsonDecode(snapshot.data.toString());

            for (var study in studyData) {
              DateTime startTime = DateTime.parse(study[1].toString());
              DateTime endTime = DateTime.parse(study[2].toString());
              DateTime studyTime = endTime.subtract(
                Duration(hours: startTime.hour, minutes: startTime.minute, seconds: startTime.second),
              );
              studies.add(Study(DateFormat('HH:mm:ss').format(studyTime).toString(), startTime, endTime, const Color(0xFF0F8644), false));
            }

            return SfCalendar(
              view: CalendarView.schedule,
              initialSelectedDate: DateTime.now(),
              dataSource: StudyDataSource(studies),
              appointmentTimeTextFormat: 'MM/dd HH:mm:ss',
              headerHeight: 0,
              scheduleViewSettings: const ScheduleViewSettings(
                hideEmptyScheduleWeek: true,
                appointmentTextStyle: TextStyle(height: 2),
                appointmentItemHeight: 63,
                monthHeaderSettings: MonthHeaderSettings(backgroundColor: Colors.grey, height: 2),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getSchedule();
          setState(() {});
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
