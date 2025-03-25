import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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
  runApp(SolanaTokenPayApp());
}

class SolanaTokenPayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solana Token-Pay Account Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TokenPayAccountCreator(),
    );
  }
}

class TokenPayAccountCreator extends StatefulWidget {
  @override
  _TokenPayAccountCreatorState createState() => _TokenPayAccountCreatorState();
}

class _TokenPayAccountCreatorState extends State<TokenPayAccountCreator> {
  final _formKey = GlobalKey<FormState>();

  // List of phantom wallet addresses (example)
  List<String> _phantomWallets = [
    '7CD5FDC1A917E8BC5BF6FFB49A3B5A7ABCA123456',
    'GH8J9KLMN1OPQRS2TUVWX3YZ4567890ABC',
  ];

  String? _selectedWalletAddress;
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _couponAmountController = TextEditingController();

  List<CouponCode> _couponCodes = [];
  bool _isPercentOff = true;

  @override
  void initState() {
    super.initState();
    // Pre-select first wallet address
    _selectedWalletAddress = _phantomWallets.first;
  }

  void _addCouponCode() {
    if (_couponAmountController.text.isNotEmpty) {
      setState(() {
        _couponCodes.add(CouponCode(
          percentOff: _isPercentOff,
          amount: double.parse(_couponAmountController.text),
        ));
        _couponAmountController.clear();
      });
    }
  }

  void _removeCouponCode(CouponCode couponCode) {
    setState(() {
      _couponCodes.remove(couponCode);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Prepare data for Firebase
      final tokenPayData = {
        'public_wallet_address': _selectedWalletAddress,
        'name_of_product': _productNameController.text,
        'price_of_product': double.parse(_productPriceController.text),
        'coupon_codes': _couponCodes.map((coupon) => {
          'percent_off': coupon.percentOff,
          'amount_off': !coupon.percentOff,
          'amount': coupon.amount,
        }).toList(),
      };

      // Save to Firebase (example reference)
      final database = FirebaseDatabase.instance.reference();
      await database.child('token_pay_accounts').push().set(tokenPayData);

      // Show JavaScript snippet
      _showJavaScriptSnippet();
    }
  }

  void _showJavaScriptSnippet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generated JavaScript Snippet'),
        content: SingleChildScrollView(
          child: Text(
            '''
// Placeholder JavaScript Snippet
async function createTokenPayAccount() {
  const accountData = {
    publicWalletAddress: '${_selectedWalletAddress}',
    productName: '${_productNameController.text}',
    productPrice: ${_productPriceController.text},
    couponCodes: ${_couponCodes.map((coupon) => {
                //return '{percentOff: ${coupon.percentOff}, amount: ${coupon.amount}}';
            }).toList()}
  };
  
  // TODO: Implement actual token-pay account creation logic
  console.log('Token-Pay Account Created:', accountData);
}
            ''',
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: '''
async function createTokenPayAccount() {
  const accountData = {
    publicWalletAddress: '${_selectedWalletAddress}',
    productName: '${_productNameController.text}',
    productPrice: ${_productPriceController.text},
    couponCodes: ${_couponCodes.map((coupon) => {
                      //return '{percentOff: ${coupon.percentOff}, amount: ${coupon.amount}}';
                  }).toList()}
  };
  
  // TODO: Implement actual token-pay account creation logic
  console.log('Token-Pay Account Created:', accountData);
}
                '''));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied to Clipboard')),
              );
              Navigator.of(context).pop();
            },
            child: Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solana Token-Pay Account Creator'),
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Wallet Address Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Solana Public Wallet Address',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedWalletAddress,
                  items: _phantomWallets.map((address) {
                    return DropdownMenuItem(
                      value: address,
                      child: Text(address),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWalletAddress = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Product Name TextField
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: 'Name of Product',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Product Price TextField
                TextFormField(
                  controller: _productPriceController,
                  decoration: InputDecoration(
                    labelText: 'Price of Product',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Coupon Code Creator
                Text(
                  'Coupon Codes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    // Percent Off / Amount Off Toggle
                    ToggleButtons(
                      isSelected: [_isPercentOff, !_isPercentOff],
                      onPressed: (index) {
                        setState(() {
                          _isPercentOff = index == 0;
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Percent Off'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Amount Off'),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Coupon Amount TextField
                    Expanded(
                      child: TextFormField(
                        controller: _couponAmountController,
                        decoration: InputDecoration(
                          labelText: _isPercentOff ? 'Percent' : 'Amount',
                          border: OutlineInputBorder(),
                          suffixText: _isPercentOff ? '%' : '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addCouponCode,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Coupon Codes List
                if (_couponCodes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _couponCodes.map((coupon) {
                      return ListTile(
                        title: Text(
                          '${coupon.percentOff ? 'Percent' : 'Amount'} Off: ${coupon.amount}${coupon.percentOff ? '%' : '\$'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeCouponCode(coupon),
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Generate JavaScript Snippet'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CouponCode {
  final bool percentOff;
  final double amount;

  CouponCode({
    required this.percentOff,
    required this.amount,
  });
}