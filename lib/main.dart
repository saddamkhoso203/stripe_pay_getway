import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_pay_getway/home_page.dart';
import 'package:stripe_pay_getway/key.dart';


void main() async
{
 WidgetsFlutterBinding.ensureInitialized();
Stripe.publishableKey = PublishableKey;
await  Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Payment Getway',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}
