import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instance Firebase dan Google Sign In
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1️⃣ Login ke Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Batal login

      // 2️⃣ Ambil detail autentikasi
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Buat credential Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Login ke Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("❌ Error saat login Google: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Dapatkan user aktif
  User? get currentUser => _auth.currentUser;
}
