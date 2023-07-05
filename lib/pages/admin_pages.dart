// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:attendance_manager_admin/chatapp/chat_login_status.dart';
import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:attendance_manager_admin/data/users.dart';
import 'package:attendance_manager_admin/pages/home_page.dart';
import 'package:attendance_manager_admin/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPages extends StatefulWidget {
  const AdminPages({super.key});

  @override
  State<AdminPages> createState() => _AdminPagesState();
}

class _AdminPagesState extends State<AdminPages> {
  int currentIndex = 0;

  List<IconData> navigationIcons = [Icons.home, Icons.group_add, Icons.person];

  List navigationTitles = ["Home", "Groups", "Profile"];

  void getDocId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Admin")
        .where('name', isEqualTo: Users.adminName)
        .get();

    setState(() {
      Users.docID = snap.docs[0].id;
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    getDocId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelperFunctions().secondaryColor,
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(),
          ChatLoginStatus(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15, right: 20, left: 20),
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = i;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  width: 50,
                  color: Colors.cyan,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navigationIcons[i],
                        color:
                            i == currentIndex ? Colors.white : Colors.grey[300],
                        size: i == currentIndex ? 30 : 24,
                      ),
                      Text(
                        navigationTitles[i],
                        style: TextStyle(
                          color: i == currentIndex
                              ? Colors.white
                              : Colors.grey[300],
                          fontSize: i == currentIndex ? 17 : 14,
                        ),
                      )
                    ],
                  ),
                ),
              ))
            }
          ],
        ),
      ),
    );
  }
}
