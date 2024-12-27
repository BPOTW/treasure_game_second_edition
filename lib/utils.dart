// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class ConnectivityService extends ChangeNotifier {
//   bool _isConnected = true;
//   StreamSubscription? _subscription;
//   final Connectivity _connectivity = Connectivity();
//
//   bool get isConnected => _isConnected;
//
//   ConnectivityService() {
//     _initConnectivity();
//     _subscription =
//         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }
//
//   Future<void> _initConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       _updateConnectionStatus(result);
//     } catch (e) {
//       debugPrint('Couldn\'t check connectivity status: $e');
//     }
//   }
//
//   void _updateConnectionStatus(List<ConnectivityResult> result) {
//     _isConnected = result != ConnectivityResult.none;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }
//
// // Create a widget to display connection status
// class ConnectivityBanner extends StatelessWidget {
//   const ConnectivityBanner({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ConnectivityService>(
//       builder: (context, connectivity, child) {
//         if (!connectivity.isConnected) {
//           print('No internet ---------------------------');
//           return Container(
//             color: Colors.red,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: const Text(
//               'No Internet Connection',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white),
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }

// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
//
// class ConnectivityService extends ChangeNotifier {
//   final Connectivity _connectivity = Connectivity();
//   ConnectivityResult _connectionStatus = ConnectivityResult.none;
//   bool _hasInternet = true;
//
//   ConnectivityService() {
//     _initConnectivity();
//     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }
//
//   bool get hasInternet => _hasInternet;
//
//   Future<void> _initConnectivity() async {
//     List<ConnectivityResult> result = [];
//     try {
//       result = await _connectivity.checkConnectivity();
//       if (result.isNotEmpty) {
//         _connectionStatus = result.first;
//       }
//       checkInternet();
//     } catch (e) {
//       if (kDebugMode) {
//         print("Couldn't check connectivity status: $e");
//       }
//       _hasInternet = false;
//       notifyListeners();
//     }
//   }
//
//   void _updateConnectionStatus(List<ConnectivityResult> result) {
//     if (result.isNotEmpty) {
//       _connectionStatus = result.first;
//     } else {
//       _connectionStatus = ConnectivityResult.none;
//     }
//     checkInternet();
//   }
//
//   Future<void> checkInternet() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       _hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       _hasInternet = false;
//     }
//     notifyListeners();
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InternetUtils {
  // Private constructor to prevent instantiation
  InternetUtils._();

  // Static fields
  static bool _isConnected = false;
  static bool _hasInternet = false;
  // static StreamSubscription<List<ConnectivityResult>>
  //     _connectivitySubscription = Connectivity().onConnectivityChanged;
  static Timer? _timer;
  static bool _isDialogShowing = false;

  // Getters for external access
  static bool get isConnected => _isConnected;
  static bool get hasInternet => _hasInternet;

  // Initialize the internet checking utility
  static Future<void> initialize(BuildContext context) async {
    // Cancel any existing subscriptions to prevent memory leaks
    // await dispose();

    // Initial check
    await checkInternetConnection(context);

    // Set up connectivity stream subscription
    StreamSubscription<List<ConnectivityResult>> _connectivitySubscription =
        (Connectivity().onConnectivityChanged)
            .listen((List<ConnectivityResult> result) async {
      await checkInternetConnection(context);
    });

    // Periodic check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await checkInternetConnection(context);
      debugPrint('Connected $_isConnected, Internet $_hasInternet');
    });
    //
    // Future<void> dispose() async {
    //   await _connectivitySubscription.cancel();
    //   _timer?.cancel();
    //   _timer = null;
    // }
  }

  static Future<bool> checkInternetConnection(BuildContext context) async {
    if (!context.mounted) return false;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final connected = connectivityResult != ConnectivityResult.none;
      bool internet = false;

      if (connected) {
        internet = await _hasInternetAccess();
      }

      _isConnected = connected;
      _hasInternet = internet;

      if (!_isDialogShowing && context.mounted) {
        if (!connected) {
          _showNoConnectionDialog(context);
        } else if (!internet) {
          _showNoInternetAccessDialog(context);
        }
      } else if (_isDialogShowing && connected && internet && context.mounted) {
        _isDialogShowing = false;
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
    }
    if (!_isConnected && !_hasInternet) {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> _hasInternetAccess() async {
    try {
      // Try multiple endpoints to ensure internet connectivity
      final result = await Future.wait([
        _checkFirestore(),
        _checkGoogle(),
      ], eagerError: false);

      return result.any((success) => success);
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      return false;
    }
  }

  static Future<bool> _checkFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('testDoc')
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkGoogle() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      request.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  static void _showNoConnectionDialog(BuildContext context) {
    if (_isDialogShowing || !context.mounted) return;
    _showDialog(
      context,
      "No Network Connection",
      "You are not connected to any network.",
    );
  }

  static void _showNoInternetAccessDialog(BuildContext context) {
    if (_isDialogShowing || !context.mounted) return;
    _showDialog(
      context,
      "No Internet Access",
      "You are connected to a network but there is no internet access.",
    );
  }

  static void _showDialog(BuildContext context, String title, String content) {
    _isDialogShowing = true;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text("Retry"),
              onPressed: () async {
                if (context.mounted) {
                  _isDialogShowing = false;
                  Navigator.of(context).pop();
                  await checkInternetConnection(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> isInternetAvailable(BuildContext context) async {
    if (!context.mounted) return false;

    final connectivityResult = await Connectivity().checkConnectivity();
    final connected = connectivityResult != ConnectivityResult.none;
    bool internet = false;

    if (connected) {
      internet = await _hasInternetAccess();
    }

    if (!connected && context.mounted) {
      _showNoConnectionDialog(context);
      return false;
    } else if (!internet && context.mounted) {
      _showNoInternetAccessDialog(context);
      return false;
    }
    return true;
  }
}

StreamSubscription? _firestoreSubscriptions;

void monitorFirestoreConnection() {
  final collectionRef = FirebaseFirestore.instance
      .collection('MainGameData'); // Replace 'my_collection'

  _firestoreSubscriptions = collectionRef.snapshots().listen(
    (snapshot) {
      // Data received, assume connected
      print('Firestore: Connected (receiving updates)');
      // Perform actions when connected
    },
    onError: (error) {
      if (error is FirebaseException &&
          (error.code == 'unavailable' ||
              error.code == 'unauthenticated' ||
              error.code == 'permission-denied')) {
        print('Firestore: Disconnected (network or auth issue)');
        // Perform actions when disconnected
      } else {
        print('Firestore: Error: $error');
      }
    },
    onDone: () {
      print('Firestore: Connection closed');
    },
  );
}
