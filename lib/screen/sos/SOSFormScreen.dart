import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/SOS.dart';
import '../../service/AuthProvider.dart';
import '../../service/sos_provider.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;

class SOSFormScreen extends StatefulWidget {
  final SosModel? sos;

  const SOSFormScreen({Key? key, this.sos}) : super(key: key);

  @override
  State<SOSFormScreen> createState() => _SOSFormScreenState();
}

class _SOSFormScreenState extends State<SOSFormScreen> {

  // Get Token
  Future<String?> _getToken(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.user != null ? auth.token : null;
  }

  final _formKey = GlobalKey<FormState>();

  bool isEdit = false;
  bool isLoading = false;

  int? regionId;
  String? title;
  String? contactNumber;
  String status = "active";

  List regions = [];

  @override
  void initState() {
    super.initState();
    isEdit = widget.sos != null;

    fetchRegions();

    if (isEdit) _setEditData();
  }

  void _setEditData() {
    final s = widget.sos!;
    regionId = s.regionId;
    title = s.title;
    contactNumber = s.contactNumber;
    status = s.status == 1 ? "active" : "inactive";
  }

  // Fetch Regions
  Future<void> fetchRegions() async {
    final url = Uri.parse("${Constants.BASE_URL}/regions");

    final token = await _getToken(context);

    try {
      final res = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      });
      final json = jsonDecode(res.body);

      if (json["status"] == true) {
        setState(() => regions = json["data"]);
      }
      print(json);
    } catch (e) {
      print("Region Fetch Error: $e");
    }
  }

  void showSnack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // Submit Form
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    Map data = {
      "region_id": regionId.toString(),
      "title": title ?? "",
      "contact_number": contactNumber ?? "",
      "status": status,
      "added_by": "1"
    };

    final provider = Provider.of<SosProvider>(context, listen: false);
    bool success;

    if (isEdit) {
      success = await provider.updateSOS(context, widget.sos!.id!, data);
    } else {
      success = await provider.createSOS(context, data);
      print(success);
    }

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'SOS Updated Successfully' : 'SOS Created Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit SOS" : "Add SOS"),
        backgroundColor: Colors.green,
      ),
      body: regions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: regionId,
                    decoration: InputDecoration(
                      labelText: "Select Region",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: regions
                        .map<DropdownMenuItem<int>>((r) =>
                        DropdownMenuItem<int>(
                            value: r["id"], child: Text(r["name"])))
                        .toList(),
                    onChanged: (v) => setState(() => regionId = v),
                    validator: (v) =>
                    v == null ? "Region is required" : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    initialValue: title,
                    decoration: InputDecoration(
                      labelText: "SOS Title",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (v) => title = v,
                    validator: (v) =>
                    v == null || v.isEmpty ? "Title is required" : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    initialValue: contactNumber,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Contact Number",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (v) => contactNumber = v,
                    validator: (v) => v == null || v.isEmpty
                        ? "Contact number is required"
                        : null,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "active", child: Text("Active")),
                      DropdownMenuItem(
                          value: "inactive", child: Text("Inactive")),
                    ],
                    onChanged: (v) => setState(() => status = v!),
                  ),

                  const SizedBox(height: 25),

                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isEdit ? "Update SOS" : "Save SOS",
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
