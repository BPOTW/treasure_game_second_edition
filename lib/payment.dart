// ignore_for_file:  must_be_immutable, camel_case_types, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:treasure_game/payment_confirm.dart';
import 'package:treasure_game/signup.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class payment extends StatefulWidget {
  final String name;
  final String username;
  final String phone;
  final String pass;
  payment({
    super.key,
    this.name = '',
    this.username = '',
    this.phone = '',
    this.pass = '',
  });

  @override
  State<payment> createState() => _paymentState();
}

class _paymentState extends State<payment> {
  final TextEditingController _idController = TextEditingController();

  String paymentMethod = 'jazzcash';

  @override
  void initState() {
    super.initState();
    // InternetUtils.initialize(context);
    // print(
    //     'Name : ${widget.name}, User Name : ${widget.username}, Phone : ${widget.phone}, GamePass : ${widget.pass}');
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
    Color selected =
        Color.fromARGB(255, 254, 197, 9); //fromARGB(255, 7, 243, 255)
    Color unselected = const Color.fromARGB(0, 255, 255, 255);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                              builder: (context) => const sign_up()),
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
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(
                  "Payment method",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        paymentMethod = 'jazzcash';
                      });
                    },
                    child: Container(
                      width: width - 60,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(28, 255, 255, 255),
                          border: Border.all(color: Colors.amber, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Image.asset(
                              'assets/imgs/jazzcash.png',
                              height: 50,
                            ),
                          ),
                          Text(
                            "JazzCash",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: width - 250),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: paymentMethod == 'jazzcash'
                                      ? selected
                                      : unselected,
                                  border: Border.all(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        paymentMethod = 'easypaisa';
                      });
                    },
                    child: Container(
                      width: width - 60,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(28, 255, 255, 255),
                          border: Border.all(color: Colors.amber, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 20),
                            child: Image.asset(
                              'assets/imgs/easypaisaWhite.png',
                              height: 40,
                            ),
                          ),
                          Text(
                            "Easypaisa",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: width - 250),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: paymentMethod == 'easypaisa'
                                      ? selected
                                      : unselected,
                                  border: Border.all(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: const Text(
                                "Send payment to.",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top: 15),
                          child: Container(
                            width: width - 60,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 0, 0, 45),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Color.fromARGB(175, 161, 159, 159),
                                    width: 1)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, top: 15, bottom: 15, right: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Account No : ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      const Text(
                                        '03006884579',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 179, 178, 168)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Receiver name : ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      const Text(
                                        'Zain Ali',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 179, 168, 168)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Bank : ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      const Text(
                                        'Jazz Cash',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 179, 168, 168)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Amount : ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      const Text(
                                        'Rs.50',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                                255, 179, 168, 168)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: double.infinity,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "If you have sent the payment then click on next.",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 201, 201, 201),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: 20,
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
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromARGB(255, 226, 194, 12))),
                      onPressed: () {
                        String username = _idController.text;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => payment_confirm(
                                    name: widget.name,
                                    username: widget.username,
                                    phone: widget.phone,
                                    pass: widget.pass,
                                    paymentmethod: paymentMethod,
                                  )),
                        );
                      },
                      child: const Text(
                        'Next',
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
    );
  }
}

// const SizedBox(
//                           height: 30,
//                         ),
//                         Formfield(
//                             controller: _idController,
//                             hintText: "Enter transaction ID",
//                             lable: "Transaction ID",
//                             lableStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontSize: 15,fontWeight: FontWeight.w400),
//                                 hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontSize: 13,fontWeight: FontWeight.w400),
//                                 textStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontSize: 13,fontWeight: FontWeight.w400),
//                             ),
//                         const SizedBox(height: 16.0),
//                         SizedBox(
//                           width: (width / 4) * 3,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: const ButtonStyle(
//                                 backgroundColor: MaterialStatePropertyAll(
//                                     Color.fromARGB(255, 226, 194, 12))),
//                             onPressed: () {
//                               String username = _idController.text;
//                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         const dashboard_app()),
//                                               );

//                             },
//                             child: const Text(
//                               'Check Payment',
//                               style: TextStyle(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color.fromARGB(255, 255, 255, 255)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         SizedBox(
//                           width: ((width / 4) * 3) - 10,
//                           child: const Text(
//                             "",
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color.fromARGB(255, 209, 201, 201)),
//                           ),
//                         )
