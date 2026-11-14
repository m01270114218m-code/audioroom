import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

enum RoomEnvironment {
  default_,
  forest,
  ocean,
  space,
  cafe,
  library,
  concert,
  fireplace,
  rain,
  city,
  meditation,
  cyberpunk,
}

class RoomEnvironmentService {
  static FlutterSoundPlayer? _ambientPlayer;
  static RoomEnvironment _currentEnvironment = RoomEnvironment.default_;
  static double _ambientVolume = 0.3;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _ambientPlayer = FlutterSoundPlayer();
    await _ambientPlayer!.openPlayer();
    _isInitialized = true;
  }

  static Future<void> setEnvironment(RoomEnvironment environment) async {
    if (!_isInitialized) await initialize();
    
    _currentEnvironment = environment;
    
    // Stop current ambient sound
    if (_ambientPlayer!.isPlaying) {
      await _ambientPlayer!.stopPlayer();
    }
    
    // Play new ambient sound
    if (environment != RoomEnvironment.default_) {
      final soundPath = _getAmbientSoundPath(environment);
      if (soundPath != null) {
        await _ambientPlayer!.startPlayer(
          fromURI: soundPath,
          codec: Codec.mp3,
        );
      }
    }
  }

  static String? _getAmbientSoundPath(RoomEnvironment environment) {
    switch (environment) {
      case RoomEnvironment.forest:
        return 'assets/sounds/ambient/forest.mp3';
      case RoomEnvironment.ocean:
        return 'assets/sounds/ambient/ocean.mp3';
      case RoomEnvironment.space:
        return 'assets/sounds/ambient/space.mp3';
      case RoomEnvironment.cafe:
        return 'assets/sounds/ambient/cafe.mp3';
      case RoomEnvironment.library:
        return 'assets/sounds/ambient/library.mp3';
      case RoomEnvironment.concert:
        return 'assets/sounds/ambient/concert.mp3';
      case RoomEnvironment.fireplace:
        return 'assets/sounds/ambient/fireplace.mp3';
      case RoomEnvironment.rain:
        return 'assets/sounds/ambient/rain.mp3';
      case RoomEnvironment.city:
        return 'assets/sounds/ambient/city.mp3';
      case RoomEnvironment.meditation:
        return 'assets/sounds/ambient/meditation.mp3';
      case RoomEnvironment.cyberpunk:
        return 'assets/sounds/ambient/cyberpunk.mp3';
      default:
        return null;
    }
  }

  static ThemeData getEnvironmentTheme(RoomEnvironment environment) {
    switch (environment) {
      case RoomEnvironment.forest:
        return _createForestTheme();
      case RoomEnvironment.ocean:
        return _createOceanTheme();
      case RoomEnvironment.space:
        return _createSpaceTheme();
      case RoomEnvironment.cafe:
        return _createCafeTheme();
      case RoomEnvironment.cyberpunk:
        return _createCyberpunkTheme();
      default:
        return _createDefaultTheme();
    }
  }

  static ThemeData _createForestTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.green.shade400,
        secondary: Colors.brown.shade300,
        background: Color(0xFF1A2E1A),
        surface: Color(0xFF2D4A2D),
      ),
      scaffoldBackgroundColor: Color(0xFF1A2E1A),
    );
  }

  static ThemeData _createOceanTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.blue.shade400,
        secondary: Colors.cyan.shade300,
        background: Color(0xFF0D1B2A),
        surface: Color(0xFF1B263B),
      ),
      scaffoldBackgroundColor: Color(0xFF0D1B2A),
    );
  }

  static ThemeData _createSpaceTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.deepPurple.shade300,
        secondary: Colors.pink.shade200,
        background: Color(0xFF0A0A0F),
        surface: Color(0xFF1A1A2E),
      ),
      scaffoldBackgroundColor: Color(0xFF0A0A0F),
    );
  }

  static ThemeData _createCafeTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.brown.shade400,
        secondary: Colors.orange.shade300,
        background: Color(0xFF2B1810),
        surface: Color(0xFF3D2317),
      ),
      scaffoldBackgroundColor: Color(0xFF2B1810),
    );
  }

  static ThemeData _createCyberpunkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.cyan.shade400,
        secondary: Colors.pink.shade400,
        background: Color(0xFF0D0D0D),
        surface: Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: Color(0xFF0D0D0D),
    );
  }

  static ThemeData _createDefaultTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
      ),
    );
  }

  static String getEnvironmentName(RoomEnvironment environment) {
    switch (environment) {
      case RoomEnvironment.default_:
        return 'Default';
      case RoomEnvironment.forest:
        return 'Forest';
      case RoomEnvironment.ocean:
        return 'Ocean';
      case RoomEnvironment.space:
        return 'Space';
      case RoomEnvironment.cafe:
        return 'Café';
      case RoomEnvironment.library:
        return 'Library';
      case RoomEnvironment.concert:
        return 'Concert Hall';
      case RoomEnvironment.fireplace:
        return 'Fireplace';
      case RoomEnvironment.rain:
        return 'Rain';
      case RoomEnvironment.city:
        return 'City';
      case RoomEnvironment.meditation:
        return 'Meditation';
      case RoomEnvironment.cyberpunk:
        return 'Cyberpunk';
    }
  }

  static IconData getEnvironmentIcon(RoomEnvironment environment) {
    switch (environment) {
      case RoomEnvironment.default_:
        return Icons.home;
      case RoomEnvironment.forest:
        return Icons.forest;
      case RoomEnvironment.ocean:
        return Icons.waves;
      case RoomEnvironment.space:
        return Icons.rocket;
      case RoomEnvironment.cafe:
        return Icons.local_cafe;
      case RoomEnvironment.library:
        return Icons.local_library;
      case RoomEnvironment.concert:
        return Icons.theater_comedy;
      case RoomEnvironment.fireplace:
        return Icons.fireplace;
      case RoomEnvironment.rain:
        return Icons.grain;
      case RoomEnvironment.city:
        return Icons.location_city;
      case RoomEnvironment.meditation:
        return Icons.self_improvement;
      case RoomEnvironment.cyberpunk:
        return Icons.computer;
    }
  }

  static Future<void> setAmbientVolume(double volume) async {
    _ambientVolume = volume.clamp(0.0, 1.0);
    if (_ambientPlayer != null && _ambientPlayer!.isPlaying) {
      await _ambientPlayer!.setVolume(_ambientVolume);
    }
  }

  static Future<void> dispose() async {
    if (_ambientPlayer != null) {
      await _ambientPlayer!.closePlayer();
      _ambientPlayer = null;
    }
    _isInitialized = false;
  }
}