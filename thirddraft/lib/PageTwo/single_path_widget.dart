import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
import 'details_path.dart';
import '../page_one.dart';

class SinglePathWidget extends StatefulWidget {
  const SinglePathWidget({
    super.key,
    required this.sourceController,
    required this.destinationController,
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
  final TextEditingController selectedTimePass;
  final Filters selectedFilterPass;
  final TextEditingController sourceController;
  final TextEditingController destinationController;
  final bool isMetroSelected;
  final bool isCTASelected;
  final bool isMiniBusSelected;
  final bool isMicroBusSelected;
  final GeoPoint firstSelectedLatLng;
  final GeoPoint lastSelectedLatLng;
  final int index;

  @override
  State<SinglePathWidget> createState() => _SinglePathWidgetState();
}

class _SinglePathWidgetState extends State<SinglePathWidget> {
  double travelTime = 0;
  double stops = 0;
  double price = 0;
  List<dynamic> journeyPoints = [];

  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);
    if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
      travelTime = cubit.singlePath![0]?['duration']?.toDouble() ?? 0;
      stops = cubit.singlePath![0]?['numberOfTransfers']?.toDouble() ?? 0;
      price = cubit.singlePath![0]?['totalPrice']?.toDouble() ?? 0;
      journeyPoints = cubit.singlePath![0]?['journeyPoints'];
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DetailsSinglePath(
                      isMetroSelected: widget.isMetroSelected,
                      isCTASelected: widget.isCTASelected,
                      isMiniBusSelected: widget.isMiniBusSelected,
                      isMicroBusSelected: widget.isMicroBusSelected,
                      sourceText: widget.sourceController.text,
                      destinationText: widget.destinationController.text,
                      selectedTimePass: widget.selectedTimePass.text,
                      selectedFilterPass: widget.selectedFilterPass,
                      index: widget.index,
                      firstSelectedLatLng: widget.firstSelectedLatLng,
                      lastSelectedLatLng: widget.lastSelectedLatLng,
                    ),
                  ),
                );
                Colors.grey;
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(16)),
                width: 320,
                height: 96,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.alt_route), Text('Mixed')],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.circle_outlined,
                            size: 15,
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              widget.sourceController.text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              softWrap: false,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_right_alt,
                            size: 15,
                          ),
                          const Icon(Icons.location_on_outlined,
                              color: Colors.red, size: 15),
                          SizedBox(
                            width: 50,
                            child: Text(
                              widget.destinationController.text,
                              style: const TextStyle(
                                color: Color.fromRGBO(169, 89, 12, 1),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromRGBO(217, 217, 217, 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 10,
                                    ),
                                    Text(
                                      '  Time',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cubit.singlePath != null &&
                                              cubit.singlePath!.isNotEmpty
                                          ? '${cubit.singlePath![widget.index]?['duration']} min'
                                          : '0',
                                      style: const TextStyle(
                                          color: Color.fromRGBO(28, 59, 189, 1),
                                          fontSize: 10),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromRGBO(217, 217, 217, 1),
                            ),
                            width: 50,
                            height: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.transfer_within_a_station_outlined,
                                      size: 10,
                                    ),
                                    Text(
                                      'Transfer',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cubit.singlePath != null &&
                                              cubit.singlePath!.isNotEmpty
                                          ? '${cubit.singlePath![widget.index]?['numberOfTransfers']}'
                                          : '0',
                                      style: const TextStyle(
                                          color: Color.fromRGBO(28, 59, 189, 1),
                                          fontSize: 10),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color.fromRGBO(217, 217, 217, 1),
                            ),
                            width: 50,
                            height: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.price_change_outlined,
                                      size: 10,
                                    ),
                                    Text(
                                      '  Price',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cubit.singlePath != null &&
                                              cubit.singlePath!.isNotEmpty
                                          ? '${cubit.singlePath![widget.index]?['totalPrice']} LE'
                                          : '0',
                                      style: const TextStyle(
                                          color: Color.fromRGBO(28, 59, 189, 1),
                                          fontSize: 10),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      listener: (BuildContext context, Object? state) {},
    );
  }
}
