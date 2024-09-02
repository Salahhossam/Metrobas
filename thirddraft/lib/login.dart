import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/page_one.dart';

import 'register.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // var email = TextEditingController();
  // var password = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  DateTime? lastBackPressTime;
  bool _isLoading = false;

  Future<Map<String, dynamic>?> _performAuthentication(context) async {
    final String email = emailController.text;
    final String password = passwordController.text;

    const String apiUrl = 'http://192.168.1.9:8000/api/auth/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'userName': email,
          'password': password,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      log(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['token'];

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        // final userDto = responseData['userDto'];
        // final String? savedPlaces = userDto['savedPlaces'] as String?;
        // final String? imageAssetPath = userDto['image'] as String?;
        // prefs.setString('image', imageAssetPath ?? '');
        // prefs.setString('savedPlaces', savedPlaces ?? '');
        // final String userName = userDto['userName'];
        // final String userEmail = userDto['email'];
        // prefs.setString('userName', userName);
        // prefs.setString('userEmail', userEmail);

        setState(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PageOne()),
          );
        });
        return responseData;
      } else {
        showToast(
          'Invalid Email or Password',
          context: context,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.fade,
          position: const StyledToastPosition(
              offset: 140, align: Alignment.bottomCenter),
          animDuration: const Duration(seconds: 1),
          duration: const Duration(seconds: 4),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear,
        );
        log('Authentication failed: ${response.statusCode}');
      }
    } catch (error) {
      log('Error during authentication: $error');
    }
    return null;
  }

  var formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return SafeArea(
          child: Listener(
            onPointerDown: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              body: WillPopScope(
                onWillPop: () async {
                  DateTime now = DateTime.now();
                  if (lastBackPressTime == null ||
                      now.difference(lastBackPressTime!) >
                          const Duration(seconds: 2)) {
                    lastBackPressTime = now;
                    showToast(
                      'Press again to exit',
                      context: context,
                      animation: StyledToastAnimation.scale,
                      reverseAnimation: StyledToastAnimation.fade,
                      position: const StyledToastPosition(
                        align: Alignment.bottomCenter,
                        offset: 40,
                      ),
                      animDuration: const Duration(seconds: 1),
                      duration: const Duration(seconds: 3),
                      curve: Curves.elasticOut,
                      reverseCurve: Curves.linear,
                    );
                    return false;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                  return true;
                },
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                color: const Color.fromRGBO(8, 15, 44, 1),
                                fontSize:
                                    MediaQuery.of(context).size.width * .11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * .2,
                            ),
                            TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(
                                    Icons.email,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        MediaQuery.of(context).size.width * .04,
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              .01,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              .04),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  return null;
                                }),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * .04,
                            ),
                            TextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !_isPasswordVisible,
                                onFieldSubmitted: (String value) {},
                                onChanged: (String value) {},
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        MediaQuery.of(context).size.width * .04,
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              .01,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              .04),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the password';
                                  }
                                  return null;
                                }),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * .04,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(8, 15, 44, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              width: double.infinity,
                              child: MaterialButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (formKey.currentState != null &&
                                            formKey.currentState!.validate()) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          final data =
                                              await _performAuthentication(
                                                  context);
                                          if (data != null) {
                                            cubit.userInfoData(data);
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PageOne()),
                                            );
                                          }
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * .04,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account?',
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const SingUp(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register Now',
                                    style: TextStyle(
                                        color: Color.fromRGBO(8, 15, 44, 1)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
