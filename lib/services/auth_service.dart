import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No se encontró ningún usuario con ese email');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'invalid-email':
          throw Exception('El formato del email no es válido');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        case 'too-many-requests':
          throw Exception('Demasiados intentos fallidos. Intenta más tarde');
        case 'invalid-credential':
          throw Exception('Las credenciales no son válidas');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('La contraseña es muy débil');
        case 'email-already-in-use':
          throw Exception('Ya existe una cuenta con este email');
        case 'invalid-email':
          throw Exception('El formato del email no es válido');
        case 'operation-not-allowed':
          throw Exception('El registro con email/contraseña no está habilitado');
        default:
          throw Exception('Error de registro: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
  Future<User?> signInWithGoogle() async {
    try {
      // Iniciar el proceso de autenticación
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario canceló el proceso
        return null;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Ya existe una cuenta con este email usando otro método');
        case 'invalid-credential':
          throw Exception('Las credenciales de Google no son válidas');
        case 'operation-not-allowed':
          throw Exception('El inicio de sesión con Google no está habilitado');
        default:
          throw Exception('Error con Google Sign-In: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado con Google: $e');
    }
  }
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No se encontró ningún usuario con ese email');
        case 'invalid-email':
          throw Exception('El formato del email no es válido');
        default:
          throw Exception('Error al enviar email de recuperación: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Error al enviar verificación de email: $e');
    }
  }
}