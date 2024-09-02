import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:thirddraft/PageTwo/map_widget_details.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';

import 'page_two.dart';
import 'package:flutter/material.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import '../page_one.dart';

class DetailsSinglePath extends StatefulWidget {
  const DetailsSinglePath({
    super.key,
    required this.sourceText,
    required this.destinationText,
    required this.selectedTimePass,
    required this.selectedFilterPass,
    required this.index,
    required this.firstSelectedLatLng,
    required this.lastSelectedLatLng,
    required this.isMetroSelected,
    required this.isCTASelected,
    required this.isMiniBusSelected,
    required this.isMicroBusSelected,
  });
  final bool isMetroSelected;
  final bool isCTASelected;
  final bool isMiniBusSelected;
  final bool isMicroBusSelected;
  final GeoPoint firstSelectedLatLng;
  final GeoPoint lastSelectedLatLng;
  final String selectedTimePass;
  final Filters selectedFilterPass;
  final String sourceText;
  final String destinationText;
  final int index;

  @override
  State<DetailsSinglePath> createState() => _DetailsSinglePathState();
}

class Stops {
  final String stopName;
  // final String stopTime;

  Stops({
    required this.stopName,
    // required this.stopTime,
  });
}

class _DetailsSinglePathState extends State<DetailsSinglePath> {
  String transportName = '';
  double travelTime = 0;
  double walkTime = 0;
  double stops = 0;
  double price = 0;
  bool isPanelExpanded = false;
  late TextEditingController sourceController;
  late TextEditingController destinationController;
  late TextEditingController selectedTime;
  late Filters selectedFilter;
  String transportationTypeFromApi = '';
  List<dynamic> apiResponse = [];
  List<dynamic> journeyPoints = [];
  List<bool> isPanelExpandedList = [];
  late bool isMetroSelected;
  late bool isCTASelected;
  late bool isMiniBusSelected;
  late bool isMicroBusSelected;
  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);
    isMetroSelected = widget.isMetroSelected;
    isCTASelected = widget.isCTASelected;
    isMiniBusSelected = widget.isMiniBusSelected;
    isMicroBusSelected = widget.isMicroBusSelected;
    sourceController = TextEditingController(text: widget.sourceText);
    destinationController = TextEditingController(text: widget.destinationText);
    selectedTime = TextEditingController(text: widget.destinationText);
    selectedTime.text = widget.selectedTimePass;
    selectedFilter = widget.selectedFilterPass;
    travelTime =
        (cubit.singlePath![widget.index]?['duration'] as num?)?.toDouble() ?? 0;
    walkTime =
        (cubit.singlePath![widget.index]?['walkingTime'] as num?)?.toDouble() ??
            0;
    stops = (cubit.singlePath![widget.index]?['numberOfTransfers'] as num?)
            ?.toDouble() ??
        0;
    price =
        (cubit.singlePath![widget.index]?['totalPrice'] as num?)?.toDouble() ??
            0;
    int subTripsCount =
        cubit.singlePath![widget.index]?['subTrips']?.length ?? 0;
    isPanelExpandedList = List.generate(subTripsCount, (index) => false);
    journeyPoints = cubit.singlePath![widget.index]?['journeyPoints'];
    if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
      travelTime =
          cubit.singlePath![widget.index]?['duration']?.toDouble() ?? 0;
      stops =
          cubit.singlePath![widget.index]?['numberOfTransfers']?.toDouble() ??
              0;
      price = cubit.singlePath![widget.index]?['totalPrice']?.toDouble() ?? 0;
      journeyPoints = cubit.singlePath![widget.index]?['journeyPoints'];
    }
    // fetchDataFromApi();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return SafeArea(
          child: Scaffold(
            body: WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => PageTwo(
                    isMetroSelected: isMetroSelected,
                    isCTASelected: isCTASelected,
                    isMiniBusSelected: isMiniBusSelected,
                    isMicroBusSelected: isMicroBusSelected,
                    selectedTimePass: selectedTime.text,
                    selectedFilterPass: selectedFilter,
                    sourceText: sourceController.text,
                    destinationText: destinationController.text,
                    firstSelectedLatLng: widget.firstSelectedLatLng,
                    lastSelectedLatLng: widget.lastSelectedLatLng,
                  ),
                ));
                return true; // Return true to allow back navigation
              },
              child: SnappingBottomSheet(
                elevation: 8,
                cornerRadius: 25,
                snapSpec: const SnapSpec(
                  snap: false,
                  snappings: [0.07, .75, .75],
                  positioning: SnapPositioning.relativeToSheetHeight,
                  initialSnap: 0.5,
                ),
                builder: (context, state) {
                  return Column(
                    children: [
                      const Icon(
                        size: 50,
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle_outlined,
                              size: 25,
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                sourceController.text,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                softWrap: false,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_right_alt,
                              size: 50,
                            ),
                            const Icon(Icons.location_on_outlined,
                                color: Colors.red, size: 25),
                            SizedBox(
                              width: 100,
                              child: Text(
                                destinationController.text,
                                style: const TextStyle(
                                  color: Color.fromRGBO(169, 89, 12, 1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTransportInfoContainer('Time',
                              '${(cubit.singlePath![widget.index]?['duration'] as num?)?.toDouble() ?? 0} min'),
                          _buildTransportInfoContainer('Transfer',
                              '${(cubit.singlePath![widget.index]?['numberOfTransfers'] as num?)?.toDouble() ?? 0}'),
                          _buildTransportInfoContainer('Price',
                              '${(cubit.singlePath![widget.index]?['totalPrice'] as num?)?.toDouble() ?? 0} LE'),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // if (cubit.singlePath![widget.index]?['tripName'] ==
                            //     'Walking')
                            //   BuildContentContainerWalk(
                            //     walkTime: double.tryParse(
                            //             cubit.singlePath![widget.index]
                            //                 ?['walkingTime'] as String) ??
                            //         0,
                            //     stopNames: cubit.singlePath![widget.index]
                            //                 ?['subTrips'][0]['stopNames']
                            //             ?.cast<String>() ??
                            //         [], // Pass stopNames here
                            //   )
                            // else if (cubit.singlePath![widget.index]
                            //         ?['tripName'] ==
                            //     'Transfer')
                            //   BuildContentContainerTransfer(
                            //     stopNames: cubit.singlePath![widget.index]
                            //                 ?['subTrips'][0]['stopNames']
                            //             ?.cast<String>() ??
                            //         [], // Pass stopNames here
                            //   )
                            // else
                            _buildContentContainer(
                              transportNames: cubit.singlePath![widget.index]
                                          ?['subTrips']
                                      ?.map((subTrip) =>
                                          subTrip['tripName'] as String)
                                      .toList() ??
                                  [],
                              subTrips: cubit.singlePath![widget.index]
                                      ?['subTrips'] as List<dynamic>? ??
                                  [],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                body: Stack(
                  children: [
                    MapWidgetDetails(
                      journeyPoints: cubit.singlePath![0]?['journeyPoints'],
                    ),
                    Positioned(
                      top: 20,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromRGBO(8, 15, 44, 1),
                          size: 40,
                        ),
                        hoverColor: Colors.grey,
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (_) => PageTwo(
                              isMetroSelected: isMetroSelected,
                              isCTASelected: isCTASelected,
                              isMiniBusSelected: isMiniBusSelected,
                              isMicroBusSelected: isMicroBusSelected,
                              selectedTimePass: selectedTime.text,
                              selectedFilterPass: selectedFilter,
                              sourceText: sourceController.text,
                              destinationText: destinationController.text,
                              firstSelectedLatLng: widget.firstSelectedLatLng,
                              lastSelectedLatLng: widget.lastSelectedLatLng,
                            ),
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, Object? state) {},
    );
  }

  Widget _buildTransportInfoContainer(String label, String value) {
    return Container(
      width: 105,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromRGBO(217, 217, 217, 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label == 'Time') const Icon(Icons.timer_outlined),
              if (label == 'Transfer')
                const Icon(Icons.transfer_within_a_station_outlined),
              if (label == 'Price') const Icon(Icons.price_change_outlined),
              Text('  $label'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(color: Color.fromRGBO(28, 59, 189, 1)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContentContainer({
    required List<dynamic> transportNames,
    required List<dynamic> subTrips,
  }) {
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            for (int i = 0; i < transportNames.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transportNames[i] == 'Walking')
                    _buildContentContainerWalk(
                      walkingTime: (cubit.singlePath![widget.index]
                                  ?['walkingTime'] as num?)
                              ?.toDouble() ??
                          0,
                      subTrips:
                          subTrips[i]['stopNames'] as List<dynamic>? ?? [],
                    )
                  else if (transportNames[i] == 'Transfer')
                    _buildContentContainerTransfer(
                      subTrips:
                          subTrips[i]['stopNames'] as List<dynamic>? ?? [],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_bus_filled_outlined),
                            const SizedBox(width: 16),
                            SizedBox(
                                width: 290,
                                child: Text(
                                  transportNames[i] as String,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildListView(
                            subTrips[i]['stopNames'] as List<dynamic>? ?? [],
                            i),
                        const SizedBox(height: 16),
                      ],
                    ),
                ],
              ),
          ],
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
  // Widget _buildContentContainer({
  //   required String transportName,
  //   required List<dynamic> stopsList,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [Text(transportName)],
  //       ),
  //       const SizedBox(height: 16),
  //       _buildListView(stopsList),
  //       const SizedBox(height: 16),
  //     ],
  //   );
  // }

  _buildListView(List<dynamic> stopsList, int panelIndex) {
  // Remove everything after the comma for each stop name
  List<String> cleanedStopsList = stopsList
      .map((stop) => (stop as String).split(',').first.trim())
      .toList();

  return InkWell(
    onTap: () {
      setState(() {
        isPanelExpandedList[panelIndex] = !isPanelExpandedList[panelIndex];
      });
    },
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.all(10),
        expansionCallback: (index, bool isExpanded) {
          setState(() {
            isPanelExpandedList[panelIndex] = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Stops'),
              );
            },
            body: isPanelExpandedList[panelIndex]
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cleanedStopsList.length,
                    itemBuilder: (context, index) {
                      if (cleanedStopsList.isNotEmpty) {
                        String stopName = cleanedStopsList[index];
                        return Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: (index == 0 ||
                                      index == cleanedStopsList.length - 1)
                                  ? Colors.black
                                  : const Color.fromRGBO(97, 125, 156, 1),
                              size: (index == 0 ||
                                      index == cleanedStopsList.length - 1)
                                  ? 15
                                  : 10,
                            ),
                            SizedBox(
                              width: 290,
                              child: Text(
                                '  $stopName',
                                softWrap: false,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: (index == 0 ||
                                          index == cleanedStopsList.length - 1)
                                      ? Colors.black
                                      : const Color.fromRGBO(97, 125, 156, 1),
                                  fontWeight: (index == 0 ||
                                          index == cleanedStopsList.length - 1)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                          ],
                        );
                      }
                      return null;
                    },
                  )
                : Container(),
            isExpanded: isPanelExpandedList[panelIndex],
          ),
        ],
      ),
    ),
  );
}
 // Widget _buildListView(List<dynamic> stopsList) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         isPanelExpanded = !isPanelExpanded;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.all(16.0),
  //       child: ExpansionPanelList(
  //         elevation: 1,
  //         expandedHeaderPadding: const EdgeInsets.all(10),
  //         expansionCallback: (index, bool isExpanded) {
  //           setState(() {
  //             isPanelExpanded = !isExpanded;
  //           });
  //         },
  //         children: [
  //           ExpansionPanel(
  //             headerBuilder: (BuildContext context, bool isExpanded) {
  //               return const ListTile(
  //                 title: Text('Stops'),
  //               );
  //             },
  //             body: isPanelExpanded
  //                 ? ListView.builder(
  //                     shrinkWrap: true,
  //                     itemCount: stopsList.length,
  //                     itemBuilder: (context, index) {
  //                       String stopName = stopsList[0][index]['stopName'];
  //                       // String stopTime = stopsList[index]['stopTime'];
  //                       return Row(
  //                         children: [
  //                           Icon(
  //                             Icons.circle,
  //                             color:
  //                                 (index == 0 || index == stopsList.length - 1)
  //                                     ? Colors.black
  //                                     : const Color.fromRGBO(97, 125, 156, 1),
  //                             size:
  //                                 (index == 0 || index == stopsList.length - 1)
  //                                     ? 15
  //                                     : 10,
  //                           ),
  //                           Text(
  //                             '  $stopName',
  //                             style: TextStyle(
  //                               color: (index == 0 ||
  //                                       index == stopsList.length - 1)
  //                                   ? (Colors.black)
  //                                   : const Color.fromRGBO(97, 125, 156, 1),
  //                               fontWeight: (index == 0 ||
  //                                       index == stopsList.length - 1)
  //                                   ? FontWeight.bold
  //                                   : FontWeight.normal,
  //                             ),
  //                           ),
  //                           // const Spacer(),
  //                           // Text(
  //                           //   stopTime,
  //                           //   style: TextStyle(
  //                           //     color: (index == 0 ||
  //                           //             index == stopsList.length - 1)
  //                           //         ? (Colors.black)
  //                           //         : const Color.fromRGBO(97, 125, 156, 1),
  //                           //     fontWeight: (index == 0 ||
  //                           //             index == stopsList.length - 1)
  //                           //         ? FontWeight.bold
  //                           //         : FontWeight.normal,
  //                           //   ),
  //                           // ),
  //                           const SizedBox(
  //                             height: 50,
  //                           )
  //                         ],
  //                       );
  //                     },
  //                   )
  //                 : Container(),
  //             isExpanded: isPanelExpanded,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildContentContainerWalk({
    required double walkingTime,
    required List<dynamic> subTrips,
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.directions_walk,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Walk $walkingTime min'),
                  SizedBox(
                      width: 300,
                      child: Text(
                        'From ${subTrips[0]} To ${subTrips[1]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              )
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentContainerTransfer({
    required List<dynamic> subTrips,
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.transfer_within_a_station,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 20,
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                  width: 300,
                  child: Text(
                    'Transfer From ${subTrips[0]} ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.circle,
                color: Color.fromRGBO(97, 125, 156, 1),
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
