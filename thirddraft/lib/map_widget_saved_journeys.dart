import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../darkcubit/cubit.dart';
import '../darkcubit/states.dart';

class MapWidgetSavedJourneys extends StatefulWidget {
  final LatLng selectedLatLng;
    final MapController mapController;


  const MapWidgetSavedJourneys({
    super.key,
    required this.selectedLatLng, required this.mapController,
  });

  @override
  State<MapWidgetSavedJourneys> createState() => _MapWidgetSavedJourneysState();
}

class _MapWidgetSavedJourneysState extends State<MapWidgetSavedJourneys> {


   @override
  void didUpdateWidget(MapWidgetSavedJourneys oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure the map position is updated when the widget updates
    if (widget.selectedLatLng != oldWidget.selectedLatLng) {
      widget.mapController.move(widget.selectedLatLng, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      builder: (BuildContext context, AppState state) {
        return Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
          mapController: widget.mapController,
                options: MapOptions(
                  initialCenter: widget.selectedLatLng,
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
                        onTap: () =>
                            (Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.selectedLatLng,
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
