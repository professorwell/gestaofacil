// lib/pages/calculator_page.dart

import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double _first = 0;
  String _operator = '';
  bool _shouldReset = false;

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _first = 0;
        _operator = '';
        _shouldReset = false;
      } else if ('0123456789.'.contains(value)) {
        if (_display == '0' || _shouldReset) {
          _display = value;
        } else {
          _display += value;
        }
        _shouldReset = false;
      } else if ('+-×÷'.contains(value)) {
        _first = double.tryParse(_display) ?? 0;
        _operator = value;
        _shouldReset = true;
      } else if (value == '=') {
        double second = double.tryParse(_display) ?? 0;
        double result = 0;
        switch (_operator) {
          case '+': result = _first + second; break;
          case '-': result = _first - second; break;
          case '×': result = _first * second; break;
          case '÷': result = second != 0 ? _first / second : 0; break;
        }
        _display = result.toString();
        _operator = '';
        _shouldReset = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '7','8','9','÷',
      '4','5','6','×',
      '1','2','3','-',
      'C','0','.','+',
      '='];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),  
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: buttons.map((b) {
                return ElevatedButton(
                  onPressed: () => _onPressed(b),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    b,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
