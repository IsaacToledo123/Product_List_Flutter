import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // Asegúrate de importar el modelo User

class RegisterService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // Login de usuario usando la API de autenticación
  Future<String?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
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
        // La API devuelve un objeto con el token
        return responseData['token'] as String?;
      } else {
        throw Exception('Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en loginUser: $e');
      return null;
    }
  }

  // Registrar nuevo usuario y devolver objeto User
  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Crear usuario temporal para generar el JSON de registro
      final tempUser = User.fromRegistration(
        id: '0', // Temporal, será reemplazado por la respuesta de la API
        username: username,
        email: email,
        password: password,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(tempUser.toRegistrationJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Crear y devolver el usuario registrado usando el modelo User
        return User.fromRegistration(
          id: responseData['id'].toString(),
          username: username,
          email: email,
          // No incluir password en el objeto final por seguridad
        );
      } else {
        throw Exception('Error en el registro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en registerUser: $e');
      return null;
    }
  }

  // Obtener todos los usuarios desde la API
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllUsers: $e');
      return [];
    }
  }

  // Validar si el email ya existe usando el modelo User
  Future<bool> isEmailTaken(String email) async {
    try {
      final users = await getAllUsers();
      return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      print('Error validando email: $e');
      return false;
    }
  }

  // Validar si el username ya existe usando el modelo User
  Future<bool> isUsernameTaken(String username) async {
    try {
      final users = await getAllUsers();
      return users.any((user) => 
        user.username?.toLowerCase() == username.toLowerCase());
    } catch (e) {
      print('Error validando username: $e');
      return false;
    }
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$id'));
      
      if (response.statusCode == 200) {
        final userJson = json.decode(response.body);
        return User.fromJson(userJson);
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      print('Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Obtener información del usuario usando el token (opcional)
  Future<User?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/1'), // Ejemplo con usuario ID 1
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final userJson = json.decode(response.body);
        return User.fromJson(userJson);
      } else {
        throw Exception('Error obteniendo perfil de usuario');
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
      return null;
    }
  }
}