import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          labelStyle: const TextStyle(color: Colors.blueAccent),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      home: const CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _amountController = TextEditingController();
  final _currencyCodeInputController = TextEditingController();
  final _currencyCodeOutputController = TextEditingController();
  double? _convertedValue;
  bool _isLoading = false;
  String? _outputCurrencyCode;

  Future<void> _convertCurrency() async {
    final amount = double.tryParse(_amountController.text);
    final currencyInput = _currencyCodeInputController.text;
    final currencyOutput = _currencyCodeOutputController.text;

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um número válido!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://open.er-api.com/v6/latest/$currencyInput')); // Usando ExchangeRate-API
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][currencyOutput];
        setState(() {
          _convertedValue = amount * rate;
          _outputCurrencyCode = currencyOutput;
        });
      } else {
        throw Exception('Falha ao carregar a taxa de câmbio.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao converter a moeda: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Digite o valor',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _currencyCodeInputController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Moeda de entrada (Ex: BRL ou USD)',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _currencyCodeOutputController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Moeda de saída (Ex: PLN ou EUR)',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _convertCurrency,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Converter'),
                ),
                const SizedBox(height: 20),
                if (_convertedValue != null)
                  Text(
                    'Valor convertido: $_outputCurrencyCode \$${_convertedValue?.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  )
                else
                  const Text(
                    'Digite os valores e converta',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
