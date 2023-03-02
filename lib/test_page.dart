import 'package:flutter/material.dart';

import 'screen_home.dart';

class ScreenLogin extends StatelessWidget {
  ScreenLogin({super.key});

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  //bool _isDataMatched = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'value is Empty';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'value is Empty';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      checkLogin(context);
                    } else {
                      print('data empty');
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Login'))
            ],
          ),
        ),
      ),
    ));
  }

  void checkLogin(BuildContext ctx) {
    final _username = _usernameController.text;
    final _password = _passwordController.text;
    if (_username == _password) {
      print('username and password match');
      //go to home

      Navigator.pushReplacement(
          ctx, MaterialPageRoute(builder: (ctx1) => ScreenHome()));
    } else {
      print('username and password does not match');
      const _errorMessage = 'Username Password does not match';
      //snackbar

      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin:  EdgeInsets.all(10),
        content: Text(_errorMessage),
        duration:   Duration(seconds: 10),
      ));
    }
  }
}
