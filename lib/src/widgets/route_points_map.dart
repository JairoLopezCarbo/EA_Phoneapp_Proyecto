import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';

class RoutePointsMap extends StatefulWidget {
  const RoutePointsMap({
    super.key,
    required this.points,
    this.height = 280,
  });

  final List<RoutePointModel> points;
  final double height;

  @override
  State<RoutePointsMap> createState() => _RoutePointsMapState();
}

class _RoutePointsMapState extends State<RoutePointsMap> {
  List<LatLng> _roadPath = const <LatLng>[];
  bool _isLoadingRoadPath = false;
  String _lastRequestKey = '';

  List<RoutePointModel> get _validPoints {
    return widget.points
        .where((point) {
          return point.latitude.isFinite &&
              point.longitude.isFinite &&
              point.latitude >= -90 &&
              point.latitude <= 90 &&
              point.longitude >= -180 &&
              point.longitude <= 180 &&
              !(point.latitude == 0 && point.longitude == 0);
        })
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  @override
  void initState() {
    super.initState();
    _loadRoadPath();
  }

  @override
  void didUpdateWidget(covariant RoutePointsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadRoadPath();
  }

  Future<void> _loadRoadPath() async {
    final validPoints = _validPoints;

    if (validPoints.length < 2) {
      if (!mounted) return;

      setState(() {
        _roadPath = const <LatLng>[];
        _isLoadingRoadPath = false;
        _lastRequestKey = '';
      });
      return;
    }

    final requestKey = validPoints
        .map(
          (point) =>
              '${point.longitude.toStringAsFixed(6)},${point.latitude.toStringAsFixed(6)}',
        )
        .join(';');

    if (requestKey == _lastRequestKey) {
      return;
    }

    _lastRequestKey = requestKey;

    setState(() {
      _isLoadingRoadPath = true;
      _roadPath = const <LatLng>[];
    });

    try {
      final fullPath = <LatLng>[];

      for (var index = 0; index < validPoints.length - 1; index++) {
        final origin = validPoints[index];
        final destination = validPoints[index + 1];

        final originLatLng = LatLng(origin.latitude, origin.longitude);
        final destinationLatLng = LatLng(
          destination.latitude,
          destination.longitude,
        );

        final segmentPath = await _fetchRoadSegment(
          origin: originLatLng,
          destination: destinationLatLng,
        );

        if (segmentPath.isEmpty) {
          if (fullPath.isEmpty || fullPath.last != originLatLng) {
            fullPath.add(originLatLng);
          }

          fullPath.add(destinationLatLng);
          continue;
        }

        if (fullPath.isEmpty || fullPath.last != originLatLng) {
          fullPath.add(originLatLng);
        }

        fullPath.addAll(segmentPath);

        if (fullPath.last != destinationLatLng) {
          fullPath.add(destinationLatLng);
        }
      }

      if (!mounted) return;

      setState(() {
        _roadPath = fullPath;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _roadPath = validPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(growable: false);
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoadingRoadPath = false;
      });
    }
  }

  Future<List<LatLng>> _fetchRoadSegment({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final coordinates =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/$coordinates?overview=full&geometries=geojson&steps=false&continue_straight=false',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      return const <LatLng>[];
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = decoded['routes'] as List<dynamic>?;

    if (routes == null || routes.isEmpty) {
      return const <LatLng>[];
    }

    final geometry = routes.first['geometry'] as Map<String, dynamic>?;
    final coordinatesList = geometry?['coordinates'] as List<dynamic>?;

    if (coordinatesList == null || coordinatesList.isEmpty) {
      return const <LatLng>[];
    }

    return coordinatesList
        .map((coordinate) {
          final item = coordinate as List<dynamic>;
          final longitude = (item[0] as num).toDouble();
          final latitude = (item[1] as num).toDouble();

          return LatLng(latitude, longitude);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final validPoints = _validPoints;

    if (validPoints.isEmpty) {
      return Container(
        height: widget.height,
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

    final linePoints = _roadPath.length > 1 ? _roadPath : latLngs;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
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
                if (linePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: linePoints,
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
            if (_isLoadingRoadPath)
              Positioned(
                right: 10,
                top: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Calculating route...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
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