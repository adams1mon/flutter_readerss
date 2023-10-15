import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_readrss/styles/styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).background,
      body: Scrollable(
        viewportBuilder: (context, position) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ReadRss",
                  style: TextStyle(
                    color: colors(context).primary,
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Arial",
                  )),
              const SizedBox(
                height: 140,
              ),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// Define a custom Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // dispose of the controller objects
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              constraints: BoxConstraints(maxWidth: 340),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(BORDER_RADIUS),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              constraints: BoxConstraints(maxWidth: 340),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(BORDER_RADIUS),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 80
          ),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: roundedBorders(),
              backgroundColor: colors(context).primary,
              foregroundColor: colors(context).onPrimary,
              minimumSize: const Size(340, 40),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
            onPressed: (
                // no validation in this case
                ) {},
            style: OutlinedButton.styleFrom(
              shape: roundedBorders(),
              backgroundColor: colors(context).surface,
              foregroundColor: colors(context).onSurface,
              minimumSize: const Size(340, 40),
            ),
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }
}
