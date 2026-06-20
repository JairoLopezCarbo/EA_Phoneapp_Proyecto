import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';

class RoutePointsMap extends StatelessWidget {
  const RoutePointsMap({
    super.key,
    required this.points,
    this.height = 280,
  });

  final List<RoutePointModel> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final validPoints = points
        .where((point) {
          return point.latitude.isFinite &&
              point.longitude.isFinite &&
              point.latitude >= -90 &&
              point.latitude <= 90 &&
              point.longitude >= -180 &&
              point.longitude <= 180;
        })
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));

    if (validPoints.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('No route points available for this map.'),
      );
    }

    final latLngs = validPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: latLngs.first,
            initialZoom: validPoints.length == 1 ? 14 : 13,
            initialCameraFit: validPoints.length > 1
                ? CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(latLngs),
                    padding: const EdgeInsets.all(36),
                  )
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.trip2guide.phoneapp',
            ),
            if (latLngs.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: latLngs,
                    strokeWidth: 4,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (var index = 0; index < validPoints.length; index++)
                  Marker(
                    point: LatLng(
                      validPoints[index].latitude,
                      validPoints[index].longitude,
                    ),
                    width: 42,
                    height: 42,
                    child: _PointMarker(
                      index: index + 1,
                      label: validPoints[index].name,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PointMarker extends StatelessWidget {
  const _PointMarker({
    required this.index,
    required this.label,
  });

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label.isEmpty ? 'Point $index' : label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            index.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}