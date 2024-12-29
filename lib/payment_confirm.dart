// ignore_for_file:  must_be_immutable, camel_case_types, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/services.dart';
import 'package:treasure_game/payment.dart';
import 'package:treasure_game/signup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'utils.dart';

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
      this.paymentmethod = '',
      super.key});

  @override
  State<payment_confirm> createState() => _payment_confirmState();
}

class _payment_confirmState extends State<payment_confirm> {
  final TextEditingController _idController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String idLable = 'Transaction ID';
  MaterialColor borderColorId = Colors.amber;
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

    if (snapshot.exists) {
      players = int.parse(snapshot['players']);
    } else {
      players = 0; // Or throw an exception if the document doesn't exist
    }

    return players;
  }

  Future<bool> sendData(String id, String name, String userid, String phone,
      String paymentMethod, String transactionId) async {
    try {
      int players = await getPlayers();
      WriteBatch batch = _firestore.batch();
      DocumentReference gameData =
          _firestore.collection('MainGameData').doc('gamedata');
      DocumentReference usersData =
          _firestore.collection('MainUsersData').doc(id);

      batch.update(gameData, {
        'players': (players + 1).toString(),
      });
      batch.set(usersData, {
        'name': name,
        'userid': userid,
        'phone': phone,
        'paymentmethod': paymentMethod,
        'transactionid': transactionId,
        'gamepass': id,
        'textIndex': 0,
        'taskscompleted': '0',
        'islost': false,
        'enable': false,
        'payment': false,
        'paymenterror': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      // await _firestore.collection('MainUsersData').doc(id).set({
      //   'name': name,
      //   'userid': userid,
      //   'phone': phone,
      //   'paymentmethod': paymentMethod,
      //   'transactionid': transactionId,
      //   'gamepass': id,
      //   'taskscompleted': '0',
      //   'enable': false,
      //   'payment': false,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });
      // await _firestore.collection('MainGameData').doc('gamedata').update({
      //   'name': name,
      // });
      print('User added successfully with ID: $id');
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
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
                            MaterialPageRoute(builder: (context) => payment()),
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
                          "Payment",
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
                                  color: Colors.amber,
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
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter your transaction ID",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: width - 60,
                      child: Formfield(
                        onTap: () {
                          setState(() {
                            idLable = 'Transaction ID';
                            borderColorId = Colors.amber;
                          });
                        },
                        controller: _idController,
                        hintText: "Transaction ID",
                        lable: idLable,
                        borderColor: borderColorId,
                        radius: 10,
                        lableStyle:
                            TextStyle(fontSize: 15, color: Colors.white),
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: width - 60,
                child: Text(
                  'Note : Make sure to enter the correct transaction ID otherwise your payment might get lost.',
                  style: TextStyle(
                      fontSize: 11, color: Color.fromARGB(176, 171, 171, 171)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: SizedBox(
                  // width: width - 15,
                  child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        "assets/imgs/${widget.paymentmethod}_slip.jpeg",
                        height: height / 2.1,
                      )),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
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
                          bool clear = false;
                          if (_idController.text == '') {
                            setState(() {
                              idLable = 'Enter your Transaction ID';
                              borderColorId = Colors.red;
                            });
                          } else {
                            transactionId = _idController.text;
                            setState(() {
                              _isLoading = true;
                            });
                            bool send = await sendData(
                                widget.pass,
                                widget.name,
                                widget.username,
                                widget.phone,
                                widget.paymentmethod,
                                transactionId);
                            setState(() {
                              _isLoading = false;
                            });
                            if (!send) {
                              final snackBar = SnackBar(
                                content:
                                    Text('An error occured. Please try again.'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 10,
                                        top: 20,
                                        left: 25,
                                        right: 25),
                                    title: Text(
                                      'Payment',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.yellow,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 0, 32),
                                    content: Container(
                                      color:
                                          const Color.fromARGB(255, 0, 0, 32),
                                      width: (width - 30),
                                      height: 120,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: (width / 5) * 3,
                                            child: Text(
                                                "We appreciate your interest! Your GamePass code is ${widget.pass}. It will be ready for use after payment verification, which usually takes 12 to 24 hours.",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: widget.pass));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'GamePass copied to clipboard!'),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Copy GamePass',
                                          style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MyHomePage()),
                                          );
                                        },
                                        child: const Text(
                                          'Ok',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 18,
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
