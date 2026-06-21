import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'src/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip2Guide'**
  String get appTitle;

  /// No description provided for @loadingPreparingRoute.
  ///
  /// In en, this message translates to:
  /// **'Preparing your next route'**
  String get loadingPreparingRoute;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN · English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'ES · Español'**
  String get languageSpanish;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'CA · Català'**
  String get languageCatalan;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to explore today?'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @perPage.
  ///
  /// In en, this message translates to:
  /// **'per page'**
  String get perPage;

  /// No description provided for @noMatchingRoutes.
  ///
  /// In en, this message translates to:
  /// **'No matching routes found.'**
  String get noMatchingRoutes;

  /// No description provided for @noFavoriteRoutes.
  ///
  /// In en, this message translates to:
  /// **'You do not have favorite routes yet.'**
  String get noFavoriteRoutes;

  /// No description provided for @loginToViewFavorites.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view favorite routes.'**
  String get loginToViewFavorites;

  /// No description provided for @hideZoneMap.
  ///
  /// In en, this message translates to:
  /// **'Hide zone map'**
  String get hideZoneMap;

  /// No description provided for @generalZoneMap.
  ///
  /// In en, this message translates to:
  /// **'General route map with zones'**
  String get generalZoneMap;

  /// No description provided for @zoneMapHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a zone below to show its polygon and search routes inside it.'**
  String get zoneMapHelp;

  /// No description provided for @zoneMapShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing routes inside {zone}.'**
  String zoneMapShowing(String zone);

  /// No description provided for @seeAllZones.
  ///
  /// In en, this message translates to:
  /// **'See all zones'**
  String get seeAllZones;

  /// No description provided for @availableZones.
  ///
  /// In en, this message translates to:
  /// **'Available zones'**
  String get availableZones;

  /// No description provided for @searchingZone.
  ///
  /// In en, this message translates to:
  /// **'Searching for routes inside the selected zone...'**
  String get searchingZone;

  /// No description provided for @zoneRoutesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 route found inside {zone}.} other{{count} routes found inside {zone}.}}'**
  String zoneRoutesFound(int count, String zone);

  /// No description provided for @noZoneRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes found inside this selected zone.'**
  String get noZoneRoutes;

  /// No description provided for @zoneRoutesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load routes inside the selected zone.'**
  String get zoneRoutesLoadFailed;

  /// No description provided for @barcelonaCentre.
  ///
  /// In en, this message translates to:
  /// **'Barcelona centre'**
  String get barcelonaCentre;

  /// No description provided for @barcelonaCentreDescription.
  ///
  /// In en, this message translates to:
  /// **'Central area of Barcelona'**
  String get barcelonaCentreDescription;

  /// No description provided for @madridCentre.
  ///
  /// In en, this message translates to:
  /// **'Madrid centre'**
  String get madridCentre;

  /// No description provided for @madridCentreDescription.
  ///
  /// In en, this message translates to:
  /// **'Central area of Madrid'**
  String get madridCentreDescription;

  /// No description provided for @sevilleCentre.
  ///
  /// In en, this message translates to:
  /// **'Seville centre'**
  String get sevilleCentre;

  /// No description provided for @sevilleCentreDescription.
  ///
  /// In en, this message translates to:
  /// **'Central area of Seville'**
  String get sevilleCentreDescription;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No routes found} =1{1 route found} other{{count} routes found}}'**
  String searchResultsCount(int count);

  /// No description provided for @accessible.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get accessible;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validNumber;

  /// No description provided for @validInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid integer'**
  String get validInteger;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String kilometers(String distance);

  /// No description provided for @featuredDay.
  ///
  /// In en, this message translates to:
  /// **'Featured route of the day'**
  String get featuredDay;

  /// No description provided for @featuredWeek.
  ///
  /// In en, this message translates to:
  /// **'Featured route of the week'**
  String get featuredWeek;

  /// No description provided for @featuredMonth.
  ///
  /// In en, this message translates to:
  /// **'Featured route of the month'**
  String get featuredMonth;

  /// No description provided for @featuredRoute.
  ///
  /// In en, this message translates to:
  /// **'Featured route'**
  String get featuredRoute;

  /// No description provided for @exploreRoutes.
  ///
  /// In en, this message translates to:
  /// **'Explore the routes available in Trip2Guide.'**
  String get exploreRoutes;

  /// No description provided for @topVisitedCities.
  ///
  /// In en, this message translates to:
  /// **'Top most visited cities'**
  String get topVisitedCities;

  /// No description provided for @topPopularRoutes.
  ///
  /// In en, this message translates to:
  /// **'Top 5 popular routes'**
  String get topPopularRoutes;

  /// No description provided for @favoriteRoutes.
  ///
  /// In en, this message translates to:
  /// **'Favorite routes'**
  String get favoriteRoutes;

  /// No description provided for @loginForFavorites.
  ///
  /// In en, this message translates to:
  /// **'Log in to save favorites.'**
  String get loginForFavorites;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue.'**
  String get loginToContinue;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @showingResults.
  ///
  /// In en, this message translates to:
  /// **'Showing {start}-{end} of {total}'**
  String showingResults(int start, int end, int total);

  /// No description provided for @createRoute.
  ///
  /// In en, this message translates to:
  /// **'Create route'**
  String get createRoute;

  /// No description provided for @routeCreated.
  ///
  /// In en, this message translates to:
  /// **'Route created successfully.'**
  String get routeCreated;

  /// No description provided for @loginToCreateRoute.
  ///
  /// In en, this message translates to:
  /// **'Log in to create a route.'**
  String get loginToCreateRoute;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @coverImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover image URL'**
  String get coverImageUrl;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @wheelchairAccessible.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair accessible'**
  String get wheelchairAccessible;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'museum, city, food'**
  String get tagsHint;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @addPoint.
  ///
  /// In en, this message translates to:
  /// **'Add point'**
  String get addPoint;

  /// No description provided for @pointNumber.
  ///
  /// In en, this message translates to:
  /// **'Point {number}'**
  String pointNumber(int number);

  /// No description provided for @pointName.
  ///
  /// In en, this message translates to:
  /// **'Point name'**
  String get pointName;

  /// No description provided for @pointDescription.
  ///
  /// In en, this message translates to:
  /// **'Point description'**
  String get pointDescription;

  /// No description provided for @pointImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Point image URL'**
  String get pointImageUrl;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @editPointsForRoute.
  ///
  /// In en, this message translates to:
  /// **'Edit points - {routeName}'**
  String editPointsForRoute(String routeName);

  /// No description provided for @editPoint.
  ///
  /// In en, this message translates to:
  /// **'Edit point'**
  String get editPoint;

  /// No description provided for @pointCreated.
  ///
  /// In en, this message translates to:
  /// **'Point created.'**
  String get pointCreated;

  /// No description provided for @pointUpdated.
  ///
  /// In en, this message translates to:
  /// **'Point updated.'**
  String get pointUpdated;

  /// No description provided for @pointDeleted.
  ///
  /// In en, this message translates to:
  /// **'Point deleted.'**
  String get pointDeleted;

  /// No description provided for @deletePoint.
  ///
  /// In en, this message translates to:
  /// **'Delete point'**
  String get deletePoint;

  /// No description provided for @deletePointConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete “{pointName}”?'**
  String deletePointConfirmation(String pointName);

  /// No description provided for @routeHasNoPoints.
  ///
  /// In en, this message translates to:
  /// **'This route has no points yet.'**
  String get routeHasNoPoints;

  /// No description provided for @noRoutePointsMap.
  ///
  /// In en, this message translates to:
  /// **'No route points available for this map.'**
  String get noRoutePointsMap;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @aboutRoute.
  ///
  /// In en, this message translates to:
  /// **'About this route'**
  String get aboutRoute;

  /// No description provided for @routeTags.
  ///
  /// In en, this message translates to:
  /// **'Route tags'**
  String get routeTags;

  /// No description provided for @routeMap.
  ///
  /// In en, this message translates to:
  /// **'Route map'**
  String get routeMap;

  /// No description provided for @startRoute.
  ///
  /// In en, this message translates to:
  /// **'Start route'**
  String get startRoute;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @routeGallery.
  ///
  /// In en, this message translates to:
  /// **'Route gallery'**
  String get routeGallery;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @saveToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Save to favorites'**
  String get saveToFavorites;

  /// No description provided for @savedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Saved to favorites'**
  String get savedToFavorites;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get notRated;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewCount(int count);

  /// No description provided for @loadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews...'**
  String get loadingReviews;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviews;

  /// No description provided for @reviewTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a review title.'**
  String get reviewTitleRequired;

  /// No description provided for @reviewPublished.
  ///
  /// In en, this message translates to:
  /// **'Review published successfully.'**
  String get reviewPublished;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @yourReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'You reviewed this route as “{title}”. You can only publish one review per route.'**
  String yourReviewNotice(String title);

  /// No description provided for @addYourReview.
  ///
  /// In en, this message translates to:
  /// **'Add your review'**
  String get addYourReview;

  /// No description provided for @scenery.
  ///
  /// In en, this message translates to:
  /// **'Scenery'**
  String get scenery;

  /// No description provided for @signage.
  ///
  /// In en, this message translates to:
  /// **'Signage'**
  String get signage;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add review'**
  String get addReview;

  /// No description provided for @cancelReview.
  ///
  /// In en, this message translates to:
  /// **'Cancel review'**
  String get cancelReview;

  /// No description provided for @loginToReview.
  ///
  /// In en, this message translates to:
  /// **'Log in to publish a review'**
  String get loginToReview;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reviewTitle;

  /// No description provided for @reviewComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get reviewComment;

  /// No description provided for @publishReview.
  ///
  /// In en, this message translates to:
  /// **'Publish review'**
  String get publishReview;

  /// No description provided for @publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing...'**
  String get publishing;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @chatLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Chats could not be loaded.'**
  String get chatLoadFailed;

  /// No description provided for @loginToUseChats.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to use chats.'**
  String get loginToUseChats;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'There are no chats available.'**
  String get noChats;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already a member'**
  String get alreadyMember;

  /// No description provided for @passwordRequiredGroup.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequiredGroup;

  /// No description provided for @openGroup.
  ///
  /// In en, this message translates to:
  /// **'Open group'**
  String get openGroup;

  /// No description provided for @selectChat.
  ///
  /// In en, this message translates to:
  /// **'Select a chat to view its messages.'**
  String get selectChat;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'There are no messages in this chat yet.'**
  String get noMessages;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String unreadMessages(int count);

  /// No description provided for @enterGroup.
  ///
  /// In en, this message translates to:
  /// **'Enter {groupName}'**
  String enterGroup(String groupName);

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @groupPassword.
  ///
  /// In en, this message translates to:
  /// **'Group password'**
  String get groupPassword;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @optionalPassword.
  ///
  /// In en, this message translates to:
  /// **'Optional password'**
  String get optionalPassword;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @loginToSendMessages.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to send messages.'**
  String get loginToSendMessages;

  /// No description provided for @messageSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent: {error}'**
  String messageSendFailed(String error);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to continue'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to sign up in this app'**
  String get signUpSubtitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address.'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get passwordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordRules.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 chars, 1 uppercase, 1 number and 1 special character.'**
  String get passwordRules;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @legalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By clicking continue, you agree to our '**
  String get legalPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyAccount;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @continueAppleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple unavailable'**
  String get continueAppleUnavailable;

  /// No description provided for @goToMainPage.
  ///
  /// In en, this message translates to:
  /// **'Go to main page'**
  String get goToMainPage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInformation;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and edit your account information and routes.'**
  String get profileSubtitle;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @newPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'The new passwords do not match.'**
  String get newPasswordsMismatch;

  /// No description provided for @newPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'The new password must contain at least 6 characters.'**
  String get newPasswordLength;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile and password updated successfully.'**
  String get profilePasswordUpdated;

  /// No description provided for @routesCreated.
  ///
  /// In en, this message translates to:
  /// **'Routes created'**
  String get routesCreated;

  /// No description provided for @pointsCreated.
  ///
  /// In en, this message translates to:
  /// **'Points created'**
  String get pointsCreated;

  /// No description provided for @reviewsWritten.
  ///
  /// In en, this message translates to:
  /// **'Reviews written'**
  String get reviewsWritten;

  /// No description provided for @noPublishedReviews.
  ///
  /// In en, this message translates to:
  /// **'You have not published any reviews yet.'**
  String get noPublishedReviews;

  /// No description provided for @reviewTitleRequiredShort.
  ///
  /// In en, this message translates to:
  /// **'Review title is required.'**
  String get reviewTitleRequiredShort;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted successfully.'**
  String get reviewDeleted;

  /// No description provided for @editingReview.
  ///
  /// In en, this message translates to:
  /// **'Editing review'**
  String get editingReview;

  /// No description provided for @editingRoute.
  ///
  /// In en, this message translates to:
  /// **'Editing route'**
  String get editingRoute;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route: {name}'**
  String routeLabel(String name);

  /// No description provided for @routeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Route ID: {id}'**
  String routeIdLabel(String id);

  /// No description provided for @coverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get coverImage;

  /// No description provided for @imagesCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Images (comma separated)'**
  String get imagesCommaSeparated;

  /// No description provided for @tagsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get tagsCommaSeparated;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete review?'**
  String get deleteReview;

  /// No description provided for @deleteReviewConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”? This action cannot be undone.'**
  String deleteReviewConfirmation(String title);

  /// No description provided for @noPublishedRoutes.
  ///
  /// In en, this message translates to:
  /// **'You have not published any routes yet.'**
  String get noPublishedRoutes;

  /// No description provided for @creatorStatistics.
  ///
  /// In en, this message translates to:
  /// **'Creator statistics'**
  String get creatorStatistics;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myReviews;

  /// No description provided for @myPublishedRoutes.
  ///
  /// In en, this message translates to:
  /// **'My published routes'**
  String get myPublishedRoutes;

  /// No description provided for @userSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'User session not found.'**
  String get userSessionNotFound;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading achievements...'**
  String get achievementsLoading;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Show unlocked'**
  String get achievementsUnlocked;

  /// No description provided for @achievementsAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get achievementsAll;

  /// No description provided for @achievementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not unlocked any achievements yet.'**
  String get achievementsEmpty;

  /// No description provided for @achievementsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Achievements could not be loaded.'**
  String get achievementsLoadFailed;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @colorAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Color adjustment'**
  String get colorAdjustment;

  /// No description provided for @monochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get monochrome;

  /// No description provided for @darkContrast.
  ///
  /// In en, this message translates to:
  /// **'Dark contrast'**
  String get darkContrast;

  /// No description provided for @lightContrast.
  ///
  /// In en, this message translates to:
  /// **'Light contrast'**
  String get lightContrast;

  /// No description provided for @lowSaturation.
  ///
  /// In en, this message translates to:
  /// **'Low saturation'**
  String get lowSaturation;

  /// No description provided for @highSaturation.
  ///
  /// In en, this message translates to:
  /// **'High saturation'**
  String get highSaturation;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @contentAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Content adjustment'**
  String get contentAdjustment;

  /// No description provided for @fontSettings.
  ///
  /// In en, this message translates to:
  /// **'Font settings'**
  String get fontSettings;

  /// No description provided for @fontSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase or modify text readability'**
  String get fontSettingsSubtitle;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// No description provided for @lineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get lineSpacing;

  /// No description provided for @wordSpacing.
  ///
  /// In en, this message translates to:
  /// **'Word spacing'**
  String get wordSpacing;

  /// No description provided for @letterSpacing.
  ///
  /// In en, this message translates to:
  /// **'Letter spacing'**
  String get letterSpacing;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get resetSettings;

  /// No description provided for @openAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Open accessibility settings'**
  String get openAccessibility;

  /// No description provided for @pedroGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hiiii, I am Pedro, and I am here to help you find routes!'**
  String get pedroGreeting;

  /// No description provided for @pedroError.
  ///
  /// In en, this message translates to:
  /// **'I could not send the message right now. Try again in a moment.'**
  String get pedroError;

  /// No description provided for @pedroOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the Pedro assistant'**
  String get pedroOpen;

  /// No description provided for @pedroCloseGreeting.
  ///
  /// In en, this message translates to:
  /// **'Close greeting'**
  String get pedroCloseGreeting;

  /// No description provided for @pedroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your route assistant'**
  String get pedroSubtitle;

  /// No description provided for @pedroCloseConversation.
  ///
  /// In en, this message translates to:
  /// **'Close conversation'**
  String get pedroCloseConversation;

  /// No description provided for @pedroAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Pedro...'**
  String get pedroAskHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @pedroThinking.
  ///
  /// In en, this message translates to:
  /// **'Pedro is thinking...'**
  String get pedroThinking;

  /// No description provided for @otherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other options'**
  String get otherOptions;

  /// No description provided for @viewRoute.
  ///
  /// In en, this message translates to:
  /// **'View route'**
  String get viewRoute;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found.'**
  String get routeNotFound;

  /// No description provided for @routeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'That route could not be opened.'**
  String get routeOpenFailed;

  /// No description provided for @routeFindFailed.
  ///
  /// In en, this message translates to:
  /// **'That route could not be found.'**
  String get routeFindFailed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorGoogleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed.'**
  String get errorGoogleLoginFailed;

  /// No description provided for @errorRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to register the user.'**
  String get errorRegistrationFailed;

  /// No description provided for @errorUserSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'User session not found.'**
  String get errorUserSessionNotFound;

  /// No description provided for @errorRouteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found.'**
  String get errorRouteNotFound;

  /// No description provided for @errorLoginToCreateRoutes.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to create routes.'**
  String get errorLoginToCreateRoutes;

  /// No description provided for @errorLoginToSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to save favorites.'**
  String get errorLoginToSaveFavorites;

  /// No description provided for @errorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed.'**
  String get errorRequestFailed;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
