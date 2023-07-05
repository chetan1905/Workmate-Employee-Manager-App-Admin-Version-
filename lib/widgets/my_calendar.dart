// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:sprintf/sprintf.dart';

class MyCalendarWidget extends StatefulWidget {
  final String employeeID;
  final String name;
  const MyCalendarWidget(
      {super.key, required this.employeeID, required this.name});

  @override
  State<MyCalendarWidget> createState() => _MyCalendarWidgetState();
}

class _MyCalendarWidgetState extends State<MyCalendarWidget> {
  String _month = DateFormat('MMMM').format(DateTime.now());

  String getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkIn = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOut = DateFormat('hh:mm:ss a').parse(checkOutTime);

    Duration duration = checkOut.difference(checkIn);

    int hours = duration.inMinutes ~/ 60;
    int minutes = (duration.inMinutes % 60).toInt();
    String formattedDuration = sprintf("%d Hrs:%02d Min", [hours, minutes]);
    return formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HelperFunctions().secondaryColor,
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          elevation: 0.0,
          centerTitle: true,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white)),
          title: Column(
            children: [
              Text("ATTENDANCE",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(
                widget.name,
                style: TextStyle(color: Colors.white, fontSize: 22),
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  height: 50,
                  width: 150,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _month,
                    style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final month = await showMonthYearPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2099));

                    if (month != null) {
                      setState(() {
                        _month = DateFormat('MMMM').format(month);
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    height: 50,
                    width: 150,
                    alignment: Alignment.center,
                    child: const Text(
                      'Pick a Month',
                      style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 700,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(widget.employeeID)
                    .collection("Records")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;

                    return ListView.builder(
                        itemCount: snap.length,
                        itemBuilder: (context, index) {
                          return DateFormat('MMMM')
                                      .format(snap[index]['date'].toDate()) ==
                                  _month
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 2, color: Colors.cyan)),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Agenda',
                                                    style: TextStyle(
                                                        color: Colors.cyan),
                                                  ),
                                                  content: Text(
                                                      snap[index]['agenda']),
                                                );
                                              });
                                        },
                                        child: Container(
                                          width: 90,
                                          margin: const EdgeInsets.only(
                                              left: 2,
                                              top: 2,
                                              bottom: 2,
                                              right: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.cyan,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          child: Center(
                                            child: Text(
                                              DateFormat('EE\ndd').format(
                                                  snap[index]['date'].toDate()),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Status',
                                                style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20),
                                              ),
                                              SizedBox(
                                                width: 40,
                                              ),
                                              snap[index]['wfh'] == true
                                                  ? Text(
                                                      "W.F.H",
                                                      style: const TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 20),
                                                    )
                                                  : Text(
                                                      'W.F.O',
                                                      style: const TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 20),
                                                    ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Check In",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[400]),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                snap[index]['checkIn'],
                                                style: const TextStyle(
                                                    color: Colors.cyan,
                                                    fontSize: 22),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Check Out",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[400])),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                snap[index]['checkOut'],
                                                style: const TextStyle(
                                                    color: Colors.cyan,
                                                    fontSize: 22),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('Duration',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[400])),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              snap[index]['checkOut'] ==
                                                      '00:00:00 AM'
                                                  ? Text(
                                                      "Didn't Checkout",
                                                      style: const TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 22),
                                                    )
                                                  : Text(
                                                      getHoursWorked(
                                                          snap[index]
                                                              ['checkIn'],
                                                          snap[index]
                                                              ['checkOut']),
                                                      style: const TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 22),
                                                    )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox();
                        });
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
