import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CalculatorScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FE),
      body: Center(
        child: SvgPicture.asset('assets/splash.svg',
          width: screenSize.width * 3,  // 100% of the screen width
          height: screenSize.height * 2, // 100% of the screen height
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Colors for different buttons
  static const Color numberButtonColor = Color(0xFFF5F6FA); // Light gray
  static const Color operatorButtonColor = Color(0xFFEDF6FF); // Light blue
  static const Color backspaceButtonColor = Color(0xFFF5F6FA); // Light pink (for ⌫)
  static const Color acButtonColor = Color(0xFFFFEEF3); // Light yellow (for DEL)
  static const Color equalsButtonColor = Color(0xFF55A1FF); // Bright blue
  static const Color textColor = Color(0xFF494949); // Dark gray for numbers
  static const Color operatorTextColor = Color(0xFF55A1FF); // Blue for operators
  static const Color backspaceTextColor = Color(0xFFFA5E4A); // Pink for ⌫
  static const Color acTextColor = Color(0xFFFF7EA8); // Orange for DEL
  static const Color resultColor = Color(0xFF00FF00); // Green for result
  static const Color errorColor = Color(0xFFFF0000); // Red for error

  String _output = '';
  String _operationSequence = '';
  bool _isNewNumber = true;
  bool _hasError = false;
  bool _isResultDisplayed = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_hasError || _isResultDisplayed) {
        _output = '';
        _operationSequence = '';
        _isNewNumber = true;
        _hasError = false;
        _isResultDisplayed = false;
      }
      if (_isNewNumber) {
        _operationSequence += number;
        _isNewNumber = false;
      } else {
        _operationSequence += number;
      }
      _output = _operationSequence;
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_hasError) {
        return;
      }
      if (_isResultDisplayed) {
        _operationSequence = _output;
        _isResultDisplayed = false;
      }
      if (_operationSequence.isNotEmpty && !_isNewNumber) {
        final lastChar = _operationSequence[_operationSequence.length - 1];
        if ('+-×÷'.contains(lastChar)) {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - 1);
        }
        _operationSequence += ' ' + operation + ' ';
        _isNewNumber = true;
      }
      _output = _operationSequence;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_hasError || _operationSequence.isEmpty) {
        return;
      }
      try {
        final result = _evaluateExpression(_operationSequence);
        _output = result;
        _isResultDisplayed = true;
      } catch (e) {
        _output = 'Error';
        _hasError = true;
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final parsedExpression = Expression.parse(exp);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(parsedExpression, {});
      if (result == double.infinity || result == double.negativeInfinity) {
        throw Exception('Division by zero');
      }
      return result % 1 == 0 ? result.toInt().toString() : result.toString();
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  void _onClearPressed() {
    setState(() {
      _output = '';
      _operationSequence = '';
      _isNewNumber = true;
      _hasError = false;
      _isResultDisplayed = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        _operationSequence = _operationSequence.substring(0, _operationSequence.length - 1);
        _output = _operationSequence;
      }
    });
  }

  void _onToggleSignPressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        if (lastNumber.startsWith('-')) {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + lastNumber.substring(1);
        } else {
          _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + '-' + lastNumber;
        }
        _output = _operationSequence;
      }
    });
  }

  void _onPercentagePressed() {
    setState(() {
      if (_operationSequence.isNotEmpty) {
        if (_operationSequence.endsWith(' ')) {
          return;
        }
        final lastNumber = _operationSequence.split(' ').last;
        final percentage = (double.parse(lastNumber) / 100).toString();
        _operationSequence = _operationSequence.substring(0, _operationSequence.length - lastNumber.length) + percentage;
        _output = _operationSequence;
      }
    });
  }

  Widget _buildButton(
    String text, {
    Color backgroundColor = numberButtonColor,
    Color textColor = textColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: MaterialButton(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () {
              if (text == 'C') {
                _onClearPressed();
              } else if (text == '⌫') {
                _onBackspacePressed();
              } else if (text == 'AC') {
                _onClearPressed();
              } else if (text == '+/-') {
                _onToggleSignPressed();
              } else if (text == '%') {
                _onPercentagePressed();
              } else if (text == '=') {
                _onEqualsPressed();
              } else if ('+-×÷'.contains(text)) {
                _onOperationPressed(text);
              } else {
                _onNumberPressed(text);
              }
            },
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FE), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    bottom: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: SvgPicture.asset(
                    'assets/logo.svg',  // Replace with your SVG path
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _output,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: _hasError ? errorColor : (_isResultDisplayed ? resultColor : Color(0xFF494949)),  // Red for error, green for result, dark gray for numbers
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Keypad
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildButton('+/-'),
                        _buildButton('%'),
                        _buildButton('⌫',
                            backgroundColor: backspaceButtonColor,
                            textColor: backspaceTextColor),
                        _buildButton('÷',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('×',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('+',
                            backgroundColor: operatorButtonColor,
                            textColor: operatorTextColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('.'),
                        _buildButton('0'),
                        _buildButton('AC',
                            backgroundColor: acButtonColor,
                            textColor: acTextColor),
                        _buildButton('=',
                            backgroundColor: equalsButtonColor,
                            textColor: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}