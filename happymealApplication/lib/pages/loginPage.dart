import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happymeal_application/models/login_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  int _passwordLength = 0;
  bool _showPassword = false;
  String? _username;
  String? _password;

  String? _validateTextField(String fieldName, String? value, int length) {
    if (value!.isEmpty) {
      return '$fieldName must not be empty';
    }
    if (value.length <= length) {
      return '$fieldName must longer than $length chars';
    }
      return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Input is invalid'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    final loginModel = context.read<LoginModel>();

    var registerMessage = '';

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _username!,
            password: _password!,
          );

      registerMessage =
          'Account created successfully for ${credential.user?.uid}';

      loginModel.username = _username!;
      loginModel.userId = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      registerMessage = e.code;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(registerMessage),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // _username = context.read<LoginModel>().username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Login Page'),
      ),
      body:  Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: _username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person),
                  hintText: 'Enter your username',
                  labelText: 'Username',
                ),
                onSaved: (value) {
                  _username = value;
                },
                validator: (value) {
                  return _validateTextField('Username', value, 5);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  suffixText: '$_passwordLength',
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.remove_red_eye),
                    onLongPress: () async {
                      setState(() {
                        _showPassword = true;
                      });

                      await Future.delayed(Duration(seconds: 5));
                      
                      setState(() {
                        _showPassword = false;
                      });
                    },
                  ),
                ),
                onSaved: (value) {
                  _password = value;
                },
                onChanged: (value) {
                  setState(() {
                    _passwordLength = value.length;
                  });
                },
                validator: (value) {
                  return _validateTextField('Password', value, 5);
                },
              ),
            ),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () async {
                if(!_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Input is invalid'),
                    ),
                  );
                  return;
                }

                _formKey.currentState!.save();

                final loginModel = context.read<LoginModel>();

                var loginMessage = '';

                try {
                  final credential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                      email: _username!,
                      password: _password!,
                    );

                  loginMessage = 'Signed in successfully for ${credential.user?.uid}';
                  loginModel.username = _username!;
                  loginModel.userId = credential.user!.uid;

                } on FirebaseAuthException catch (e) {
                  loginMessage = 'Error ${e.message}';
                }

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loginMessage),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            TextButton(
              onPressed: _register,
              child: Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
