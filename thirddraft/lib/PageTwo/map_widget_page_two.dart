import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../darkcubit/cubit.dart';
import '../darkcubit/states.dart';

// import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng initialCenter = const LatLng(30.044326328134307, 31.236321058539797);
  List<LatLng> pathPoints = [];
  LatLng sourcePoint = const LatLng(0, 0);
  LatLng destinationPoint = const LatLng(0, 0);
  // late MapController mapController;


  double travelTime = 0;
  double stops = 0;
  double price = 0;
  late List<dynamic> journeyPoints ;



  @override
  void initState() {
    super.initState();
    // mapController = MapController();

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
      builder: (BuildContext context, AppState state) {
        if (cubit.singlePath != null && cubit.singlePath!.isNotEmpty) {
          List<dynamic> journeyPoints = cubit.singlePath![0]?['journeyPoints'];

          pathPoints.clear();
          for (dynamic point in journeyPoints) {
            if (point is List<dynamic> && point.length == 2) {
              pathPoints.add(LatLng(point[0] as double, point[1] as double));
            }
          }

          if (pathPoints.isNotEmpty) {
            sourcePoint = pathPoints.first;
            destinationPoint = pathPoints.last;

            LatLngBounds bounds = LatLngBounds(sourcePoint, destinationPoint);
            for (var point in pathPoints) {
              bounds.extend(point);
            }

            // mapController.fitBounds(bounds,
            //     options: const FitBoundsOptions(padding: EdgeInsets.all(8.0)));
          }
        } else {
          pathPoints = [];
        }

        return Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                // mapController: mapController,
                options: MapOptions(
                  initialCenter: sourcePoint,
                  initialZoom:15,
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
                        onTap: () =>
                            (Uri.parse('https://openstreetmap.org/copyright')),
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