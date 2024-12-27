// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:treasure_game/dashboard.dart';
import 'package:treasure_game/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showcaseview/showcaseview.dart';
import 'firebase_options.dart';
import 'countdown.dart';
import 'utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => const MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(body: MyHomePage()),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  TextEditingController ticketFieldNo = TextEditingController();

  String players = '0';
  String loot = '0';
  String button_text = 'Join Now';
  String whatsapp = '';
  String username = '';
  String gamePass = '';

  bool buy_enable = true;
  bool window = false;
  bool isLoggedInVar = false;
  bool isGameOnline = false;
  bool payment = true;
  bool moveUp = true;
  bool _isKeyboardVisible = false;
  bool joinEnable = true;
  bool isJoined = false;
  bool gameEnded = false;

  int joinedplayers = 0;

  Map gamecompleted = {};

  Color primary = const Color.fromARGB(255, 255, 255, 255);
  Color secondary = const Color.fromARGB(255, 189, 189, 189);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    isJoinedgame();
    isLoggedIn();
    isLoggedInVar = false;
    setLoggedIn(false);
    getgamepass();
    monitorFirestoreConnection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetUtils.initialize(context);
    });
    FirebaseFirestore.instance
        .collection('MainGameData')
        .doc('gamedata')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> Data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          // print(Data);
          players = Data['players'];
          loot = Data['prize_money'];
          whatsapp = Data['whatsapp'];
          buy_enable = Data['buy_enable'];
          isGameOnline = Data['isGameOnline'];
          joinEnable = Data['joinEnable'];
          joinedplayers = Data['joinedplayers'];
          gameEnded = Data['gameEnded'];
          gamecompleted = Data['gamecompleted'];
          // if (!isGameOnline) {
          setLoggedIn(false);
          isLoggedIn();
        });
      } else {
        print("Data not exists");
      }
    });

    // print('Login value $isLoggedInVar');
  }

  Future<void> isJoinedgame() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // prefs.setBool('isJoined', false);
      isJoined = prefs.getBool('isJoined') ?? false;
    });
  }

  void setJoinedGame(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isJoined', val);
    if (!isJoined) {
      isJoined = prefs.getBool('isJoined') ?? false;
      await FirebaseFirestore.instance
          .collection('MainGameData')
          .doc('gamedata')
          .update({'joinedplayers': joinedplayers + 1})
          .then((value) => print("Data Updated"))
          .catchError((error) => print("Failed to update user: $error"));
      isLoggedIn();
    }
  }

  Future<Map<String, bool>> checkPassEnable(String gamepass) async {
    bool value = false;
    bool exists = false;

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('MainUsersData')
        .doc(gamepass)
        .get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> Data =
          documentSnapshot.data() as Map<String, dynamic>;
      bool passEnable = Data['enable'];
      // bool payment = Data['payment'];
      // print(passEnable);
      value = passEnable;
      exists = true;
    } else {
      print("Data not exists");
      value = false;
      exists = false;
    }
    return {'value': value, 'exists': exists};
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedInVar = prefs.getBool('login') ?? false;
    });
    // print('Obtained value = $isLoggedInVar');
    if (gameEnded && joinEnable) {
      // dialogBox(200, 'The game has been ended.', 50);
    } else {
      if (!joinEnable && isJoined) {
        setState(() {
          button_text = 'Added to list';
        });
      } else {
        if (!isLoggedInVar) {
          setState(() {
            button_text = "Join Now";
          });
        } else {
          setState(() {
            button_text = "Enter In Game";
            gamePass = (prefs.getString('gamepass'))!;
          });
        }
      }
    }

    return isLoggedInVar;
  }

  Future<bool> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    bool val = await prefs.setBool('login', value);
    return val;
  }

  Future<void> setgamepass(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gamepass', value);
    getgamepass();
  }

  Future<void> getgamepass() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gamePass = prefs.getString('gamepass')!;
    });
  }

  void dialogBox(double width, String text, double height) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(bottom: 10, top: 20, left: 25, right: 25),
          title: const Text(
            'Note',
            style: TextStyle(
                fontSize: 20,
                color: Colors.yellow,
                fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 32),
          content: Container(
            color: const Color.fromARGB(0, 255, 255, 255),
            width: (width - 60),
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (width / 5) * 3,
                  child: Text(text,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _showNoInternetDialog(BuildContext context) async {
  //   isDialogShown = true;
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // User must tap a button to close
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('No Internet Connection'),
  //         content: const SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Please check your internet connection and try again.'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Retry'),
  //             onPressed: () async {
  //               final connectivityService =
  //               Provider.of<ConnectivityService>(context, listen: false);
  //               await connectivityService.checkInternet();
  //               if (connectivityService.hasInternet) {
  //                 Navigator.of(context).pop();
  //                 isDialogShown = false;
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.implicitView!.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // InternetUtils.initialize(context).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Treasure Hunt",
                  style: TextStyle(
                      fontSize: width / 13,
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
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Game will start in",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: width / 20,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CountdownTimer(
                  documentId: 'game_start_time',
                  textStyle: TextStyle(
                      color: primary,
                      fontSize: width / 17,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SizedBox(
              height: 95,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Players",
                        style: TextStyle(
                          color: primary,
                          fontSize: 25,
                          fontFamily: 'BungeeSpice',
                        ),
                      ),
                      Text(
                        players.toString(),
                        style: TextStyle(
                            color: primary,
                            fontSize: 23,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height < 700 ? 25 : 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Treasure Loot",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 188, 3),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "Rs.$loot",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Image.asset(
                  'assets/imgs/chest.png',
                  width: height < 700 ? 120 : 150,
                ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTapUp: (details) async {
                    bool internet =
                        await InternetUtils.checkInternetConnection(context);
                    if (!internet) {
                      print('No Internet');
                    } else {
                      isJoinedgame();
                      if (gameEnded) {
                        dialogBox(
                            width, 'Dear player the game has be ended.', 60);
                      } else {
                        if (joinEnable) {
                          if (isLoggedInVar == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => dashboard_app(
                                        gamePass: gamePass,
                                      )),
                            );
                          } else {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                // useSafeArea: true,
                                // anchorPoint: Offset(0, 50),
                                // constraints: BoxConstraints(minHeight: height),
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: primary,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15))),
                                    height: _isKeyboardVisible
                                        ? (height / 1.5)
                                        : (height / 2.2),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      window == false;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                  )),
                                            )
                                          ],
                                        ),
                                        Visibility(
                                            visible: !_isKeyboardVisible,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0),
                                                  child: SizedBox(
                                                    width: (width / 4) * 3,
                                                    child: const Text(
                                                      "To join the game you have to buy GamePass for Rs.50.",
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: InkWell(
                                                    onTapUp: (details) {
                                                      if (buy_enable) {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const sign_up()),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: (width / 4) * 3.4,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: buy_enable
                                                              ? Colors.amber
                                                              : Colors.grey,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.amber,
                                                              width: 2)),
                                                      child: Center(
                                                        child: SizedBox(
                                                          width:
                                                              (width / 4) * 2.5,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text("Buy Now",
                                                                  style: TextStyle(
                                                                      color:
                                                                          primary,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                              CountdownTimer(
                                                                  documentId:
                                                                      'register_end_time',
                                                                  textStyle: TextStyle(
                                                                      color:
                                                                          primary,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: SizedBox(
                                                    width: (width / 4) * 3,
                                                    child: const Text(
                                                        "Or if you already have a GamePass then enter it below to enter in the game.",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                        )),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: (width / 4) * 2.4,
                                              height: 81,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  autofillHints: null,
                                                  maxLength: 10,
                                                  controller: ticketFieldNo,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .characters,
                                                  // textAlignVertical: TextAlignVertical.center,
                                                  decoration:
                                                      const InputDecoration(
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    231,
                                                                    9,
                                                                    9)),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6))),
                                                    labelText: "GamePass.",
                                                    labelStyle: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color.fromARGB(
                                                              255,
                                                              0,
                                                              157,
                                                              255)), // Set the focus color here
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6)),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 7,
                                                            bottom: 1,
                                                            left: 9),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6)),
                                                      // borderSide:
                                                      //     const BorderSide(width: 5, color: Colors.white)
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: InkWell(
                                                onTapUp: (details) async {
                                                  var pass =
                                                      await checkPassEnable(
                                                          ticketFieldNo.text);

                                                  if (pass['exists'] == true) {
                                                    if (pass['value'] == true) {
                                                      if (isGameOnline) {
                                                        setLoggedIn(true);
                                                        setgamepass(
                                                            ticketFieldNo.text);
                                                        isLoggedIn();
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  dashboard_app(
                                                                    gamePass:
                                                                        ticketFieldNo
                                                                            .text,
                                                                  )),
                                                        );
                                                      } else {
                                                        dialogBox(
                                                            width,
                                                            'The game has not yet started. Be patient, it will start soon.',
                                                            80);
                                                      }
                                                    } else {
                                                      dialogBox(
                                                          width,
                                                          "Your account is under payment review.",
                                                          50);
                                                      print(
                                                          '${ticketFieldNo.text} Is under payment review');
                                                    }
                                                  } else {
                                                    dialogBox(
                                                        width,
                                                        "No account found for ${ticketFieldNo.text}. To report any problem contact on this No. $whatsapp.",
                                                        80);
                                                    print(
                                                        '${ticketFieldNo.text} No GamePass found.');
                                                  }

                                                  // print(pass);
                                                },
                                                child: Container(
                                                  width: 90,
                                                  height: 48,
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomRight: Radius
                                                                  .circular(6)),
                                                      color: Color.fromARGB(
                                                          255, 7, 255, 32),
                                                      border: Border(
                                                          left: BorderSide(
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      7,
                                                                      255,
                                                                      32),
                                                              width: 1))),
                                                  child: Center(
                                                    child: Text("Enter",
                                                        style: TextStyle(
                                                            color: primary,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        } else {
                          setJoinedGame(true);
                          dialogBox(
                              width,
                              'You are added to the list. You will be able to play the game when atleast 1000 people join the game.',
                              80);
                        }
                      }
                    }
                  },
                  child: Container(
                    width: height < 700 ? 210 : 250,
                    height: height < 700 ? 50 : 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber,
                        border: Border.all(color: Colors.amber, width: 2)),
                    child: Center(
                      child: Text(button_text,
                          style: TextStyle(
                              color: primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: width / 1.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "For More information join our Whatsapp group.",
                    style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SelectableText(
                    whatsapp,
                    style: TextStyle(
                        color: secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

// class InstructionWidget extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const InstructionWidget({Key? key, required this.icon, required this.text})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TreasureHuntDescription extends StatelessWidget {
//   const TreasureHuntDescription({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Text(
//             '🎉 Welcome to the most thrilling adventure of your life - the Mian Channu Treasure Hunt! 🎉',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Are you ready to embark on a real-life treasure hunt that will put your wit, speed, and intelligence to the ultimate test? Look no further! This game is 100% real and waiting for brave adventurers like you to join in.',
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 16),
//           InstructionWidget(
//             icon: Icons.timer,
//             text:
//                 'Limited Time Offer: Join the game within the given time window! Once the clock runs out, joining will be closed, and the adventure begins. Don\'t miss your chance!',
//           ),
//           InstructionWidget(
//             icon: Icons.attach_money,
//             text:
//                 'Ticket to Thrills: To participate, you\'ll need to purchase a ticket. Secure your spot in the race for real prize money!',
//           ),
//           InstructionWidget(
//             icon: Icons.access_time,
//             text:
//                 'Race Against Time: Complete tasks within the allotted time to stay in the game. Fail a challenge, and you risk disqualification. But fear not, there\'s always another chance in the next game!',
//           ),
//           InstructionWidget(
//               icon: Icons.lightbulb_outline,
//               text:
//                   "Challenge Your Mind: Prepare to solve riddles and uncover hidden objects scattered throughout Mian Channu. It's not just a treasure hunt; it's a test of your brainpower!"),
//           InstructionWidget(
//               icon: Icons.emoji_events,
//               text:
//                   "Be the Ultimate Victor: Only the fastest, cleverest, and most cunning participant will claim the prize money. Will it be you?"),
//           InstructionWidget(
//               icon: Icons.workspace_premium,
//               text:
//                   "Solo Glory: In this hunt, there can only be one winner. Will you rise to the top and claim victory?"),
//           InstructionWidget(
//               icon: Icons.stars,
//               text:
//                   "Fair Play: If no player completes the game within the time limit, the player with the most completed tasks and the shortest completion time will be crowned the champion."),
//           InstructionWidget(
//               icon: Icons.map,
//               text:
//                   "Exclusive to Mian Channu Residents: This exhilarating adventure is exclusively for the daring souls residing in Mian Channu. Get ready to explore your city like never before!"),
//           SizedBox(
//             height: 8,
//           ),
//           Text(
//               "Join us in the ultimate quest for treasure and glory. Gather your courage, sharpen your mind, and get ready for the adventure of a lifetime. Let the hunt begin! "),
//           SizedBox(
//             height: 15,
//           )
//         ],
//       ),
//     );
//   }
// }
// const SizedBox(
//                       height: 5,
//                     ),
//                     InkWell(
//                       onTapUp: (details) {
//                         showModalBottomSheet(
//                             isScrollControlled: true,
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Container(
//                                 decoration: BoxDecoration(
//                                   color: primary,
//                                   // borderRadius: BorderRadius.only(
//                                   //     topLeft: Radius.circular(15),
//                                   //     topRight: Radius.circular(15))
//                                 ),
//                                 height: (height),
//                                 width: width,
//                                 child: Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 30),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: InkWell(
//                                                 onTap: () {
//                                                   Navigator.pop(context);
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.close,
//                                                   color: Colors.black,
//                                                 )),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: (width / 4) * 3.5,
//                                       height: height - 80,
//                                       child: const TreasureHuntDescription(),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             });
//                       },
//                       child: Text(
//                         "More Info.",
//                         style: TextStyle(
//                           color: secondary,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors
//                               .red, // Optional: Change the color of the underline
//                           decorationThickness:
//                               1, // Optional: Change the thickness of the underline
//                           decorationStyle: TextDecorationStyle
//                               .solid, // Optional: Change the style of the underline
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Text(
//                       "Or join our WhatsApp group.",
//                       style: TextStyle(
//                           color: primary,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),

// Padding(
//   padding: EdgeInsets.only(top:140),
//   child: Row(
//     mainAxisSize: MainAxisSize.max,
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         "Remaining Time",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.w500),
//       ),
//     ],
//   ),
//   ),
// Padding(
//   padding: EdgeInsets.only(top: 20),
//   child: Row(
//     mainAxisSize: MainAxisSize.max,
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Padding(
//         padding: const EdgeInsets.only(left: 30),
//         child: SizedBox(
//           height: 90,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "Tasks",
//                 style: TextStyle(
//                     color: Color.fromRGBO(67, 97, 238, 1),
//                     fontSize: 30,
//                     fontWeight: FontWeight.w500),
//               ),
//               Text(
//                 "10",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 188, 3),
//                     fontSize: 25,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(right: 30),
//         child: SizedBox(
//           height: 90,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "Prize",
//                 style: TextStyle(
//                     color: Color.fromRGBO(67, 97, 238, 1),
//                     fontSize: 30,
//                     fontWeight: FontWeight.w500),
//               ),
//               Text(
//                 "Rs.5000",
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 188, 3),
//                     fontSize: 25,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
