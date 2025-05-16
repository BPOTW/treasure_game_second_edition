// ignore_for_file:  must_be_immutable, camel_case_types, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/services.dart'; // Added for Clipboard
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
  // final TextEditingController _idController = TextEditingController(); // Not used on this page as per current UI

  String paymentMethod = 'jazzcash'; // Default selection

  @override
  void initState() {
    super.initState();
    // InternetUtils.initialize(context);
    // print(
    //     'Name : ${widget.name}, User Name : ${widget.username}, Phone : ${widget.phone}, GamePass : ${widget.pass}');
  }

  // @override
  // void dispose() { // No controllers to dispose here unless _idController is re-added
  //   // _idController.dispose();
  //   super.dispose();
  // }

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
    Color selectedColor = Colors.amber;
    Color unselectedColor = Colors.transparent; // More distinct difference

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 0, 0, 32),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTapUp: (details) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const sign_up()),
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
                          "Payment",
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
                            _buildStepIndicator(isActive: true),
                            _buildStepIndicator(isActive: false),
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
                "Select Payment Method", // Changed title
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Adjusted size
                    fontWeight: FontWeight.w600), // Bolder
              ),
              SizedBox(
                height: 15, // Increased spacing
              ),
              _buildPaymentMethodTile(
                title: "JazzCash",
                imageAsset: 'assets/imgs/jazzcash.png',
                value: 'jazzcash',
                groupValue: paymentMethod,
                onChanged: (val) {
                  setState(() {
                    paymentMethod = val!;
                  });
                },
                width: width - 48, // account for padding
              ),
              SizedBox(
                height: 12,
              ),
              _buildPaymentMethodTile(
                title: "Easypaisa",
                imageAsset: 'assets/imgs/easypaisaWhite.png',
                value: 'easypaisa',
                groupValue: paymentMethod,
                onChanged: (val) {
                  setState(() {
                    paymentMethod = val!;
                  });
                },
                width: width - 48, // account for padding
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 30, bottom: 15), // Adjusted spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Details", // Changed title
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w600), // Bolder
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity, // Take full width available
                      decoration: BoxDecoration(
                          color: Color.fromARGB(
                              255, 5, 10, 45), // Darker, distinct background
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.blueGrey
                                  .withOpacity(0.5), // Softer border
                              width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(15), // Increased padding
                        child: Column(
                          children: [
                            _buildPaymentDetailRow(
                                context: context,
                                label: 'Account No:',
                                value: '03006884579',
                                canCopy: true),
                            Divider(color: Colors.blueGrey.withOpacity(0.3)),
                            _buildPaymentDetailRow(
                                context: context,
                                label: 'Receiver Name:',
                                value: 'Zain Ali'),
                            Divider(color: Colors.blueGrey.withOpacity(0.3)),
                            _buildPaymentDetailRow(
                                context: context,
                                label: 'Bank:',
                                value: 'Jazz Cash'),
                            Divider(color: Colors.blueGrey.withOpacity(0.3)),
                            _buildPaymentDetailRow(
                                context: context,
                                label: 'Amount:',
                                value: 'Rs.50'),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30), // Spacing before note and button
              Center(
                child: Text(
                  "Once payment is sent, proceed to the next step.", // Updated text
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 201, 201, 201),
                      fontSize: 13, // Slightly larger
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity, // Full width button
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    bool internet =
                        await InternetUtils.checkInternetConnection(context);
                    if (!internet) return;

                    // String username = _idController.text; // Not used here
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String imageAsset,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required double width,
  }) {
    bool isSelected = value == groupValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: isSelected
                  ? Colors.amber.withOpacity(0.15)
                  : Color.fromARGB(28, 255, 255, 255),
              border: Border.all(
                  color:
                      isSelected ? Colors.amber : Colors.grey.withOpacity(0.5),
                  width: isSelected ? 2 : 1.5),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Image.asset(
                imageAsset,
                height: 35, // Adjusted size
                width: 35, // Adjusted size
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Adjusted size
                      fontWeight: FontWeight.w500),
                ),
              ),
              Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white54),
                child: Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: Colors.amber,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(
      {required BuildContext context,
      required String label,
      required String value,
      bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 10.0), // Increased vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14, // Adjusted size
                fontWeight: FontWeight.w500, // Bolder
                color: Colors.white.withOpacity(0.9)),
          ),
          Row(
            children: [
              SelectableText(
                // Made value selectable
                value,
                style: TextStyle(
                    fontSize: 14, // Adjusted size
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7)),
              ),
              if (canCopy) SizedBox(width: 8),
              if (canCopy)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('$label copied to clipboard!',
                          style: TextStyle(color: Colors.black)),
                      backgroundColor: Colors.amber,
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child:
                      Icon(Icons.copy_outlined, color: Colors.amber, size: 18),
                ),
            ],
          ),
        ],
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
