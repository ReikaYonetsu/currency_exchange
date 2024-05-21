import 'package:flutter/material.dart';
import 'exchange_service.dart';

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeService _exchangeService = ExchangeService();
  final TextEditingController _amountController = TextEditingController();
  double _rate = 1.0;
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    _amountController.addListener(_convert);
  }

  void _fetchExchangeRate() async {
    try {
      double rate = await _exchangeService.getExchangeRate(_fromCurrency, _toCurrency);
      setState(() {
        _rate = rate;
      });
      _convert(); // Recalculate and show the result after fetching the rate
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load exchange rate')));
    }
  }

  void _convert() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _result = (amount * _rate).toStringAsFixed(2);
    });
  }

  void _switchCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _fetchExchangeRate();
    });
  }

  void _onNumberButtonPressed(String number) {
    setState(() {
      _amountController.text = _amountController.text + number;
    });
  }

  void _onClearButtonPressed() {
    setState(() {
      _amountController.clear();
    });
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExchangeRate,
          ),
        ],
      ),
      body: Container(
        color: Colors.blue, // Set background color to blue
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDropdown(_fromCurrency, (String? newValue) {
                    setState(() {
                      _fromCurrency = newValue!;
                      _fetchExchangeRate();
                    });
                  }),
                  Text(
                    '${_getCurrencySymbol(_fromCurrency)} ${_amountController.text.isEmpty ? '0' : _amountController.text}',
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.swap_vert, size: 36, color: Colors.white),
                onPressed: _switchCurrencies,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDropdown(_toCurrency, (String? newValue) {
                    setState(() {
                      _toCurrency = newValue!;
                      _fetchExchangeRate();
                    });
                  }),
                  Text(
                    '${_getCurrencySymbol(_toCurrency)} $_result',
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Exchange Rate: 1 $_fromCurrency = $_rate $_toCurrency',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5, // Adjusted to make buttons smaller
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          textStyle: const TextStyle(fontSize: 24),
                        ),
                        onPressed: _onClearButtonPressed,
                        child: const Text('C'),
                      );
                    } else if (index == 10) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        onPressed: () => _onNumberButtonPressed('0'),
                        child: const Text('0'),
                      );
                    } else if (index == 11) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        onPressed: () => _onNumberButtonPressed('.'),
                        child: const Text('.'),
                      );
                    } else {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        onPressed: () => _onNumberButtonPressed('${index + 1}'),
                        child: Text('${index + 1}'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String currency, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: currency,
      items: ['USD', 'EUR', 'JPY'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      dropdownColor: Colors.teal,
      onChanged: onChanged,
    );
  }
}
