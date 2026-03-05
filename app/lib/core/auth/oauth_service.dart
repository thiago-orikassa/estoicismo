import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OAuthCredential {
  const OAuthCredential({
    required this.provider,
    required this.identityToken,
    required this.email,
  });

  final String provider;
  final String identityToken;
  final String email;
}

class OAuthService {
  static Future<OAuthCredential?> signInWithApple() async {
    final result = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final token = result.identityToken;
    if (token == null) return null;

    final email = result.email ?? '';
    return OAuthCredential(
      provider: 'apple',
      identityToken: token,
      email: email,
    );
  }

  static Future<OAuthCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: '481843993446-d9iu6be6kaq6869cbs7to7o2npigmnsc.apps.googleusercontent.com',
    );
    final account = await googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) return null;

    return OAuthCredential(
      provider: 'google',
      identityToken: idToken,
      email: account.email,
    );
  }
}
