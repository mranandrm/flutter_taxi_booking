import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/SOS.dart';
import '../utils/constants.dart';
import 'AuthProvider.dart';

class SosProvider with ChangeNotifier {
  List<SosModel> items = [];
  bool isLoading = false;

  int currentPage = 1;
  int lastPage = 1;
  String searchQuery = '';

  // Get Token
  Future<String?> _getToken(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.user != null ? auth.token : null;
  }

  // -----------------------------
  // FETCH LIST
  // -----------------------------
  Future<void> fetchSOS(BuildContext context, {int page = 1}) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken(context);

      final uri = Uri.parse("${Constants.BASE_URL}/sos").replace(
        queryParameters: {
          "page": page.toString(),
          if (searchQuery.isNotEmpty) "search": searchQuery,
        },
      );

      final response = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      final body = jsonDecode(response.body);

      // ERROR FIX: CORRECT JSON STRUCTURE
      final data = body["data"];

      items = (data["data"] as List)
          .map((e) => SosModel.fromJson(e))
          .toList();

      currentPage = data["current_page"] ?? 1;
      lastPage = data["last_page"] ?? 1;

    } catch (e) {
      print("SOS error: $e");
      items = [];
    }

    isLoading = false;
    notifyListeners();
  }


  // CREATE
  Future<bool> createSOS(BuildContext context, Map data) async {
    final token = await _getToken(context);
    final uri = Uri.parse("${Constants.BASE_URL}/sos/store");

    final response = await http.post(uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: data);

    final body = jsonDecode(response.body);
    print(body);
    return body["status"] == true;
  }

  // UPDATE
  Future<bool> updateSOS(BuildContext context, int id, Map data) async {
    final token = await _getToken(context);
    final uri = Uri.parse("${Constants.BASE_URL}/sos/update/$id");

    final response = await http.post(uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: data);

    final body = jsonDecode(response.body);
    return body["status"] == true;
  }

  // DELETE
  Future<bool> deleteSOS(BuildContext context, int id) async {
    final token = await _getToken(context);
    final uri = Uri.parse("${Constants.BASE_URL}/sos/delete/$id");

    final response = await http.get(uri, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    final body = jsonDecode(response.body);

    print(body);
    return body["status"] == true;
  }
}
