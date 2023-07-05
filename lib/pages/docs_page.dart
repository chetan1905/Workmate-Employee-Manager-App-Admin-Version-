// ignore_for_file: use_build_context_synchronously

import 'package:attendance_manager_admin/chatapp/helper_functions.dart';
import 'package:attendance_manager_admin/pages/pdf_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DocsPage extends StatefulWidget {
  final String employeeID;
  const DocsPage({super.key, required this.employeeID});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  Future<Map<String, String>> fetchDocumentUrls(String employeeId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('Employee')
            .doc(employeeId)
            .collection('docs')
            .doc('Profile Data')
            .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      final aadharImageUrl = data?['aadharImageUrl'] as String? ?? '';
      final profileImageUrl = data?['profileImageUrl'] as String? ?? '';
      final panImageUrl = data?['panImageUrl'] as String? ?? '';
      final pdfUrl = data?['pdfUrl'] as String? ?? '';

      return {
        'aadharImageUrl': aadharImageUrl,
        'profileImageUrl': profileImageUrl,
        'panImageUrl': panImageUrl,
        'pdfUrl': pdfUrl,
      };
    }

    return {
      'aadharImageUrl': '',
      'profileImageUrl': '',
      'panImageUrl': '',
      'pdfUrl': '',
    };
  }

  late Map<String, String> documentUrls;
  String? aadharImageUrl;
  String? panImageUrl;
  String? pdfUrl;

  @override
  void initState() {
    super.initState();
    fetchDocumentUrls(widget.employeeID);
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
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "DOCUMENTS",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.cyan, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    const Text("Aadhar Card",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () async {
                        documentUrls =
                            await fetchDocumentUrls(widget.employeeID);

                        setState(() {
                          aadharImageUrl = documentUrls['aadharImageUrl'];
                        });

                        if (aadharImageUrl == '' ||
                            aadharImageUrl ==
                                'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png') {
                          showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                    title: Text(
                                      "Notice !!",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content: Text(
                                      "No image available",
                                      style: TextStyle(color: Colors.cyan),
                                    ),
                                  ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 100, horizontal: 20),
                                    child: Image.network(
                                        aadharImageUrl.toString()),
                                  ));
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 60,
                        margin: const EdgeInsets.only(left: 120),
                        decoration: BoxDecoration(
                            color: Colors.cyan,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text(
                          "VIEW",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.cyan, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    const Text("Pan Card",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () async {
                        documentUrls =
                            await fetchDocumentUrls(widget.employeeID);
                        setState(() {
                          panImageUrl = documentUrls['panImageUrl'];
                        });

                        if (panImageUrl == '' ||
                            panImageUrl ==
                                'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png') {
                          showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                    title: Text(
                                      "Notice !!",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content: Text(
                                      "No image available",
                                      style: TextStyle(color: Colors.cyan),
                                    ),
                                  ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 100, horizontal: 20),
                                    child:
                                        Image.network(panImageUrl.toString()),
                                  ));
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 60,
                        margin: const EdgeInsets.only(left: 155),
                        decoration: BoxDecoration(
                            color: Colors.cyan,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text(
                          "VIEW",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.cyan, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    const Text("Resume",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () async {
                        documentUrls =
                            await fetchDocumentUrls(widget.employeeID);
                        setState(() {
                          pdfUrl = documentUrls['pdfUrl'];
                        });

                        if (pdfUrl == '' ||
                            pdfUrl ==
                                'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png') {
                          showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                    title: Text(
                                      "Notice !!",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content: Text(
                                      "No pdf available",
                                      style: TextStyle(color: Colors.cyan),
                                    ),
                                  ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PdfPage(pdfUrl: pdfUrl)));
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 60,
                        margin: const EdgeInsets.only(left: 165),
                        decoration: BoxDecoration(
                            color: Colors.cyan,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Text(
                          "VIEW",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
