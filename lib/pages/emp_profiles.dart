// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:async';
import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:attendance_manager_admin/pages/admin_pages.dart';
import 'package:attendance_manager_admin/pages/docs_page.dart';
import 'package:attendance_manager_admin/widgets/attendance_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmpProfiles extends StatefulWidget {
  final String empName;
  final String email;
  final String phNumber;
  final String role;
  final String empId;
  final int salary;
  const EmpProfiles(
      {super.key,
      required this.empName,
      required this.email,
      required this.phNumber,
      required this.role,
      required this.empId,
      required this.salary});

  @override
  State<EmpProfiles> createState() => _EmpProfilesState();
}

class _EmpProfilesState extends State<EmpProfiles> {
  late dynamic checkInTime;
  late dynamic checkOutTime;
  dynamic email;
  dynamic phNumber;
  dynamic role;
  dynamic salary;

  void setValues() {
    setState(() {
      email = widget.email;
      phNumber = widget.phNumber;
      role = widget.role;
      salary = widget.salary;
    });
  }

  Future<void> deleteUser(String docId) async {
    try {
      // Delete the subcollection "Records" associated with the user
      QuerySnapshot recordsQuerySnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(docId)
          .collection('Records')
          .get();
      for (DocumentSnapshot docSnapshot in recordsQuerySnapshot.docs) {
        await docSnapshot.reference.delete();
      }

      // Delete the document with the given docId from the "Employee" collection
      await FirebaseFirestore.instance
          .collection('Employee')
          .doc(docId)
          .delete()
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.cyan,
            content: Text(
              "Employee removed successfully!",
              style: TextStyle(color: Colors.white),
            )));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AdminPages()));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.cyan,
          content: Text(
            "Error removing employee $e",
            style: TextStyle(color: Colors.white),
          )));
    }
  }

  int getWorkingDaysInMonth() {
    final now = DateTime.now();
    final monthStartDate = DateTime(now.year, now.month, 1);
    final monthEndDate = DateTime(now.year, now.month + 1, 0);
    final totalDays = monthEndDate.day - monthStartDate.day + 1;
    return totalDays;
  }

  double calculatePayRatePerHour(int workingDays) {
    const hoursPerDay = 8;
    final totalHours = workingDays * hoursPerDay;
    final monthlyPay = widget.salary;
    final payRatePerHour = monthlyPay / totalHours;
    return payRatePerHour;
  }

  int getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkIn = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOut = DateFormat('hh:mm:ss a').parse(checkOutTime);

    Duration duration = checkOut.difference(checkIn);

    int hours = duration.inHours;
    return hours;
  }

  Future<void> saveTotalWorkHours(List<int> totalWorkHours) async {
    final employeeRef =
        FirebaseFirestore.instance.collection('Employee').doc(widget.empId);

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final docRef = employeeRef
        .collection('MonthlyWorkHours')
        .doc('$year-${month.toString().padLeft(2, '0')}');

    await docRef.set({
      'year': year,
      'month': month,
      'totalWorkHours': totalWorkHours,
    });
  }

// This function should only be called once a day
  Future<void> updateTotalWorkHours(DateTime date) async {
    final employeeRef =
        FirebaseFirestore.instance.collection('Employee').doc(widget.empId);

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

    final recordsSnapshot =
        await employeeRef.collection('Records').doc(formattedDate).get();

    if (recordsSnapshot.exists) {
      final checkInTime = recordsSnapshot.get('checkIn');
      final checkOutTime = recordsSnapshot.get('checkOut');

      int workedHours = getHoursWorked(checkInTime, checkOutTime);

      // Get the current totalWorkHours from Firebase
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      final docRef = employeeRef
          .collection('MonthlyWorkHours')
          .doc('$year-${month.toString().padLeft(2, '0')}');
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      final totalWorkHours = data != null && data.containsKey('totalWorkHours')
          ? List<int>.from(data['totalWorkHours'])
          : List.filled(getWorkingDaysInMonth(), 0);

      // Update the totalWorkHours list for the current day
      if (formattedDate.toString() ==
          DateFormat("dd MMMM yyyy").format(DateTime.now())) {
        if (checkOutTime != "00:00:00 AM" &&
            DateTime.now().weekday != DateTime.sunday) {
          totalWorkHours[DateTime.now().day - 1] = workedHours;
        } else if (DateTime.now().weekday == DateTime.sunday) {
          totalWorkHours[DateTime.now().day - 1] = 8;
        }
      }

      // Save the updated totalWorkHours to Firebase
      await saveTotalWorkHours(totalWorkHours);
    }
  }

  dynamic payout;

// Initialize totalHours as null
  List<int>? totalHours;

  Future<void> fetchCheckInOutTime(DateTime date) async {
    final employeeRef =
        FirebaseFirestore.instance.collection('Employee').doc(widget.empId);

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

    final recordsSnapshot =
        await employeeRef.collection('Records').doc(formattedDate).get();

    if (recordsSnapshot.exists) {
      checkInTime = recordsSnapshot.get('checkIn');
      checkOutTime = recordsSnapshot.get('checkOut');

      // If totalHours hasn't been retrieved yet, get it from Firestore and store it in totalHours
      if (totalHours == null) {
        final now = DateTime.now();
        final year = now.year;
        final month = now.month;

        final querySnapshot = await employeeRef
            .collection('MonthlyWorkHours')
            .where('year', isEqualTo: year)
            .where('month', isEqualTo: month)
            .get();

        if (querySnapshot.size > 0) {
          final docSnapshot = querySnapshot.docs.first;
          totalHours = List<int>.from(docSnapshot.get('totalWorkHours'));
        } else {
          final daysInMonth = DateTime(year, month + 1, 0).day;
          totalHours = List<int>.filled(daysInMonth, 0);
        }
      }

      int sum = 0;

      for (int i in totalHours!) {
        if (i != 0) {
          sum += i;
        }
      }

      dynamic payRate = double.parse(
          (calculatePayRatePerHour(getWorkingDaysInMonth()))
              .toStringAsFixed(2));

      await updateTotalWorkHours(DateTime.now());

      setState(() {
        payout = double.parse((sum * payRate).toStringAsFixed(2));
      });
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        throw Exception('Invalid month: $month');
    }
  }

  // Function to update email in Firestore
  Future<void> updateEmailInFirestore(String field, String employeeID,
      String newValue, BuildContext context) async {
    try {
      final collection = FirebaseFirestore.instance.collection('Employee');
      final document = collection.doc(employeeID);
      await document.update({field: newValue});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.cyan,
        content: Text(
          "Error while updating information!!",
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  Future<void> updateIntegerInFirestore(
      String employeeID, String field, int value, BuildContext context) async {
    try {
      final collection = FirebaseFirestore.instance.collection('Employee');
      final document = collection.doc(employeeID);
      await document.update({field: value});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.cyan,
        content: Text(
          "Error while updating information!!",
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  String? selectedItem;
  List<String> items = ['Documents', 'Calculate Payout', 'Remove Employee'];

  @override
  void initState() {
    super.initState();
    fetchCheckInOutTime(DateTime.now());
    setValues();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: HelperFunctions().secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        elevation: 0.0,
        leadingWidth: 250,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8.0),
          child: SizedBox(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PROFILE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.empName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 6.0),
            child: DropdownButton(
              underline: Container(),
              iconSize: 32,
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              dropdownColor: Colors.cyan,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 18),
              value: selectedItem,
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedItem = newValue!;
                });
                // Perform separate functions based on the selected value
                if (selectedItem == 'Documents') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DocsPage(employeeID: widget.empId)));
                } else if (selectedItem == 'Calculate Payout') {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "PAYOUT",
                            style: TextStyle(
                                color: Colors.cyan,
                                fontStyle: FontStyle.italic),
                          ),
                          content: Text("₹ $payout",
                              style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500)),
                        );
                      });
                } else if (selectedItem == 'Remove Employee') {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("WARNING!!",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic)),
                          content: Text(
                              "Are you sure you want to remove this employee ?",
                              style: TextStyle(color: Colors.cyan)),
                          actions: [
                            TextButton(
                                onPressed: () => deleteUser(widget.empId),
                                child: Text(
                                  "YES",
                                  style: TextStyle(color: Colors.green),
                                )),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "NO",
                                  style: TextStyle(color: Colors.red),
                                ))
                          ],
                        );
                      });
                }
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(color: Colors.cyan),
              child: Row(
                children: [
                  Text(
                    "Email : ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.white,
                      initialValue: email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter email',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Update the email value in the widget
                        setState(() {
                          email = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        // Save the updated email value to Firestore
                        updateEmailInFirestore(
                            'email', widget.empId, value.trim(), context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(color: Colors.cyan),
              child: Row(
                children: [
                  Text(
                    "Ph. Number : ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.number,
                      initialValue: phNumber,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter phone number',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Update the phNumber value in the widget
                        setState(() {
                          phNumber = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        // Save the updated phNumber value to Firestore
                        updateEmailInFirestore(
                            'phNumber', widget.empId, value.trim(), context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(color: Colors.cyan),
              child: Row(
                children: [
                  Text(
                    "Role : ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.white,
                      initialValue: role,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter designation',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Update the email value in the widget
                        setState(() {
                          role = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        // Save the updated email value to Firestore
                        updateEmailInFirestore(
                            'role', widget.empId, value.trim(), context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(color: Colors.cyan),
              child: Row(
                children: [
                  Text(
                    "Salary : ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.white,
                      initialValue: salary.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter salary',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Update the email value in the widget
                        setState(() {
                          salary = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        // Save the updated email value to Firestore
                        updateIntegerInFirestore(
                            widget.empId, 'salary', int.parse(value), context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            AttendanceCalendar(empId: widget.empId)
          ],
        ),
      ),
    ));
  }
}
