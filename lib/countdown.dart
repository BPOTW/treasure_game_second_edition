// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownTimer extends StatefulWidget {
  final String documentId;
  final TextStyle textStyle;

  CountdownTimer({required this.documentId, required this.textStyle});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  DateTime endTime = DateTime(2024);
  Duration remainingTime = Duration();
  Timer timer = Timer(Duration.zero, () { });

  @override
  void initState() {
    super.initState();
    // Set up the Firestore listener
    FirebaseFirestore.instance.collection('MainGameData').doc('gamedata').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        String formattedEndTime = snapshot[widget.documentId];
        setState(() {
          endTime = DateTime.parse(formattedEndTime);
          updateRemainingTime();
          startTimer();
        });
      }
    });
  }

  void startTimer() {
    timer.cancel(); // Cancel any existing timer
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        updateRemainingTime();
        if (remainingTime.isNegative) {
          timer.cancel();
        }
      });
    });
  }

  void updateRemainingTime() {
    if (endTime != null) {
      remainingTime = endTime.difference(DateTime.now());
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
            formatDuration(remainingTime),
            style: widget.textStyle,
          );
  }

  String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return "00D:00H:00M";
    }
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);

    return "${twoDigits(days)}D:${twoDigits(hours)}H:${twoDigits(minutes)}M";
  }
}
