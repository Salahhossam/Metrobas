// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'package:thirddraft/map_widget_saved_journeys.dart';
import 'package:thirddraft/page_one.dart';
import 'package:thirddraft/state.dart';

class EditSavedJourneys extends StatefulWidget {
  final int savedPlaceId;
  final String saveName;
  final String placeName;

  const EditSavedJourneys({
    super.key,
    required this.savedPlaceId,
    required this.saveName,
    required this.placeName,
  });
  @override
  State<EditSavedJourneys> createState() => _EditSavedJourneysState();
}

class _EditSavedJourneysState extends State<EditSavedJourneys> {
  var controller = Get.put(MainStateController());
  late int savedPlaceId;

  late String wSaveName;
  late String wPlaceName;

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
            editSavedLatLng = data.first.point;
            _mapController.move(
              LatLng(editSavedLatLng!.latitude, editSavedLatLng!.longitude),
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
  GeoPoint? editSavedLatLng;
  late fm.MapController _mapController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
    savedPlaceId = widget.savedPlaceId;
    wSaveName = widget.saveName;
    wPlaceName = widget.placeName;

    _savedController.text = widget.saveName;
    _placeNameController.text = widget.placeName;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _savedController.dispose();
    _placeNameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> editSavePlace(int savedPlaceId, String saveName,
      String placeName, GeoPoint editSavedLatLng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    var apiUrl = 'http://192.168.1.9:8000/api/saved-places/$savedPlaceId';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        body: json.encode(
          {
            "longitude": editSavedLatLng.longitude,
            "latitude": editSavedLatLng.latitude,
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

      if (response.statusCode == 200) {
        log('Place updated successfully with status code: ${response.statusCode}');

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
        log('Failed to update place: ${response.statusCode}, Response body: ${response.body}');
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
              title: const Text('Edit Saved Place'),
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
                              savedText = _savedController.text.trim();
                              placeName = _placeNameController.text.trim();

                              if (placeName.isEmpty) {
                                log('Place name is empty');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a valid place name'),
                                  ),
                                );
                                return;
                              }

                              if (editSavedLatLng != null) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final data = await editSavePlace(savedPlaceId,
                                    savedText, placeName, editSavedLatLng!);
                                if (data != null) {
                                  var cubit = AppCubit.get(context);
                                  cubit.saveJourneysData(data);
                                  log('Selected LatLng: $editSavedLatLng');
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
                      selectedLatLng: editSavedLatLng != null
                          ? LatLng(editSavedLatLng!.latitude,
                              editSavedLatLng!.longitude)
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
