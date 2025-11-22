import 'package:flutter/material.dart';
import '../../models/SOS.dart';

class SOSDetailsScreen extends StatelessWidget {
  final SosModel sos;

  const SOSDetailsScreen({
    Key? key,
    required this.sos,
  }) : super(key: key);

  /// Row Widget
  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(thickness: 1, height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Convert numeric or string status to text
  String getStatus(dynamic statusValue) {
    if (statusValue == null) return "-";

    if (statusValue is int) {
      return statusValue == 1 ? "Active" : "Inactive";
    }

    if (statusValue is String) {
      return statusValue.toLowerCase() == "active"
          ? "Active"
          : "Inactive";
    }

    return "-";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SOS Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Avatar Circle
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.warning_rounded,
                  size: 60,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SOS Basic Details
            _section("SOS Information", [
              _row("Title", sos.title),
              _row("Contact Number", sos.contactNumber),
              _row("Status", getStatus(sos.status)),
            ]),

            /// Region & User Info
            _section("Additional Details", [
              _row("Region ID", sos.regionId),
              _row("Added By (User ID)", sos.addedBy),
            ]),
          ],
        ),
      ),
    );
  }
}
