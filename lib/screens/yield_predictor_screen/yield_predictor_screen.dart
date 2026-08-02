import 'package:flutter/material.dart';

class YieldPredictorScreen extends StatefulWidget {
  const YieldPredictorScreen({super.key});

  @override
  State<YieldPredictorScreen> createState() => _YieldPredictorScreenState();
}

class _YieldPredictorScreenState extends State<YieldPredictorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yield Predictor'),
      ),
      body: const Center(
        child: Text(
          'Yield Predictor Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}