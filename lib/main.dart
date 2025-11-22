import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_taxi_booking/screen/HomeScreen.dart';
import 'package:flutter_taxi_booking/screen/LocationScreen.dart';
import 'package:flutter_taxi_booking/screen/LoginScreen.dart';
import 'package:flutter_taxi_booking/screen/NoInternetScreen.dart';
import 'package:flutter_taxi_booking/service/AuthProvider.dart';
import 'package:flutter_taxi_booking/service/sos_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    _checkInternet();

      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
        bool online = !results.contains(ConnectivityResult.none);

        setState(() {
          _isOnline = online;
        });

        if (online) {
          _checkInternet(); // Real internet check
        }
      });
    }

    // 🔥 Real Internet Check (Google DNS Ping)
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInternet() async {
    bool internet = await hasInternetConnection();

    setState(() {
      _isOnline = internet;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Still checking
    if (_isOnline == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Main Screens Swap
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isOnline! ? HomeScreen(title: 'Home') : NoInternetScreen(onRetry: _checkInternet),
    );
  }
}
