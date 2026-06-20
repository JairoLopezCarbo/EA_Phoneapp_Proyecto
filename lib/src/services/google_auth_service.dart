import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService()
    : _googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
        clientId: Platform.isIOS
            ? '136495957431-r01tadnj1457j8c3avlubl674n1k6rm6.apps.googleusercontent.com'
            : null,
        serverClientId:
            '136495957431-f36ubav6rnlu1aultggn38u5a239masj.apps.googleusercontent.com',
      );

  final GoogleSignIn _googleSignIn;

  Future<String> signInAndGetAccessToken() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw StateError('Google sign in was cancelled.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final String? accessToken = googleAuth.accessToken;

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw StateError('Google did not return an access token.');
    }

    return accessToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

final GoogleAuthService googleAuthService = GoogleAuthService();
