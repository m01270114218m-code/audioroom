/// LiveKit access tokens must be issued by a trusted server/Edge Function.
/// Signing a LiveKit JWT in the mobile app would expose the API secret.
class JwtService {
  static String createJwtToken(String roomName, {required bool isAdmin}) {
    throw StateError(
      'LiveKit token generation is server-side only. Configure the LiveKit token Edge Function.',
    );
  }
}
