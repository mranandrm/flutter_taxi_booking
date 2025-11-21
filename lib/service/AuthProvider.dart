import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/User.dart';
import 'package:http/http.dart' as http;

import '../utils/Constants.dart';
import 'dio.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user;
  String? _token;

  bool get authenticated => _isLoggedIn;
  User? get user => _user;

  final storage = FlutterSecureStorage();

  // =========================================================
  // LOGIN
  // =========================================================
  Future<void> login({required Map creds}) async {
    print("LOGIN CREDS: $creds");

    try {
      Dio.Response response = await dio().post(
        Constants.BASE_URL + Constants.LOGIN_ROUTE,
        data: creds,
      );

      print("LOGIN RESPONSE: ${response.data}");

      String token = response.data.toString();

      await tryToken(token: token);

      _isLoggedIn = true;
      notifyListeners();

    } catch (e) {
      print("LOGIN ERROR: $e");
    }
  }

  // =========================================================
  // TRY TOKEN (Load logged-in user)
  // =========================================================
  Future<void> tryToken({required String token}) async {
    try {
      Dio.Response response = await dio().get(
        Constants.BASE_URL + Constants.USER_ROUTE,
        options: Dio.Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      _user = User.fromJson(response.data);
      _token = token;
      _isLoggedIn = true;

      await storeToken(token: token);

      print("USER LOADED: $_user");

      notifyListeners();

    } catch (e) {
      print("TOKEN ERROR: $e");
      _isLoggedIn = false;
    }
  }

  // =========================================================
  // LOAD USER WHEN APP STARTS (Splash screen)
  // =========================================================
  Future<void> loadUser() async {
    String? token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      print("NO STORED TOKEN");
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    print("TOKEN FOUND: $token → Trying login...");
    await tryToken(token: token);
  }

  // =========================================================
  // STORE TOKEN
  // =========================================================
  Future<void> storeToken({required String token}) async {
    await storage.write(key: "token", value: token);
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> logout() async {
    dynamic token = await storage.read(key: "token");

    try {
      print("LOGOUT STARTED");

      await dio().post(
        Constants.BASE_URL + Constants.LOGOUT_ROUTE,
        options: Dio.Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      print("LOGOUT SUCCESS");
      await cleanUp();
      notifyListeners();

    } catch (e) {
      print("LOGOUT ERROR: $e");
    }
  }

  // =========================================================
  // CLEAN UP
  // =========================================================
  Future<void> cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;

    await storage.delete(key: "token");
  }

  // =========================================================
  // REGISTER USER
  // =========================================================
  Future<void> registerUser({required Map creds}) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.BASE_URL + Constants.REGISTER_ROUTE),
        body: creds,
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);

        print("USER REGISTERED: ${data['user']['name']}");
      } else {
        print("REGISTRATION FAILED: ${response.body}");
      }

    } catch (e) {
      print("REG ERROR: $e");
    }

    await Future.delayed(Duration(seconds: 2));
    notifyListeners();
  }

  // =========================================================
  // UPDATE PROFILE
  // =========================================================
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields) async {
    try {
      Dio.Response response = await dio().post(
        Constants.BASE_URL + Constants.UPDATE_PROFILE_ROUTE,
        data: fields,
        options: Dio.Options(headers: {
          "Authorization": "Bearer $_token",
        }),
      );

      return response.data;

    } catch (e) {
      return {"error": "$e"};
    }
  }

  // =========================================================
  // UPLOAD PROFILE PICTURE
  // =========================================================
  Future<void> uploadProfilePic(File file) async {
    try {
      String fileName = file.path.split("/").last;

      Dio.FormData formData = Dio.FormData.fromMap({
        "file": await Dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      await dio().post(
        Constants.BASE_URL + "/upload-profile-pic",
        data: formData,
        options: Dio.Options(headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "multipart/form-data"
        }),
      );

      print("PROFILE PIC UPLOADED");

      // Refresh user after upload
      if (_token != null) {
        await tryToken(token: _token!);
      }

    } catch (e) {
      print("IMAGE UPLOAD ERROR: $e");
    }
  }
}
