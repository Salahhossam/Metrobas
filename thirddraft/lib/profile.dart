// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thirddraft/darkcubit/cubit.dart';
// import 'package:thirddraft/darkcubit/states.dart';
// import 'package:thirddraft/edit_profile.dart';
// import 'package:thirddraft/login.dart';
// import 'package:thirddraft/tab_screens.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   State<Profile> createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   String? userName = 'userName';
//   String? userEmail = 'email@gmail.com';
//   String? imageAssetPath = 'images/MetroBas.png';

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _getUserDetails();
//   // }

//   // Future<void> _getUserDetails() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     userName = prefs.getString('userName');
//   //     userEmail = prefs.getString('userEmail');
//   //     imageAssetPath = prefs.getString('image');
//   //   });
//   // }

//   @override
//   void initState() {
//     super.initState();
//     var cubit = AppCubit.get(context);
//     if (cubit.userInfo != null) {
//       userName = cubit.userInfo!['userDto']['userName'];
//       userEmail = cubit.userInfo!['userDto']['email'];
//       imageAssetPath =
//           cubit.userInfo!['userDto']['image'] ?? 'images/MetroBas.png';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var cubit = AppCubit.get(context);

//     return BlocConsumer<AppCubit, AppState>(
//       builder: (BuildContext context, state) {
//         return SafeArea(
//           child: Scaffold(
//             body: WillPopScope(
//               onWillPop: () async {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (_) => TabScreens(
//                       selectedIndex: 0,
//                     ),
//                   ),
//                 );
//                 return true; // Return true to allow back navigation
//               },
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 50.0,
//                       backgroundImage: cubit.userInfo != null &&
//                               cubit.userInfo!.isNotEmpty &&
//                               cubit.userInfo!['userDto']['image'] != null
//                           ? AssetImage(cubit.userInfo!['userDto']['image'])
//                           : AssetImage(imageAssetPath!),
//                       backgroundColor: Colors.grey,
//                     ),
//                     const SizedBox(height: 15),
//                     Text(
//                       cubit.userInfo != null &&
//                               cubit.userInfo!.isNotEmpty &&
//                               cubit.userInfo!['userDto']['userName'] != null
//                           ? (cubit.userInfo!['userDto']['userName'])
//                           : userName,
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                     const SizedBox(height: 15),
//                     Text(
//                       cubit.userInfo != null &&
//                               cubit.userInfo!.isNotEmpty &&
//                               cubit.userInfo!['userDto']['email'] != null
//                           ? (cubit.userInfo!['userDto']['email'])
//                           : userEmail,
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                     const SizedBox(height: 15),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           decoration: const BoxDecoration(
//                             color: Color.fromRGBO(8, 15, 44, 1),
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           width: 100,
//                           child: MaterialButton(
//                             onPressed: () {
//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(
//                                   builder: (context) => const EditProfile(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               'Edit Profile',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Container(
//                           decoration: const BoxDecoration(
//                             color: Color.fromRGBO(8, 15, 44, 1),
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           width: 100,
//                           child: MaterialButton(
//                             onPressed: () async {
//                               final prefs = await SharedPreferences.getInstance();
//                               prefs.remove('token');
//                               // ignore: use_build_context_synchronously
//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(
//                                   builder: (context) => const Login(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               'Log Out',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       listener: (BuildContext context, AppState state) {},
//     );
//   }
// }
