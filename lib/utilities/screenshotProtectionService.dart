import 'package:no_screenshot/no_screenshot.dart';

class ScreenshotProtectionService {
  static final NoScreenshot _noScreenshot = NoScreenshot.instance;
  static bool _isProtected = false;
  static Future<bool> enableProtection() async {
    try {
      bool result = await _noScreenshot.screenshotOff();
      _isProtected = result;
      
      if (result) {
        print('✅ Protección activada');
      } else {
        print('❌ No se pudo activar protección');
      }
      
      return result;
    } catch (e) {
      print('⚠️ Error: $e');
      return false;
    }
  }
  static Future<bool> disableProtection() async {
    try {
      bool result = await _noScreenshot.screenshotOn();
      _isProtected = !result;
      
      if (result) {
        print('✅ Protección desactivada');
      } else {
        print('❌ No se pudo desactivar protección');
      }
      
      return result;
    } catch (e) {
      print('⚠️ Error: $e');
      return false;
    }
  }
  static bool get isProtected => _isProtected;
  static Future<bool> toggleProtection() async {
    if (_isProtected) {
      return await disableProtection();
    } else {
      return await enableProtection();
    }
  }
}