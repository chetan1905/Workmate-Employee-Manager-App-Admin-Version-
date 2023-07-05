import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class CustomEvent implements EventInterface {
  final DateTime date;
  final String title;
  final IconData icon;
  final Color color;
  final String checkIn;
  final String checkOut;

  CustomEvent({
    required this.date,
    required this.title,
    required this.icon,
    required this.color,
    required this.checkIn,
    required this.checkOut,
  });

  DateTime getEventDate() {
    return date;
  }

  IconData? getEventIcon() {
    return icon;
  }

  Color? getEventIconColor() {
    return color;
  }

  String? getEventType() {
    return title;
  }

  @override
  String toString() {
    return 'CustomEvent{date: $date, title: $title, icon: $icon, '
        'color: $color, checkIn: $checkIn, checkOut: $checkOut}';
  }

  @override
  DateTime getDate() {
    throw UnimplementedError();
  }

  @override
  String? getDescription() {
    throw UnimplementedError();
  }

  @override
  Widget? getDot() {
    throw UnimplementedError();
  }

  @override
  Widget? getIcon() {
    throw UnimplementedError();
  }

  @override
  int? getId() {
    throw UnimplementedError();
  }

  @override
  String? getLocation() {
    throw UnimplementedError();
  }

  @override
  String? getTitle() {
    throw UnimplementedError();
  }
}
