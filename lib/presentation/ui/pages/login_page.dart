import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

import '../const/screen_route.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).background,
      body: const MainContainer(),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
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
  const MainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TitleText(),
        AuthForm(),
      ],
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Text(
        "ReadRss",
        style: TextStyle(
          color: colors(context).primary,
          fontSize: 55,
          fontWeight: FontWeight.bold,
          fontFamily: "Arial",
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  AuthFormState createState() => AuthFormState();
}

class AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // TODO: fix async gap
        Navigator.pushReplacementNamed(context, ScreenRoute.main.route);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Check your credentials.'),
          ),
        );
      }
    }
  }

  Future<void> onRegisterPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // TODO: fix async gap
        Navigator.pushReplacementNamed(context, ScreenRoute.main.route);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Registration failed. Try a different email or password.'),
          ),
        );
      }
    }
  }

  void onGuestLoginPressed() {
    Navigator.pushReplacementNamed(context, ScreenRoute.main.route);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FormInputContainer(
                emailController: emailController,
                passwordController: passwordController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AuthButtonContainer(
                onLoginPressed: onLoginPressed,
                onRegisterPressed: onRegisterPressed,
                onGuestLoginPressed: onGuestLoginPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthButtonContainer extends StatelessWidget {
  const AuthButtonContainer({
    Key? key,
    required void Function()? onLoginPressed,
    required void Function()? onRegisterPressed,
    required void Function()? onGuestLoginPressed,
  })  : _onLoginPressed = onLoginPressed,
        _onRegisterPressed = onRegisterPressed,
        _onGuestLoginPressed = onGuestLoginPressed,
        super(key: key);

  final void Function()? _onLoginPressed;
  final void Function()? _onRegisterPressed;
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
        ElevatedButton(
          onPressed: _onRegisterPressed,
          style: ElevatedButton.styleFrom(
            shape: roundedBorders(),
            backgroundColor: colors(context).primary,
            foregroundColor: colors(context).onPrimary,
            minimumSize: const Size(340, 40),
          ),
          child: const Text('Register'),
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

class FormInputContainer extends StatelessWidget {
  const FormInputContainer({
    Key? key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  })  : _emailController = emailController,
        _passwordController = passwordController,
        super(key: key);

  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _emailController,
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
          controller: _passwordController,
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
