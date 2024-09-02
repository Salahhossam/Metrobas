import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/map_widget_saved_journeys.dart';
import 'package:thirddraft/page_one.dart';
import 'package:thirddraft/state.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart' as fm;

class SavedJourneys extends StatefulWidget {
  const SavedJourneys({super.key});
  @override
  State<SavedJourneys> createState() => _SavedJourneysState();
}

class _SavedJourneysState extends State<SavedJourneys> {
  var controller = Get.put(MainStateController());
  bool _isLoading = false;

  FutureOr<Iterable<String>> _optionsBuilder(
      TextEditingValue textEditingValue) async {
    var data = await addressSuggestion(textEditingValue.text);
    return data.map((searchInfo) => '${searchInfo.address}');
  }

  Widget buildAutocomplete(String labelText, TextEditingController controller,
      String address, context) {
    AppCubit.get(context);
    return SizedBox(
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) =>
            _optionsBuilder(textEditingValue),
        onSelected: (selection) async {
          setState(() {
            controller.text = selection;
          });
          var data = await addressSuggestion(selection);
          setState(() {
            savedLatLng = data.first.point;
            _mapController.move(
              LatLng(savedLatLng!.latitude, savedLatLng!.longitude),
              15,
            );
          });
          FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode fieldFocusNode,
          void Function() onFieldSubmitted,
        ) {
          if (controller.text.isEmpty) {
            controller.text = address;
          } else {
            controller.text = controller.text;
          }
          return Container(
            margin: const EdgeInsets.all(15),
            child: TextFormField(
              controller: controller,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: labelText,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                 border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        MediaQuery.of(context).size.width * .04,
                                      ),
                                    ),
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
            ),
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
                color: Colors.white,
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      onTap: () {
                        onSelected(option);
                        FocusManager.instance.primaryFocus
                            ?.unfocus(); // Dismiss keyboard
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

  final _savedController = TextEditingController();
  final _placeNameController = TextEditingController();

  GeoPoint? savedLatLng;
  late fm.MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
  }

  Future<Map<String, dynamic>?> savePlace(
      String placeName, String saveName, GeoPoint savedLatLng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    const apiUrl = 'http://192.168.1.9:8000/api/saved-places';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(
          {
            "longitude": savedLatLng.longitude,
            "latitude": savedLatLng.latitude,
            "name": saveName,
            "label": placeName,
          },
        ),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 201) {
        log('Place saved successfully with status code: ${response.statusCode}');

        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          try {
            final Map<String, dynamic> responseData =
                json.decode(utf8.decode(response.bodyBytes));
            return responseData;
          } catch (e) {
            log('Error parsing JSON: $e');
          }
        } else {
          log('Non-JSON response: ${response.body}');
          return {
            'message': response.body,
          };
        }
      } else {
        log('Failed to save place: ${response.statusCode}, Response body: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String savedText = _savedController.text;
    String placeName = _placeNameController.text;

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Saved Place'),
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
                      MaterialPageRoute(builder: (context) => const PageOne()));
                },
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PageOne()),
                );
                return true; // Return true to allow back navigation
              },
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .04,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: TextFormField(
                      controller: _placeNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Place Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              MediaQuery.of(context).size.width * .04,
                            ),
                          ),
                        ),
                        isDense: true,
                        prefixIcon: const Icon(Icons.favorite_border),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * .01,
                            horizontal:
                                MediaQuery.of(context).size.width * .04),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .04,
                  ),
                  buildAutocomplete(
                      'Save Place', _savedController, savedText, context),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .04,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(8, 15, 44, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          MediaQuery.of(context).size.width * .04,
                        ),
                      ),
                    ),
                    width: 200,
                    child: MaterialButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (savedLatLng != null) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final data = await savePlace(
                                    placeName, savedText, savedLatLng!);
                                if (data != null) {
                                  var cubit = AppCubit.get(context);
                                  cubit.saveJourneysData(data);
                                  log('Selected LatLng: $savedLatLng');
                                  log(savedText);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => const PageOne()),
                                  );
                                } else {
                                  log('Failed to save place');
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                log('No location selected');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a location'),
                                  ),
                                );
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .04,
                  ),
                  Expanded(
                    child: MapWidgetSavedJourneys(
                      mapController: _mapController,
                      selectedLatLng: savedLatLng != null
                          ? LatLng(
                              savedLatLng!.latitude, savedLatLng!.longitude)
                          : const LatLng(30.044326328134307,
                              31.236321058539797), // Default location
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
