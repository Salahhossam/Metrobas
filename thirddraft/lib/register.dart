import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'package:thirddraft/login.dart';

class SingUp extends StatefulWidget {
  const SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

enum Gender { male, female }

class _SingUpState extends State<SingUp> {
  // var username = TextEditingController();
  // var email = TextEditingController();
  // var password = TextEditingController();
  // var phone = TextEditingController();
  // Gender selectGender = Gender.MALE;
  final _formKey = GlobalKey<FormState>();
  Gender _gender = Gender.male;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fisrtnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  Future<void> _performRegistration(context) async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    final String phone = phoneController.text;
    final String gender = _gender == Gender.male ? 'MALE' : 'FEMALE';
    final String firstname = fisrtnameController.text;
    final String lastname = lastnameController.text;
    final String age = ageController.text;
    final String confrirmpassword = confirmPasswordController.text;

    const String apiUrl = 'http://192.168.1.9:8000/api/auth/register';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'email': email,
          'password': password,
          'userName': username,
          'phone': phone,
          'gender': gender,
          'firstName': firstname,
          'lastName': lastname,
          'age': int.parse(age),
          'confirmPassword': confrirmpassword,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      log(response.body);
      if (response.statusCode == 201) {
        emailController.clear();
        passwordController.clear();
        usernameController.clear();
        phoneController.clear();
        fisrtnameController.clear();
        lastnameController.clear();
        ageController.clear();
        confirmPasswordController.clear();
        showToast(
          'Email Created',
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
      } else {
        showToast(
          'Invalid Data',
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
        log('Registration failed: ${response.statusCode}');
      }
    } catch (error) {
      log('Error during registration: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        onPointerDown: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const Login()),
              );
              return true; // Return true to allow back navigation
            },
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              child: Form(
                key: _formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: const Color.fromRGBO(8, 15, 44, 1),
                              fontSize: MediaQuery.of(context).size.width * .11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: fisrtnameController,
                            decoration: InputDecoration(
                              labelText: 'Firstname',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              fisrtnameController.text = value!;
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            controller: lastnameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Lastname',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              lastnameController.text = value!;
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            // onSaved: (value) {
                            //   _username = value;
                            // },
                            controller: usernameController,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            // onSaved: (value) {
                            //   _email = value;
                            // },
                            controller: emailController,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            // onSaved: (value) {
                            //   _password = value;
                            // },
                            controller: passwordController,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(
                                  MediaQuery.of(context).size.width * .04,
                                )),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                            // onSaved: (value) {
                            //   _phone = value;
                            // },
                            controller: phoneController,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: const Icon(Icons.numbers),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              ageController.text = value!;
                            },
                            controller: ageController,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * .04,
                          ),
                          DropdownButtonFormField<Gender>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * .04,
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * .01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04),
                            ),
                            items: Gender.values
                                .map((gender) => DropdownMenuItem<Gender>(
                                      value: gender,
                                      child: Text(gender == Gender.male
                                          ? 'Male'
                                          : 'Female'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your Gender';
                              }
                              return null;
                            },
                          ),
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
                                      if (_formKey.currentState != null &&
                                          _formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await _performRegistration(
                                            context); // Wait for registration
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Text(
                                      'Sign Up',
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
                                'already have an account?',
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                ),
                                child: const Text(
                                  'login',
                                  style: TextStyle(
                                      color: Color.fromRGBO(8, 15, 44, 1)),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
