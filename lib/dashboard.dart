// ignore_for_file: camel_case_types, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:treasure_game/countdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:treasure_game/main.dart';
import 'utils.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'map.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class dashboard_app extends StatefulWidget {
  final String gamePass;
  final ans;
  final check;
  const dashboard_app(
      {this.gamePass = '', this.ans = '', this.check = false, super.key});

  @override
  State<dashboard_app> createState() => _dashboard_appState();
}

double offset = 0;

class _dashboard_appState extends State<dashboard_app>
    with SingleTickerProviderStateMixin {
  double imageheight = 0.0;
  double imageoffset = 0.0;
  double width = 0;
  double height = 0;

  Map gameData = {};
  Map continueEnableData = {};
  Map answers = {};
  Map qrEnableData = {};
  Map gameCompleted = {};

  List optionData = ['a', 'b', 'c'];
  List optionDatatwo = ['a', 'b', 'c'];

  String players = '';
  String tasks = '';
  String gamepass = '';
  String gameText = "Treasure Hunt now begins. Good luck!";
  String scanResult = '';
  String username = '';

  int textIndex = 1;
  int textIndexFire = 1;
  int totalIndex = 1;
  int tasksCompleted = 0;
  int optionRiddle = 0;

  bool continueEnable = false;
  bool qrEnable = false;
  bool dataLoaded = false;
  bool isKeyboardVisible = false;
  bool tutorial = false;
  bool showScanner = false;
  bool gameEnded = false;
  bool timeEnded = false;
  bool options = false;
  bool isLost = false;

  final GlobalKey _players = GlobalKey();
  final GlobalKey _task = GlobalKey();
  final GlobalKey _time = GlobalKey();
  final GlobalKey _continue = GlobalKey();
  final GlobalKey _qrcode = GlobalKey();

  Barcode? result = Barcode('', BarcodeFormat.qrcode, []);
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();

    // InternetUtils.initialize(context);
    FirebaseFirestore.instance
        .collection('MainGameData')
        .doc('gamedata')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> Data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          players = Data['players'];
          tasks = Data['tasks'];
          gameData = Data['data'];
          continueEnableData = Data['continueEnable'];
          qrEnableData = Data['qrEnable'];
          totalIndex = Data['totalIndex'];
          answers = Data['answers'];
          gameEnded = Data['gameEnded'];
          gameCompleted = Data['gamecompleted'];
          optionRiddle = Data['optionriddle'];
          optionData = (gameData['r${optionRiddle}OPt']).split('/');
          if (timeEnded) {
            dialogBox(
                width,
                'Dear player the time has ended. The winner will be announced soon.',
                100);
          }
          if (gameEnded && gameCompleted['id'] != widget.gamePass) {
            // gamecompleted(widget.gamePass);
            dialogBox(
                width,
                'Dear player the game has be ended. A player $username has completed the game.',
                100);
          }
          setState(() {
            print('object');
            dataLoaded = true;
            // gameText = gameData['r$textIndex'];
          });
        });
      } else {
        print("Data not exists");
      }
    });
    FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(widget.gamePass)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> Data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          textIndex = Data['textIndex'];
          tasksCompleted = Data['taskscompleted'];
          username = Data['userid'];
          isLost = Data['islost'];
          print('Have you lost $isLost');
          if (isLost) {
            dialogBox(width, 'Your answer is incorrect. You have lost.', 70);
          }
          if (textIndex == optionRiddle) {
            setState(() {
              options = true;
            });
          } else {
            setState(() {
              options = false;
            });
          }
          // gameText = gameData['r$textIndex'];
        });
      } else {
        print("Data not exists");
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkShowcase());
  }

  void dialogBox(double width, String text, double height) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(bottom: 10, top: 20, left: 25, right: 25),
          title: const Text(
            'Note',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 32),
          content: Container(
            color: const Color.fromARGB(0, 255, 255, 255),
            width: (width - 60),
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (width / 5) * 3,
                  child: Text(text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              child: const Text(
                'Ok',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  void checkAnswer(String answer) {
    print('Checking answer');
    print(answer);
    if (answer != '' && answer == answers['r$textIndex']) {
      print('Correct answer.');
      setState(() {
        options = false;
      });
      setTask();
      _updateText();
    } else {
      print('Wrong answer.');
      if (options) {
        // setLost();
        dialogBox(width, 'This is not the clue you are after.', 70);
      }
    }
    print(
        'My answer is $answer and correct answer is ${answers['r$textIndex']} text index is $textIndex');
  }

  Future<void> setLost() async {
    FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(widget.gamePass)
        .update({'islost': true})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> setindex(int index) async {
    FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(widget.gamePass)
        .update({'textIndex': index})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> setTask() async {
    FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(widget.gamePass)
        .update({'taskscompleted': (tasksCompleted + 1)})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  void _updateText() {
    setState(() {
      if (textIndex <= totalIndex) {
        setState(() {
          continueEnable = false;
          qrEnable = false;
          textIndex = (textIndex + 1);
        });
        setindex(textIndex);
        print(
            'Text index is $textIndex : Total index is $totalIndex : Continue enable is $continueEnable : Qr enable is $qrEnable');
      }
      if (textIndex == totalIndex) {
        setState(() {
          continueEnable = false;
          qrEnable = false;
        });
      }
    });
  }

  Future<void> _checkShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('showcaseShown', false);
    bool showcaseShown = prefs.getBool('showcaseShown') ?? false;
    if (!showcaseShown) {
      tutorial = showcaseShown;
      ShowCaseWidget.of(context)
          .startShowCase([_players, _task, _time, _continue, _qrcode]);
      prefs.setBool('showcaseShown', true);
    }
  }

  Future<void> gamecompleted(String id) async {
    await FirebaseFirestore.instance
        .collection('MainGameData')
        .doc('gamedata')
        .update({
          'gamecompleted': {'completed': true, 'id': id, 'user': username}
        })
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
    await FirebaseFirestore.instance
        .collection('MainGameData')
        .doc('gamedata')
        .update({'gameEnded': true})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
    await FirebaseFirestore.instance
        .collection('MainGameData')
        .doc('gamedata')
        .update({'joinEnable': false})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
    await FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(widget.gamePass)
        .update({'enable': false})
        .then((value) => print("Data Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width / 1.3);
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      cameraFacing: CameraFacing.back,
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.amber,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller!.stopCamera();
        showScanner = false;
        checkAnswer(result?.code ?? '');
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    print(optionData);
    if (keyboardHeight == 0) {
      setState(() {
        offset = 0;
      });
    } else {
      setState(() {
        offset = 250;
      });
    }
    setState(() {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    });

    double imageHeight =
        height < 670 ? (height / 4) * 3.09 : (height / 4) * 3.16;

    if (height < 700) {
      imageheight = (height / 4) * 3.4;
    } else {
      imageheight = (height / 4) * 3.4;
    }

    if (height < 700) {
      imageoffset = 1;
    } else {
      imageoffset = 1.23;
    }

    if (width < 380 && height > 800) {
      imageoffset = 3;
      imageheight = (height / 4) * 4;
    }

    return !showScanner
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromARGB(
                255, 0, 0, 9), //Original Color.fromARGB(255, 0, 1, 44),
            floatingActionButton: SizedBox(
              width: 60,
              height: 60,
              child: Visibility(
                visible: qrEnable,
                child: Showcase(
                  key: _qrcode,
                  description: 'Use to scan the hidden object.',
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        showScanner = true;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Color.fromARGB(0, 201, 151, 0),
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.qr_code,
                          color: Color.fromARGB(255, 97, 29, 0),
                          size: 40,
                        )),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "The Hunt Begins",
                        style: TextStyle(
                            fontSize: width / 14,
                            letterSpacing: 2,
                            fontFamily: 'BungeeSpice',
                            shadows: const [
                              Shadow(
                                  color: Color.fromARGB(255, 134, 134, 134),
                                  offset: Offset(3, 4),
                                  blurRadius: 9)
                            ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: (width),
                      height: 40,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Showcase(
                            key: _players,
                            description: 'Total players playing this game.',
                            child: SizedBox(
                              // width: 100,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.groups,
                                      size: 20,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Center(
                                      child: Text(
                                    players,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Showcase(
                            key: _task,
                            description: 'Total tasks',
                            child: SizedBox(
                              // width: 100,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.task,
                                      size: 20,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Center(
                                      child: Text(
                                    "${tasksCompleted.toString()}/$tasks",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Showcase(
                            key: _time,
                            description: 'Time remaining for game to end.',
                            child: SizedBox(
                              // width: 102,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.alarm,
                                      size: 20,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Center(
                                    child: CountdownTimer(
                                      documentId: 'game_remaining_time',
                                      textStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: const SizedBox(
                    height: 5,
                  ),
                ),
                Container(
                  // width: width-40,
                  height:
                      height < 700 ? (height / 4) * 3.16 : (height / 4) * 3.16,
                  color: const Color.fromARGB(0, 255, 193, 7),
                  child: Stack(alignment: Alignment.topCenter, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              const Color.fromARGB(255, 72, 35, 3)
                                  .withOpacity(0.5),
                              BlendMode.darken),
                          child: Transform.scale(
                              scaleY: height < 700 ? 1.2 : 1.27,
                              scaleX: 0.97,
                              child: Image.asset(
                                'assets/imgs/back_image.webp',
                                height: imageheight,
                              ))),
                    ),
                    Positioned(
                      left: 45,
                      right: 40,
                      top: 0,
                      bottom: 50,
                      child: dataLoaded
                          ? Container(
                              width: (width / 4) * 3,
                              color: Color.fromARGB(0, 0, 0, 0),
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromARGB(188, 57, 35, 2),
                                      Color.fromARGB(189, 67, 35, 1),
                                      Color.fromARGB(189, 77, 35, 2),
                                      Color.fromARGB(189, 87, 35, 1),
                                      Color.fromARGB(189, 97, 35, 2),
                                      Color.fromARGB(189, 107, 35, 1),
                                    ],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcIn,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      AnimatedSwitcher(
                                        duration: Duration(milliseconds: 700),
                                        transitionBuilder: (Widget child,
                                            Animation<double> animation) {
                                          return FadeTransition(
                                              opacity: animation, child: child);
                                        },
                                        child: SizedBox(
                                          key: ValueKey<int>(textIndex),
                                          width: (width / 4) * 3,
                                          child: AnimatedTextKit(
                                            animatedTexts: [
                                              TypewriterAnimatedText(
                                                textAlign: TextAlign.center,
                                                gameData['r$textIndex']
                                                    .toString()
                                                    .replaceAll('/', ''),
                                                textStyle: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    fontSize: width / 22,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                speed:
                                                    Duration(milliseconds: 70),
                                              ),
                                            ],
                                            repeatForever: false,
                                            isRepeatingAnimation: false,
                                            onFinished: () {
                                              if (true) {
                                                setState(() {
                                                  continueEnable =
                                                      continueEnableData[
                                                          'r$textIndex'];
                                                  // continueEnable = true;
                                                  qrEnable = qrEnableData[
                                                      'r$textIndex'];
                                                  if (textIndex == totalIndex) {
                                                    gamecompleted(
                                                        widget.gamePass);
                                                  }
                                                  if (textIndex ==
                                                      optionRiddle) {
                                                    setState(() {
                                                      options = true;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      options = false;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            )
                          : Container(),
                    ),
                    Positioned(
                      bottom: 100,
                      child: Visibility(
                          visible: options,
                          child: SizedBox(
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    checkAnswer((optionData[0]
                                            .toString()
                                            .replaceAll(' ', ''))
                                        .toLowerCase());
                                  },
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color.fromARGB(188, 57, 35, 2),
                                          Color.fromARGB(189, 67, 35, 1),
                                          Color.fromARGB(189, 77, 35, 2),
                                          Color.fromARGB(189, 87, 35, 1),
                                          Color.fromARGB(189, 97, 35, 2),
                                          Color.fromARGB(189, 107, 35, 1),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn,
                                    child: Center(
                                      child: Text(optionData[0],
                                          // textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: width / 25,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    checkAnswer((optionData[1]
                                            .toString()
                                            .replaceAll(' ', ''))
                                        .toLowerCase());
                                  },
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color.fromARGB(188, 57, 35, 2),
                                          Color.fromARGB(189, 67, 35, 1),
                                          Color.fromARGB(189, 77, 35, 2),
                                          Color.fromARGB(189, 87, 35, 1),
                                          Color.fromARGB(189, 97, 35, 2),
                                          Color.fromARGB(189, 107, 35, 1),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    blendMode: BlendMode.srcIn,
                                    child: Center(
                                      child: Text(optionData[1],
                                          // textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: width / 25,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    Visibility(
                      visible: continueEnable,
                      child: Positioned(
                        bottom: 30,
                        child: Showcase(
                          key: _continue,
                          description: 'Click to continue the game.',
                          child: InkWell(
                            onTap: () {
                              continueEnable = false;
                              _updateText();
                            },
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromARGB(188, 57, 35, 2),
                                    Color.fromARGB(189, 67, 35, 1),
                                    Color.fromARGB(189, 77, 35, 2),
                                    Color.fromARGB(189, 87, 35, 1),
                                    Color.fromARGB(189, 97, 35, 2),
                                    Color.fromARGB(189, 107, 35, 1),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Center(
                                child: Text('Continue',
                                    // textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontSize: width / 25,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                Expanded(
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: 5),
                //   child:
                //   Container(
                //           width: (width - 6),
                //           height: 60,
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(10),
                //               color: Colors.amber,
                //               border: Border.all(color: Color.fromARGB(255, 0, 0, 0), width: 2)),
                //           child: Image.asset('assets/imgs/map.png',)
                //         ),
                //   )
              ],
            ),
          )
        : Scaffold(
            body: Stack(children: [
              Expanded(child: _buildQrView(context)),
              Positioned(
                  bottom: 20,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              controller!.stopCamera();
                              showScanner = false;
                            });
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ))
            ]),
          );
  }
}

// class Top_rank extends StatelessWidget {
//   final no;
//   final user_name;
//   final tasks;
//   final time;

//   const Top_rank({
//     super.key,
//     required this.no,
//     required this.user_name,
//     required this.tasks,
//     required this.time,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     return Padding(
//       padding: const EdgeInsets.only(top: 2),
//       child: Container(
//         width: width - 30,
//         height: 25,
//         decoration: BoxDecoration(
//             color: Colors.white, borderRadius: BorderRadius.circular(5)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Text(
//                 no,
//                 style: const TextStyle(
//                     color: Color.fromARGB(255, 255, 126, 6),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14),
//               ),
//             ),
//             Text(
//               user_name,
//               style: const TextStyle(
//                   color: Color.fromARGB(255, 0, 0, 0),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14),
//             ),
//             Text(
//               tasks,
//               style: const TextStyle(
//                   color: Color.fromARGB(255, 0, 0, 0),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: Text(
//                 time,
//                 style: const TextStyle(
//                     color: Color.fromARGB(255, 0, 0, 0),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//"تیز رفتار بھورا لومڑی ایک میز پر سے کود گئی۔ یہ صرف ٹیسٹنگ کے لیے استعمال ہونے والا ایک ٹیسٹ ٹیکسٹ ہے اور اس کے علاوہ کچھ نہیں ہے"

// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   children: [
//     Container(
//       width: (width / 2) - 30,
//       height: 78,
//       decoration: BoxDecoration(
//           color: Colors.amber,
//           borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "My Time",
//             style: TextStyle(
//                 color: Color.fromARGB(255, 0, 0, 0),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 17),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//               width: double.infinity,
//               height: 44,
//               decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 231, 230, 228),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Center(
//                   child: Text(
//                 "00D:00H:00M",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 126, 6),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14),
//               )))
//         ],
//       ),
//     ),
//     Container(
//       width: (width / 2) - 30,
//       height: 78,
//       decoration: BoxDecoration(
//           color: Colors.amber,
//           borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Time Remaining",
//             style: TextStyle(
//                 color: Color.fromARGB(255, 0, 0, 0),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 17),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//               width: double.infinity,
//               height: 44,
//               decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 231, 230, 228),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Center(
//                   child: Text(
//                 "00D:00H:00M",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 126, 6),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14),
//               )))
//         ],
//       ),
//     ),
//   ],
// ),

// Padding(
//   padding: const EdgeInsets.only(top: 10),
//   child: Container(
//     width: 70,
//     height: 25,
//     decoration: BoxDecoration(
//         color: Colors.amber,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(5),
//             topRight: Radius.circular(5))),
//     child: Center(
//       child: Text(
//         "Top 10",
//         style: TextStyle(
//             color: Color.fromARGB(255, 0, 0, 0),
//             fontWeight: FontWeight.w500,
//             fontSize: 14),
//       ),
//     ),
//   ),
// ),

// Padding(
//   padding: const EdgeInsets.only(top: 10),
//   child: Container(
//     width: width - 15,
//     height: 120,
//     decoration: BoxDecoration(
//         color: Colors.amber,
//         borderRadius: BorderRadius.circular(5)
//         // border: Border.all(color: Color.fromARGB(255, 0, 0, 0))
//         ),
//     child: SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             height: 25,
//             decoration: BoxDecoration(
//                 color: Colors.amber,
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
//                 border: Border(bottom: BorderSide(color: Colors.black))
//                 ),
//             child: Center(
//               child: Text(
//                 "Top 10",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 0, 0, 0),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14),
//               ),
//             ),
//           ),
//           SizedBox(height: 5,),
//           Top_rank(
//               no: "1",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "2",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "3",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "4",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "5",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "6",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "7",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "8",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "9",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//           Top_rank(
//               no: "10",
//               user_name: "Zain0431",
//               tasks: "8/10",
//               time: "00D:00H:00M"),
//         ],
//       ),
//     ),
//   ),
// ),

// Padding(
//   padding: EdgeInsets.only(top: 10),
//   child: Container(
//     width: width - 5,
//     height: 135,
//     color: Color.fromARGB(0, 255, 193, 7),
//     child: Column(
//       children: [
//         Row(
//           children: [
//             Container(
//             width: width-5,
//             height: 25,
//             decoration: BoxDecoration(
//                 color: const Color.fromARGB(0, 255, 193, 7),
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
//                 border: Border(bottom: BorderSide(color: Colors.black))
//                 ),
//             child: Center(
//               child: Text(
//                 "My Tasks",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 255, 255),
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14),
//               ),
//             ),
//           ),
//           ],
//         ),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               SizedBox(width: 5,),
//               Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Container(
//                   width: (width/4)-14,
//                   height: 110,
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 252, 252, 251),
//                     borderRadius: BorderRadius.circular(7)
//                   ),
//                   child: Image.asset("assets/imgs/quest_1.png",),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Container(
//                   width: (width/4)-10,
//                   height: 110,
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 252, 252, 251),
//                     borderRadius: BorderRadius.circular(7)
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Container(
//                   width: (width/4)-10,
//                   height: 110,
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 252, 252, 251),
//                     borderRadius: BorderRadius.circular(7)
//                   ),
//                 ),
//               ),

// Padding(
//   padding: const EdgeInsets.only(right: 5),
//   child: Container(
//     width: (width / 4) - 10,
//     height: 110,
//     decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 252, 252, 251),
//         borderRadius: BorderRadius.circular(7)),
//   ),
// ),
// Padding(
//   padding: const EdgeInsets.only(right: 5),
//   child: Container(
//     width: (width / 4) - 10,
//     height: 110,
//     decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 252, 252, 251),
//         borderRadius: BorderRadius.circular(7)),
//   ),
// ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   ),
// ),

// Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 InkWell(
//                   onTapUp: (details) {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           // title: Text('AlertDialog Title'),
//                           contentPadding:
//                               const EdgeInsets.only(top: 15, left: 20, right: 20),
//                           backgroundColor:
//                               const Color.fromARGB(255, 255, 255, 255),
//                           content: Container(
//                               color: const Color.fromARGB(0, 255, 255, 255),
//                               width: (width / 5) * 3,
//                               // height: 55,
//                               child: const Text(
//                                   "Are you sure you want to use a hint",
//                                   style: TextStyle(
//                                       color: Color.fromARGB(255, 0, 0, 0),
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w400))),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(); // Close the dialog
//                               },
//                               child: const Text(
//                                 'No',
//                                 style: TextStyle(
//                                     color: Color.fromARGB(255, 194, 0, 0),
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(); // Close the dialog
//                               },
//                               child: const Text(
//                                 'Yes',
//                                 style: TextStyle(
//                                     color: Color.fromARGB(255, 0, 0, 0),
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: (width / 4) - 10,
//                     height: 45,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: const Color.fromARGB(0, 255, 193, 7),
//                         border: Border.all(color: Colors.amber, width: 2)),
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.lightbulb,
//                           color: Colors.amber,
//                           size: 15,
//                         ),
//                         Text("2",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTapUp: (details) {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           contentPadding: const EdgeInsets.only(
//                               bottom: 10, top: 20, left: 25, right: 25),
//                           // title: Text('AlertDialog Title'),
//                           backgroundColor:
//                               const Color.fromARGB(255, 255, 255, 255),
//                           content: Container(
//                             color: const Color.fromARGB(0, 255, 255, 255),
//                             width: (width / 5) * 3,
//                             height: 117,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Formfield(
//                                   controller: _answerController,
//                                   hintText: 'Give your answer',
//                                   lable: 'Answer',
//                                   radius: 10,
//                                   borderColor: Colors.black,
//                                   lableStyle: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w400),
//                                   hintStyle: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400),
//                                   textStyle: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400),
//                                   borderColorfocus: Colors.amber,
//                                 ),
//                                 const SizedBox(
//                                   height: 8,
//                                 ),
//                                 SizedBox(
//                                   width: (width / 5) * 3,
//                                   child: const Text(
//                                       "Only answer when you are sure. If you ran out of chances you will loose.",
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                       )),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(); // Close the dialog
//                               },
//                               child: const Text(
//                                 'Cancel',
//                                 style: TextStyle(
//                                     color: Color.fromARGB(255, 194, 0, 0),
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(); // Close the dialog
//                               },
//                               child: const Text(
//                                 'Check Answer',
//                                 style: TextStyle(
//                                     color: Color.fromARGB(255, 0, 0, 0),
//                                     fontWeight: FontWeight.w500),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: (width / 4) * 2,
//                     height: 45,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.amber,
//                         border: Border.all(color: Colors.amber, width: 2)),
//                     child: const Center(
//                       child: Text("Answer",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: (width / 4) - 10,
//                   height: 45,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color.fromARGB(0, 255, 193, 7),
//                       border: Border.all(color: Colors.amber, width: 2)),
//                   child: const Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.favorite,
//                         color: Color.fromARGB(255, 251, 0, 0),
//                         size: 15,
//                       ),
//                       Text("2",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
