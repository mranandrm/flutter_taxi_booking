import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/AuthProvider.dart';


class RegisterScreen extends StatefulWidget {
  final String title;
  const RegisterScreen({super.key, required this.title});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Get Device Info
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String _deviceName = '';

  void getDeviceName() async {

    try {

      if(Platform.isAndroid)
      {

        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        // e.g. "Moto G (4)"
        _deviceName = androidInfo.model;

      }
      else if(Platform.isIOS)
      {

        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        // e.g. "iPod7,1"
        _deviceName = iosInfo.utsname.machine;

      }

    }
    catch (e) {

    }

  }

  @override
  void initState() {

    getDeviceName();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add more email validation logic if needed
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // You can add more password validation logic if needed
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                  Map creds = {
                    'name' : _nameController.text,
                    'email' : _emailController.text,
                    'password' : _passwordController.text,
                    'device_name' : _deviceName ?? 'unknown'
                  };

                  if (_formKey.currentState?.validate() ?? false) {

                    // authProvider.registerUser(
                    //   name: _nameController.text,
                    //   email: _emailController.text,
                    //   password: _passwordController.text,
                    // );

                    Provider.of<AuthProvider>(context, listen: false).registerUser(creds: creds);
                    Provider.of<AuthProvider>(context, listen: false).login(creds: creds);
                    // print(creds.toString());

                    Navigator.pop(context);

                  }

                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}