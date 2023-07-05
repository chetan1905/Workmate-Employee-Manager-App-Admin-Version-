import 'package:attendance_manager_admin/data/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

class AttendanceCalendar extends StatefulWidget {
  final String empId;
  const AttendanceCalendar({super.key, required this.empId});

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late DateTime _currentDate;

  EventList<CustomEvent> _markedDates = EventList<CustomEvent>(
    events: {},
  );

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadAttendance(); // Load attendance data from Firestore
  }

  void _loadAttendance() async {
    final Map<String, List<String>> attendanceMap = {};

    final records = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(widget.empId)
        .collection('Records')
        .get();

    for (final record in records.docs) {
      final date = record.id; // get document id as date
      final checkIn = record['checkIn'];
      final checkOut = record['checkOut'];

      if (!attendanceMap.containsKey(date)) {
        // if date not found in map, add new empty list
        attendanceMap[date] = [];
      }

      attendanceMap[date]!.add(checkIn!); // add checkIn to list
      attendanceMap[date]!.add(checkOut!); // add checkOut to list
    }

    final newEvents = <CustomEvent>[];

    final dates = List<String>.from(attendanceMap.keys);
    for (final date in dates) {
      final attendanceData = attendanceMap[date]!;
      final checkIn = attendanceData.isNotEmpty ? attendanceData[0] : null;
      final checkOut = attendanceData.length > 1 ? attendanceData[1] : null;

      if (date != null && checkOut != null && checkOut != "00:00:00 AM") {
        final formattedDate = DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd MMMM yyyy').parse(date));

        newEvents.add(
          CustomEvent(
            date: DateTime.parse(formattedDate),
            title: 'Present',
            icon: Icons.check,
            color: Colors.green,
            checkIn: checkIn ?? '',
            checkOut: checkOut,
          ),
        );
      } else {
        final formattedDate = DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd MMMM yyyy').parse(date));

        newEvents.add(
          CustomEvent(
            date: DateTime.parse(formattedDate),
            title: 'Absent',
            icon: Icons.close,
            color: Colors.red,
            checkIn: checkIn ?? '',
            checkOut: checkOut ?? '',
          ),
        );
      }
    }

    final markedDates = <DateTime, List<CustomEvent>>{};

    for (final event in newEvents) {
      final date = event.date;
      if (!markedDates.containsKey(date)) {
        markedDates[date] = <CustomEvent>[];
      }
      markedDates[date]!.add(event);
    }

    final eventList = EventList<CustomEvent>(events: {});
    markedDates.forEach((date, events) {
      for (var event in events) {
        eventList.add(date, event);
      }
    });
    for (var events in eventList.events.values) {
      if (events.length > 1) {
        events.sort((a, b) => a.date.compareTo(b.date));
        eventList.remove(events.first.date, events.last);
        eventList.add(events.first.date, events.last);
      }
    }

    setState(() {
      _markedDates = eventList;
    });

    // Update the UI to reflect the changes
  }

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel<CustomEvent>(
      height: 433,
      width: 400,
      isScrollable: false,
      weekdayTextStyle: const TextStyle(color: Colors.cyan),
      daysTextStyle: const TextStyle(color: Colors.cyan),
      headerTextStyle: const TextStyle(color: Colors.cyan, fontSize: 26),
      iconColor: Colors.cyan,
      todayButtonColor: Colors.cyan,
      onDayPressed: (DateTime date, List<CustomEvent> events) {
        // Handle day press event here
      },
      weekendTextStyle: const TextStyle(
        color: Colors.blueAccent,
      ),
      markedDatesMap: _markedDates,
      markedDateIconBuilder: (event) {
        Color color;

        if (event.checkOut != null && event.checkOut != "00:00:00 AM") {
          color = Colors.green;
        } else if (event.checkIn == "00:00:00 AM" &&
            DateTime.now().weekday == DateTime.sunday) {
          color = Colors.cyan;
        } else {
          color = Colors.red;
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Center(
                child: Text(
                  '${event.date.day}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
    );
  }
}
