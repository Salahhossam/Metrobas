
// ///////////////////////////////////////////////////////////////////////////////////////////////////////
// ///
// // import 'package:shared_preferences/shared_preferences.dart';

// import 'PageTwo/page_two.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:get/get.dart';
// import 'state.dart';
// import 'dart:developer';
// import 'dart:convert';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thirddraft/darkcubit/cubit.dart';
// import 'package:thirddraft/darkcubit/states.dart';
// import 'package:http/http.dart' as http;

// class PageOne extends StatefulWidget {
//   const PageOne({super.key});
//   // final String token;
//   // final LatLng savedPlaces;
//   // final Image image;
//   // const PageOne({
//   //   required this.token,
//   //   required this.savedPlaces,
//   //   required this.image,
//   //   super.key,
//   // });
//   @override
//   State<PageOne> createState() => _PageOneState();
// }

// enum Filters { LessTime, LessPrice, FewerTransportation, LessWalking }

// class _PageOneState extends State<PageOne> {
//   TimeOfDay selectedTime = TimeOfDay.now();
//   Filters selectedFilter = Filters.LessTime;
//   final _sourceController = TextEditingController();
//   final _destinationController = TextEditingController();

//   bool sourceControllerChanged = false;
//   bool destinationControllerChanged = false;
//   GeoPoint? firstSelectedLatLng;
//   GeoPoint? lastSelectedLatLng;
//   void swapText() {
//     String sourceText = _sourceController.text;
//     _sourceController.text = _destinationController.text;
//     _destinationController.text = sourceText;
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   void navigateToSecondPage() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => PageTwo(
//           selectedTimePass: selectedTime,
//           selectedFilterPass: selectedFilter,
//           sourceText: _sourceController.text,
//           destinationText: _destinationController.text,
//           firstSelectedLatLng: firstSelectedLatLng!,
//           lastSelectedLatLng: lastSelectedLatLng!,
//         ),
//       ),
//     );
//   }

//   OverlayEntry? overlayEntry;

//   var controller = Get.put(MainStateController());

//   FutureOr<Iterable<String>> _optionsBuilder(
//       TextEditingValue textEditingValue) async {
//     var data = await addressSuggestion(textEditingValue.text);
//     return data.map((searchInfo) => '${searchInfo.address}');
//   }

//   Widget buildAutocomplete(String labelText, TextEditingController controller,
//       String address, context) {
//     var cubit = AppCubit.get(context);
//     return SizedBox(
//       width: 270,
//       height: 40,
//       child: Autocomplete<String>(
//         optionsBuilder: (TextEditingValue textEditingValue) =>
//             _optionsBuilder(textEditingValue),
//         onSelected: (selection) {
//           setState(() {
//             controller.text = selection;
//           });
//         },
//         fieldViewBuilder: (
//           BuildContext context,
//           controller,
//           FocusNode fieldFocusNode,
//           void Function() onFieldSubmitted,
//         ) {
//           if (controller.text.isEmpty) {
//             controller.text = address;
//           } else {
//             () {
//               controller.text = controller.text;
//             };
//           }

//           return TextFormField(
//             controller: controller,
//             focusNode: fieldFocusNode,
//             decoration: InputDecoration(
//               labelText: labelText,
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               enabledBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(
//                   width: .5,
//                   color: Colors.grey,
//                 ),
//                 borderRadius: BorderRadius.all(Radius.circular(15.0)),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//               isDense: true,
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   controller.clear();
//                 },
//               ),
//             ),
//             keyboardType: TextInputType.text,
//           );
//         },
//         optionsViewBuilder: (
//           BuildContext context,
//           AutocompleteOnSelected<String> onSelected,
//           Iterable<String> options,
//         ) {
//           return Align(
//             alignment: Alignment.topLeft,
//             child: Material(
//               color: Colors.white,
//               child: Container(
//                 width: 270,
//                 color: Colors.white,
//                 child: ListView.builder(
//                   itemCount: options.length,
//                   itemBuilder: (context, index) {
//                     final option = options.elementAt(index);
//                     return ListTile(
//                       onTap: () async {
//                         onSelected(option);
//                         var data = await addressSuggestion(option);

//                         if (controller == _sourceController) {
//                           sourceControllerChanged = true;
//                           firstSelectedLatLng = data.first.point;
//                         } else if (controller == _destinationController) {
//                           destinationControllerChanged = true;
//                           lastSelectedLatLng = data.first.point;
//                         }
//                       },
//                       title: Text(option),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<List<Map<String, dynamic>?>?> postLatLngToApi(
//     GeoPoint? firstSelectedLatLng,
//     GeoPoint? lastSelectedLatLng,
//     TimeOfDay selectedTime,
//     Filters selectedFilter,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('token');
//     String filter = 'TIME';
//     if (selectedFilter == Filters.LessTime) {
//       filter = 'TIME';
//     } else if (selectedFilter == Filters.LessPrice) {
//       filter = 'PRICE';
//     } else if (selectedFilter == Filters.FewerTransportation) {
//       filter = 'NUMBER_OF_TRANSPORTATIONS';
//     } else if (selectedFilter == Filters.LessWalking) {
//       filter = 'WALKING_TIME';
//     }
//     const apiUrl = 'http://192.168.137.1:8000/api/journey';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode(
//           {
//             "source": {
//               "longitude": firstSelectedLatLng!.longitude,
//               "latitude": firstSelectedLatLng.latitude,
//             },
//             "destination": {
//               "longitude": lastSelectedLatLng!.longitude,
//               "latitude": lastSelectedLatLng.latitude,
//             },
//             "time": "10:00:00",
//             "filter": filter,
//             "transportations": ["BUS", "METRO", "MICROBUS"],
//           },
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<Map<String, dynamic>> responseData =
//             List<Map<String, dynamic>>.from(json.decode(response.body));
//         log(response.body);

//         log('Data successfully sent to the API');
//         return responseData;
//       } else {
//         log('Failed to send data to the API ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error in LatLng: $e');
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     String sourceText = _sourceController.text;
//     String destinationText = _destinationController.text;

//     return BlocConsumer<AppCubit, AppState>(
//       builder: (BuildContext context, AppState state) {
//         return SafeArea(
//           child: Scaffold(
//             body: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               buildAutocomplete('From', _sourceController,
//                                   sourceText, context),
//                               const SizedBox(height: 16),
//                               buildAutocomplete('To', _destinationController,
//                                   destinationText, context),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Positioned(
//                         top: 45,
//                         right: 80,
//                         child: IconButton(
//                           icon: const Icon(
//                             Icons.swap_vert_circle,
//                             color: Color.fromRGBO(8, 15, 44, 1),
//                             size: 50,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               swapText();
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               width: .5,
//                               color: Colors.grey,
//                             ),
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(15.0),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Time'),
//                               TextButton.icon(
//                                 onPressed: () async {
//                                   TimeOfDay? pickedTime = await showTimePicker(
//                                     context: context,
//                                     initialTime: selectedTime,
//                                   );
//                                   if (pickedTime != null &&
//                                       pickedTime != selectedTime) {
//                                     setState(() {
//                                       selectedTime = pickedTime;
//                                     });
//                                   }
//                                 },
//                                 icon: const Icon(
//                                   Icons.timer,
//                                 ),
//                                 label: Text(
//                                   selectedTime.format(context),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               width: .5,
//                               color: Colors.grey,
//                             ),
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(15.0),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Filter'),
//                               DropdownButton(
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(15)),
//                                 elevation: 0,
//                                 value: selectedFilter,
//                                 onChanged: (newValue) {
//                                   if (newValue == null) {
//                                     return;
//                                   }
//                                   setState(() {
//                                     selectedFilter = newValue;
//                                   });
//                                 },
//                                 items: Filters.values.map((value) {
//                                   return DropdownMenuItem(
//                                     value: value,
//                                     child: Text(value.name),
//                                   );
//                                 }).toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       navigateToSecondPage();

//                       if (sourceControllerChanged &&
//                           destinationControllerChanged) {
//                         final data = await postLatLngToApi(
//                           firstSelectedLatLng,
//                           lastSelectedLatLng,
//                           selectedTime,
//                           selectedFilter,
//                         );

//                         if (data != null) {
//                           var cubit = AppCubit.get(context);
//                           cubit.singlePathData(data);

//                           if (cubit.singlePath != null &&
//                               cubit.singlePath!.isNotEmpty) {
//                             final firstMap = cubit.singlePath![0];
//                             if (firstMap != null) {
//                               final duration = firstMap['duration'];
//                               if (duration != null) {
//                                 log('Duration: $duration');
//                               } else {
//                                 log('Duration not available');
//                               }
//                             } else {
//                               log('First map in the list is null');
//                             }
//                           } else {
//                             log('List is null or empty');
//                           }

//                           log('Selected LatLng: ${firstSelectedLatLng?.longitude.runtimeType}');
//                           log('Selected LatLng: ${firstSelectedLatLng}');
//                           log('Selected LatLng: $lastSelectedLatLng');
//                           log('Selected selectedTimePass: $selectedTime');
//                           log('Selected selectedFilterPass: $selectedFilter');
//                           sourceControllerChanged = false;
//                           destinationControllerChanged = false;
//                         }
                        
//                       }
//                     },
//                     style: const ButtonStyle(
//                       backgroundColor: MaterialStatePropertyAll(
//                         Color.fromRGBO(8, 15, 44, 1),
//                       ),
//                     ),
//                     child: const Text(
//                       'Show Me',
//                       style: TextStyle(color: Colors.white),
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
