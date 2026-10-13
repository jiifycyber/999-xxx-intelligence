import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/genesis_theme.dart';

class _RadarRoute {
  const _RadarRoute({
    required this.origin,
    required this.target,
    required this.originName,
    required this.targetName,
    required this.value,
  });

  final Offset origin;
  final Offset target;
  final String originName;
  final String targetName;
  final double value;

  static const Map<String, Offset> centroids = {
    'US': Offset(-98.5, 39.8),
    'BR': Offset(-51.9, -14.2),
    'HK': Offset(114.2, 22.3),
    'CL': Offset(-71.5, -33.4),
    'CA': Offset(-106.3, 56.1),
    'MX': Offset(-102.5, 23.6),
    'GB': Offset(-3.4, 55.4),
    'FR': Offset(2.2, 46.2),
    'DE': Offset(10.4, 51.2),
    'ES': Offset(-3.7, 40.4),
    'IT': Offset(12.6, 41.9),
    'NL': Offset(5.3, 52.1),
    'RU': Offset(105.3, 61.5),
    'CN': Offset(104.2, 35.9),
    'JP': Offset(138.3, 36.2),
    'IN': Offset(78.9, 20.6),
    'SG': Offset(103.8, 1.35),
    'AU': Offset(133.8, -25.3),
    'ZA': Offset(22.9, -30.6),
    'NG': Offset(8.7, 9.1),
    'AE': Offset(53.8, 23.4),
  };

  static _RadarRoute? fromJson(Map<String, dynamic> json) {
    final originCode =
        (json['originCountryAlpha2'] ?? '').toString().toUpperCase();
    final targetCode =
        (json['targetCountryAlpha2'] ?? '').toString().toUpperCase();
    final origin = centroids[originCode];
    final target = centroids[targetCode];
    if (origin == null || target == null) return null;

    return _RadarRoute(
      origin: origin,
      target: target,
      originName: (json['originCountryName'] ?? originCode).toString(),
      targetName: (json['targetCountryName'] ?? targetCode).toString(),
      value: double.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class DetailedWorldMap extends StatefulWidget {
  const DetailedWorldMap({
    required this.pulse,
    super.key,
  });

  final Animation<double> pulse;

  @override
  State<DetailedWorldMap> createState() => _DetailedWorldMapState();
}

class _DetailedWorldMapState extends State<DetailedWorldMap> {
  List<List<Offset>>? _polygons;
  List<_RadarRoute> _routes = const [];
  String? _radarError;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMap();
    _loadRadar();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _loadRadar(),
    );
  }

  Future<void> _loadMap() async {
    final source = await rootBundle.loadString('assets/maps/world.geojson');
    final data = jsonDecode(source) as Map<String, dynamic>;
    final polygons = <List<Offset>>[];

    for (final feature in data['features'] as List<dynamic>) {
      final geometry = (feature as Map<String, dynamic>)['geometry']
          as Map<String, dynamic>?;
      if (geometry == null) continue;

      final type = geometry['type'] as String?;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      if (type == 'Polygon') {
        _addPolygon(coordinates, polygons);
      } else if (type == 'MultiPolygon') {
        for (final polygon in coordinates) {
          _addPolygon(polygon as List<dynamic>, polygons);
        }
      }
    }

    if (mounted) {
      setState(() => _polygons = polygons);
    }
  }

  Future<void> _loadRadar() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://999-global-threat-map.jontarius.workers.dev',
            ),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? decoded['data'] : null;
      final result = data is Map ? data['result'] : null;
      final routes = <_RadarRoute>[];

      if (result is Map) {
        for (final group in result.values) {
          if (group is! List) continue;
          for (final item in group) {
            if (item is! Map) continue;
            final route = _RadarRoute.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (route != null) routes.add(route);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _routes = routes;
        _radarError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _radarError = error.toString());
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _addPolygon(
    List<dynamic> polygon,
    List<List<Offset>> output,
  ) {
    if (polygon.isEmpty) return;

    final ring = polygon.first as List<dynamic>;
    final points = <Offset>[];

    for (final coordinate in ring) {
      final pair = coordinate as List<dynamic>;
      if (pair.length < 2) continue;

      points.add(
        Offset(
          (pair[0] as num).toDouble(),
          (pair[1] as num).toDouble(),
        ),
      );
    }

    if (points.length >= 3) output.add(points);
  }

  @override
  Widget build(BuildContext context) {
    final polygons = _polygons;

    if (polygons == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: GenesisColors.cyan,
          strokeWidth: 2,
        ),
      );
    }

    return AnimatedBuilder(
      animation: widget.pulse,
      builder: (context, child) {
        return CustomPaint(
          painter: _DetailedMapPainter(
            polygons: polygons,
            phase: widget.pulse.value,
            routes: _routes,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xDD031018),
                    border: Border.all(
                      color: _radarError == null
                          ? GenesisColors.emerald
                          : GenesisColors.danger,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _radarError == null
                        ? 'LIVE - ${_routes.length} VERIFIED ROUTES'
                        : 'RADAR CONNECTION ERROR',
                    style: TextStyle(
                      color: _radarError == null
                          ? GenesisColors.emerald
                          : GenesisColors.danger,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 65,
                top: 42,
                child: _MapLabel(
                  'N. AMERICA',
                  'CLOUDFLARE RADAR',
                ),
              ),
              Positioned(
                left: 185,
                bottom: 38,
                child: _MapLabel(
                  'S. AMERICA',
                  'CLOUDFLARE RADAR',
                ),
              ),
              Positioned(
                left: 430,
                top: 26,
                child: _MapLabel(
                  'EUROPE',
                  'CLOUDFLARE RADAR',
                ),
              ),
              Positioned(
                left: 475,
                bottom: 32,
                child: _MapLabel(
                  'AFRICA',
                  'CLOUDFLARE RADAR',
                ),
              ),
              Positioned(
                right: 115,
                top: 65,
                child: _MapLabel(
                  'ASIA',
                  'CLOUDFLARE RADAR',
                ),
              ),
              Positioned(
                right: 35,
                bottom: 38,
                child: _MapLabel(
                  'OCEANIA',
                  'CLOUDFLARE RADAR',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.title, this.detail);

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      color: const Color(0x99030A11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: GenesisColors.text,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              color: GenesisColors.muted,
              fontSize: 6,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedMapPainter extends CustomPainter {
  const _DetailedMapPainter({
    required this.polygons,
    required this.phase,
    required this.routes,
  });

  final List<List<Offset>> polygons;
  final double phase;
  final List<_RadarRoute> routes;

  static const nodes = <Offset>[
    Offset(-122.3, 47.6),
    Offset(-97.7, 30.2),
    Offset(-74.0, 40.7),
    Offset(-46.6, -23.5),
    Offset(-0.1, 51.5),
    Offset(13.4, 52.5),
    Offset(31.2, 30.0),
    Offset(28.0, -26.2),
    Offset(55.3, 25.2),
    Offset(77.2, 28.6),
    Offset(103.8, 1.3),
    Offset(116.4, 39.9),
    Offset(139.7, 35.6),
    Offset(151.2, -33.8),
  ];

  static const nodeColors = <Color>[
    GenesisColors.danger,
    GenesisColors.warning,
    GenesisColors.danger,
    GenesisColors.danger,
    GenesisColors.warning,
    GenesisColors.danger,
    GenesisColors.cyan,
    GenesisColors.warning,
    GenesisColors.warning,
    GenesisColors.danger,
    GenesisColors.cyan,
    GenesisColors.danger,
    GenesisColors.warning,
    GenesisColors.danger,
  ];

  Offset _project(Offset coordinate, Size size) {
    final x = (coordinate.dx + 180) / 360 * size.width;
    final latitude = coordinate.dy.clamp(-85.0, 85.0);
    final y = (90 - latitude) / 180 * size.height;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF0B2638),
          Color(0xFF04101A),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, background);

    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .22)
      ..strokeWidth = .5;

    for (double x = 0; x <= size.width; x += size.width / 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    for (double y = 0; y <= size.height; y += size.height / 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final fill = Paint()
      ..color = const Color(0xFF123A54)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = GenesisColors.cyan.withValues(alpha: .52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55;

    for (final polygon in polygons) {
      if (polygon.length < 3) continue;

      final path = Path();
      final first = _project(polygon.first, size);
      path.moveTo(first.dx, first.dy);

      for (final point in polygon.skip(1)) {
        final projected = _project(point, size);
        path.lineTo(projected.dx, projected.dy);
      }

      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }

    for (var index = 0; index < routes.length; index++) {
      final radarRoute = routes[index];
      final start = _project(radarRoute.origin, size);
      final end = _project(radarRoute.target, size);
      final color = radarRoute.value >= 4
          ? GenesisColors.danger
          : radarRoute.value >= 2
              ? const Color(0xFFFF8B38)
              : GenesisColors.warning;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          (start.dx + end.dx) / 2,
          math.min(start.dy, end.dy) - size.height * (.10 + (index % 3) * .035),
          end.dx,
          end.dy,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .72)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );

      final metric = path.computeMetrics().first;
      final distance =
          ((phase + index / math.max(routes.length, 1)) % 1) * metric.length;
      final tangent = metric.getTangentForOffset(distance);

      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          6,
          Paint()..color = color.withValues(alpha: .16),
        );
        canvas.drawCircle(
          tangent.position,
          2.3,
          Paint()..color = color,
        );
      }

      for (final point in [start, end]) {
        final glow =
            6 + math.sin((phase + index * .12) * math.pi * 2).abs() * 7;
        canvas.drawCircle(
          point,
          glow,
          Paint()..color = color.withValues(alpha: .11),
        );
        canvas.drawCircle(point, 3.2, Paint()..color = color);
        canvas.drawCircle(point, 1.1, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedMapPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.polygons != polygons ||
        oldDelegate.routes != routes;
  }
}
