import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_taxi_booking/screen/sos/SOSDetailsScreen.dart';
import 'package:flutter_taxi_booking/screen/sos/SOSFormScreen.dart';
import 'package:provider/provider.dart';
import '../../models/SOS.dart';
import '../../service/sos_provider.dart';

class SOSListScreen extends StatefulWidget {
  const SOSListScreen({Key? key}) : super(key: key);

  @override
  State<SOSListScreen> createState() => _SOSListScreenState();
}

class _SOSListScreenState extends State<SOSListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Provider.of<SosProvider>(context, listen: false).fetchSOS(context);
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final prov = Provider.of<SosProvider>(context, listen: false);
      prov.searchQuery = query.trim();
      prov.fetchSOS(context, page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS List"),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SOSFormScreen(),
            ),
          );
        },
      ),

      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.items.isEmpty
          ? const Center(child: Text("No SOS found"))
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search SOS...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      prov.searchQuery = "";
                      prov.fetchSOS(context, page: 1);
                    })
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // List View
          Expanded(
            child: ListView.separated(
              itemCount: prov.items.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (context, i) {
                SosModel sos = prov.items[i];

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  SOSDetailsScreen(sos: sos),
                      ),
                    );
                  },

                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      (sos.title?.isNotEmpty == true ? sos.title![0] : "?").toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  title: Text(sos.title ?? "No Title"),
                  subtitle: Text("Contact: ${sos.contactNumber ?? "-"}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  SOSFormScreen(sos: sos),
                            ),
                          );
                        },
                      ),

                      /// DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await prov.deleteSOS(context, sos.id!);

                          if (ok) {
                            prov.fetchSOS(context, page: prov.currentPage);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Deleted Successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );

              },
            ),
          ),

          // Pagination Buttons
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Page ${prov.currentPage} of ${prov.lastPage}"),
                Row(
                  children: [
                    TextButton(
                      onPressed: prov.currentPage > 1
                          ? () => prov.fetchSOS(context,
                          page: prov.currentPage - 1)
                          : null,
                      child: const Text("Prev"),
                    ),
                    TextButton(
                      onPressed: prov.currentPage <
                          prov.lastPage
                          ? () => prov.fetchSOS(context,
                          page: prov.currentPage + 1)
                          : null,
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
