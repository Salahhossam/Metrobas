// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thirddraft/tab_screens.dart';
// import 'package:thirddraft/darkcubit/cubit.dart';

// class EditProfile extends StatefulWidget {
//   const EditProfile({Key? key}) : super(key: key);

//   @override
//   State<EditProfile> createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _userNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   File? _image;
//   bool _isEditingUserName = false;
//   bool _isEditingEmail = false;
//   bool _isEditingPassword = false;
//   bool _isPasswordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     var cubit = AppCubit.get(context);
//     if (cubit.userInfo != null) {
//       _userNameController.text = cubit.userInfo!['userDto']['userName'] ?? '';
//       _emailController.text = cubit.userInfo!['userDto']['email'] ?? '';
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       }
//     });
//   }

//   Widget _buildEditableField({
//     required String label,
//     required TextEditingController controller,
//     required Icon icon,
//     required bool isEditing,
//     required VoidCallback onEdit,
//     String? initialValue,
//     TextInputType inputType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: isEditing
//                   ? TextFormField(
//                       controller: controller,
//                       keyboardType: inputType,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(
//                               MediaQuery.of(context).size.width * .04,
//                             ),
//                           ),
//                         ),
//                         prefixIcon: icon,
//                         contentPadding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.width * .01,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * .04),
//                       ),
//                     )
//                   : Container(
//                       padding: EdgeInsets.symmetric(
//                           vertical: MediaQuery.of(context).size.width * .02,
//                           horizontal: MediaQuery.of(context).size.width * .04),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(
//                             MediaQuery.of(context).size.width * .04),
//                       ),
//                       child: Text(controller.text),
//                     ),
//             ),
//             IconButton(
//               icon: Icon(isEditing ? Icons.check : Icons.edit),
//               onPressed: onEdit,
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildEditableFieldPassword({
//     required String label,
//     required TextEditingController controller,
//     required Icon icon,
//     required bool isEditing,
//     required VoidCallback onEdit,
//     String? initialValue,
//     TextInputType inputType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: isEditing
//                   ? TextFormField(
//                       controller: controller,
//                       keyboardType: inputType,
//                       obscureText: !_isPasswordVisible,
//                        onChanged: (value) {
//                         _passwordController.text = value;
//                       },
//                       decoration: InputDecoration(
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isPasswordVisible = !_isPasswordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(
//                               MediaQuery.of(context).size.width * .04,
//                             ),
//                           ),
//                         ),
//                         prefixIcon: icon,
//                         contentPadding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.width * .01,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * .04),
//                       ),
//                     )
//                   : Container(
//                       padding: EdgeInsets.symmetric(
//                           vertical: MediaQuery.of(context).size.width * .02,
//                           horizontal: MediaQuery.of(context).size.width * .04),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(
//                             MediaQuery.of(context).size.width * .04),
//                       ),
//                       child: const Text('********'),
//                     ),
//             ),
//             IconButton(
//               icon: Icon(isEditing ? Icons.check : Icons.edit),
//               onPressed: onEdit,
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildEditableFieldConfirmPassword({
//     required String label,
//     required TextEditingController controller,
//     required Icon icon,
//     required bool isEditing,
//     required VoidCallback onEdit,
//     String? initialValue,
//     TextInputType inputType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: isEditing
//                   ? TextFormField(
//                       controller: controller,
//                       keyboardType: inputType,
//                       obscureText: !_isPasswordVisible,
//                        onChanged: (value) {
//                         _confirmPasswordController.text = value;
//                       },
//                        validator: (value) {
                          
//                             if (value != _passwordController.text) {
//                               return 'Passwords do not match';
//                             }
//                             return null;
//                           },
//                       decoration: InputDecoration(
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isPasswordVisible = !_isPasswordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(
//                               MediaQuery.of(context).size.width * .04,
//                             ),
//                           ),
//                         ),
//                         prefixIcon: icon,
//                         contentPadding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.width * .01,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * .04),
//                       ),
//                     )
//                   : Container(
//                       padding: EdgeInsets.symmetric(
//                           vertical: MediaQuery.of(context).size.width * .02,
//                           horizontal: MediaQuery.of(context).size.width * .04),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(
//                             MediaQuery.of(context).size.width * .04),
//                       ),
//                       child: const Text('********'),
//                     ),
//             ),
//             IconButton(
//               icon: Icon(isEditing ? Icons.check : Icons.edit),
//               onPressed: onEdit,
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Future<void> _performEdit(String fieldName, String updatedValue) async {
//     const String apiUrl =
//         'http://192.168.1.9:8000/api/edit-profile';
        
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('token');
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode({
//           'fieldName': fieldName,
//           'updatedValue': updatedValue,
//         },),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         log('Successfully updated $fieldName');
//       } else {
//         log('Failed to update $fieldName: ${response.statusCode}');
//       }
//     } catch (error) {
//       log('Error during API call: $error');
//     }
//   }

//   void _saveProfile() {
//     if (_isEditingUserName) {
//       _performEdit('username', _userNameController.text);
//     }
//     if (_isEditingEmail) {
//       _performEdit('email', _emailController.text);
//     }
//     if (_isEditingPassword) {
//       _performEdit('password', _passwordController.text);
//     }
//     // Add additional conditions for other fields if needed
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Stack(
//             children: [
//               ListView(
//                 children: [
//                   Center(
//                     child: Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 50.0,
//                           backgroundImage: _image != null
//                               ? FileImage(_image!)
//                               : AssetImage(AppCubit.get(context).userInfo !=
//                                           null &&
//                                       AppCubit.get(context)
//                                           .userInfo!
//                                           .isNotEmpty &&
//                                       AppCubit.get(context).userInfo!['userDto']
//                                               ['image'] !=
//                                           null
//                                   ? AppCubit.get(context).userInfo!['userDto']
//                                       ['image']
//                                   : 'images/MetroBas.png') as ImageProvider,
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: IconButton(
//                             icon: const Icon(Icons.camera_alt),
//                             onPressed: _pickImage,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   _buildEditableField(
//                     label: 'Username',
//                     controller: _userNameController,
//                     isEditing: _isEditingUserName,
//                     onEdit: () {
//                       setState(() {
//                         _isEditingUserName = !_isEditingUserName;
//                       });
//                     },
//                     initialValue: _userNameController.text,
//                     icon: const Icon(Icons.person),
//                   ),
//                   _buildEditableField(
//                     label: 'Email',
//                     controller: _emailController,
//                     isEditing: _isEditingEmail,
//                     onEdit: () {
//                       setState(() {
//                         _isEditingEmail = !_isEditingEmail;
//                       });
//                     },
//                     initialValue: _emailController.text,
//                     icon: const Icon(Icons.email),
//                   ),
//                   _buildEditableFieldPassword(
//                     label: 'Password',
//                     controller: _passwordController,
//                     isEditing: _isEditingPassword,
//                     onEdit: () {
//                       setState(() {
//                         _isEditingPassword = !_isEditingPassword;
//                       });
//                     },
//                     inputType: TextInputType.visiblePassword,
//                     icon: const Icon(Icons.lock),
//                   ),
//                   _buildEditableFieldConfirmPassword(
//                     label: 'Confirm Password',
//                     controller: _confirmPasswordController,
//                     isEditing: _isEditingPassword,
//                     onEdit: () {
//                       setState(() {
//                         _isEditingPassword = !_isEditingPassword;
//                       });
//                     },
//                     inputType: TextInputType.visiblePassword,
//                     icon: const Icon(Icons.lock),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _saveProfile,
//                     child: const Text('Save'),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 top: 20,
//                 left: 10,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                     size: 40,
//                   ),
//                   hoverColor: Colors.grey,
//                   onPressed: () {
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(
//                       builder: (_) => TabScreens(
//                         selectedIndex: 3,
//                       ),
//                     ));
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
