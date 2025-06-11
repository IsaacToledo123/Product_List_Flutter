import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_list_app/models/user.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); // Cambiado de email a username
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cargar credenciales guardadas si el usuario eligió "Recordarme"
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe && savedUsername != null) {
        setState(() {
          _usernameController.text = savedUsername;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error cargando credenciales: $e');
    }
  }

  // Verificar si ya hay una sesión activa
  Future<void> _checkExistingSession() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        // Si ya está autenticado, ir directo a home
        _navigateToHome();
      }
    } catch (e) {
      print('Error verificando sesión: $e');
    }
  }

  // Función principal de login con tu API
  Future<void> _signInWithUsernamePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final result = await _authService.loginUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      if (result != null) {
        // Guardar credenciales si "Recordarme" está activado
        await _saveCredentialsIfRemembered();
        
        // Login exitoso, navegar a home
        _navigateToHome();
        
        // Mostrar mensaje de bienvenida
        _showSuccessMessage(result['user']['username']);
      } else {
        _showErrorDialog('Credenciales incorrectas. Verifica tu usuario y contraseña.');
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Personalizar mensajes de error
      if (errorMessage.contains('Credenciales inválidas')) {
        errorMessage = 'Usuario o contraseña incorrectos';
      } else if (errorMessage.contains('connection') || errorMessage.contains('SocketException')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet y que el servidor esté funcionando.';
      }
      
      _showErrorDialog(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Login con Google (mantiene Firebase)
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Navegar a home con datos de Firebase
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: user, // Usuario de Firebase
              username: user.displayName ?? 'Usuario Google',
              email: user.email ?? '',
            ),
          ),
        );
        
        _showSuccessMessage(user.displayName ?? 'Usuario');
      } else {
        _showErrorDialog('Login con Google cancelado');
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      _showErrorDialog('Error con Google Sign-In: $errorMessage');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Navegar a home con datos de tu API
  void _navigateToHome() async {
    try {
      // Obtener datos actuales del usuario desde tu API
      final userProfile = await _authService.getUserProfile();
      
      if (userProfile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: null, // No es usuario de Firebase
              username: userProfile['username'],
              email: userProfile['email'],
              // Datos adicionales de tu API
            ),
          ),
        );
      } else {
        // Fallback si no se puede obtener el perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              user: null,
              username: _usernameController.text.trim(),
              email: 'usuario@app.com',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
      // Navegar con datos básicos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            user: null,
            username: _usernameController.text.trim(),
            email: 'usuario@app.com',
          ),
        ),
      );
    }
  }

  // Guardar credenciales si "Recordarme" está activo
  Future<void> _saveCredentialsIfRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberMe) {
        await prefs.setString('saved_username', _usernameController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_username');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Error guardando credenciales: $e');
    }
  }

  // Navegar a registro
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  // Mostrar mensaje de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Mostrar mensaje de éxito
  void _showSuccessMessage(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Bienvenido, $username!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Test de conexión con la API (para debugging)
  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    
    try {
      final isConnected = await _authService.testConnection();
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Estado de Conexión'),
          content: Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                color: isConnected ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text(isConnected ? 'Conectado al servidor' : 'Sin conexión al servidor'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('Error probando conexión: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botón de test de conexión (solo en desarrollo)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: Icon(Icons.wifi, color: Colors.grey[600]),
              onPressed: _testConnection,
              tooltip: 'Probar conexión',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              
              // Logo o título de la app
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Product List App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
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

              // Formulario de usuario y contraseña
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de usuario
                        TextFormField(
                          controller: _usernameController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Nombre de usuario',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: 'Ingresa tu nombre de usuario',
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
                          enabled: !_isLoading,
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
                        SizedBox(height: 16),

                        // Checkbox "Recordarme"
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: _isLoading ? null : (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            Text(
                              'Recordar mi usuario',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
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
                              elevation: 3,
                            ),
                            child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Iniciando sesión...'),
                                  ],
                                )
                              : Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),

              // Botón de Google Sign-In
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

              // Link a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _navigateToRegister,
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
              
              // Información de desarrollo
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Modo Desarrollo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Usa el ícono WiFi para probar la conexión con tu API',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}