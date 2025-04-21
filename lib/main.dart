import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'configure_checkout.dart';
import 'appbar.dart'; // Import your custom app bar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'YOUR_FIREBASE_API_KEY',
      appId: 'YOUR_FIREBASE_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      databaseURL: 'YOUR_FIREBASE_DATABASE_URL',
    ),
  );
  runApp(const SolanaTokenPayApp());
}

class SolanaTokenPayApp extends StatelessWidget {
  const SolanaTokenPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solana Token Pay',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Configure a product checkout for Solana (USDC or SOL), using Phantom Wallet browser extension.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConfigureCheckoutPage()),
                  );
                },
                child: const Text('Configure A Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
