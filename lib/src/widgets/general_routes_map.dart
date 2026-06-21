import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../services/route_service.dart';
import '../state/accessibility_state.dart';
import '../utils/localization.dart';

class RouteZone {
  const RouteZone({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
  });

  final String id;
  final String name;
  final String description;

  /// Same format as web/backend:
  /// [longitude, latitude]
  final List<List<double>> coordinates;
}

const List<RouteZone> routeZones = [
  RouteZone(
    id: 'barcelona-centre',
    name: 'Barcelona centre',
    description: 'Central area of Barcelona',
    coordinates: [
      [2.1402, 41.3661],
      [2.2064, 41.3661],
      [2.2064, 41.4089],
      [2.1402, 41.4089],
      [2.1402, 41.3661],
    ],
  ),
  RouteZone(
    id: 'madrid-centre',
    name: 'Madrid centre',
    description: 'Central area of Madrid',
    coordinates: [
      [-3.7250, 40.4000],
      [-3.6750, 40.4000],
      [-3.6750, 40.4300],
      [-3.7250, 40.4300],
      [-3.7250, 40.4000],
    ],
  ),
  RouteZone(
    id: 'seville-centre',
    name: 'Seville centre',
    description: 'Central area of Seville',
    coordinates: [
      [-6.0100, 37.3700],
      [-5.9700, 37.3700],
      [-5.9700, 37.4000],
      [-6.0100, 37.4000],
      [-6.0100, 37.3700],
    ],
  ),
];

class GeneralRoutesMap extends StatefulWidget {
  const GeneralRoutesMap({
    super.key,
    required this.routes,
    required this.onOpenRoute,
  });

  final List<RouteModel> routes;
  final ValueChanged<RouteModel> onOpenRoute;

  @override
  State<GeneralRoutesMap> createState() => _GeneralRoutesMapState();
}

class _GeneralRoutesMapState extends State<GeneralRoutesMap> {
  final MapController _mapController = MapController();

  RouteZone? _selectedZone;
  List<RouteModel> _zoneRoutes = const <RouteModel>[];
  bool _isLoadingZone = false;
  String _error = '';

  List<RouteModel> get _routesToRender {
    if (_selectedZone != null) {
      return _zoneRoutes;
    }

    return widget.routes;
  }

  Future<void> _selectZone(RouteZone zone) async {
    setState(() {
      _selectedZone = zone;
      _zoneRoutes = const <RouteModel>[];
      _isLoadingZone = true;
      _error = '';
    });

    _zoomToZone(zone);

    try {
      final routes = await routeService.getRoutesInsidePolygon(
        zone.coordinates,
      );

      if (!mounted) return;

      setState(() {
        _zoneRoutes = routes;
      });

      if (routes.isNotEmpty) {
        _zoomToZoneWithRoutes(zone, routes);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error is Exception
            ? localizedError(context, error)
            : context.l10n.zoneRoutesLoadFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingZone = false;
        });
      }
    }
  }

  void _clearZone() {
    setState(() {
      _selectedZone = null;
      _zoneRoutes = const <RouteModel>[];
      _error = '';
      _isLoadingZone = false;
    });

    _zoomToAllRoutes();
  }

  void _zoomToZone(RouteZone zone) {
    final points = zone.coordinates
        .map((coordinate) => LatLng(coordinate[1], coordinate[0]))
        .toList(growable: false);

    if (points.length < 2) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(42),
        ),
      );
    });
  }

  void _zoomToZoneWithRoutes(RouteZone zone, List<RouteModel> routes) {
    final points = <LatLng>[
      ...zone.coordinates.map(
        (coordinate) => LatLng(coordinate[1], coordinate[0]),
      ),
      ..._collectMapPoints(routes).map((item) => item.point),
    ];

    if (points.length < 2) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(42),
        ),
      );
    });
  }

  void _zoomToAllRoutes() {
    final points = _collectMapPoints(
      widget.routes,
    ).map((item) => item.point).toList(growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (points.length < 2) {
        _mapController.move(const LatLng(40.15, -3.7), 6);
        return;
      }

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(42),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final mapPoints = _collectMapPoints(_routesToRender);

    final isDarkSurface = accessibility.surfaceColor.computeLuminance() < 0.5;
    final headerTextColor = isDarkSurface
        ? Colors.white
        : accessibility.textColor;
    final headerSecondaryTextColor = isDarkSurface
        ? Colors.white70
        : accessibility.secondaryTextColor;

    final zonesToRender = _selectedZone == null
        ? const <RouteZone>[]
        : <RouteZone>[_selectedZone!];

    final zonePoints = zonesToRender
        .expand((zone) => zone.coordinates)
        .map((coordinate) => LatLng(coordinate[1], coordinate[0]))
        .toList(growable: false);

    final fitPoints = <LatLng>[
      ...zonePoints,
      ...mapPoints.map((item) => item.point),
    ];

    return Container(
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accessibility.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: accessibility.surfaceColor,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.generalZoneMap,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: headerTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedZone == null
                      ? context.l10n.zoneMapHelp
                      : context.l10n.zoneMapShowing(
                          _zoneName(context, _selectedZone!),
                        ),
                  style: TextStyle(
                    color: headerSecondaryTextColor,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (_selectedZone != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _MapActionButton(
                      label: context.l10n.seeAllZones,
                      onPressed: _clearZone,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 360,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(40.15, -3.7),
                initialZoom: 6,
                initialCameraFit: fitPoints.length > 1
                    ? CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(fitPoints),
                        padding: const EdgeInsets.all(36),
                      )
                    : null,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.trip2guide.phoneapp',
                ),
                if (zonesToRender.isNotEmpty)
                  PolygonLayer(
                    polygons: [
                      for (final zone in zonesToRender)
                        Polygon(
                          points: zone.coordinates
                              .map(
                                (coordinate) =>
                                    LatLng(coordinate[1], coordinate[0]),
                              )
                              .toList(growable: false),
                          borderColor: accessibility.buttonColor,
                          color: accessibility.buttonColor.withValues(
                            alpha: 0.20,
                          ),
                          borderStrokeWidth: 3,
                        ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    for (final item in mapPoints)
                      Marker(
                        point: item.point,
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.onOpenRoute(item.route);
                          },
                          child: _RouteMarker(route: item.route),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: accessibility.surfaceColor,
            padding: const EdgeInsets.all(14),
            child: _selectedZone == null
                ? _ZoneList(onSelectZone: _selectZone)
                : _ZoneResults(
                    selectedZone: _selectedZone!,
                    routes: _zoneRoutes,
                    isLoading: _isLoadingZone,
                    error: _error,
                    onOpenRoute: widget.onOpenRoute,
                  ),
          ),
        ],
      ),
    );
  }

  List<_RouteMapPoint> _collectMapPoints(List<RouteModel> routes) {
    final result = <_RouteMapPoint>[];
    final seenCoordinates = <String>{};

    for (final route in routes) {
      if (route.id.trim().isEmpty) {
        continue;
      }

      final validPoints =
          route.points
              .where((point) {
                final latitude = point.latitude;
                final longitude = point.longitude;

                if (!latitude.isFinite || !longitude.isFinite) return false;
                if (latitude < -90 || latitude > 90) return false;
                if (longitude < -180 || longitude > 180) return false;

                if (latitude == 0 && longitude == 0) return false;

                return true;
              })
              .toList(growable: false)
            ..sort((a, b) => a.index.compareTo(b.index));

      if (validPoints.isEmpty) continue;

      final firstPoint = validPoints.first;
      final coordinateKey =
          '${firstPoint.latitude.toStringAsFixed(6)},${firstPoint.longitude.toStringAsFixed(6)}';

      if (!seenCoordinates.add(coordinateKey)) {
        continue;
      }

      result.add(
        _RouteMapPoint(
          route: route,
          point: LatLng(firstPoint.latitude, firstPoint.longitude),
        ),
      );
    }

    return result;
  }
}

class _RouteMapPoint {
  const _RouteMapPoint({required this.route, required this.point});

  final RouteModel route;
  final LatLng point;
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accessibility.buttonColor,
        border: Border.all(color: accessibility.buttonTextColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ZoneList extends StatelessWidget {
  const _ZoneList({required this.onSelectZone});

  final ValueChanged<RouteZone> onSelectZone;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final isDarkSurface = accessibility.surfaceColor.computeLuminance() < 0.5;
    final titleColor = isDarkSurface ? Colors.white : accessibility.textColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.availableZones,
          style: TextStyle(fontWeight: FontWeight.w800, color: titleColor),
        ),
        const SizedBox(height: 10),
        for (final zone in routeZones) ...[
          _ZoneButton(zone: zone, onPressed: () => onSelectZone(zone)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ZoneButton extends StatelessWidget {
  const _ZoneButton({required this.zone, required this.onPressed});

  final RouteZone zone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final isDarkSurface =
        accessibility.secondarySurfaceColor.computeLuminance() < 0.5;
    final titleColor = isDarkSurface ? Colors.white : accessibility.textColor;
    final descriptionColor = isDarkSurface
        ? Colors.white70
        : accessibility.secondaryTextColor;

    return Material(
      color: accessibility.secondarySurfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accessibility.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _zoneName(context, zone),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _zoneDescription(context, zone),
                style: TextStyle(color: descriptionColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneResults extends StatelessWidget {
  const _ZoneResults({
    required this.selectedZone,
    required this.routes,
    required this.isLoading,
    required this.error,
    required this.onOpenRoute,
  });

  final RouteZone selectedZone;
  final List<RouteModel> routes;
  final bool isLoading;
  final String error;
  final ValueChanged<RouteModel> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final isDarkSurface = accessibility.surfaceColor.computeLuminance() < 0.5;
    final titleColor = isDarkSurface ? Colors.white : accessibility.textColor;
    final subtitleColor = isDarkSurface
        ? Colors.white70
        : accessibility.secondaryTextColor;

    if (isLoading) {
      return Text(
        context.l10n.searchingZone,
        style: TextStyle(color: titleColor),
      );
    }

    if (error.isNotEmpty) {
      return Text(
        error,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.zoneRoutesFound(
            routes.length,
            _zoneName(context, selectedZone),
          ),
          style: TextStyle(fontWeight: FontWeight.w800, color: titleColor),
        ),
        const SizedBox(height: 10),
        if (routes.isEmpty)
          Text(
            context.l10n.noZoneRoutes,
            style: TextStyle(color: subtitleColor),
          ),
        for (final route in routes) ...[
          _RouteResultButton(route: route, onPressed: () => onOpenRoute(route)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RouteResultButton extends StatelessWidget {
  const _RouteResultButton({required this.route, required this.onPressed});

  final RouteModel route;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final isDarkSurface =
        accessibility.secondarySurfaceColor.computeLuminance() < 0.5;
    final titleColor = isDarkSurface ? Colors.white : accessibility.textColor;
    final subtitleColor = isDarkSurface
        ? Colors.white70
        : accessibility.secondaryTextColor;

    return Material(
      color: accessibility.secondarySurfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accessibility.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(route.locationLabel, style: TextStyle(color: subtitleColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Material(
      color: accessibility.buttonColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: accessibility.buttonTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

String _zoneName(BuildContext context, RouteZone zone) {
  return switch (zone.id) {
    'barcelona-centre' => context.l10n.barcelonaCentre,
    'madrid-centre' => context.l10n.madridCentre,
    'seville-centre' => context.l10n.sevilleCentre,
    _ => zone.name,
  };
}

String _zoneDescription(BuildContext context, RouteZone zone) {
  return switch (zone.id) {
    'barcelona-centre' => context.l10n.barcelonaCentreDescription,
    'madrid-centre' => context.l10n.madridCentreDescription,
    'seville-centre' => context.l10n.sevilleCentreDescription,
    _ => zone.description,
  };
}
