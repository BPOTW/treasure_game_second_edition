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
    do {
      uniqueId = generateUniqueId();
      exists = await checkID(uniqueId);
    } while (exists);
    setState(() {
      gamepassId = uniqueId;
      print(gamepassId);
    });
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
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(id)
        .get();
    if (documentSnapshot.exists) {
      value = true;
    } else {
      value = false;
    }
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: Stack(children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: width,
              height: height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTapUp: (details) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyHomePage()),
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
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStepIndicator(isActive: true),
                                  _buildStepIndicator(isActive: false),
                                  _buildStepIndicator(isActive: false),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Formfield(
                          controller: _nameController,
                          borderColor: borderColorName,
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          onTap: () {
                            setState(() {
                              nameLable = 'Name';
                              borderColorName = Colors.amber;
                            });
                          },
                          radius: 10,
                          hintText: "Enter your full name",
                          lable: nameLable,
                          lableStyle: const TextStyle(
                              color: Color.fromARGB(255, 220, 220, 220),
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20.0),
                        Formfield(
                          controller: _userNameController,
                          borderColor: borderColorUserid,
                          prefixIcon: Icons.account_circle_outlined,
                          keyboardType: TextInputType.text,
                          onTap: () {
                            setState(() {
                              useridLable = 'User Name';
                              borderColorUserid = Colors.amber;
                            });
                          },
                          radius: 10,
                          hintText: "Choose a unique username",
                          lable: useridLable,
                          lableStyle: const TextStyle(
                              color: Color.fromARGB(255, 220, 220, 220),
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20.0),
                        Formfield(
                          borderColor: borderColorPhone,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onTap: () {
                            setState(() {
                              phoneLable = 'Phone';
                              borderColorPhone = Colors.amber;
                            });
                          },
                          radius: 10,
                          controller: _phoneController,
                          hintText: "Enter your phone number",
                          lable: phoneLable,
                          lableStyle: const TextStyle(
                              color: Color.fromARGB(255, 220, 220, 220),
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30.0),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                backgroundColor: Colors.amber,
                                foregroundColor:
                                    const Color.fromARGB(255, 0, 0, 32)),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    bool internet = await InternetUtils
                                        .checkInternetConnection(context);
                                    if (!internet) {
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    bool isNameClear = false;
                                    bool isUsenamerClear = false;
                                    bool isPhoneClear = false;

                                    if (_nameController.text.trim().isEmpty) {
                                      setState(() {
                                        nameLable = 'Name cannot be empty.';
                                        borderColorName = Colors.red;
                                      });
                                    } else {
                                      name = _nameController.text.trim();
                                      setState(() {
                                        borderColorName = Colors.amber;
                                      });
                                      isNameClear = true;
                                    }

                                    if (_userNameController.text
                                        .trim()
                                        .isEmpty) {
                                      setState(() {
                                        useridLable =
                                            'User name cannot be empty.';
                                        borderColorUserid = Colors.red;
                                      });
                                    } else {
                                      username =
                                          _userNameController.text.trim();
                                      bool checkId =
                                          await checkKey('userid', username);
                                      if (checkId) {
                                        setState(() {
                                          _userNameController.text = '';
                                          useridLable =
                                              'User name already used.';
                                          borderColorUserid = Colors.red;
                                        });
                                      } else {
                                        setState(() {
                                          borderColorUserid = Colors.amber;
                                          isUsenamerClear = true;
                                        });
                                      }
                                    }

                                    if (_phoneController.text.trim().isEmpty) {
                                      setState(() {
                                        phoneLable = 'Phone cannot be empty.';
                                        borderColorPhone = Colors.red;
                                      });
                                    } else if (!RegExp(r'^[0-9]{10,15}$')
                                        .hasMatch(
                                            _phoneController.text.trim())) {
                                      setState(() {
                                        phoneLable =
                                            'Enter a valid phone number.';
                                        borderColorPhone = Colors.red;
                                      });
                                    } else {
                                      phone = _phoneController.text.trim();
                                      bool checkPh =
                                          await checkKey('phone', phone);
                                      if (checkPh) {
                                        setState(() {
                                          _phoneController.text = '';
                                          phoneLable =
                                              'Phone No. already used.';
                                          borderColorPhone = Colors.red;
                                        });
                                      } else {
                                        setState(() {
                                          borderColorPhone = Colors.amber;
                                          isPhoneClear = true;
                                        });
                                      }
                                    }

                                    if (isNameClear &&
                                        isUsenamerClear &&
                                        isPhoneClear) {
                                      await getID();
                                      if (mounted) {
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
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.6),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildStepIndicator({required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: isActive ? 35 : 10,
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
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  Formfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.lable,
      this.validator,
      this.onTap,
      this.radiusFocus = 10,
      this.capitalText = TextCapitalization.none,
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
      this.textColor = Colors.white,
      this.prefixIcon,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      onTap: onTap,
      controller: controller,
      style: textStyle,
      textCapitalization: capitalText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: borderColor, size: 20)
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
