// import 'package:flutter/material.dart';
// import 'package:thirddraft/chat.dart';
// import 'package:thirddraft/contact_us.dart';
// import 'package:thirddraft/page_one.dart';
// import 'package:thirddraft/profile.dart';

// // ignore: must_be_immutable
// class TabScreen extends StatefulWidget {
//   int selectedIndex;

//   TabScreen({
//     super.key,
//     required this.selectedIndex,
//   });

//   @override
//   State<TabScreen> createState() => _TabScreenState();
// }

// class _TabScreenState extends State<TabScreen> {
//   late PageController _pageController;
//   int _selectedIndex = 0;

//   // Create GlobalKeys for each page
//   final GlobalKey<State<PageOne>> pageOneKey = GlobalKey<State<PageOne>>();
//   final GlobalKey<State<Chat>> chatKey = GlobalKey<State<Chat>>();
//   final GlobalKey<State<ContactUs>> contactUsKey = GlobalKey<State<ContactUs>>();
//   final GlobalKey<State<Profile>> profileKey = GlobalKey<State<Profile>>();

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: widget.selectedIndex);
//     _selectedIndex = widget.selectedIndex;
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.ease,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: [
//           PageOne(key: pageOneKey),
//           Chat(key: chatKey),
//           ContactUs(key: contactUsKey),
//           Profile(key: profileKey),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chat',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.help),
//             label: 'Help',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color.fromRGBO(8, 15, 44, 1),
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
