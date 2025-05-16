// ignore_for_file:  must_be_immutable, camel_case_types, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/services.dart';
import 'package:treasure_game/payment.dart';
// import 'package:treasure_game/signup.dart'; // Not directly needed if Formfield is self-contained or passed
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'utils.dart'; // Assuming Formfield from signup.dart is not used here, or this page has its own.
// If utils.dart contains a shared Formfield, ensure it's the one being used.

class payment_confirm extends StatefulWidget {
  final String name;
  final String username;
  final String phone;
  final String pass;
  final String paymentmethod;
  payment_confirm(
      {this.name = '',
      this.username = '',
      this.phone = '',
      this.pass = '',
      this.paymentmethod = '', // Corrected: added comma
      super.key});

  @override
  State<payment_confirm> createState() => _payment_confirmState();
}

class _payment_confirmState extends State<payment_confirm> {
  final TextEditingController _idController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String idLable = 'Transaction ID';
  // MaterialColor borderColorId = Colors.amber; // This can be managed by Formfield directly
  Color borderColorId =
      Colors.amber; // Changed to Color for consistency with Formfield

  String transactionId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // InternetUtils.initialize(context);
    // print(
    //     'Name : ${widget.name}, User Name : ${widget.username}, Phone : ${widget.phone}, GamePass : ${widget.pass}, Payment method : ${widget.paymentmethod}');
  }

  Future<int> getPlayers() async {
    int players = 0;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('MainGameData').doc('gamedata').get();

    if (snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!['players'] != null) {
      players = int.tryParse(snapshot.data()!['players'].toString()) ?? 0;
    } else {
      players = 0;
    }
    return players;
  }

  Future<bool> sendData(String id, String name, String userid, String phone,
      String paymentMethod, String transactionId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      int currentPlayers = await getPlayers();
      WriteBatch batch = _firestore.batch();
      DocumentReference gameDataRef = // Renamed for clarity
          _firestore.collection('MainGameData').doc('gamedata');
      DocumentReference userDataRef = // Renamed for clarity
          _firestore.collection('MainUsersData').doc(id);

      batch.update(gameDataRef, {
        'players': (currentPlayers + 1).toString(),
      });
      batch.set(userDataRef, {
        'name': name,
        'userid': userid,
        'phone': phone,
        'paymentmethod': paymentMethod,
        'transactionid': transactionId,
        'gamepass': id,
        'textIndex': 1,
        'taskscompleted': '0',
        'islost': false,
        'enable': false,
        'payment': false,
        'paymenterror': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      print('User added successfully with ID: $id');
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      return true;
    } catch (e) {
      print('Error adding user: $e');
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      return false;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Widget _buildStepIndicator({required bool isActive}) {
    // Helper for step dots
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: isActive ? 35 : 10, // Active dot is wider
        height: 10,
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 1)
                ]
              : [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: Stack(children: [
        SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTapUp: (details) {
                          // Navigate back to payment selection, not signup directly unless intended
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => payment(
                                    name: widget.name,
                                    username: widget.username,
                                    phone: widget.phone,
                                    pass: widget.pass)),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.white,
                        )),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Confirm Payment", // Updated Title
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepIndicator(isActive: false),
                              _buildStepIndicator(isActive: false),
                              _buildStepIndicator(isActive: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40), // Placeholder for balance
                  ],
                ),
                SizedBox(
                  height: 30, // Increased spacing
                ),
                Text(
                  "Enter Transaction ID", // Clearer instruction
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15,
                ),
                // Assuming this page uses its own Formfield or one from utils.dart
                // If it's the signup.dart Formfield, it needs to be imported or passed.
                Formfield_confirm(
                  // Using a distinct name for clarity if it's a local version
                  onTap: () {
                    setState(() {
                      idLable = 'Transaction ID';
                      borderColorId = Colors.amber;
                    });
                  },
                  controller: _idController,
                  hintText: "E.g., 1234567890", // Example hint
                  lable: idLable,
                  borderColor: borderColorId,
                  prefixIcon: Icons.receipt_long_outlined, // Added icon
                  keyboardType: TextInputType.number, // Set keyboard type
                  radius: 10,
                  lableStyle: TextStyle(
                      fontSize: 15, color: Color.fromARGB(255, 220, 220, 220)),
                  hintStyle: TextStyle(
                      fontSize: 14, color: Color.fromARGB(255, 180, 180, 180)),
                  textStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Note: Double-check your Transaction ID. Incorrect IDs can cause delays or issues with verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 25), // Adjusted padding
                  child: Column(
                    children: [
                      Text(
                        "Example Slip (${widget.paymentmethod == 'jazzcash' ? 'JazzCash' : 'Easypaisa'}):",
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(8)),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(7), // Inner clip for image
                          child: Opacity(
                              opacity:
                                  0.9, // Increased opacity for better visibility
                              child: Image.asset(
                                "assets/imgs/${widget.paymentmethod}_slip.jpeg",
                                height: height / 2.5, // Adjusted height
                                fit: BoxFit
                                    .contain, // Ensure full image is visible
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                      height: height / 2.5,
                                      alignment: Alignment.center,
                                      child: Text('Error loading example slip.',
                                          style: TextStyle(
                                              color: Colors.redAccent)));
                                },
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded( // Removed Expanded here, SingleChildScrollView will handle height
                //   child: SizedBox(
                //     height: double.infinity, // This was causing issues with fixed height elements
                //   ),
                // ),
                SizedBox(height: 20), // Spacing before button
                SizedBox(
                  width: double.infinity, // Full width button
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            bool internet =
                                await InternetUtils.checkInternetConnection(
                                    context);
                            if (!internet) return;

                            if (_idController.text.trim().isEmpty) {
                              setState(() {
                                idLable = 'Transaction ID cannot be empty';
                                borderColorId = Colors.red;
                              });
                            } else {
                              transactionId = _idController.text.trim();
                              // setState(() { // Moved to sendData
                              //   _isLoading = true;
                              // });
                              bool send = await sendData(
                                  widget.pass,
                                  widget.name,
                                  widget.username,
                                  widget.phone,
                                  widget.paymentmethod,
                                  transactionId);
                              // setState(() { // Moved to sendData
                              //   _isLoading = false;
                              // });
                              if (!send) {
                                if (mounted) {
                                  final snackBar = SnackBar(
                                    content: Text(
                                        'An error occurred. Please try again.',
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.redAccent,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              } else {
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // User must interact with dialog
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: const Color.fromARGB(
                                            255,
                                            10,
                                            20,
                                            50), // Darker background
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        titlePadding: const EdgeInsets.only(
                                            top: 25, left: 25, right: 25),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 20),
                                        actionsPadding: const EdgeInsets.only(
                                            right: 15, bottom: 15, left: 15),
                                        title: Text(
                                          'Payment Submitted!', // Positive title
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                            "Thank you! Your GamePass code is ${widget.pass}. Activation may take 12-24 hours after payment verification.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                                height: 1.5,
                                                fontWeight: FontWeight.w400)),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: widget.pass));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'GamePass ${widget.pass} copied!',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    backgroundColor:
                                                        Colors.amber,
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                // Icon and text for copy button
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.copy_all_outlined,
                                                      color: Colors.amber,
                                                      size: 18),
                                                  SizedBox(width: 5),
                                                  Text('Copy Pass',
                                                      style: TextStyle(
                                                          color: Colors.amber,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              )),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.amber,
                                                foregroundColor: Color.fromARGB(
                                                    255, 0, 0, 32)),
                                            onPressed: () {
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                              // Navigator.pushReplacement( // Use pushReplacement to avoid stacking MyHomePage
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //           const MyHomePage()),
                                              // );
                                            },
                                            child: const Text(
                                              'Done',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            }
                          },
                    child: const Text(
                      'Confirm & Submit', // More descriptive text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600, // Bolder
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
        if (_isLoading) // Conditional loading overlay
          Container(
            color: Colors.black.withOpacity(0.6), // Slightly darker overlay
            child: const Center(
              // Centered indicator
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.amber), // Amber color
              ),
            ),
          ),
      ]),
    );
  }
}

// Custom Formfield for this page to avoid conflicts if signup.dart Formfield is different
// Or, ensure a shared Formfield from a common utility file is used across pages.
class Formfield_confirm extends StatelessWidget {
  final String lable;
  double radius = 10;
  double radiusFocus = 10;
  Color borderColor = Colors.amber;
  Color borderColorfocus = Colors.blueAccent;
  TextStyle lableStyle = const TextStyle();
  TextStyle hintStyle = const TextStyle();
  TextStyle textStyle = const TextStyle();
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  void Function()? onTap = () {};

  Formfield_confirm(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.lable,
      this.onTap,
      this.radiusFocus = 10,
      this.radius = 10,
      this.hintStyle = const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 180, 180, 180)),
      this.textStyle = const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
      this.lableStyle = const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 220, 220, 220)),
      this.borderColor = Colors.amber,
      this.borderColorfocus = Colors.blueAccent,
      this.prefixIcon,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      style: textStyle,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: borderColor.withOpacity(0.8), size: 20)
            : null,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(radius)),
        labelText: lable,
        hintText: hintText,
        labelStyle: lableStyle,
        hintStyle: hintStyle,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColorfocus, width: 2),
          borderRadius: BorderRadius.circular(radiusFocus),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(radiusFocus),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}
