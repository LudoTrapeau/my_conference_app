import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

class PaymentPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    _PaymentPageState();
  }

}

class _PaymentPageState extends State<PaymentPage> {
  var publicKey = 'pk_test_fa23a8cdc46981db9960f0457a1f365e45220aa7';

  @override
  void initState() {
    PaystackPlugin.initialize(
        publicKey: publicKey);
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}