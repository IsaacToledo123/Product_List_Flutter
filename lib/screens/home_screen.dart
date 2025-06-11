import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import '../models/navItem.dart';

class HomeScreen extends StatefulWidget {
  final User? user; 
  final String? username;
  final String? email; 

  HomeScreen({
    this.user, 
    this.username, 
    this.email,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  
  late List<Widget> _screens;
  late PageController _pageController;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Tienda',
      color: Color(0xFF6C5CE7),
    ),
    NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'Carrito',
      color: Color(0xFFE17055),
    ),
  ];

  // Propiedades para obtener información del usuario
  bool get isFakeUser => widget.user == null;
  String get userEmail => widget.user?.email ?? widget.email ?? 'Sin email';
  String get userInitial {
    if (widget.user?.email != null) {
      return widget.user!.email!.substring(0, 1).toUpperCase();
    } else if (widget.username != null) {
      return widget.username!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
  bool get isEmailVerified => widget.user?.emailVerified ?? true; // Fake users siempre verificados

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _screens = [
      ProductListScreen(),
      CartScreen(),
    ];
    
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.mediumImpact();
    
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SignOutBottomSheet(),
    );

    if (result == true) {
      try {
        // Solo hacer sign out de Firebase si no es usuario fake
        if (!isFakeUser) {
          await _authService.signOut();
        }
        
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
          (route) => false,
        );
      } catch (e) {
        _showErrorSnackBar('Error al cerrar sesión');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showUserProfile() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UserProfileBottomSheet(
        user: widget.user,
        username: widget.username,
        email: widget.email,
        onLogout: _handleSignOut, // Pasar el método de logout
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      extendBody: true,
      appBar: _buildAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      title: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Text(
          _navItems[_currentIndex].label,
          key: ValueKey(_currentIndex),
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        ScaleTransition(
          scale: _fabAnimation,
          child: Container(
            margin: EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _showUserProfile,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isFakeUser 
                          ? [Color(0xFF00B894), Color(0xFF55EFC4)] // Verde para usuario fake
                          : [Color(0xFF6C5CE7), Color(0xFFA29BFE)], // Morado para Firebase
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFakeUser ? Color(0xFF00B894) : Color(0xFF6C5CE7)).withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userInitial,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: _navItems[_currentIndex].color,
          unselectedItemColor: Color(0xFFB2BEC3),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          items: _navItems.map((item) {
            final isSelected = _navItems.indexOf(item) == _currentIndex;
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SignOutBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout,
              color: Color(0xFFFF6B6B),
              size: 28,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Cerrar Sesión',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '¿Estás seguro de que quieres salir?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF636E72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Salir',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _UserProfileBottomSheet extends StatelessWidget {
  final User? user;
  final String? username;
  final String? email;
  final VoidCallback? onLogout; // Agregamos callback para logout

  _UserProfileBottomSheet({
    this.user,
    this.username,
    this.email,
    this.onLogout, // Nuevo parámetro
  });

  bool get isFakeUser => user == null;
  String get displayEmail => user?.email ?? email ?? 'Sin email';
  String get displayInitial {
    if (user?.email != null) {
      return user!.email!.substring(0, 1).toUpperCase();
    } else if (username != null) {
      return username!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFakeUser 
                    ? [Color(0xFF00B894), Color(0xFF55EFC4)] // Verde para usuario fake
                    : [Color(0xFF6C5CE7), Color(0xFFA29BFE)], // Morado para Firebase
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayInitial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Mi Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          if (isFakeUser)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Usuario Demo',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(height: 24),
          _buildProfileItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: displayEmail,
          ),
          if (username != null)
            _buildProfileItem(
              icon: Icons.person_outline,
              title: 'Username',
              subtitle: username!,
            ),
          _buildProfileItem(
            icon: (user?.emailVerified ?? true) ? Icons.verified : Icons.warning_outlined,
            title: 'Estado',
            subtitle: (user?.emailVerified ?? true) ? 'Verificado' : 'No verificado',
            subtitleColor: (user?.emailVerified ?? true) ? Color(0xFF00B894) : Color(0xFFE17055),
          ),
          if (user?.displayName != null)
            _buildProfileItem(
              icon: Icons.person_outline,
              title: 'Nombre',
              subtitle: user!.displayName!,
            ),
          SizedBox(height: 24),
          
          // BOTÓN DE CERRAR SESIÓN
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Cerrar el modal primero
                if (onLogout != null) {
                  onLogout!(); // Ejecutar el callback de logout
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Color(0xFFFF6B6B).withOpacity(0.3),
              ),
              icon: Icon(Icons.logout, size: 20),
              label: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: isFakeUser ? Color(0xFF00B894) : Color(0xFF6C5CE7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isFakeUser ? Color(0xFF00B894) : Color(0xFF6C5CE7),
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor ?? Color(0xFF2D3436),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}