import 'package:flutter/material.dart';
import 'package:flutter_readrss/styles/styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).background,
      body: const MainContainer(),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: MainContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TitleText(),
        LoginForm(),
      ],
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Text("ReadRss",
          style: TextStyle(
            color: colors(context).primary,
            fontSize: 55,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          )),
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

  onLoginPressed() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
    }
  }

  onGuestLoginPressed() {
    Navigator.pushReplacementNamed(context, '/guestfeed');
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: FormInputContainer(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FormButtonContainer(
                onLoginPressed: onLoginPressed,
                onGuestLoginPressed: onGuestLoginPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormButtonContainer extends StatelessWidget {
  const FormButtonContainer({
    super.key,
    required void Function()? onLoginPressed,
    required Function() onGuestLoginPressed,
  })  : _onLoginPressed = onLoginPressed,
        _onGuestLoginPressed = onGuestLoginPressed;

  final void Function()? _onLoginPressed;
  final void Function()? _onGuestLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _onLoginPressed,
          style: ElevatedButton.styleFrom(
            shape: roundedBorders(),
            backgroundColor: colors(context).primary,
            foregroundColor: colors(context).onPrimary,
            minimumSize: const Size(340, 40),
          ),
          child: const Text('Login'),
        ),
        OutlinedButton(
          onPressed: _onGuestLoginPressed,
          style: OutlinedButton.styleFrom(
            shape: roundedBorders(),
            backgroundColor: colors(context).surface,
            foregroundColor: colors(context).onSurface,
            minimumSize: const Size(340, 40),
          ),
          child: const Text('Continue as Guest'),
        ),
      ],
    );
  }
}

class FormInputContainer extends StatefulWidget {
  const FormInputContainer({
    super.key,
  });

  @override
  State<FormInputContainer> createState() => _FormInputContainerState();
}

class _FormInputContainerState extends State<FormInputContainer> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: "Enter your email",
            constraints: BoxConstraints(maxWidth: 340),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
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
            hintText: "Your password",
            constraints: BoxConstraints(maxWidth: 340),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
