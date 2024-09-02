import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/edit_profile.dart';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:http/http.dart' as http;

class EditUsername extends StatefulWidget {
  final String username;

  const EditUsername({super.key, required this.username});

  @override
  State<EditUsername> createState() => _EditUsernameState();
}

class _EditUsernameState extends State<EditUsername> {
  late TextEditingController _usernameController;
  final ValueNotifier<bool> _isSaveButtonEnabled = ValueNotifier(false);
  late int userId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _usernameController.addListener(_onTextChanged);
    var cubit = AppCubit.get(context);

    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onTextChanged);
    _usernameController.dispose();
    _isSaveButtonEnabled.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _isSaveButtonEnabled.value = _usernameController.text != widget.username &&
        _usernameController.text.isNotEmpty;
  }

  Future<void> postNewUserName(userId, String newUserName) async {
    var apiUrl = 'http://192.168.1.9:8000/api/users/$userId';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        log('Token is null, user might be logged out.');
        return;
      }

      log('Token before update: $token');

      final uri = Uri.parse(apiUrl).replace(queryParameters: {
        'userName': newUserName,
      });

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Username updated successfully: ${response.body}');
        log('Token after successful update: $token');

        // Re-save token to ensure it's not removed
        await prefs.setString('token', token);

        // Update user info in the cubit
        var cubit = AppCubit.get(context);
        cubit.updateUserInfo({
          ...cubit.userInfo!,
          'userDto': {
            ...cubit.userInfo!['userDto'],
            'userName': newUserName,
          }
        });

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const EditProfile(),
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UserName updated successfully!'),
          ),
        );
      } else {
        log('Failed to update username: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update Failed, Something Wrong.'),
          ),
        );

        if (response.statusCode == 401) {
          log('Unauthorized request, token might be invalid or expired.');
        }
      }
    } catch (e) {
      log('Error in postNewUserName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        log('Current state: $state');
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Username'),
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
                                  await postNewUserName(
                                      userId, _usernameController.text);
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
                      controller: _usernameController,
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
                            vertical: MediaQuery.of(context).size.width * .01,
                            horizontal:
                                MediaQuery.of(context).size.width * .04),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, AppState state) {
        log('State changed to: $state');
      },
    );
  }
}
