import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtimechatapp/Auth.dart';
import 'package:realtimechatapp/Input.dart';
import 'package:realtimechatapp/pages/Home.dart';
import 'package:realtimechatapp/pages/Login.dart';
import 'package:realtimechatapp/state/user/UserCubit.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String emailError = "";
  String passwordError = "";
  String nameError = "";
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    log(value, name: "data");
    if (value.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
    } else if (!isEmailValid(value)) {
      setState(() {
        emailError = 'Enter a valid email address';
      });
    } else {
      setState(() {
        emailError = "";
      });
    }
  }

  bool isEmailValid(String email) {
    // Basic email validation using regex
    // You can implement more complex validation if needed
    return RegExp(r'^[\w-\.]+@[a-zA-Z]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  _validatePassword(String value) {
    if (value.isEmpty || value == "") {
      setState(() {
        passwordError = 'Password is required';
      });
    } else {
      setState(() {
        passwordError = "";
      });
    }
  }

  _validateName(String value) {
    if (value.isEmpty || value == "") {
      setState(() {
        nameError = 'Name is required';
      });
    } else {
      setState(() {
        nameError = "";
      });
    }
  }

  void submit() {
    _validateEmail(emailController.text);
    _validatePassword(passwordController.text);
    _validateName(nameController.text);
    if (emailError == "" &&
        passwordError == "" &&
        loading == false &&
        nameError == "") {
      setState(() {
        loading = true;
      });
      Auth auth = Auth(callback: () {});

      auth
          .signUp(emailController.text, passwordController.text,
              nameController.text)
          .then((data) {
        if (data['error'] != "") {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['error'])));
        } else {
          context.read<UserCubit>().login(data['user']);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                        loginTry: true,
                      )),
              (Route<dynamic> route) => false);
        }
        setState(() {
          loading = false;
        });
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height - 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(),
                          child: Column(
                            children: [
                              const Text(
                                "Welcome :)",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Input(
                                      controller: emailController,
                                      title: "Email",
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      error: emailError,
                                      keyboard: TextInputType.emailAddress,
                                      validate: _validateEmail,
                                      gradiantColors: [
                                        ThemeData().primaryColorDark,
                                        ThemeData().secondaryHeaderColor
                                      ],
                                    ),
                                    Input(
                                      controller: passwordController,
                                      title: "Password",
                                      error: passwordError,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      keyboard: TextInputType.text,
                                      obscureText: true,
                                      enableSuggestion: false,
                                      autocorrect: false,
                                      validate: _validatePassword,
                                      gradiantColors: [
                                        ThemeData().primaryColorDark,
                                        ThemeData().secondaryHeaderColor
                                      ],
                                    ),
                                    Input(
                                      controller: nameController,
                                      title: "Name",
                                      error: nameError,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      keyboard: TextInputType.text,
                                      obscureText: false,
                                      enableSuggestion: true,
                                      autocorrect: true,
                                      validate: _validateName,
                                      gradiantColors: [
                                        ThemeData().primaryColorDark,
                                        ThemeData().secondaryHeaderColor
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: submit,
                                  style: const ButtonStyle(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      loading
                                          ? const SizedBox(
                                              child:
                                                  CircularProgressIndicator(),
                                              height: 15,
                                              width: 15,
                                            )
                                          : const SizedBox(),
                                      loading
                                          ? const SizedBox(
                                              width: 5,
                                            )
                                          : const SizedBox(),
                                      const Text("Register"),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                child: const Text(
                                  "have an Account? login",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()),
                                      (Route<dynamic> route) => false);
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    )))));
  }
}
