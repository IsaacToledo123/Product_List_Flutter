class User {
  final String id;
  final String name;
  final String email;
  final String? username; // Agregado para compatibilidad con FakeStore API
  final String? password; // Solo para uso temporal, no se debe persistir

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.password,
  });

  // Factory para crear User desde la respuesta de FakeStore API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(), // Convertir a String por si viene como int
      name: json['name'] != null 
          ? '${json['name']['firstname'] ?? ''} ${json['name']['lastname'] ?? ''}'.trim()
          : json['username'] ?? '', // Usar username como fallback si no hay name
      email: json['email'] as String,
      username: json['username'] as String?,
    );
  }

  // Factory para crear User desde datos de registro
  factory User.fromRegistration({
    required String id,
    required String username,
    required String email,
    String? password,
  }) {
    return User(
      id: id,
      name: username, // Usar username como name
      email: email,
      username: username,
      password: password,
    );
  }

  // Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
    };
  }

  // Convertir a JSON para registro (incluye datos adicionales requeridos por FakeStore)
  Map<String, dynamic> toRegistrationJson() {
    return {
      'email': email,
      'username': username ?? name,
      'password': password ?? '',
      'name': {
        'firstname': name.split(' ').first,
        'lastname': name.split(' ').length > 1 ? name.split(' ').last : '',
      },
      'address': {
        'city': 'kilcoole',
        'street': '7835 new road',
        'number': 3,
        'zipcode': '12926-3874',
        'geolocation': {
          'lat': '-37.3159',
          'long': '81.1496'
        }
      },
      'phone': '1-570-236-7033'
    };
  }

  // Método para crear una copia del usuario sin la contraseña
  User copyWithoutPassword() {
    return User(
      id: id,
      name: name,
      email: email,
      username: username,
    );
  }
}

