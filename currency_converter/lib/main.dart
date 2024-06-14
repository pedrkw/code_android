import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'currency_descriptions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      background: Colors.grey[900],
    );

    return MaterialApp(
      title: 'Conversor de Moedas',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
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
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
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
  const CurrencyConverterPage({Key? key}) : super(key: key);

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _amountController = TextEditingController();
  double? _convertedValue;
  bool _isLoading = false;
  String? _outputCurrencyCode;
  String _currencyInput = 'BRL';
  String _currencyOutput = 'USD';
  final List<String> _currencies =
      currencyDescriptions.keys.toList(); // Utiliza as chaves do mapa
  final Map<String, String> _currencyDescriptions =
      currencyDescriptions; // Utiliza o mapa de descrições

  Future<void> _convertCurrency() async {
    final amount = double.tryParse(_amountController.text);

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
          'https://open.er-api.com/v6/latest/$_currencyInput')); // Usando ExchangeRate-API
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_currencyOutput];
        setState(() {
          _convertedValue = amount * rate;
          _outputCurrencyCode = _currencyOutput;
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
        title: const Text('Conversor de Moedas'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Digite o valor e selecione as moedas para conversão:',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Digite o valor a ser convertido',
                    prefixIcon:
                        Icon(Icons.monetization_on, color: Colors.blueAccent),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Moeda de Entrada',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const Text(
                          'Escolha a moeda que você possui',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _currencyInput,
                          items: _currencies.map((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currencyInput = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currencyDescriptions[_currencyInput] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Moeda de Saída',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const Text(
                          'Escolha a moeda para a qual deseja converter',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _currencyOutput,
                          items: _currencies.map((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currencyOutput = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currencyDescriptions[_currencyOutput] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
