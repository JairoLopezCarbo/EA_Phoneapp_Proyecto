import '../models/app_models.dart';

String toTitleCase(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

String formatDistance(double? distance) {
  if (distance == null) {
    return 'Not specified';
  }

  final asInt = distance.truncateToDouble() == distance;
  return asInt ? '${distance.toStringAsFixed(0)} km' : '${distance.toStringAsFixed(1)} km';
}

String formatDuration(int? duration) {
  return duration == null ? 'Not specified' : '$duration min';
}

String featuredOverlayText(int index) {
  switch (index) {
    case 0:
      return 'Featured route of the day';
    case 1:
      return 'Featured route of the week';
    case 2:
      return 'Featured route of the month';
    default:
      return 'Featured route';
  }
}

String navAssetPath(String iconName, bool selected) {
  final variant = selected ? 'selected' : 'non_selected';
  return 'assets/resources/icons/$variant/$iconName.png';
}

String difficultyBadgePath(RouteDifficulty difficulty) {
  return 'assets/resources/icons/badges/${difficulty.value}.png';
}

String routeImage(RouteModel route) {
  return route.firstImage;
}

List<RouteModel> sortRoutes(List<RouteModel> routes, SortOption? option) {
  final sorted = [...routes];

  if (option == null) {
    return sorted;
  }

  int compareDifficulty(RouteDifficulty a, RouteDifficulty b, bool asc) {
    return asc ? a.rank - b.rank : b.rank - a.rank;
  }

  int compareOptional(num? a, num? b, bool asc) {
    final aMissing = a == null;
    final bMissing = b == null;

    if (aMissing && bMissing) {
      return 0;
    }

    if (aMissing) {
      return 1;
    }

    if (bMissing) {
      return -1;
    }

    return asc ? a.compareTo(b) : b.compareTo(a);
  }

  switch (option) {
    case SortOption.difficultyAsc:
      sorted.sort((a, b) => compareDifficulty(a.difficulty, b.difficulty, true));
      break;
    case SortOption.difficultyDesc:
      sorted.sort((a, b) => compareDifficulty(a.difficulty, b.difficulty, false));
      break;
    case SortOption.durationAsc:
      sorted.sort((a, b) => compareOptional(a.duration, b.duration, true));
      break;
    case SortOption.durationDesc:
      sorted.sort((a, b) => compareOptional(a.duration, b.duration, false));
      break;
    case SortOption.distanceAsc:
      sorted.sort((a, b) => compareOptional(a.distance, b.distance, true));
      break;
    case SortOption.distanceDesc:
      sorted.sort((a, b) => compareOptional(a.distance, b.distance, false));
      break;
  }

  return sorted;
}

enum SortOption {
  difficultyAsc,
  difficultyDesc,
  durationAsc,
  durationDesc,
  distanceAsc,
  distanceDesc,
}
