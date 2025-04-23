import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'key.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double amount = 20;
  Map<String, dynamic>? intentPaymentData;

  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        intentPaymentData = null;
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print("StripeException: $error");
      }
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("Payment Cancelled"),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error presenting payment sheet: $e");
      }
    }
  }

  Future<Map<String, dynamic>?> makeIntentForPayment(String amount, String currency) async {
    try {
      Map<String, dynamic> paymentInfo = {
        "amount": (int.parse(amount) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card", // fixed typo
      };

      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"), // removed extra space
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $SecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print("Stripe API error: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error making payment intent: $e");
      }
      return null;
    }
  }

  Future<void> paymentSheetInitialization(String amount, String currency) async {
    try {
      intentPaymentData = await makeIntentForPayment(amount, currency);
      if (intentPaymentData == null || !intentPaymentData!.containsKey("client_secret")) {
        if (kDebugMode) {
          print("Invalid intentPaymentData: $intentPaymentData");
        }
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Saddam Khoso",
        ),
      );

      await showPaymentSheet();
    } catch (e, s) {
      if (kDebugMode) {
        print("Error initializing payment sheet: $e");
        print(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            paymentSheetInitialization(amount.round().toString(), "USD");
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text("PAY NOW \$${amount.toString()}",
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
