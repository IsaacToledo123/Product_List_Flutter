import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // Asegúrate de importar el modelo User

class RegisterService {
  // Cambia esta URL por la de tu API
  static const String _baseUrl = 'http://localhost:3000'; // o tu dominio/IP

  // Login de usuario - adaptado a tu API
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
          // Retorna tanto el token como la información del usuario
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
      return null;
    }
  }

  // Registrar nuevo usuario - adaptado a tu API
  Future<Map<String, dynamic>?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
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
          // Retorna tanto el token como la información del usuario
          return {
            'token': responseData['data']['token'],
            'user': responseData['data']['user'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Error en el registro');
        }
      } else {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null) {
          // Si hay errores de validación, los concatenamos
          final errors = errorData['errors'] as List;
          final errorMessages = errors.map((e) => e['msg']).join(', ');
          throw Exception(errorMessages);
        } else {
          throw Exception(errorData['message'] ?? 'Error en el registro: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error en registerUser: $e');
      return null;
    }
  }

  // Obtener perfil del usuario autenticado
  Future<User?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final userData = responseData['data']['user'];
          return User.fromJson(userData);
        } else {
          throw Exception(responseData['message'] ?? 'Error obteniendo perfil');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error obteniendo perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
      return null;
    }
  }

  // Test de conexión a la base de datos
  Future<bool> testDatabaseConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/test-db'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('DB Test response status: ${response.statusCode}');
      print('DB Test response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error en test de DB: $e');
      return false;
    }
  }

  // Obtener información básica de la API
  Future<Map<String, dynamic>?> getApiInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo info de API: $e');
      return null;
    }
  }

  // Validar formato de email localmente (opcional)
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validar formato de username localmente (opcional)
  bool isValidUsername(String username) {
    // Debe tener entre 3 y 20 caracteres, solo letras, números y guiones bajos
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  // Validar longitud de contraseña localmente (opcional)
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Método helper para manejar errores de red
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    } else if (error.toString().contains('FormatException')) {
      return 'Error en el formato de respuesta del servidor.';
    }
    return error.toString();
  }

  // Método mejorado para login con manejo de errores más específico
  Future<Map<String, dynamic>?> loginUserWithErrorHandling({
    required String username,
    required String password,
  }) async {
    try {
      // Validaciones locales antes de enviar
      if (!isValidUsername(username)) {
        throw Exception('Username debe tener entre 3 y 20 caracteres y solo contener letras, números y guiones bajos');
      }
      
      if (!isValidPassword(password)) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      return await loginUser(username: username, password: password);
    } catch (e) {
      print('Error en loginUserWithErrorHandling: $e');
      throw Exception(_getErrorMessage(e));
    }
  }

  // Método mejorado para registro con manejo de errores más específico
  Future<Map<String, dynamic>?> registerUserWithErrorHandling({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones locales antes de enviar
      if (!isValidUsername(username)) {
        throw Exception('Username debe tener entre 3 y 20 caracteres y solo contener letras, números y guiones bajos');
      }
      
      if (!isValidEmail(email)) {
        throw Exception('Formato de email inválido');
      }
      
      if (!isValidPassword(password)) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      return await registerUser(
        username: username,
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error en registerUserWithErrorHandling: $e');
      throw Exception(_getErrorMessage(e));
    }
  }
}