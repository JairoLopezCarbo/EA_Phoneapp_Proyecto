// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Trip2Guide';

  @override
  String get loadingPreparingRoute => 'Preparing your next route';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'EN · English';

  @override
  String get languageSpanish => 'ES · Español';

  @override
  String get languageCatalan => 'CA · Català';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get viewProfile => 'View profile';

  @override
  String get home => 'Home';

  @override
  String get routes => 'Routes';

  @override
  String get chats => 'Chats';

  @override
  String get favorites => 'Favorites';

  @override
  String get searchHint => 'Where do you want to explore today?';

  @override
  String get searchResults => 'Search results';

  @override
  String get show => 'Show';

  @override
  String get perPage => 'per page';

  @override
  String get noMatchingRoutes => 'No matching routes found.';

  @override
  String get noFavoriteRoutes => 'You do not have favorite routes yet.';

  @override
  String get loginToViewFavorites =>
      'You need to log in to view favorite routes.';

  @override
  String get hideZoneMap => 'Hide zone map';

  @override
  String get generalZoneMap => 'General route map with zones';

  @override
  String get zoneMapHelp =>
      'Choose a zone below to show its polygon and search routes inside it.';

  @override
  String zoneMapShowing(String zone) {
    return 'Showing routes inside $zone.';
  }

  @override
  String get seeAllZones => 'See all zones';

  @override
  String get availableZones => 'Available zones';

  @override
  String get searchingZone =>
      'Searching for routes inside the selected zone...';

  @override
  String zoneRoutesFound(int count, String zone) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes found inside $zone.',
      one: '1 route found inside $zone.',
    );
    return '$_temp0';
  }

  @override
  String get noZoneRoutes => 'No routes found inside this selected zone.';

  @override
  String get zoneRoutesLoadFailed =>
      'Unable to load routes inside the selected zone.';

  @override
  String get barcelonaCentre => 'Barcelona centre';

  @override
  String get barcelonaCentreDescription => 'Central area of Barcelona';

  @override
  String get madridCentre => 'Madrid centre';

  @override
  String get madridCentreDescription => 'Central area of Madrid';

  @override
  String get sevilleCentre => 'Seville centre';

  @override
  String get sevilleCentreDescription => 'Central area of Seville';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes found',
      one: '1 route found',
      zero: 'No routes found',
    );
    return '$_temp0';
  }

  @override
  String get accessible => 'Accessible';

  @override
  String get all => 'All';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get requiredField => 'Required field';

  @override
  String get validNumber => 'Enter a valid number';

  @override
  String get validInteger => 'Enter a valid integer';

  @override
  String get duration => 'Duration';

  @override
  String get distance => 'Distance';

  @override
  String get notSpecified => 'Not specified';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String kilometers(String distance) {
    return '$distance km';
  }

  @override
  String get featuredDay => 'Featured route of the day';

  @override
  String get featuredWeek => 'Featured route of the week';

  @override
  String get featuredMonth => 'Featured route of the month';

  @override
  String get featuredRoute => 'Featured route';

  @override
  String get exploreRoutes => 'Explore the routes available in Trip2Guide.';

  @override
  String get topVisitedCities => 'Top most visited cities';

  @override
  String get topPopularRoutes => 'Top 5 popular routes';

  @override
  String get favoriteRoutes => 'Favorite routes';

  @override
  String get loginForFavorites => 'Log in to save favorites.';

  @override
  String get loginToContinue => 'Log in to continue.';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String showingResults(int start, int end, int total) {
    return 'Showing $start-$end of $total';
  }

  @override
  String get createRoute => 'Create route';

  @override
  String get routeCreated => 'Route created successfully.';

  @override
  String get loginToCreateRoute => 'Log in to create a route.';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get coverImageUrl => 'Cover image URL';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get city => 'City';

  @override
  String get country => 'Country';

  @override
  String get wheelchairAccessible => 'Wheelchair accessible';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'museum, city, food';

  @override
  String get points => 'Points';

  @override
  String get addPoint => 'Add point';

  @override
  String pointNumber(int number) {
    return 'Point $number';
  }

  @override
  String get pointName => 'Point name';

  @override
  String get pointDescription => 'Point description';

  @override
  String get pointImageUrl => 'Point image URL';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String editPointsForRoute(String routeName) {
    return 'Edit points - $routeName';
  }

  @override
  String get editPoint => 'Edit point';

  @override
  String get pointCreated => 'Point created.';

  @override
  String get pointUpdated => 'Point updated.';

  @override
  String get pointDeleted => 'Point deleted.';

  @override
  String get deletePoint => 'Delete point';

  @override
  String deletePointConfirmation(String pointName) {
    return 'Are you sure you want to delete “$pointName”?';
  }

  @override
  String get routeHasNoPoints => 'This route has no points yet.';

  @override
  String get noRoutePointsMap => 'No route points available for this map.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get aboutRoute => 'About this route';

  @override
  String get routeTags => 'Route tags';

  @override
  String get routeMap => 'Route map';

  @override
  String get startRoute => 'Start route';

  @override
  String get reviews => 'Reviews';

  @override
  String get routeGallery => 'Route gallery';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get saveToFavorites => 'Save to favorites';

  @override
  String get savedToFavorites => 'Saved to favorites';

  @override
  String get rating => 'Rating';

  @override
  String get notRated => 'Not rated';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get loadingReviews => 'Loading reviews...';

  @override
  String get noReviews => 'No reviews yet.';

  @override
  String get reviewTitleRequired => 'Please add a review title.';

  @override
  String get reviewPublished => 'Review published successfully.';

  @override
  String get yourReview => 'Your review';

  @override
  String yourReviewNotice(String title) {
    return 'You reviewed this route as “$title”. You can only publish one review per route.';
  }

  @override
  String get addYourReview => 'Add your review';

  @override
  String get scenery => 'Scenery';

  @override
  String get signage => 'Signage';

  @override
  String get safety => 'Safety';

  @override
  String get addReview => 'Add review';

  @override
  String get cancelReview => 'Cancel review';

  @override
  String get loginToReview => 'Log in to publish a review';

  @override
  String get reviewTitle => 'Title';

  @override
  String get reviewComment => 'Comment';

  @override
  String get publishReview => 'Publish review';

  @override
  String get publishing => 'Publishing...';

  @override
  String get newGroup => 'New group';

  @override
  String get chatLoadFailed => 'Chats could not be loaded.';

  @override
  String get loginToUseChats => 'You need to log in to use chats.';

  @override
  String get noChats => 'There are no chats available.';

  @override
  String get alreadyMember => 'You are already a member';

  @override
  String get passwordRequiredGroup => 'Password required';

  @override
  String get openGroup => 'Open group';

  @override
  String get selectChat => 'Select a chat to view its messages.';

  @override
  String get noMessages => 'There are no messages in this chat yet.';

  @override
  String unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String enterGroup(String groupName) {
    return 'Enter $groupName';
  }

  @override
  String get createGroup => 'Create group';

  @override
  String get messageHint => 'Message...';

  @override
  String get groupPassword => 'Group password';

  @override
  String get groupName => 'Group name';

  @override
  String get optionalPassword => 'Optional password';

  @override
  String get enter => 'Enter';

  @override
  String get create => 'Create';

  @override
  String get loginToSendMessages => 'You need to log in to send messages.';

  @override
  String messageSendFailed(String error) {
    return 'Message could not be sent: $error';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get signInSubtitle => 'Enter your email to continue';

  @override
  String get signUpSubtitle => 'Enter your email to sign up in this app';

  @override
  String get emailRequired => 'Please enter an email address.';

  @override
  String get passwordRequired => 'Please enter a password.';

  @override
  String get confirmPasswordRequired => 'Please confirm your password.';

  @override
  String get passwordRules =>
      'Min. 6 chars, 1 uppercase, 1 number and 1 special character.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get required => 'Required';

  @override
  String get loading => 'Loading...';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get legalPrefix => 'By clicking continue, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get legalAnd => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get continueAppleUnavailable => 'Continue with Apple unavailable';

  @override
  String get goToMainPage => 'Go to main page';

  @override
  String get email => 'Email';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get accountInformation => 'Account information';

  @override
  String get myProfile => 'My profile';

  @override
  String get profileSubtitle =>
      'View and edit your account information and routes.';

  @override
  String get backHome => 'Back to home';

  @override
  String get saving => 'Saving...';

  @override
  String get edit => 'Edit';

  @override
  String get surname => 'Surname';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get newPasswordsMismatch => 'The new passwords do not match.';

  @override
  String get newPasswordLength =>
      'The new password must contain at least 6 characters.';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get profilePasswordUpdated =>
      'Profile and password updated successfully.';

  @override
  String get routesCreated => 'Routes created';

  @override
  String get pointsCreated => 'Points created';

  @override
  String get reviewsWritten => 'Reviews written';

  @override
  String get noPublishedReviews => 'You have not published any reviews yet.';

  @override
  String get reviewTitleRequiredShort => 'Review title is required.';

  @override
  String get reviewDeleted => 'Review deleted successfully.';

  @override
  String get editingReview => 'Editing review';

  @override
  String get editingRoute => 'Editing route';

  @override
  String get deleting => 'Deleting...';

  @override
  String get date => 'Date';

  @override
  String routeLabel(String name) {
    return 'Route: $name';
  }

  @override
  String routeIdLabel(String id) {
    return 'Route ID: $id';
  }

  @override
  String get coverImage => 'Cover image';

  @override
  String get imagesCommaSeparated => 'Images (comma separated)';

  @override
  String get tagsCommaSeparated => 'Tags (comma separated)';

  @override
  String get deleteReview => 'Delete review?';

  @override
  String deleteReviewConfirmation(String title) {
    return 'Delete “$title”? This action cannot be undone.';
  }

  @override
  String get noPublishedRoutes => 'You have not published any routes yet.';

  @override
  String get creatorStatistics => 'Creator statistics';

  @override
  String get myReviews => 'My reviews';

  @override
  String get myPublishedRoutes => 'My published routes';

  @override
  String get userSessionNotFound => 'User session not found.';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementsLoading => 'Loading achievements...';

  @override
  String get achievementsUnlocked => 'Show unlocked';

  @override
  String get achievementsAll => 'Show all';

  @override
  String get achievementsEmpty => 'You have not unlocked any achievements yet.';

  @override
  String get achievementsLoadFailed => 'Achievements could not be loaded.';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get close => 'Close';

  @override
  String get colorAdjustment => 'Color adjustment';

  @override
  String get monochrome => 'Monochrome';

  @override
  String get darkContrast => 'Dark contrast';

  @override
  String get lightContrast => 'Light contrast';

  @override
  String get lowSaturation => 'Low saturation';

  @override
  String get highSaturation => 'High saturation';

  @override
  String get highContrast => 'High contrast';

  @override
  String get contentAdjustment => 'Content adjustment';

  @override
  String get fontSettings => 'Font settings';

  @override
  String get fontSettingsSubtitle => 'Increase or modify text readability';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String get lineSpacing => 'Line spacing';

  @override
  String get wordSpacing => 'Word spacing';

  @override
  String get letterSpacing => 'Letter spacing';

  @override
  String get resetSettings => 'Reset settings';

  @override
  String get openAccessibility => 'Open accessibility settings';

  @override
  String get pedroGreeting =>
      'Hiiii, I am Pedro, and I am here to help you find routes!';

  @override
  String get pedroError =>
      'I could not send the message right now. Try again in a moment.';

  @override
  String get pedroOpen => 'Open the Pedro assistant';

  @override
  String get pedroCloseGreeting => 'Close greeting';

  @override
  String get pedroSubtitle => 'Your route assistant';

  @override
  String get pedroCloseConversation => 'Close conversation';

  @override
  String get pedroAskHint => 'Ask Pedro...';

  @override
  String get send => 'Send';

  @override
  String get pedroThinking => 'Pedro is thinking...';

  @override
  String get otherOptions => 'Other options';

  @override
  String get viewRoute => 'View route';

  @override
  String get routeNotFound => 'Route not found.';

  @override
  String get routeOpenFailed => 'That route could not be opened.';

  @override
  String get routeFindFailed => 'That route could not be found.';

  @override
  String get errorInvalidCredentials => 'Invalid credentials.';

  @override
  String get errorGoogleLoginFailed => 'Google login failed.';

  @override
  String get errorRegistrationFailed => 'Unable to register the user.';

  @override
  String get errorUserSessionNotFound => 'User session not found.';

  @override
  String get errorRouteNotFound => 'Route not found.';

  @override
  String get errorLoginToCreateRoutes => 'You need to log in to create routes.';

  @override
  String get errorLoginToSaveFavorites =>
      'You need to log in to save favorites.';

  @override
  String get errorRequestFailed => 'Request failed.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';
}
