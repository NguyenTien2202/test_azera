import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<Map<String, String>> getCalculationHistory() {
    return calculationHistory;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> calculationHistory =
        getCalculationHistory(); // Lấy danh sách lịch sử tính toán

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
      ),
      body: ListView.builder(
        itemCount: calculationHistory.length,
        itemBuilder: (context, index) {
          Map<String, String> calculation = calculationHistory[index];
          String? expression = calculation['expression'];
          String? result = calculation['result'];

          return ListTile(
            title: Text(expression ?? ''),
            subtitle: Text(result ?? ''),
          );
        },
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
  String input = '';
  String output = '';
  String ansValue = '';

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        actions: [
          IconButton(
              onPressed: onHistoryPressed,
              icon: const Icon(Icons.history_rounded)),
        ],
      ),
      body: Column(
        children: <Widget>[
          /// Input Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                input,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ),

          /// Output Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Text(
                output,
                style: const TextStyle(
                    fontSize: 36.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          /// Keyboard Layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("("),
              buildButton(")"),
              buildButton("%"),
              buildButton("C"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("7"),
              buildButton("8"),
              buildButton("9"),
              buildButton("÷"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("4"),
              buildButton("5"),
              buildButton("6"),
              buildButton("x"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("1"),
              buildButton("2"),
              buildButton("3"),
              buildButton("-"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("0"),
              buildButton("."),
              buildButton("="),
              buildButton("+"),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        onButtonPressed(buttonText);
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }

  bool isValidExpression(String expression) {
    try {
      // Check conditions to determine the validity of the expression
      if (expression.isEmpty) {
        return false; // Expression must not be empty
      }

      // Check if the expression contains any invalid characters
      final validCharacters = RegExp(r'^[0-9+\-x÷().]+$');
      if (!validCharacters.hasMatch(expression)) {
        return false; // Expression contains invalid characters
      }

      // Check if the expression has consecutive operators
      final operators = RegExp(r'[\+\-x÷][\+\-x÷]');
      if (operators.hasMatch(expression)) {
        return false; // Consecutive operators found
      }

      // Check if the expression has properly formatted parentheses pairs
      final openParenthesisCount = expression.split('(').length - 1;
      final closeParenthesisCount = expression.split(')').length - 1;
      if (openParenthesisCount != closeParenthesisCount) {
        return false; // Mismatched number of opening and closing parentheses
      }

      // Check if a closing parenthesis immediately follows an opening parenthesis
      final parenthesisFollowedByClose = RegExp(r'\([\+\-x÷)]');
      if (parenthesisFollowedByClose.hasMatch(expression)) {
        return false; // Closing parenthesis immediately follows an opening parenthesis
      }

      // Check if an opening parenthesis follows an operator
      final operatorFollowedByParenthesis = RegExp(r'[\+\-x÷]\(');
      if (operatorFollowedByParenthesis.hasMatch(expression)) {
        return false; // Opening parenthesis follows an operator
      }

      // Check if an operator is at the end of the expression
      final lastChar = expression[expression.length - 1];
      if (lastChar == '+' ||
          lastChar == '-' ||
          lastChar == 'x' ||
          lastChar == '÷') {
        return false; // Operator at the end of the expression
      }

      // All checks passed, expression is valid
      return true;
    } catch (e) {
      return false; // Error occurred while validating the expression
    }
  }

// Define a function to handle button clicks
  void onButtonPressed(String value) {
    if (value == '=') {
      // Check if the expression is valid
      if (isValidExpression(input)) {
        // Calculate and update the result
        final result = calculate(input);
        return setState(() {
          output = result;
        });
      } else {
        // Invalid expression, handle corresponding error
        return setState(() {
          output = 'Error';
        });
      }
    }

    if (value == 'C') {
      // Clear the input and output
      return setState(() {
        input = '';
        output = '';
      });
    }

    if (canAppendValue(input, value)) {
      // Append the value to the input
      return setState(() {
        input += value;
      });
    }
  }

  void showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calculation History'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: calculationHistory.length,
                    itemBuilder: (context, index) {
                      Map<String, String> calculation =
                          calculationHistory[index];
                      String expression = calculation['expression']!;
                      return ListTile(
                        title: Text(expression),
                        onTap: () {
                          // Replace current input with selected expression
                          setState(() {
                            input = expression;
                          });
                          Navigator.pop(context); // Close the dialog
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: calculationHistory.length,
                    itemBuilder: (context, index) {
                      Map<String, String> calculation =
                          calculationHistory[index];
                      String result = calculation['result']!;
                      return ListTile(
                        title: Text(result),
                        onTap: () {
                          // Replace current output with selected result
                          setState(() {
                            output = result;
                          });
                          Navigator.pop(context); // Close the dialog
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onHistoryPressed() {
    showHistoryDialog(context);
  }

  void loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('calculation_history');

    if (historyJson != null) {
      List<dynamic> historyList = jsonDecode(historyJson);
      historyList.forEach((item) {
        Map<String, String> calculation = {
          'expression': item['expression'],
          'result': item['result'],
        };
        calculationHistory.add(calculation);
      });

      setState(() {
        // Set last calculation as current input and output
        Map<String, String> lastCalculation = calculationHistory.last;
        input = lastCalculation['expression']!;
        output = lastCalculation['result']!;
      });
    }
  }
}

bool canAppendValue(String currentInput, String nextValue) {
  if (nextValue == '.') {
    if (currentInput.contains('.') || currentInput.isEmpty) {
      return false; // Cannot append a decimal point if it already exists or the input is empty
    }
  } else if (nextValue == '(') {
    if (currentInput.isEmpty) {
      return true; // Can append an opening parenthesis if the input is empty
    }
    final lastChar = currentInput[currentInput.length - 1];
    if (lastChar == '+' ||
        lastChar == '-' ||
        lastChar == 'x' ||
        lastChar == '÷') {
      return true; // Can append an opening parenthesis after an operator
    }
    return false; // Cannot append an opening parenthesis in other cases
  } else if (nextValue == ')') {
    if (currentInput.isEmpty) {
      return false; // Cannot append a closing parenthesis if the input is empty
    }
    final openParenthesisCount = currentInput.split('(').length - 1;
    final closeParenthesisCount = currentInput.split(')').length - 1;
    if (openParenthesisCount > closeParenthesisCount) {
      return true; // Can append a closing parenthesis if a corresponding opening parenthesis exists
    }
    return false; // Cannot append a closing parenthesis in other cases
  } else if (nextValue == '+' ||
      nextValue == '-' ||
      nextValue == 'x' ||
      nextValue == '÷') {
    if (currentInput.isEmpty) {
      return false; // Cannot append an operator if the input is empty
    }
    final lastChar = currentInput[currentInput.length - 1];
    if (lastChar == '+' ||
        lastChar == '-' ||
        lastChar == 'x' ||
        lastChar == '÷') {
      return false; // Cannot append an operator if another operator is immediately before
    }
    return true; // Can append an operator in other cases
  } else {
    if (currentInput.isNotEmpty) {
      final lastChar = currentInput[currentInput.length - 1];
      if (lastChar == ')' ||
          lastChar == '+' ||
          lastChar == '-' ||
          lastChar == 'x' ||
          lastChar == '÷') {
        return true; // Can append an operator after a closing parenthesis or another operator
      }
    }
    return true; // Can append a number after an operator
  }

  return true; // The next value is valid
}

List<Map<String, String>> calculationHistory = [];

String calculate(String expression) {
  try {
    String sanitizedExpression =
        expression.replaceAll('x', '*').replaceAll('÷', '/');
    Parser p = Parser();
    Expression exp = p.parse(sanitizedExpression);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    // Format the result to remove trailing zeros if it's an integer
    String result = eval.toString();
    if (eval % 1 == 0) {
      result = eval.toInt().toString();
    }

    saveHistory(expression, result); // Save the calculation history
    return result;
  } catch (e) {
    return 'Error';
  }
}

void saveHistory(String expression, String result) async {
  Map<String, String> calculation = {
    'expression': expression,
    'result': result,
  };
  calculationHistory.add(calculation);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String historyJson = jsonEncode(calculationHistory);
  await prefs.setString('calculation_history', historyJson);
}
