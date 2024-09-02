import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../darkcubit/cubit.dart';
import '../darkcubit/states.dart';

class MapWidgetDetails extends StatefulWidget {
  const MapWidgetDetails({
    super.key,
    required this.journeyPoints,
  });

  final List<dynamic> journeyPoints;

  @override
  State<MapWidgetDetails> createState() => _MapWidgetDetailsState();
}

class _MapWidgetDetailsState extends State<MapWidgetDetails> {
  LatLng initialCenter = const LatLng(30.044326328134307, 31.236321058539797);
  List<LatLng> pathPoints = [];
  LatLng sourcePoint = const LatLng(0, 0);
  LatLng destinationPoint = const LatLng(0, 0);
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureMap();
    });
  }

  void _configureMap() {
    LatLngBounds bounds = LatLngBounds(sourcePoint, destinationPoint);
    for (var point in pathPoints) {
      bounds.extend(point);
    }

    // ignore: deprecated_member_use
    mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(8.0)));
  }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
          List<dynamic> journeyPoints = widget.journeyPoints;

          pathPoints.clear();
          for (dynamic point in journeyPoints) {
            if (point is List<dynamic> && point.length == 2) {
              pathPoints.add(LatLng(point[0] as double, point[1] as double));
            }
          }

          if (pathPoints.isNotEmpty) {
            sourcePoint = pathPoints.first;
            destinationPoint = pathPoints.last;
          }
        } else {
          pathPoints = [];
        }

        return Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => (Uri.parse(
                            'https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pathPoints,
                            color: const Color.fromARGB(255, 47, 73, 175),
                            strokeWidth: 7, // Adjust the width as needed
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: sourcePoint,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          ),
                          Marker(
                            point: destinationPoint,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      listener: (BuildContext context, AppState state) {},
    );
  }
}
