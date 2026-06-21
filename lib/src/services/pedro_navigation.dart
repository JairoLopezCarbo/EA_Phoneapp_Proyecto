import 'dart:async';

typedef PedroRouteOpener = FutureOr<void> Function(String routeId);

class PedroNavigation {
  PedroRouteOpener? _routeOpener;

  void attach(PedroRouteOpener opener) {
    _routeOpener = opener;
  }

  void detach() {
    _routeOpener = null;
  }

  Future<void> openRoute(String routeId) async {
    final opener = _routeOpener;
    if (opener == null || routeId.trim().isEmpty) {
      return;
    }
    await opener(routeId.trim());
  }
}

final PedroNavigation pedroNavigation = PedroNavigation();
