import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';
import 'package:thirddraft/darkcubit/states.dart';

import '../darkcubit/cubit.dart';
import '../page_one.dart';
import 'map_widget_page_two.dart';
import 'paths_widget.dart';

class SnappingBottomSheetAllPathsWidget extends StatefulWidget {
  const SnappingBottomSheetAllPathsWidget({
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
  State<SnappingBottomSheetAllPathsWidget> createState() =>
      _SnappingBottomSheetAllPathsWidgetState();
}

class _SnappingBottomSheetAllPathsWidgetState
    extends State<SnappingBottomSheetAllPathsWidget> {
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
    AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return SnappingBottomSheet(
          elevation: 8,
          cornerRadius: 25,
          snapSpec: const SnapSpec(
              snap: false,
              snappings: [0.07, 0.75, 0.75],
              positioning: SnapPositioning.relativeToAvailableSpace,
              initialSnap: 0.5),
          builder: (BuildContext context, SheetState state) {
            return PathsWidget(
              isMetroSelected: widget.isMetroSelected,
              isCTASelected: widget.isCTASelected,
              isMiniBusSelected: widget.isMiniBusSelected,
              isMicroBusSelected: widget.isMicroBusSelected,
              sourceController: widget.sourceController,
              destinationController: widget.destinationController,
              selectedTimePass: widget.selectedTimePass,
              selectedFilterPass: widget.selectedFilterPass,
              firstSelectedLatLng: widget.firstSelectedLatLng,
              lastSelectedLatLng: widget.lastSelectedLatLng,
            );
          },
          body: const MapWidget(),
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
