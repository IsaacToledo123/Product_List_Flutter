import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  static const String _baseUrl = 'http://54.210.135.104'; // Ajusta según tu puerto
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          // Guardar token en SharedPreferences
          await _saveToken(responseData['data']['token']);
          
          return {
            'token': responseData['data']['token'],
            'user': responseData['data']['user'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Error en el login');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en loginUser: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signUpWithEmailPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones locales antes de enviar
      if (!_isValidEmail(email)) {
        throw Exception('El formato del email no es válido');
      }
      
      if (!_isValidUsername(username)) {
        throw Exception('El username debe tener entre 3-20 caracteres: letras, números y _');
      }
      
      if (!_isValidPassword(password)) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          // Guardar token automáticamente después del registro
          await _saveToken(responseData['data']['token']);
          
          // Retornar datos del usuario y token
          return {
            'token': responseData['data']['token'],
            'user': responseData['data']['user'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Error en el registro');
        }
      } else {
        final errorData = json.decode(response.body);
        
        // Manejar errores de validación específicos
        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as List;
          final errorMessages = errors.map((e) => e['msg']).join(', ');
          throw Exception(errorMessages);
        } else {
          // Manejar mensajes de error específicos de tu API
          String errorMessage = errorData['message'] ?? 'Error en el registro';
          
          // Personalizar mensajes comunes
          if (errorMessage.contains('El username ya está en uso')) {
            throw Exception('Este nombre de usuario ya está en uso');
          } else if (errorMessage.contains('El email ya está registrado')) {
            throw Exception('Ya existe una cuenta con este email');
          }
          
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('Error en signUpWithEmailPassword: $e');
      rethrow;
    }
  }

  // Método para mantener compatibilidad con Firebase (si necesitas usar ambos)
  Future<User?> signUpWithEmailPasswordFirebase(String email, String password) async {
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

  // Obtener perfil del usuario desde tu API
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return responseData['data']['user'];
        } else {
          throw Exception(responseData['message'] ?? 'Error obteniendo perfil');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token inválido o expirado
        await _clearToken();
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error obteniendo perfil');
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
      rethrow;
    }
  }

  // Verificar si el usuario está autenticado con tu API
  Future<bool> isAuthenticated() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      // Verificar token con el servidor
      final profile = await getUserProfile();
      return profile != null;
    } catch (e) {
      print('Error verificando autenticación: $e');
      return false;
    }
  }

  // Funciones auxiliares para manejo de tokens
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('login_time', DateTime.now().toIso8601String());
      print('Token guardado exitosamente');
    } catch (e) {
      print('Error guardando token: $e');
    }
  }

  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('login_time');
      print('Token eliminado');
    } catch (e) {
      print('Error eliminando token: $e');
    }
  }

  // Validaciones locales
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  // Logout actualizado para tu API
  Future<void> signOut() async {
    try {
      // Limpiar token de tu API
      await _clearToken();
      
      // También cerrar sesión de Firebase y Google (si están activos)
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      print('Logout exitoso');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Test de conexión con tu API
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/test-db'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error en test de conexión: $e');
      return false;
    }
  }

  // Mantener métodos originales de Firebase/Google sin cambios
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
  // Al final de tu clase AuthService
@visibleForTesting
bool testValidEmail(String email) => _isValidEmail(email);

@visibleForTesting  
bool testValidUsername(String username) => _isValidUsername(username);

@visibleForTesting
bool testValidPassword(String password) => _isValidPassword(password);

@visibleForTesting
Future<void> testSaveToken(String token) => _saveToken(token);

@visibleForTesting
Future<String?> testGetStoredToken() => _getStoredToken();

@visibleForTesting
Future<void> testClearToken() => _clearToken();
  
}
