// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateEmp extends StatefulWidget {
  const CreateEmp({super.key});

  @override
  State<CreateEmp> createState() => _CreateEmpState();
}

class _CreateEmpState extends State<CreateEmp> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final numberController = TextEditingController();
  final roleController = TextEditingController();
  final salaryController = TextEditingController();

  void signUserUp() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        numberController.text.isNotEmpty &&
        roleController.text.isNotEmpty &&
        salaryController.text.isNotEmpty) {
      //show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      // try sign-in
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);

        wrongErrorMessage(e.code);
      }

      addData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.cyan,
          content: Text(
            "Kindly fill all the details",
            style: TextStyle(color: Colors.white),
          )));
    }
  }

  void wrongErrorMessage(String error) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text(error)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: HelperFunctions().secondaryColor,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            centerTitle: true,
            elevation: 0.0,
            title: Text(
              "ADD EMPLOYEE",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    label: Text("Name...",
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 18,
                            fontStyle: FontStyle.italic)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 2)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      label: Text("Email...",
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontStyle: FontStyle.italic)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      label: Text("Password...",
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontStyle: FontStyle.italic)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      label: Text("Phone Number...",
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontStyle: FontStyle.italic)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                      label: Text("Designation...",
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontStyle: FontStyle.italic)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: salaryController,
                  decoration: InputDecoration(
                      label: Text("Salary...",
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontStyle: FontStyle.italic)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  signUserUp();
                },
                child: Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(
                    "ADD",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              )
            ],
          )),
    );
  }

  void addData() async {
    await FirebaseFirestore.instance.collection("Employee").doc().set({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'phNumber': numberController.text.trim(),
      'role': roleController.text.trim(),
      'salary': int.parse(salaryController.text.trim())
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.cyan,
          content: Text(
            "Employee added successfully!",
            style: TextStyle(color: Colors.white),
          )));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CreateEmp()));
    });
  }
}
