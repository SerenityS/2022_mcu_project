import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class Study {
  Study(this.eventName, this.from, this.to, this.background, this.isAllDay);
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class StudyDataSource extends CalendarDataSource {
  StudyDataSource(List<Study> source) {
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
