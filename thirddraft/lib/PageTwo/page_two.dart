import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';

import '../page_one.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import '../state.dart';
import 'package:http/http.dart' as http;
import 'snapping_bottom_sheet_all_paths_widget.dart';
import 'dart:developer';

// ignore: must_be_immutable
class PageTwo extends StatefulWidget {
  String selectedTimePass;
  final Filters selectedFilterPass;
  String sourceText;
  String destinationText;
  final GeoPoint firstSelectedLatLng;
  final GeoPoint lastSelectedLatLng;
  final bool isMetroSelected;
  final bool isCTASelected;
  final bool isMiniBusSelected;
  final bool isMicroBusSelected;
  PageTwo({
    required this.selectedTimePass,
    required this.selectedFilterPass,
    required this.sourceText,
    required this.destinationText,
    super.key,
    required this.firstSelectedLatLng,
    required this.lastSelectedLatLng,
    required this.isMetroSelected,
    required this.isCTASelected,
    required this.isMiniBusSelected,
    required this.isMicroBusSelected,
  });

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final selectedTime = TextEditingController();
  late Filters selectedFilter;
  bool sourceControllerChanged = false;
  bool destinationControllerChanged = false;
  late bool isMetroSelected;
  late bool isCTASelected;
  late bool isMiniBusSelected;
  late bool isMicroBusSelected;
  GeoPoint firstSelectedLatLng =
      GeoPoint(latitude: 30.044326328134307, longitude: 31.236321058539797);
  GeoPoint lastSelectedLatLng =
      GeoPoint(latitude: 30.044326328134307, longitude: 31.236321058539797);
  void swapText() {
    setState(() {
      String temp = widget.sourceText;
      widget.sourceText = widget.destinationText;
      widget.destinationText = temp;
    });
  }
// @override
  // void initState() {
  //   super.initState();

  //   // final prefs = await SharedPreferences.getInstance();
  //   // final String? token = prefs.getString('token');
  // }
  @override
  void initState() {
    super.initState();
    isMetroSelected = widget.isMetroSelected;
    isCTASelected = widget.isCTASelected;
    isMiniBusSelected = widget.isMiniBusSelected;
    isMicroBusSelected = widget.isMicroBusSelected;
    _sourceController.text = widget.sourceText;
    _destinationController.text = widget.destinationText;
    selectedTime.text = widget.selectedTimePass;
    selectedFilter = widget.selectedFilterPass;
    var cubit = AppCubit.get(context);
    if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
      travelTime = cubit.singlePath![0]?['duration']?.toDouble() ?? 0;
      stops = cubit.singlePath![0]?['numberOfTransfers']?.toDouble() ?? 0;
      price = cubit.singlePath![0]?['totalPrice']?.toDouble() ?? 0;
      journeyPoints = cubit.singlePath![0]?['journeyPoints'];
    }
  }

  var controller = Get.put(MainStateController());

  FutureOr<Iterable<String>> _optionsBuilder(
      TextEditingValue textEditingValue) async {
    var data = await addressSuggestion(textEditingValue.text);
    return data.map((searchInfo) => '${searchInfo.address}');
  }

  double travelTime = 0;
  double stops = 0;
  double price = 0;
  List<dynamic> journeyPoints = [];

  Widget buildAutocomplete(String labelText, TextEditingController controller,
      String address, context) {
    var cubit = AppCubit.get(context);
    return SizedBox(
      width: 270,
      height: 40,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) =>
            _optionsBuilder(textEditingValue),
        onSelected: (selection) {
          setState(() {
            controller.text = selection;
          });
          FocusManager.instance.primaryFocus
              ?.unfocus(); // Dismiss the keyboard after selection
        },
        fieldViewBuilder: (
          BuildContext context,
          controller,
          FocusNode fieldFocusNode,
          void Function() onFieldSubmitted,
        ) {
          if (controller.text.isEmpty) {
            controller.text = address;
          } else {
            () {
              controller.text = controller.text;
            };
          }

          return TextFormField(
            controller: controller,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: labelText,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: .5,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                },
              ),
            ),
            keyboardType: TextInputType.text,
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.white,
              child: Container(
                width: 270,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      onTap: () async {
                        onSelected(option);
                        var data = await addressSuggestion(option);
                        if (controller == _sourceController) {
                          sourceControllerChanged = true;
                          firstSelectedLatLng = data.first.point!;
                        } else if (controller == _destinationController) {
                          destinationControllerChanged = true;
                          lastSelectedLatLng = data.first.point!;
                        }
                        if (sourceControllerChanged &&
                            destinationControllerChanged) {
                          if (data.isNotEmpty) {
                            final data = await postLatLngToApi(
                              firstSelectedLatLng,
                              lastSelectedLatLng,
                              widget.selectedTimePass,
                              widget.selectedFilterPass,
                            );
                            cubit.singlePathData(data);

                            if (cubit.singlePath != null &&
                                cubit.singlePath!.isNotEmpty) {
                              final firstMap = cubit.singlePath![
                                  0]; // Accessing the first map in the list

                              if (firstMap != null) {
                                final duration = firstMap['duration'];
                                if (duration != null) {
                                  log('Duration: $duration');
                                } else {
                                  log('Duration not available');
                                }
                              } else {
                                log('First map in the list is null');
                              }
                            } else {
                              log('List is null or empty');
                            }

                            log('Selected LatLng: ${firstSelectedLatLng.longitude.runtimeType}');
                            log('Selected LatLng: ${firstSelectedLatLng.latitude}');
                            log('Selected LatLng: $lastSelectedLatLng');
                            log('Selected selectedTimePass: ${widget.selectedTimePass}');
                            log('Selected selectedFilterPass: ${widget.selectedFilterPass}');
                            sourceControllerChanged = false;
                            destinationControllerChanged = false;
                          }
                        }
                        FocusManager.instance.primaryFocus
                            ?.unfocus(); // Dismiss the keyboard after selection
                      },
                      title: Text(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>?>?> postLatLngToApi(
    GeoPoint? firstSelectedLatLng,
    GeoPoint? lastSelectedLatLng,
    String? selectedTime,
    Filters selectedFilter,
  ) async {
    List<String> transportations = [];
    if (isCTASelected == true) {
      transportations.add("BUS");
    } else if (isMetroSelected == true) {
      transportations.add("METRO");
    } else if (isMicroBusSelected == true) {
      transportations.add("MICROBUS");
    } else if (isMiniBusSelected == true) {
      transportations.add("BUS");
    }
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String filter = 'TIME';
    if (selectedFilter == Filters.LessTime) {
      filter = 'TIME';
    } else if (selectedFilter == Filters.LessPrice) {
      filter = 'PRICE';
    } else if (selectedFilter == Filters.FewerTransportation) {
      filter = 'NUMBER_OF_TRANSPORTATIONS';
    } else if (selectedFilter == Filters.LessWalking) {
      filter = 'WALKING_TIME';
    }

    const apiUrl = 'http://192.168.1.9:8000/api/journey';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(
          {
            "source": {
              "longitude": firstSelectedLatLng!.longitude,
              "latitude": firstSelectedLatLng.latitude,
            },
            "destination": {
              "longitude": lastSelectedLatLng!.longitude,
              "latitude": lastSelectedLatLng.latitude,
            },
            "time": "10:00:00",
            "filter": filter,
            "transportations": transportations,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> responseData =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        if (selectedFilter == Filters.LessTime) {
          responseData.sort((a, b) {
            final double aValue = a['duration'] is int
                ? (a['duration'] as int).toDouble()
                : a['duration'] as double;

            final double bValue = b['duration'] is int
                ? (b['duration'] as int).toDouble()
                : b['duration'] as double;

            return aValue.compareTo(bValue);
          });
        } else if (selectedFilter == Filters.LessWalking) {
          responseData.sort((a, b) {
            final double aValue = a['walkingTime'] is int
                ? (a['walkingTime'] as int).toDouble()
                : a['walkingTime'] as double;

            final double bValue = b['walkingTime'] is int
                ? (b['walkingTime'] as int).toDouble()
                : b['walkingTime'] as double;

            return aValue.compareTo(bValue);
          });
        } else if (selectedFilter == Filters.LessPrice) {
          responseData.sort((a, b) {
            final double aValue = a['totalPrice'] is int
                ? (a['totalPrice'] as int).toDouble()
                : a['totalPrice'] as double;

            final double bValue = b['totalPrice'] is int
                ? (b['totalPrice'] as int).toDouble()
                : b['totalPrice'] as double;

            return aValue.compareTo(bValue);
          });
        } else if (selectedFilter == Filters.FewerTransportation) {
          responseData.sort((a, b) {
            final double aValue = a['numberOfTransfers'] is int
                ? (a['numberOfTransfers'] as int).toDouble()
                : a['numberOfTransfers'] as double;

            final double bValue = b['numberOfTransfers'] is int
                ? (b['numberOfTransfers'] as int).toDouble()
                : b['numberOfTransfers'] as double;

            return aValue.compareTo(bValue);
          });
        }

        log(response.body);
        log('Data successfully sent to the API');
        return responseData;
      } else {
        log('Failed to send data to the API ${response.body}');
      }
    } catch (e) {
      log('Error in LatLng: $e');
    }
    return null;
  }

  AppBar appBarMethod(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      leading: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                                       builder: (context) => const PageOne()

                  ),
                );
              },
            ),
          )
        ],
      ),
      flexibleSpace: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Icon(
                      Icons.circle_outlined,
                      size: 15,
                    ),
                  ]),
                  Row(children: [
                    Text(
                      '.',
                      style: TextStyle(height: 1),
                    )
                  ]),
                  Row(children: [
                    Text(
                      '.',
                      style: TextStyle(height: 1),
                    )
                  ]),
                  Row(children: [
                    Text(
                      '.',
                      style: TextStyle(height: 1),
                    )
                  ]),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.red, size: 20)
                  ]),
                ],
              ),
              Stack(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAutocomplete(
                        'From', _sourceController, widget.sourceText, context),
                    const SizedBox(height: 16),
                    buildAutocomplete('To', _destinationController,
                        widget.destinationText, context),
                  ],
                ),
                Positioned(
                  top: 27.5,
                  right: 50,
                  height: 50,
                  width: 50,
                  child: IconButton(
                    icon: const Icon(
                      Icons.swap_vert_circle,
                      color: Color.fromRGBO(8, 15, 44, 1),
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        swapText();
                      });
                    },
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      builder: (context, state) {
        return SafeArea(
          child: Listener(
            onPointerDown: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: appBarMethod(context),
              body: WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                                           builder: (context) => const PageOne()

                    ),
                  );
                  return true; // Return true to allow back navigation
                },
                child: SnappingBottomSheetAllPathsWidget(
                  isMetroSelected: widget.isMetroSelected,
                  isCTASelected: widget.isCTASelected,
                  isMiniBusSelected: widget.isMiniBusSelected,
                  isMicroBusSelected: widget.isMicroBusSelected,
                  sourceController: _sourceController,
                  destinationController: _destinationController,
                  selectedTimePass: selectedTime,
                  selectedFilterPass: selectedFilter,
                  firstSelectedLatLng: firstSelectedLatLng,
                  lastSelectedLatLng: lastSelectedLatLng,
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}
