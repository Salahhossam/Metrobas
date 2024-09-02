// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
// import 'dart:developer';
import '../page_one.dart';
import 'single_path_widget.dart';
// import 'package:http/http.dart' as http;

class Test {
  final String text;
  final String time;

  Test({required this.text, required this.time});
}

class PathsWidget extends StatefulWidget {
  const PathsWidget({
    super.key,
    required this.sourceController,
    required this.destinationController,
    required this.selectedTimePass,
    required this.selectedFilterPass,
    required this.firstSelectedLatLng,
    required this.lastSelectedLatLng,
    required this.isMetroSelected,
    required this.isCTASelected,
    required this.isMiniBusSelected,
    required this.isMicroBusSelected,
  });
  final TextEditingController selectedTimePass;
  final Filters selectedFilterPass;
  final TextEditingController sourceController;
  final TextEditingController destinationController;
  final GeoPoint firstSelectedLatLng;
  final GeoPoint lastSelectedLatLng;
  final bool isMetroSelected;
  final bool isCTASelected;
  final bool isMiniBusSelected;
  final bool isMicroBusSelected;
  @override
  State<PathsWidget> createState() => _PathsWidgetState();
}

class _PathsWidgetState extends State<PathsWidget> {
  int itemCount = 5;
  late Filters selectedFilter;

  double travelTime = 0;
  double stops = 0;
  double price = 0;
  List<dynamic> journeyPoints = [];
late bool isMetroSelected;
  late bool isCTASelected;
  late bool isMiniBusSelected;
  late bool isMicroBusSelected;
   List<Map<String, dynamic>?>? paths;
  @override
  void initState() {
    super.initState();
    selectedFilter = widget.selectedFilterPass;
 isMetroSelected = widget.isMetroSelected;
    isCTASelected = widget.isCTASelected;
    isMiniBusSelected = widget.isMiniBusSelected;
    isMicroBusSelected = widget.isMicroBusSelected;
    var cubit = AppCubit.get(context);
     // Initialize paths list
  paths = cubit.singlePath ?? [];
  // Sort the paths based on the selected filter
  sortPaths();
    if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
      travelTime = cubit.singlePath![0]?['duration']?.toDouble() ?? 0;
      stops = cubit.singlePath![0]?['numberOfTransfers']?.toDouble() ?? 0;
      price = cubit.singlePath![0]?['totalPrice']?.toDouble() ?? 0;
      journeyPoints = cubit.singlePath![0]?['journeyPoints'];
    }
  }
void sortPaths() {
  paths?.sort((a, b) {
    if (selectedFilter == Filters.LessTime) {
      return (a?['duration'] as num).compareTo(b?['duration'] as num);
    } else if (selectedFilter == Filters.LessWalking) {
      return (a?['walkingTime'] as num).compareTo(b?['walkingTime'] as num);
    } else if (selectedFilter == Filters.LessPrice) {
      return (a?['totalPrice'] as num).compareTo(b?['totalPrice'] as num);
    } else if (selectedFilter == Filters.FewerTransportation) {
      return (a?['numberOfTransfers'] as num)
          .compareTo(b?['numberOfTransfers'] as num);
    }
    return 0;
  });
}

  // Future<List<Map<String, dynamic>?>?> postSelectedFilterToApi(
  //   GeoPoint? firstSelectedLatLng,
  //   GeoPoint? lastSelectedLatLng,
  //   Filters filter,
  //   String selectedTime,
  // ) async {
  //    List<String> transportations = ["BUS"];
  //   if (isCTASelected == true) {
  //     transportations.add("BUS");
  //   }else if (isMetroSelected == true) {
  //     transportations.add("METRO");
  //   }else if (isMicroBusSelected == true) {
  //     transportations.add("MICROBUS");
  //   }else if (isMiniBusSelected == true) {
  //     transportations.add("BUS");
  //   }
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? token = prefs.getString('token');
  //   String filter = 'TIME';
  //   if (selectedFilter == Filters.LessTime) {
  //     filter = 'TIME';
  //   } else if (selectedFilter == Filters.LessPrice) {
  //     filter = 'PRICE';
  //   } else if (selectedFilter == Filters.FewerTransportation) {
  //     filter = 'NUMBER_OF_TRANSPORTATIONS';
  //   } else if (selectedFilter == Filters.LessWalking) {
  //     filter = 'WALKING_TIME';
  //   }
  //   const apiUrl = 'http://192.168.1.9:8000/api/journey';
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       body: json.encode(
  //         {
  //           "source": {
  //             "longitude": firstSelectedLatLng!.longitude,
  //             "latitude": firstSelectedLatLng.latitude,
  //           },
  //           "destination": {
  //             "longitude": lastSelectedLatLng!.longitude,
  //             "latitude": lastSelectedLatLng.latitude,
  //           },
  //           "time": selectedTime,
  //           "filter": filter,
  //           "transportations":transportations,
  //         },
  //       ),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final List<Map<String, dynamic>> responseData =
  //           List<Map<String, dynamic>>.from(json.decode(response.body));
  //             if (selectedFilter == Filters.LessTime) {
  //         responseData.sort((a, b) {
  //           final double aValue = a['duration'] is int
  //               ? (a['duration'] as int).toDouble()
  //               : a['duration'] as double;

  //           final double bValue = b['duration'] is int
  //               ? (b['duration'] as int).toDouble()
  //               : b['duration'] as double;

  //           return aValue.compareTo(bValue);
  //         });
  //       } else if (selectedFilter == Filters.LessWalking) {
  //         responseData.sort((a, b) {
  //           final double aValue = a['walkingTime'] is int
  //               ? (a['walkingTime'] as int).toDouble()
  //               : a['walkingTime'] as double;

  //           final double bValue = b['walkingTime'] is int
  //               ? (b['walkingTime'] as int).toDouble()
  //               : b['walkingTime'] as double;

  //           return aValue.compareTo(bValue);
  //         });
  //       } else if (selectedFilter == Filters.LessPrice) {
  //         responseData.sort((a, b) {
  //           final double aValue = a['totalPrice'] is int
  //               ? (a['totalPrice'] as int).toDouble()
  //               : a['totalPrice'] as double;

  //           final double bValue = b['totalPrice'] is int
  //               ? (b['totalPrice'] as int).toDouble()
  //               : b['totalPrice'] as double;

  //           return aValue.compareTo(bValue);
  //         });
  //       } else if (selectedFilter == Filters.FewerTransportation) {
  //         responseData.sort((a, b) {
  //           final double aValue = a['numberOfTransfers'] is int
  //               ? (a['numberOfTransfers'] as int).toDouble()
  //               : a['numberOfTransfers'] as double;

  //           final double bValue = b['numberOfTransfers'] is int
  //               ? (b['numberOfTransfers'] as int).toDouble()
  //               : b['numberOfTransfers'] as double;

  //           return aValue.compareTo(bValue);
  //         });
  //       }

  //       log(response.body);
  //       log('Data successfully sent to the API');
  //       return responseData;
  //     } else {
  //       log('Failed to send data to the API ${response.body}');
  //     }
  //   } catch (e) {
  //     log('Error in LatLng: $e');
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    final size = MediaQuery.of(context).size;
    final containerHeight = size.height * 0.5;
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return Center(
          child: Container(
            height: containerHeight,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  size: 50,
                  Icons.drag_handle,
                  color: Colors.grey,
                ),
                Row(
                  children: [
                    const Text(
                      'Choose Filter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      value: selectedFilter,
                      onChanged: (newValue) {
                        if (newValue == null) {
                          return;
                        }
                        setState(() {
                          selectedFilter = newValue;
                              sortPaths();

                          // postSelectedFilterToApi(
                          //   widget.firstSelectedLatLng,
                          //   widget.lastSelectedLatLng,
                          //   newValue,
                          //   widget.selectedTimePass.text,
                          // );
                        });
                      },
                      items: Filters.values.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cubit.singlePath?.length,
                    itemBuilder: (context, index) {
                      return SinglePathWidget(
                        isMetroSelected: widget.isMetroSelected,
                      isCTASelected: widget.isCTASelected,
                      isMiniBusSelected: widget.isMiniBusSelected,
                      isMicroBusSelected: widget.isMicroBusSelected,
                        sourceController: widget.sourceController,
                        destinationController: widget.destinationController,
                        selectedTimePass: widget.selectedTimePass,
                        selectedFilterPass: widget.selectedFilterPass,
                        index: index,
                        firstSelectedLatLng: widget.firstSelectedLatLng,
                        lastSelectedLatLng: widget.lastSelectedLatLng,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
