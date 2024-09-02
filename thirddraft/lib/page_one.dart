import 'package:flutter/material.dart';
import 'package:thirddraft/chat.dart';
import 'package:thirddraft/contact_us.dart';
import 'package:thirddraft/edit_profile.dart';
import 'package:thirddraft/edit_save_journeys.dart';
import 'package:thirddraft/login.dart';
import 'package:thirddraft/saved_journeys.dart';
import 'PageTwo/page_two.dart';
import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'state.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class PageOne extends StatefulWidget {
  const PageOne({super.key});
  @override
  State<PageOne> createState() => _PageOneState();
}

// ignore: constant_identifier_names
enum Filters { LessTime, LessPrice, FewerTransportation, LessWalking }

class _PageOneState extends State<PageOne> {
  late TimeOfDay _timeOfDay;
  Filters selectedFilter = Filters.LessTime;
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  bool sourceControllerChanged = false;
  bool destinationControllerChanged = false;
  GeoPoint? firstSelectedLatLng;
  GeoPoint? lastSelectedLatLng;
  bool _isLoading = false;

  void swapText() {
    String sourceText = _sourceController.text;
    _sourceController.text = _destinationController.text;
    _destinationController.text = sourceText;
  }

  final TextEditingController _timeController = TextEditingController();
  bool isMetroSelected = false;
  bool isCTASelected = true;
  bool isMiniBusSelected = false;
  bool isMicroBusSelected = false;
  late int userId;
  String? imageAssetPath = 'images/MetroBas.png';

  void navigateToSecondPage() {
    if (firstSelectedLatLng != null && lastSelectedLatLng != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PageTwo(
            selectedTimePass: _timeController.text,
            selectedFilterPass: selectedFilter,
            sourceText: _sourceController.text,
            destinationText: _destinationController.text,
            firstSelectedLatLng: firstSelectedLatLng!,
            lastSelectedLatLng: lastSelectedLatLng!,
            isMetroSelected: isMetroSelected,
            isCTASelected: isCTASelected,
            isMiniBusSelected: isMiniBusSelected,
            isMicroBusSelected: isMicroBusSelected,
          ),
        ),
      );
    } else {
      log('firstSelectedLatLng: $firstSelectedLatLng');
      log('lastSelectedLatLng: $lastSelectedLatLng');
      // Handle the case where the locations are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select both source and destination locations')),
      );
    }
  }

  OverlayEntry? overlayEntry;
  FocusNode focusNode = FocusNode();
  DateTime? lastBackPressTime;

  var controller = Get.put(MainStateController());
  // FutureOr<Iterable<String>> _optionsBuilder(
  //     TextEditingValue textEditingValue) async {
  //   var data = await addressSuggestion(textEditingValue.text);
  //   return data.map((searchInfo) => '${searchInfo.address}');
  // }
  FutureOr<Iterable<String>> _optionsBuilder(
      TextEditingValue textEditingValue) async {
    var savedPlaces = await postSavedPlaces(userId); // Fetch saved journeys
    var data = await addressSuggestion(
        textEditingValue.text); // Fetch dynamic suggestions
    List<String> suggestions = []; // Combined list of suggestions

    if (savedPlaces != null) {
      suggestions
          .addAll(savedPlaces.map((journey) => 'saved_${journey?['label']}'));
    }

    suggestions.addAll(data.map(
        (searchInfo) => '${searchInfo.address}')); // Add dynamic suggestions

    return suggestions;
  }

  Widget buildAutocomplete(
    String labelText,
    TextEditingController controller,
    String address,
    BuildContext context,
  ) {
    return SizedBox(
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) =>
            _optionsBuilder(textEditingValue),
        onSelected: (selection) async {
          setState(() {
            controller.text = selection.replaceFirst('saved_', '');
          });

          // Fetch details for the selected address
          var data = await addressSuggestion(selection);

          // Update firstSelectedLatLng and lastSelectedLatLng based on controller
          if (controller == _sourceController) {
            setState(() {
              sourceControllerChanged = true;
              firstSelectedLatLng =
                  data.first.point; // Ensure data has correct structure
            });
          } else if (controller == _destinationController) {
            setState(() {
              destinationControllerChanged = true;
              lastSelectedLatLng =
                  data.first.point; // Ensure data has correct structure
            });
          }

          FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldController,
          FocusNode fieldFocusNode,
          void Function() onFieldSubmitted,
        ) {
          if (fieldController.text.isEmpty) {
            fieldController.text = address;
          }
          return TextFormField(
            controller: fieldController,
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  fieldController.clear();
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
          // Separate saved places and address suggestions
          final savedPlaces =
              options.where((option) => option.startsWith('saved_'));
          final addressSuggestions =
              options.where((option) => !option.startsWith('saved_'));

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (savedPlaces.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: savedPlaces.length,
                        itemBuilder: (context, index) {
                          final option = savedPlaces
                              .elementAt(index)
                              .replaceFirst('saved_', '');
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: const Color.fromRGBO(8, 15, 44, 1),
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Center(
                                  child:
                                      Text(option.replaceFirst('saved_', ''))),
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addressSuggestions.length,
                      itemBuilder: (context, index) {
                        final option = addressSuggestions.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(8, 15, 44, 1),
                                ),
                              ),
                            ),
                            child: Center(child: Text(option)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
    String selectedTime,
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
            "time": selectedTime,
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
        log(' $transportations');
        return responseData;
      } else {
        log('Failed to send data to the API ${response.body}');
      }
    } catch (e) {
      log('Error in LatLng: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>?>?> postSavedPlaces(userId) async {
    var apiUrl = 'http://192.168.1.9:8000/api/saved-places/user/$userId';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> responseData =
            List<Map<String, dynamic>>.from(
                json.decode(utf8.decode(response.bodyBytes)));
        return responseData;
      } else {
        log('Failed to send data to the API ${response.body}');
      }
    } catch (e) {
      log('Error in LatLng: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateSavedPlace(
      int savedPlaceId, String name, GeoPoint updatedLatLng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final apiUrl = 'http://192.168.1.9:8000/saved-places/$savedPlaceId';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        body: json.encode({
          "name": name,
          "stopLat": updatedLatLng.latitude,
          "stopLon": updatedLatLng.longitude,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            Map<String, dynamic>.from(json.decode(response.body));
        return responseData;
      } else {
        log('Failed to update saved place: ${response.statusCode}, Response body: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  Future<void> deleteSavePlace(savedPlaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    var apiUrl = 'http://192.168.1.9:8000/api/saved-places/$savedPlaceId';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('Place saved successfully deleted with status code: ${response.statusCode}');
      } else {
        log('Failed to delete saved place: ${response.statusCode}, Response body: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);
    if (cubit.listSaveJourneys != null && cubit.listSaveJourneys!.isNotEmpty) {
      savedJourney = cubit.listSaveJourneys![0]?['name'] ?? 'Tap to set';
    }
    if (cubit.userInfo != null) {
      userId = cubit.userInfo!['userDto']['userId'];
    }
      fetchSavedPlaces(userId, cubit); // Fetch the saved places data
    _timeOfDay = TimeOfDay.now();
    _timeController.text =
        '${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  void fetchSavedPlaces(int userId, AppCubit cubit) async {
    final data =
        await postSavedPlaces(userId); // Wait for the data to be fetched
    if (data != null) {
      cubit
          .listSaveJourneysData(data); // Update the cubit with the fetched data
    } else {
      log('Failed to fetch saved places');
    }
  }

  String savedJourney = 'Tap to set';

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    String sourceText = _sourceController.text;
    String destinationText = _destinationController.text;
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return SafeArea(
            child: Listener(
          onPointerDown: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 100,
              centerTitle: true,
              title: const Text(
                'METRO BAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(8, 15, 44, 1),
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Chat(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat,
                    color: Color.fromRGBO(8, 15, 44, 1),
                    size: 35,
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0)),
                      color: Color.fromRGBO(8, 15, 44, 1),
                    ),
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 80.0,
                          backgroundImage: AssetImage(imageAssetPath!),
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          cubit.userInfo!['userDto']['userName'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          cubit.userInfo!['userDto']['email'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Color.fromRGBO(8, 15, 44, 1),
                              size: 25,
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const EditProfile(),
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 15.0,
                  ),
                  InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.contact_support,
                              color: Color.fromRGBO(8, 15, 44, 1),
                              size: 25,
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              "Contact Us",
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ContactUs(),
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 15.0,
                  ),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 25,
                            color: Color.fromRGBO(8, 15, 44, 1),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Text(
                            "Log Out",
                            style: TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog<bool>(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            content: const Text(
                                "Are you sure you want to Log Out ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.remove('token');
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Log Out",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                DateTime now = DateTime.now();
                if (lastBackPressTime == null ||
                    now.difference(lastBackPressTime!) >
                        const Duration(seconds: 2)) {
                  lastBackPressTime = now;
                  showToast(
                    'Press again to exit',
                    context: context,
                    animation: StyledToastAnimation.scale,
                    reverseAnimation: StyledToastAnimation.fade,
                    position: const StyledToastPosition(
                      align: Alignment.bottomCenter,
                      offset: 40,
                    ),
                    animDuration: const Duration(seconds: 1),
                    duration: const Duration(seconds: 3),
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.linear,
                  );
                  return false;
                }

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PageOne()),
                );
                return true;
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 5.0,
                              ),
                              buildAutocomplete('From', _sourceController,
                                  sourceText, context),
                              const SizedBox(height: 15),
                              buildAutocomplete('To', _destinationController,
                                  destinationText, context),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: TextFormField(
                                      controller: _timeController,
                                      readOnly: true,
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        labelText: 'Time',
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            ).then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  _timeOfDay = value;

                                                  // Format the TimeOfDay to a string in the default format (e.g., "10:00 AM")
                                                  String formattedTime =
                                                      _timeOfDay
                                                          .format(context);

                                                  // Extract the hour, minute, and period from the formatted string
                                                  int hour = int.parse(
                                                      formattedTime
                                                          .split(":")[0]);
                                                  int minute = int.parse(
                                                      formattedTime
                                                          .split(":")[1]
                                                          .split(" ")[0]);
                                                  // String period = formattedTime
                                                  //     .split(" ")[1];

                                                  // Convert the hour to 24-hour format if needed
                                                  // if (period == "PM" &&
                                                  //     hour < 12) {
                                                  //   hour = 0;
                                                  // } else if (period == "AM" &&
                                                  //     hour == 12) {
                                                  //   hour = 0;
                                                  // }

                                                  // Format the final string in the desired format "10:00:00"
                                                  _timeController.text =
                                                      "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";
                                                });
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.access_time),
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 15.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  SizedBox(
                                    width: 206,
                                    child: DropdownButtonFormField(
                                      value: selectedFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Filter',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 15.0),
                                      ),
                                      items: Filters.values.map((filter) {
                                        return DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter
                                              .toString()
                                              .split('.')
                                              .last),
                                        );
                                      }).toList(),
                                      onChanged: (Filters? val) {
                                        setState(() {
                                          selectedFilter = val!;
                                        });
                                      },
                                      validator: (Filters? val) {
                                        if (val == null) {
                                          return 'Please select your filter';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: const Color.fromRGBO(8, 15, 44, 1),
                                ),
                                width: 200.0,
                                child: MaterialButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (sourceControllerChanged &&
                                              destinationControllerChanged) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            final data = await postLatLngToApi(
                                              firstSelectedLatLng,
                                              lastSelectedLatLng,
                                              _timeController.text,
                                              selectedFilter,
                                            );
                                            if (data != null) {
                                              var cubit = AppCubit.get(context);
                                              cubit.singlePathData(data);
                                              if (cubit.singlePath != null &&
                                                  cubit
                                                      .singlePath!.isNotEmpty) {
                                                final firstMap =
                                                    cubit.singlePath![0];
                                                if (firstMap != null) {
                                                  final duration =
                                                      firstMap['duration'];
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
                                              log('Selected LatLng: ${firstSelectedLatLng?.longitude.runtimeType}');
                                              log('Selected LatLng: $firstSelectedLatLng');
                                              log('Selected LatLng: $lastSelectedLatLng');
                                              log('Selected selectedTimePass: $_timeController');
                                              log('Selected selectedFilterPass: $selectedFilter');
                                              sourceControllerChanged = false;
                                              destinationControllerChanged =
                                                  false;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                          navigateToSecondPage();
                                        },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : const Text(
                                          'SHOW ME',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
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
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'transportation way',
                            style: TextStyle(
                              color: Color.fromRGBO(8, 15, 44, 1),
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isMetroSelected = !isMetroSelected;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isMetroSelected
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    child: Image.asset(
                                      'images/Metro.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                const Text(
                                  "Metro",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isCTASelected = !isCTASelected;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isCTASelected
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    child: Image.asset(
                                      'images/CTA.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                const Text(
                                  "Bus",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isMiniBusSelected = !isMiniBusSelected;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isMiniBusSelected
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    child: Image.asset(
                                      'images/MiniBus.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                const Text(
                                  "Mini Bus",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isMicroBusSelected = !isMicroBusSelected;
                                    });
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isMicroBusSelected
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    child: Image.asset(
                                      'images/MicroBus.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                const Text(
                                  "Micro Bus",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Places',
                            style: TextStyle(
                              color: Color.fromRGBO(8, 15, 44, 1),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final result =
                                  await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SavedJourneys(),
                                ),
                              );
                              if (result != null) {
                                cubit.listSaveJourneysData(result);
                              }
                            },
                            icon: const Icon(Icons.add),
                          )
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      if (cubit.listSaveJourneys != null)
                        for (var i = 0; i < cubit.listSaveJourneys!.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dismissible(
                              key: Key(
                                  '${cubit.listSaveJourneys![i]?['savedPlaceId']}'),
                              background: Container(
                                color: const Color.fromARGB(255, 141, 14, 5),
                                alignment: Alignment.centerLeft,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.transparent,
                              ),
                              confirmDismiss:
                                  (DismissDirection direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  final bool? response = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext ctx) {
                                      return AlertDialog(
                                        content: Text(
                                            "Are you sure you want to delete ${cubit.listSaveJourneys![i]?['name']} ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(false);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop(true);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (response == true) {
                                    deleteSavePlace(cubit.listSaveJourneys![i]
                                        ?['savedPlaceId']);
                                    return true;
                                  } else {
                                    return false;
                                  }
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  return false; // Don't allow dismissing to the endToStart direction
                                } else {
                                  return false;
                                }
                              },
                              child: InkWell(
                                onTap: () {
                                  int savedPlaceId = cubit.listSaveJourneys![i]
                                      ?['savedPlaceId'];
                                  String saveName =
                                      cubit.listSaveJourneys![i]?['name'];
                                  String placeName =
                                      cubit.listSaveJourneys![i]?['label'];

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => EditSavedJourneys(
                                        savedPlaceId: savedPlaceId,
                                        saveName: saveName,
                                        placeName: placeName,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.place,
                                      color: Color.fromRGBO(8, 15, 44, 1),
                                    ),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${cubit.listSaveJourneys![i]?['label']}',
                                          style: const TextStyle(
                                              color:
                                                  Color.fromRGBO(8, 15, 44, 1),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 250,
                                          child: Text(
                                            cubit.listSaveJourneys![i]
                                                    ?['name'] ??
                                                'No Name',
                                            style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color.fromRGBO(8, 15, 44, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 15.0),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(8, 15, 44, 1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Color.fromRGBO(8, 15, 44, 1),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You can add new save place here",
                                style: TextStyle(
                                 color: Color.fromRGBO(8, 15, 44, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      //   const Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Recent Journeys',
                      //         style: TextStyle(
                      //           color: Color.fromRGBO(8, 15, 44, 1),
                      //           fontSize: 20.0,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      //   Container(
                      //     width: 300,
                      //     height: 300,
                      //     decoration: BoxDecoration(
                      //       borderRadius:
                      //           const BorderRadius.all(Radius.circular(10.0)),
                      //       border: Border.all(
                      //         color: const Color.fromRGBO(8, 15, 44, 1),
                      //       ),
                      //     ),
                      //     child: const MapWidgetSave(),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
