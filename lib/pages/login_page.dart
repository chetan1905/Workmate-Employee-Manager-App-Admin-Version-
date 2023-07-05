// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:attendance_manager_admin/data/users.dart';
import 'package:attendance_manager_admin/pages/admin_pages.dart';
import 'package:attendance_manager_admin/widgets/custom_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WORKMATE",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "For ADMINS",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Keep a tab on your employees...",
              style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[400]),
            ),
            Image.asset("assets/login.jpg"),
            CustomField(
              controller: emailController,
              obscureText: false,
              suffixIcon: Icon(Icons.email),
              labelText: "Email",
            ),
            SizedBox(
              height: 10,
            ),
            CustomField(
                controller: passwordController,
                labelText: "Password",
                suffixIcon: Icon(Icons.lock),
                obscureText: true),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter your email.")));
                } else if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter your password.")));
                } else {
                  QuerySnapshot snap = await FirebaseFirestore.instance
                      .collection("Admin")
                      .where("email", isEqualTo: email)
                      .get();

                  Users.adminName = snap.docs[0][
                      'name']; // saves the name of current user to Users.adminName

                  try {
                    if (password == snap.docs[0]['password']) {
                      sharedPreferences = await SharedPreferences.getInstance();

                      sharedPreferences.setString(
                          "adminName",
                          Users
                              .adminName); // storing the Users.empName to sharedpreferences in empName.
                      sharedPreferences
                          .setString("adminEmail", email)
                          .then((_) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminPages()));
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Password is incorrect.")));
                    }
                  } catch (e) {
                    String error = " ";

                    if (e.toString() ==
                        "RangeError (index): Invalid value: Valid value range is empty: 0") {
                      setState(() {
                        error = "Employee id does not exist";
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      setState(() {
                        error = "An error has occured";
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    }
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 60),
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.cyan, width: 2)),
                alignment: Alignment.center,
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
