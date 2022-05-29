import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text("캘린더")),
      body: FutureBuilder(
        future: getStudyData(),
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
              dataSource: MeetingDataSource(studies),
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                agendaViewHeight: 300,
              ),
            );
          }
        },
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Study> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getStudyData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getStudyData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getStudyData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getStudyData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getStudyData(index).isAllDay;
  }

  Study _getStudyData(int index) {
    final dynamic meeting = appointments![index];
    late final Study meetingData;
    if (meeting is Study) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

class Study {
  Study(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;

  DateTime from;

  DateTime to;

  Color background;

  bool isAllDay;
}
