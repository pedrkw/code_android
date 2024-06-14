import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maior Número',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF242424),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelStyle: TextStyle(color: Colors.white),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController num1Controller = TextEditingController();
  TextEditingController num2Controller = TextEditingController();
  TextEditingController num3Controller = TextEditingController();
  String resultado = '';

  void calcularMaiorNumero() {
    if (!isNumeric(num1Controller.text) ||
        !isNumeric(num2Controller.text) ||
        !isNumeric(num3Controller.text)) {
      setState(() {
        resultado = 'Por favor, digite apenas números.';
      });
      return;
    }

    double? num1 = double.tryParse(num1Controller.text);
    double? num2 = double.tryParse(num2Controller.text);
    double? num3 = double.tryParse(num3Controller.text);

    if (num1 == null || num2 == null || num3 == null) {
      setState(() {
        resultado = 'Por favor, digite apenas números válidos.';
      });
      return;
    }

    double maior = num1;

    if (num2 > maior) {
      maior = num2;
    }
    if (num3 > maior) {
      maior = num3;
    }

    setState(() {
      resultado = 'O maior número é: $maior';
    });
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maior Número',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Centraliza o título
        backgroundColor: const Color(0xFF242424),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número 1'),
            ),
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número 2'),
            ),
            TextField(
              controller: num3Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número 3'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: calcularMaiorNumero,
              child: const Text('Calcular'),
            ),
            const SizedBox(
              height: 20.0,
              width: 5,
            ),
            Text(
              resultado,
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
