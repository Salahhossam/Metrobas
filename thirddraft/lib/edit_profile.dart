// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/page_one.dart';
// import 'edit_email.dart';
import 'edit_username.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

import 'edit_password.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // late String currentEmail;

  late String currentUsername;
  // File? imageFile;

  String? userName = 'userName';
  // String? userEmail = 'email@gmail.com';
  // String? imageAssetPath = 'images/MetroBas.png';
  // late ImagePicker _picker;
  late int userId;

  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);
    if (cubit.userInfo != null) {
      currentUsername = cubit.userInfo != null &&
              cubit.userInfo!.isNotEmpty &&
              cubit.userInfo!['userDto']['userName'] != null
          ? cubit.userInfo!['userDto']['userName']
          : 'userName';
      // currentEmail = cubit.userInfo != null &&
      //         cubit.userInfo!.isNotEmpty &&
      //         cubit.userInfo!['userDto']['email'] != null
      //     ? cubit.userInfo!['userDto']['email']
      //     : 'email@gmail.com';
    }
    if (cubit.userInfo != null) {
      userName = cubit.userInfo!['userDto']['userName'];
      // userEmail = cubit.userInfo!['userDto']['email'];
      // imageAssetPath =
      //     cubit.userInfo!['userDto']['image'] ?? 'images/MetroBas.png';
    }
    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
    }
    // _picker = ImagePicker();
  }

  // Future<void> _changeProfilePicture() async {
  //   final pickedFile = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 80,
  //   );

  //   if (pickedFile != null) {
  //     imageFile = File(pickedFile.path);

  //     // Call API to upload new image
  //     await postNewImage(userId, imageFile!.path);
  //     setState(() {
  //       imageFile;
  //       log('Image path selected: $imageFile');
  //     });
  //   } else {
  //     log('No image selected.');
  //   }
  // }

  // Future<void> postNewImage(userId, String imagePath) async {
  //   var apiUrl = 'http://192.168.1.9:8000/newImage/user/$userId';
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? token = prefs.getString('token');
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       body: json.encode(
  //         {
  //           "newImage": imagePath,
  //         },
  //       ),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       // If API call is successful, update imageAssetPath
  //       setState(() {
  //         imageAssetPath = imagePath;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Profile image updated successfully!'),
  //         ),
  //       );
  //     } else {
  //       setState(() {
  //         imageFile = null;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Failed to update profile image.'),
  //         ),
  //       );
  //       log('Failed to send data to the API ${response.body}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error updating profile image.'),
  //       ),
  //     );
  //     log('Error in postNewImage: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              toolbarHeight: 100,
              leadingWidth: 70,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromRGBO(8, 15, 44, 1),
                  size: 40,
                ),
                hoverColor: Colors.grey,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const PageOne()));
                },
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PageOne()),
                );
                return true; // Return true to allow back navigation
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     _changeProfilePicture();
                    //   },
                    //   child: CircleAvatar(
                    //     radius: 50.0,
                    //     backgroundImage: imageFile != null
                    //         ? FileImage(
                    //             imageFile!) // Use FileImage for dynamic files
                    //         : const AssetImage('images/MetroBas.png')
                    //             as ImageProvider, // Default asset path

                    //     backgroundColor: Colors.grey,
                    //   ),
                    // ),
                    // const SizedBox(height: 15),
                    // SizedBox(
                    //   height: 100,
                    //   child: InkWell(
                    //     onTap: () {
                    //       Navigator.of(context).pushReplacement(
                    //         MaterialPageRoute(
                    //           builder: (_) => EditEmail(email: currentEmail),
                    //         ),
                    //       );
                    //     },
                    //     child: Row(
                    //       children: [
                    //         const Text(
                    //           'Email',
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         const Spacer(),
                    //         Text(currentEmail,
                    //             style:
                    //                 const TextStyle(fontWeight: FontWeight.bold)),
                    //         const Icon(Icons.arrow_forward_ios)
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const Text(
                      'About You',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 100,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditUsername(username: currentUsername),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(currentUsername,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const EditPassword()),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios)
                          ],
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
