// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thirddraft/darkcubit/cubit.dart';
// import 'package:thirddraft/darkcubit/states.dart';
// import 'package:thirddraft/edit_profile.dart';
// import 'package:http/http.dart' as http;

// class EditEmail extends StatefulWidget {
//   final String email;

//   const EditEmail({super.key, required this.email});

//   @override
//   State<EditEmail> createState() => _EditEmailState();
// }

// class _EditEmailState extends State<EditEmail> {
//   late TextEditingController _emailController;
//   final ValueNotifier<bool> _isSaveButtonEnabled = ValueNotifier(false);
//   late int userId;

//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController(text: widget.email);
//     _emailController.addListener(_onTextChanged);
//     var cubit = AppCubit.get(context);

//     if (cubit.userInfo != null) {
//       userId = cubit.userInfo!['userDto']['userId'];
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.removeListener(_onTextChanged);
//     _emailController.dispose();
//     _isSaveButtonEnabled.dispose();
//     super.dispose();
//   }

//   void _onTextChanged() {
//     _isSaveButtonEnabled.value = _emailController.text != widget.email &&
//         _emailController.text.isNotEmpty;
//   }

//   Future<void> postNewEmail(userId, String newEmail) async {
//     var apiUrl = 'http://192.168.1.9:8000/newEmail/user/$userId';
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('token');
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode(
//           {
//             "newEmail": newEmail,
//           },
//         ),
//         headers: {
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       if (response.statusCode == 200) {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(
//           builder: (_) => const EditProfile(),
//         ));
//           ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Email updated successfully!'),
//           ),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(
//           builder: (_) => const EditProfile(),
//         ));
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Update Failed , Something Wrong.'),
//           ),
//         );
//         log('Failed to send data to the API ${response.body}');
//       }
//     } catch (e) {
//       log('Error in LatLng: $e');
//     }
//     return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AppCubit, AppState>(
//       builder: (BuildContext context, AppState state) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Edit Email'),
//             leadingWidth: 70,
//             centerTitle: true,
//             leading: TextButton(
//               onPressed: () {
//                 Navigator.of(context).pushReplacement(MaterialPageRoute(
//                   builder: (_) => const EditProfile(),
//                 ));
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//             actions: [
//               ValueListenableBuilder<bool>(
//                 valueListenable: _isSaveButtonEnabled,
//                 builder: (context, isEnabled, child) {
//                   return TextButton(
//                     onPressed: isEnabled
//                         ? () {
//                             postNewEmail(userId, _emailController.text);
//                           }
//                         : null,
//                     child: Text(
//                       'Save',
//                       style: TextStyle(
//                         color: isEnabled ? Colors.red : Colors.grey,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: WillPopScope(
//             onWillPop: () async {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (_) => const EditProfile(),
//                 ),
//               );
//               return true; // Return true to allow back navigation
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(
//                             MediaQuery.of(context).size.width * .04,
//                           ),
//                         ),
//                       ),
//                       prefixIcon: const Icon(Icons.email),
//                       contentPadding: EdgeInsets.symmetric(
//                           vertical: MediaQuery.of(context).size.width * .01,
//                           horizontal: MediaQuery.of(context).size.width * .04),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       listener: (BuildContext context, AppState state) {},
//     );
//   }
// }
