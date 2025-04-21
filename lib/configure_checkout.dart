import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'checkout.dart';

class ConfigureCheckout extends StatelessWidget {
  const ConfigureCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configure Checkout',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ConfigureCheckoutPage(),
    );
  }
}

enum PaymentCurrency { USDC, SOL }

class CouponCode {
  final bool percentOff;
  final double amount;

  CouponCode({required this.percentOff, required this.amount});
}

class ConfigureCheckoutPage extends StatefulWidget {
  const ConfigureCheckoutPage({super.key});

  @override
  State<ConfigureCheckoutPage> createState() => _ConfigureCheckoutPageState();
}

class _ConfigureCheckoutPageState extends State<ConfigureCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final _phantomWallets = [
    '7CD5FDC1A917E8BC5BF6FFB49A3B5A7ABCA123456',
    'GH8J9KLMN1OPQRS2TUVWX3YZ4567890ABC',
  ];

  String? _selectedWallet;
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _couponAmountController = TextEditingController();
  final List<CouponCode> _couponCodes = [];

  PaymentCurrency _selectedCurrency = PaymentCurrency.USDC;
  bool _isPercentOff = true;

  @override
  void initState() {
    super.initState();
    _selectedWallet = _phantomWallets.first;
  }

  void _addCouponCode() {
    final amountText = _couponAmountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount != null) {
      setState(() {
        _couponCodes.add(CouponCode(percentOff: _isPercentOff, amount: amount));
        _couponAmountController.clear();
      });
    }
  }

  void _removeCouponCode(CouponCode code) {
    setState(() {
      _couponCodes.remove(code);
    });
  }

  void _submitAndNavigateToCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final tokenPayData = {
      'public_wallet_address': _selectedWallet,
      'name_of_product': _productNameController.text.trim(),
      'price_of_product': double.parse(_productPriceController.text.trim()),
      'payment_currency': _selectedCurrency.name,
      'coupon_codes': _couponCodes.map((c) => {
        'percent_off': c.percentOff,
        'amount': c.amount,
      }).toList(),
    };

    final db = FirebaseDatabase.instance.ref();
    await db.child('token_pay_accounts').push().set(tokenPayData);

    final uri = Uri(
      path: '/checkout',
      queryParameters: {
        'wallet': _selectedWallet,
        'name': _productNameController.text.trim(),
        'price': _productPriceController.text.trim(),
        'currency': _selectedCurrency.name,
        'coupons': _couponCodes
            .map((c) => '${c.percentOff ? 'p' : 'a'}-${c.amount}')
            .join(','),
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(uri: uri),
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _couponAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure A Checkout')),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Solana Wallet Address',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedWallet,
                  items: _phantomWallets
                      .map((addr) => DropdownMenuItem(value: addr, child: Text(addr)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWallet = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter a product name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _productPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Product Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter a price';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentCurrency>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Currency',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCurrency,
                  items: PaymentCurrency.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
                const SizedBox(height: 24),
                Text('Coupon Codes', style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    ToggleButtons(
                      isSelected: [_isPercentOff, !_isPercentOff],
                      onPressed: (index) => setState(() => _isPercentOff = index == 0),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Percent Off')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Amount Off')),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _couponAmountController,
                        decoration: InputDecoration(
                          labelText: _isPercentOff ? 'Percent' : 'Amount',
                          suffixText: _isPercentOff ? '%' : '\$',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.add), onPressed: _addCouponCode),
                  ],
                ),
                const SizedBox(height: 8),
                ..._couponCodes.map((c) => ListTile(
                  title: Text(
                      '${c.percentOff ? 'Percent' : 'Amount'} Off: ${c.amount}${c.percentOff ? '%' : '\$'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeCouponCode(c),
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitAndNavigateToCheckout,
                  child: const Text('Go To Checkout Page'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}