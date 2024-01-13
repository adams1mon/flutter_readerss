import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:flutter_readrss/use_case/exceptions/use_case_exceptions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    Key? key,
    required this.register,
    required this.login,
    required this.guestLogin,
  }) : super(key: key);

  final Future<void> Function(String email, String password)
      register;
  final Future<void> Function(String email, String password) login;
  final void Function() guestLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).background,
      body: MainContainer(
        register: register,
        login: login,
        guestLogin: guestLogin,
      ),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({
    Key? key,
    required this.register,
    required this.login,
    required this.guestLogin,
  }) : super(key: key);

  final Future<void> Function(String email, String password)
      register;
  final Future<void> Function(String email, String password) login;
  final void Function() guestLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: MainContent(
                register: register,
                login: login,
                guestLogin: guestLogin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({
    Key? key,
    required this.register,
    required this.login,
    required this.guestLogin,
  }) : super(key: key);

  final Future<void> Function(String email, String password)
      register;
  final Future<void> Function(String email, String password) login;
  final void Function() guestLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const TitleText(),
        AuthForm(
          register: register,
          login: login,
          guestLogin: guestLogin,
        ),
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
  const AuthForm({
    Key? key,
    required this.register,
    required this.login,
    required this.guestLogin,
  }) : super(key: key);

  final Future<void> Function(String email, String password)
      register;
  final Future<void> Function(String email, String password) login;
  final void Function() guestLogin;

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
        await widget.login(emailController.text, passwordController.text);
      } on UseCaseException catch (e) {
        _snackbarMessage(e.message ?? "Login failed. Check your credentials");
      } catch (e) {
        _snackbarMessage('Login failed. Check your credentials');
      }
    }
  }

  Future<void> onRegisterPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.register(emailController.text, passwordController.text);
      } on UseCaseException catch (e) {
        _snackbarMessage(e.message ??
            "Registration failed. Try a different email or password.");
      } catch (e) {
        _snackbarMessage(
            'Registration failed. Try a different email or password.');
      }
    }
  }

  void _snackbarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                onGuestLoginPressed: widget.guestLogin,
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
    required this.onLoginPressed,
    required this.onRegisterPressed,
    required this.onGuestLoginPressed,
  }) : super(key: key);

  final void Function() onLoginPressed;
  final void Function() onRegisterPressed;
  final void Function() onGuestLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onLoginPressed,
          style: ElevatedButton.styleFrom(
            shape: roundedBorders(),
            backgroundColor: colors(context).primary,
            foregroundColor: colors(context).onPrimary,
            minimumSize: const Size(340, 40),
          ),
          child: const Text('Login'),
        ),
        ElevatedButton(
          onPressed: onRegisterPressed,
          style: ElevatedButton.styleFrom(
            shape: roundedBorders(),
            backgroundColor: colors(context).primary,
            foregroundColor: colors(context).onPrimary,
            minimumSize: const Size(340, 40),
          ),
          child: const Text('Register'),
        ),
        OutlinedButton(
          onPressed: onGuestLoginPressed,
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
