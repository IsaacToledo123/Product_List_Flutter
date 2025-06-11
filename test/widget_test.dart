// test/widget_test.dart - Los tests más básicos posibles
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_app/screens/login_screen.dart';
import 'package:product_list_app/screens/register_screen.dart';

void main() {
  testWidgets('LoginScreen se construye', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  // Test 2: RegisterScreen se puede crear
  testWidgets('RegisterScreen se construye', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  // Test 3: LoginScreen tiene texto
  testWidgets('LoginScreen tiene título', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.text('Product List App'), findsOneWidget);
  });

  // Test 4: RegisterScreen tiene texto
  testWidgets('RegisterScreen tiene título', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    expect(find.text('Crear Cuenta'), findsOneWidget);
  });

  // Test 5: LoginScreen tiene campos de texto
  testWidgets('LoginScreen tiene campos', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byType(TextFormField), findsWidgets);
  });

  // Test 6: RegisterScreen tiene campos de texto
  testWidgets('RegisterScreen tiene campos', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    expect(find.byType(TextFormField), findsWidgets);
  });

  // Test 7: LoginScreen tiene botón
  testWidgets('LoginScreen tiene botón', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  // Test 8: RegisterScreen tiene botón
  testWidgets('RegisterScreen tiene botón', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    expect(find.text('Crear Cuenta'), findsOneWidget);
  });
}