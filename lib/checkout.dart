import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatefulWidget {
  final String solanaAddress;
  final String projectId;

  const CheckoutPage({
    super.key,
    required this.solanaAddress,
    required this.projectId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Map<String, dynamic>? projectData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjectInfo();
  }

  Future<void> fetchProjectInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('projects') // Change this if your project data is stored elsewhere
          .doc(widget.projectId)
          .get();

      if (doc.exists) {
        setState(() {
          projectData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching project: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (projectData == null) {
      return const Scaffold(
        body: Center(child: Text("Project not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Project: ${projectData!['name'] ?? 'Unnamed Project'}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Connected Wallet: ${widget.solanaAddress}"),
            const SizedBox(height: 20),
            // Add your custom fields here
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Coupon Code (Optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement checkout logic
              },
              child: const Text("Complete Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
