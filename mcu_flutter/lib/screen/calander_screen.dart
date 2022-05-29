import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcu/model/study.dart';
import 'package:mcu/util/socket_client.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sendSocketData('{"cmd": "get_study_data"}'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final List<Study> studies = <Study>[];
          var studyData = jsonDecode(snapshot.data.toString());

          for (var study in studyData) {
            DateTime startTime = DateTime.parse(study[1].toString());
            DateTime endTime = DateTime.parse(study[2].toString());
            DateTime studyTime = endTime.subtract(
              Duration(
                  hours: startTime.hour,
                  minutes: startTime.minute,
                  seconds: startTime.second),
            );
            studies.add(Study(
                DateFormat('HH:mm:ss').format(studyTime).toString(),
                startTime,
                endTime,
                const Color(0xFF0F8644),
                false));
          }

          return SfCalendar(
            view: CalendarView.month,
            initialSelectedDate: DateTime.now(),
            dataSource: StudyDataSource(studies),
            appointmentTimeTextFormat: 'MM/dd HH:mm:ss',
            headerDateFormat: 'yyy-MM',
            monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true,
                agendaItemHeight: 63,
                agendaStyle:
                    AgendaStyle(appointmentTextStyle: TextStyle(height: 2))),
          );
        }
      },
    );
  }
}
