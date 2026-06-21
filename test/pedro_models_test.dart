import 'package:flutter_test/flutter_test.dart';
import 'package:phoneapp/src/models/pedro_models.dart';

void main() {
  group('PedroResponse', () {
    test('parses answer, selected route and alternatives', () {
      final response = PedroResponse.fromJson(<String, dynamic>{
        'answer': 'Prueba Ruta Verde (route-1).',
        'selectedRoute': <String, dynamic>{
          'route_id': 'route-1',
          'name': 'Ruta Verde',
          'city': 'Barcelona',
          'country': 'España',
          'cover_image': 'https://example.com/route.jpg',
        },
        'routes': <Map<String, dynamic>>[
          <String, dynamic>{
            'route_id': 'route-1',
            'name': 'Ruta Verde',
            'city': 'Barcelona',
            'country': 'España',
          },
          <String, dynamic>{
            'route_id': 'route-2',
            'name': 'Ruta Azul',
            'city': 'Girona',
            'country': 'España',
          },
        ],
      });

      expect(response.answer, contains('Ruta Verde'));
      expect(response.selectedRoute?.id, 'route-1');
      expect(response.routes, hasLength(2));
      expect(response.routes.last.name, 'Ruta Azul');
    });

    test('accepts a response without routes', () {
      final response = PedroResponse.fromJson(<String, dynamic>{
        'answer': 'Puedo ayudarte a encontrar otra ruta.',
      });

      expect(response.routes, isEmpty);
      expect(response.selectedRoute, isNull);
    });

    test('rejects a missing or empty answer', () {
      expect(
        () => PedroResponse.fromJson(<String, dynamic>{'routes': <dynamic>[]}),
        throwsFormatException,
      );
      expect(
        () => PedroResponse.fromJson(<String, dynamic>{'answer': '   '}),
        throwsFormatException,
      );
    });
  });
}
