import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;
  final Timestamp? checkIn;
  final Timestamp? checkOut;

  AttendanceRecord(this.date, this.isPresent, this.checkIn, this.checkOut);
}
