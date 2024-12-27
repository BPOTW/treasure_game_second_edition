// ignore_for_file:  must_be_immutable, camel_case_types, unused_local_variable

import 'dart:math';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment.dart';
import 'utils.dart';

class sign_up extends StatefulWidget {
  const sign_up({super.key});

  @override
  State<sign_up> createState() => _sign_upState();
}

class _sign_upState extends State<sign_up> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String gamepassId = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String name = '';
  String username = '';
  String phone = '';

  // String usernameError = 'Phone';
  // String phoneError = 'Phone';

  String phoneLable = 'Phone';
  Color borderColorPhone = Colors.amber;
  String nameLable = 'Name';
  Color borderColorName = Colors.amber;
  String useridLable = 'User Name';
  Color borderColorUserid = Colors.amber;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // getID();
    // checkID("AADX221902");
    // InternetUtils.initialize(context);
  }

  Future<void> getID() async {
    String uniqueId;
    bool exists;
    _isLoading = true;
    do {
      uniqueId = generateUniqueId();
      exists = await checkID(uniqueId);
    } while (exists);
    setState(() {
      gamepassId = uniqueId;
      print(gamepassId);
    });
    _isLoading = false;
  }

  String generateUniqueId() {
    const String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    Random random = Random();

    String randomLetters =
        List.generate(5, (index) => letters[random.nextInt(letters.length)])
            .join();
    String randomNumbers =
        List.generate(5, (index) => numbers[random.nextInt(numbers.length)])
            .join();
    String id = randomLetters + randomNumbers;

    return id;
  }

  Future<bool> checkID(String id) async {
    bool value = false;
    _isLoading = true;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(id)
        .get();
    if (documentSnapshot.exists) {
      value = true;
    } else {
      value = false;
    }
    _isLoading = false;
    return value;
  }

  Future<bool> checkKey(String key, String value) async {
    print('Checking $value in $key');
    QuerySnapshot querySnapshot = await _firestore
        .collection('MainUsersData')
        .where(key, isEqualTo: value)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    // InternetUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: Stack(children: [
        SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, left: 15),
                    child: InkWell(
                        onTapUp: (details) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 25,
                          color: Colors.white,
                        )),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 35.0, left: width - width / 1.29),
                    child: Column(
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 75,
                  )
                ],
              ),
              SizedBox(
                width: (width / 4) * 3,
                height: height / 1.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Formfield(
                      controller: _nameController,
                      borderColor: borderColorName,
                      onTap: () {
                        setState(() {
                          nameLable = 'Name';
                          borderColorName = Colors.amber;
                        });
                      },
                      radius: 10,
                      hintText: "Enter your name",
                      lable: nameLable,
                      lableStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16.0),
                    Formfield(
                      controller: _userNameController,
                      borderColor: borderColorUserid,
                      onTap: () {
                        setState(() {
                          useridLable = 'User Name';
                          borderColorUserid = Colors.amber;
                        });
                      },
                      radius: 10,
                      hintText: "Select your username",
                      lable: useridLable,
                      lableStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16.0),
                    //ToDo - change keyboard type to number
                    Formfield(
                      borderColor: borderColorPhone,
                      onTap: () {
                        setState(() {
                          phoneLable = 'Phone';
                          borderColorPhone = Colors.amber;
                        });
                      },
                      radius: 10,
                      controller: _phoneController,
                      hintText: "Enter your phone no.",
                      lable: phoneLable,
                      lableStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: (width / 4) * 3,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius here
                            ),
                            elevation: 5, // Optional: Adjust the elevation
                            backgroundColor: Color.fromARGB(255, 226, 194, 12)),
                        onPressed: () async {
                          // bool internet =
                          //     await InternetUtils.isInternetAvailable(context);
                          if (true) {
                            bool isNameClear = false;
                            bool isUsenamerClear = false;
                            bool isPhoneClear = false;
                            _isLoading = true;
                            if (_nameController.text == '') {
                              setState(() {
                                nameLable = 'Name cannot be empty.';
                                borderColorName = Colors.red;
                                isNameClear = false;
                              });
                            } else {
                              name = _nameController.text;
                              isNameClear = true;
                            }
                            if (_userNameController.text == '') {
                              setState(() {
                                useridLable = 'User name cannot be empty.';
                                borderColorUserid = Colors.red;
                                isUsenamerClear = false;
                              });
                            } else {
                              username = _userNameController.text;
                              bool checkId = await checkKey('userid', username);
                              if (checkId) {
                                setState(() {
                                  _userNameController.text = '';
                                  useridLable = 'User name already used.';
                                  borderColorUserid = Colors.red;
                                  isUsenamerClear = false;
                                });
                              } else {
                                setState(() {
                                  borderColorUserid = Colors.amber;
                                  isUsenamerClear = true;
                                });
                              }
                            }
                            if (_phoneController.text == '') {
                              setState(() {
                                phoneLable = 'Phone cannot be empty.';
                                borderColorPhone = Colors.red;
                                isPhoneClear = false;
                              });
                            } else {
                              phone = _phoneController.text;
                              bool checkPh = await checkKey('phone', phone);
                              if (checkPh) {
                                setState(() {
                                  _phoneController.text = '';
                                  phoneLable = 'Phone No. already used.';
                                  borderColorPhone = Colors.red;
                                  isPhoneClear = false;
                                });
                              } else {
                                setState(() {
                                  borderColorUserid = Colors.amber;
                                  isPhoneClear = true;
                                });
                              }
                            }
                            _isLoading = false;
                            if (isNameClear &&
                                isUsenamerClear &&
                                isPhoneClear) {
                              await getID();
                              // print(getID());
                              // print('Ok');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => payment(
                                          name: name,
                                          username: username,
                                          phone: phone,
                                          pass: gamepassId,
                                        )),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _isLoading
            ? Container(
                color: Colors.black
                    .withOpacity(0.5), // Semi-transparent background
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ]),
    );
  }
}

class Formfield extends StatelessWidget {
  final String lable;
  double radius = 20;
  double radiusFocus = 6;
  Color borderColor = Colors.amber;
  Color borderColorfocus = Colors.amber;
  Color hintColor = Colors.white;
  Color labelColor = Colors.white;
  Color textColor = Colors.white;
  void Function()? onTap = () {};
  String? Function(String?)? validator = (p0) {
    return '';
  };
  TextCapitalization capitalText = TextCapitalization.none;
  TextStyle lableStyle = const TextStyle();
  TextStyle hintStyle = const TextStyle();
  TextStyle textStyle = const TextStyle();
  final String hintText;
  final TextEditingController controller;
  Formfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.lable,
      this.validator,
      this.onTap,
      this.radiusFocus = 6,
      this.capitalText = TextCapitalization.none,
      this.radius = 20,
      this.hintStyle = const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
      this.textStyle = const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
      this.lableStyle = const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
      this.borderColor = Colors.amber,
      this.borderColorfocus = Colors.amber,
      this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      onTap: onTap,
      controller: controller,
      style: textStyle,
      textCapitalization: capitalText,
      // textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(radius)),
        labelText: lable,
        hintText: hintText,
        labelStyle: lableStyle,
        hintStyle: hintStyle,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: borderColorfocus), // Set the focus color here
          borderRadius: BorderRadius.circular(radiusFocus),
        ),
        contentPadding: const EdgeInsets.only(top: 7, bottom: 1, left: 21),
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
        //   // borderSide:
        //   //     const BorderSide(width: 5, color: Colors.white)
        // ),
      ),
    );
  }
}
