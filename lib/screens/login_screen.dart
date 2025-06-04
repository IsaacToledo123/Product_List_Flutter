import 'package:flutter/material.dart';
import 'package:product_list_app/models/user.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart'; // Importar la pantalla de registro

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función para login con email y contraseña
Future<void> _signInWithUsernamePassword() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);

  try {
    final token = await _authService.loginUser(
      username: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (token != null) {
      // Pasar usuario fake con parámetros adicionales
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            user: null, // Usuario Firebase es null
            username: _emailController.text.trim(),
            email: '${_emailController.text.trim()}@gmail.com',
          ),
        ),
      );
    } else {
      _showErrorDialog('Credenciales incorrectas. Verifica tu usuario y contraseña.');
    }
  } catch (e) {
    _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
  } finally {
    setState(() => _isLoading = false);
  }
}

// Función para login con Google (sin cambios)
Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);

  try {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      // Pasar usuario de Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            user: user, // Usuario Firebase
            // username y email se toman del user de Firebase
          ),
        ),
      );
    } else {
      _showErrorDialog('Error al iniciar sesión con Google');
    }
  } catch (e) {
    _showErrorDialog(e.toString());
  } finally {
    setState(() => _isLoading = false);
  }
}

  // Navegar a la pantalla de registro
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  // Mostrar dialog de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              
              // Logo o título de la app
              Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Product List App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Inicia sesión en tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),

              // Formulario de email y contraseña
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de usuario
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu usuario';
                            }
                            if (value.length < 3) {
                              return 'El usuario debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Campo de contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithUsernamePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Divisor
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('O', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),

              // Botón de Google
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                  label: Text(
                    'Continuar con Google',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Navegar a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _navigateToRegister,
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}