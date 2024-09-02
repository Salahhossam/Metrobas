import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/edit_profile.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:thirddraft/login.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final ValueNotifier<bool> _isSaveButtonEnabled = ValueNotifier(false);
  late int userId;
  bool _iscurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_onTextChanged);
    _newPasswordController.addListener(_onTextChanged);
    _confirmNewPasswordController.addListener(_onTextChanged);
    var cubit = AppCubit.get(context);

    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
    }
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onTextChanged);
    _newPasswordController.removeListener(_onTextChanged);
    _confirmNewPasswordController.removeListener(_onTextChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _isSaveButtonEnabled.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _isSaveButtonEnabled.value = _newPasswordController.text.isNotEmpty &&
        _confirmNewPasswordController.text.isNotEmpty &&
        _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmNewPasswordController.text;
  }

 Future<void> postNewPassword(String currentPassword, String newPassword,
    String newConfirmPassword) async {
  var apiUrl = 'http://192.168.1.9:8000/api/auth/changePassword';
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse(apiUrl),
      body: json.encode(
        {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
          "confirmNewPassword": newConfirmPassword,
        },
      ),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: const SizedBox(
              height: 100, // Set the height you need
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Password updated successfully",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10), // Add some spacing
                  Text("You must login again"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.remove('token');
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                },
                child: const Text(
                  "Ok",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const EditProfile(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update Failed , Something Wrong.'),
        ),
      );
      log('Failed to send data to the API ${response.body}');
    }
  } catch (e) {
    log('Error in LatLng: $e');
  }
  return;
}

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Password'),
              toolbarHeight: 100,
              leadingWidth: 70,
              centerTitle: true,
              leading: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const EditProfile(),
                  ));
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              actions: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isSaveButtonEnabled,
                  builder: (context, isEnabled, child) {
                    return TextButton(
                      onPressed: _isLoading
                          ? null
                          : isEnabled
                              ? () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await postNewPassword(
                                      _currentPasswordController.text,
                                      _newPasswordController.text,
                                      _confirmNewPasswordController.text);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              : null,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            )
                          : Text(
                              'Save',
                              style: TextStyle(
                                color: isEnabled ? Colors.red : Colors.grey,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
            body: WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EditProfile(),
                  ),
                );
                return true; // Return true to allow back navigation
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: !_iscurrentPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'current Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _iscurrentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _iscurrentPasswordVisible =
                                  !_iscurrentPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmNewPasswordController,
                      obscureText: !_isConfirmNewPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmNewPasswordVisible =
                                  !_isConfirmNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
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
