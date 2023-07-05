// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:attendance_manager_admin/data/users.dart';
import 'package:attendance_manager_admin/pages/create_page.dart';
import 'package:attendance_manager_admin/pages/emp_profiles.dart';
import 'package:attendance_manager_admin/pages/login_page.dart';
import 'package:attendance_manager_admin/widgets/custom_field.dart';
import 'package:attendance_manager_admin/widgets/my_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final taskController = TextEditingController();
  late SharedPreferences sharedPreferences;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _employeeCollection =
      FirebaseFirestore.instance.collection('Employee');

  Future<void> signOut() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear().then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  String getFirstChars(String input) {
    List<String> words = input.split(" ");
    String firstChars = "";
    for (int i = 0; i < words.length; i++) {
      String firstChar = words[i][0];
      firstChars += firstChar;
    }
    return firstChars;
  }

  List<String> employeeId = [];

  Future<List<String>> fetchEmployeeIds() async {
    QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<String> employeeIds = [];

    employeeSnapshot.docs.forEach((doc) {
      employeeIds.add(doc.id);
    });

    employeeId = employeeIds;

    return employeeIds;
  }

  String getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkIn = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOut = DateFormat('hh:mm:ss a').parse(checkOutTime);

    Duration duration = checkOut.difference(checkIn);

    int hours = duration.inMinutes ~/ 60;
    int minutes = (duration.inMinutes % 60).toInt();
    String formattedDuration = sprintf("%d Hrs:%02d Min", [hours, minutes]);
    return formattedDuration;
  }

  Future<void> updateAssignedTask(
      String employeeId, String assignedTask) async {
    // Get a reference to the Firestore document for the employee
    final employeeRef =
        FirebaseFirestore.instance.collection('Employee').doc(employeeId);

    // Get the current date in the format of the Firestore document name
    final currentDate = DateFormat("dd MMMM yyyy").format(DateTime.now());

    // Get a reference to the Firestore document for the current date of the employee
    final recordRef = employeeRef.collection('Records').doc(currentDate);

    // Retrieve the updated record data
    final snapshot = await recordRef.get();
    final recordData = snapshot.data();

    if (recordData == null) {
      // If the field is not available, show a dialog box saying the employee has not checked in yet
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          titleTextStyle: TextStyle(color: Colors.cyan, fontSize: 24),
          title: Text("Can not assign task yet!"),
          content: Text("The employee has not checked in yet today."),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.cyan, fontSize: 24),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      // Update the assignedTask field with the new value
      await recordRef.update({'assignedtask': assignedTask});
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    fetchEmployeeIds();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: HelperFunctions().secondaryColor,
          key: _scaffoldKey,
          appBar: AppBar(
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Center(
                child: Row(
                  children: [
                    Text(
                      "Welcome!",
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                    SizedBox(width: 8),
                    Text(
                      Users.adminName,
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.cyan,
            elevation: 0.0,
            actions: [
              IconButton(
                  onPressed: () {
                    _openDrawer();
                  },
                  icon: Icon(
                    Icons.menu,
                    size: 32,
                    color: Colors.white,
                  ))
            ],
          ),
          endDrawer: Drawer(
            backgroundColor: HelperFunctions().secondaryColor,
            elevation: 0.0,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                    ),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          Users.adminName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontStyle: FontStyle.italic),
                        ))),
                ListTile(
                  leading: Icon(
                    Icons.person_2,
                    color: Colors.cyan,
                  ),
                  title: Text('ADD EMPLOYEE',
                      style: TextStyle(
                          color: Colors.cyan, fontStyle: FontStyle.italic)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateEmp()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.cyan),
                  title: Text('LOGOUT',
                      style: TextStyle(
                          color: Colors.cyan, fontStyle: FontStyle.italic)),
                  onTap: () {
                    signOut();
                  },
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    "Today : ${DateFormat("dd MMMM, yyyy").format(DateTime.now())}",
                    style: TextStyle(color: Colors.cyan, fontSize: 22),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: 640,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _employeeCollection.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Colors.cyan,
                          ));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot employeeDoc =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> employeeData =
                                employeeDoc.data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return FutureBuilder<List<String>>(
                                      future: fetchEmployeeIds(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            final employeeIds = snapshot.data!;
                                            final employeeID =
                                                employeeIds[index];
                                            final name = employeeData['name'];
                                            return MyCalendarWidget(
                                                employeeID: employeeID,
                                                name: name);
                                          } else {
                                            return Center(
                                                child: Text(
                                                    "No employees found."));
                                          }
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  }),
                                );
                              },
                              child: Slidable(
                                endActionPane: ActionPane(
                                    motion: StretchMotion(),
                                    children: [
                                      SlidableAction(
                                          onPressed: (context) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return FutureBuilder<
                                                      List<String>>(
                                                    future: fetchEmployeeIds(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        if (snapshot.hasData) {
                                                          final employeeIds =
                                                              snapshot.data!;
                                                          final employeeID =
                                                              employeeIds[
                                                                  index];
                                                          final name =
                                                              employeeData[
                                                                  'name'];
                                                          return AlertDialog(
                                                            title: Text(
                                                              "Assign task to $name",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .cyan),
                                                            ),
                                                            content: CustomField(
                                                                controller:
                                                                    taskController,
                                                                labelText: null,
                                                                suffixIcon:
                                                                    null,
                                                                obscureText:
                                                                    false),
                                                            actionsPadding:
                                                                EdgeInsets.only(
                                                                    right: 10,
                                                                    bottom: 10),
                                                            actions: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  updateAssignedTask(
                                                                      employeeID,
                                                                      taskController
                                                                          .text
                                                                          .trim());
                                                                  taskController
                                                                      .clear();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "OK",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .cyan,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        } else {
                                                          return Center(
                                                              child: Text(
                                                                  "No employees found."));
                                                        }
                                                      } else {
                                                        return Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      }
                                                    },
                                                  );
                                                });
                                          },
                                          label: "Assign Task",
                                          icon: Icons.chat,
                                          foregroundColor: Colors.cyan,
                                          backgroundColor: Colors.transparent)
                                    ]),
                                child: Card(
                                  color: Colors.cyan,
                                  elevation: 0.0,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: SizedBox(
                                    height: 90,
                                    child: ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmpProfiles(
                                                        empName: employeeData[
                                                            'name'],
                                                        email: employeeData[
                                                            'email'],
                                                        phNumber: employeeData[
                                                            'phNumber'],
                                                        role: employeeData[
                                                            'role'],
                                                        salary: employeeData[
                                                            'salary'],
                                                        empId:
                                                            employeeId[index],
                                                      )));
                                        },
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.cyan.shade300,
                                          child: Text(
                                            getFirstChars(employeeData['name'])
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        employeeData['name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('Employee')
                                            .doc(employeeDoc.id)
                                            .collection('Records')
                                            .orderBy('date', descending: true)
                                            .limit(1)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                recordsSnapshot) {
                                          if (recordsSnapshot.hasError) {
                                            return Text(
                                                'Error fetching records');
                                          }

                                          if (recordsSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Loading records');
                                          }

                                          if (recordsSnapshot.data == null ||
                                              recordsSnapshot
                                                  .data!.docs.isEmpty) {
                                            return Text(
                                              'Did not check in yet!',
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            );
                                          }

                                          Map<String, dynamic> recordDoc =
                                              recordsSnapshot.data!.docs[0]
                                                      .data()
                                                  as Map<String, dynamic>;

                                          int seconds =
                                              recordDoc['date'].seconds;
                                          int nanoseconds =
                                              recordDoc['date'].nanoseconds;
                                          String milliseconds =
                                              (seconds * 1000 +
                                                      nanoseconds ~/ 1000000)
                                                  .toString();
                                          DateTime timeStamp = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(milliseconds));

                                          String dateStr =
                                              DateFormat('dd MMMM yyyy')
                                                  .format(timeStamp);

                                          if (dateStr !=
                                              DateFormat('dd MMMM yyyy')
                                                  .format(DateTime.now())) {
                                            return Text(
                                              'Did not check in yet!',
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            );
                                          }

                                          getHoursWorked(recordDoc['checkIn'],
                                              recordDoc['checkOut']);

                                          final checkInTime =
                                              DateFormat('hh:mm:ss a')
                                                  .parse(recordDoc['checkIn']);
                                          final onTime =
                                              DateFormat('hh:mm:ss a')
                                                  .parse('10:00:00 AM');

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Check-In : ',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Text(
                                                        '${recordDoc['checkIn']}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Check-Out : ',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Text(
                                                        '${recordDoc['checkOut']}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Worked For : ',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      recordDoc['checkOut'] ==
                                                              '00:00:00 AM'
                                                          ? Text(
                                                              '0 Hrs:0 Min',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                            )
                                                          : Text(
                                                              getHoursWorked(
                                                                  recordDoc[
                                                                      'checkIn'],
                                                                  recordDoc[
                                                                      'checkOut']),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                            ),
                                                    ],
                                                  ),
                                                  if (checkInTime
                                                          .isBefore(onTime) ||
                                                      checkInTime == onTime)
                                                    Text(
                                                      "Checked-In on time",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[700]),
                                                    )
                                                  else
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Delayed by : ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          getHoursWorked(
                                                              '10:00:00 AM',
                                                              recordDoc[
                                                                  'checkIn']),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700]),
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  if (recordDoc['wfo'] == true)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Status : ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          'W.F.O',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700]),
                                                        ),
                                                      ],
                                                    )
                                                  else if (recordDoc['wfh'] ==
                                                      true)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Status : ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text('W.F.H',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey[
                                                                        700])),
                                                      ],
                                                    )
                                                  else
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Status : ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text("NULL",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey[
                                                                        700])),
                                                      ],
                                                    ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  titleTextStyle: TextStyle(
                                                                      color: Colors
                                                                          .cyan,
                                                                      fontSize:
                                                                          18),
                                                                  title: Text(
                                                                      employeeData[
                                                                          'name']),
                                                                  contentTextStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.grey[700]),
                                                                  content:
                                                                      SizedBox(
                                                                    height: 200,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            "Checked-In at : ${recordDoc['myLocation']}"),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        recordDoc['agenda'] ==
                                                                                ""
                                                                            ? Text('Task : No Task Entered For Today!')
                                                                            : Text("Task : ${recordDoc['agenda']}")
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 15),
                                                          height: 30,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white30,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 2)),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text("MORE",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_right,
                                                        size: 32,
                                                        color: Colors.white,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
