import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

const yellow = Color(0xFFFFC107);
const pageColor = Color(0xFFFFF8FF);

void main() => runApp(const TaxiFareApp());

class TaxiFareApp extends StatelessWidget {
  const TaxiFareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi Fare Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: yellow),
        scaffoldBackgroundColor: pageColor,
      ),
      home: const SplashScreenUi(),
    );
  }
}

class TaxiLogo extends StatelessWidget {
  const TaxiLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/taxi.webp',
      width: 190,
      height: 190,
      fit: BoxFit.contain,
      semanticLabel: 'รถแท็กซี่สีเหลือง',
    );
  }
}

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const TaxiFareUi()),
      );
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TaxiLogo(),
            SizedBox(height: 14),
            Text(
              'Taxi Fare Calculator',
              style: TextStyle(
                color: Color(0xFF297DAB),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('คำนวณค่าโดยสารแท็กซี่'),
            SizedBox(height: 24),
            CircularProgressIndicator(color: yellow),
          ],
        ),
      ),
    );
  }
}

double calculateTaxiFare(double km, double minutes) {
  double fare = 35.0;
  double previous = 1.0;
  const tiers = [
    (10.0, 6.50),
    (20.0, 7.00),
    (40.0, 8.00),
    (60.0, 8.50),
    (80.0, 9.00),
    (double.infinity, 10.50),
  ];

  for (final (limit, rate) in tiers) {
    if (km <= previous) break;
    fare += (math.min(km, limit) - previous) * rate;
    previous = limit;
  }

  return fare + minutes * 3;
}

class TaxiFareUi extends StatefulWidget {
  const TaxiFareUi({super.key});

  @override
  State<TaxiFareUi> createState() => _TaxiFareUiState();
}

class _TaxiFareUiState extends State<TaxiFareUi> {
  final distance = TextEditingController();
  final traffic = TextEditingController();
  double fare = 0;

  @override
  void dispose() {
    distance.dispose();
    traffic.dispose();
    super.dispose();
  }

  void calculate() {
    final km = double.tryParse(distance.text.trim());
    final minutes = double.tryParse(traffic.text.trim());
    FocusScope.of(context).unfocus();

    final messages = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (km == null ||
        !km.isFinite ||
        km <= 0 ||
        minutes == null ||
        !minutes.isFinite ||
        minutes < 0) {
      setState(() => fare = 0);
      messages.showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE53935),
          content: Text('⚠ กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง'),
        ),
      );
      return;
    }

    setState(() => fare = calculateTaxiFare(km, minutes));
  }

  void reset() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    distance.clear();
    traffic.clear();
    setState(() => fare = 0);
  }

  Widget input(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget button(String label, Color color, VoidCallback onPressed) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taxi Fare',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: yellow,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(36, 36, 36, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TaxiLogo()),
                  const SizedBox(height: 14),
                  const Text(
                    'คำนวณค่าโดยสารแท็กซี่',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  input('ระยะทาง (กิโลเมตร) 🛣️', 'กรุณากรอกระยะทาง', distance),
                  const SizedBox(height: 16),
                  input('เวลารถติด (นาที) ⏰', 'กรุณากรอกเวลารถติด', traffic),
                  const SizedBox(height: 24),
                  button('คำนวณค่าโดยสาร', yellow, calculate),
                  const SizedBox(height: 10),
                  button('ยกเลิก', const Color(0xFF9E9E9E), reset),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECB3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ค่าโดยสารแท็กซี่',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          fare.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF44336),
                          ),
                        ),
                        const Text('บาท', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}