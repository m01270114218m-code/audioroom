import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceEffect {
  none,
  robot,
  echo,
  reverb,
  pitchHigh,
  pitchLow,
  whisper,
  demon,
  chipmunk,
  deepVoice,
  spacey,
  vintage,
}

enum SoundEffect {
  applause,
  laugh,
  drumRoll,
  airhorn,
  ninja,
  sword,
  magic,
  explosion,
  notification,
  success,
  fail,
  pop,
}

class VoiceEffectsService {
  static double _tanh(double value) {
    final e = math.exp(2 * value);
    return (e - 1) / (e + 1);
  }
  static FlutterSoundRecorder? _recorder;
  static FlutterSoundPlayer? _player;
  static VoiceEffect _currentVoiceEffect = VoiceEffect.none;
  static bool _isInitialized = false;
  static double _effectIntensity = 0.5;

  /// Initialize voice effects service
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request permissions
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }

      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();

      await _recorder!.openRecorder();
      await _player!.openPlayer();

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize voice effects: $e');
      return false;
    }
  }

  /// Set current voice effect
  static void setVoiceEffect(VoiceEffect effect, {double intensity = 0.5}) {
    _currentVoiceEffect = effect;
    _effectIntensity = intensity.clamp(0.0, 1.0);
  }

  /// Get current voice effect
  static VoiceEffect get currentEffect => _currentVoiceEffect;

  /// Apply voice effect to audio stream
  static Uint8List applyVoiceEffect(Uint8List audioData) {
    switch (_currentVoiceEffect) {
      case VoiceEffect.robot:
        return _applyRobotEffect(audioData);
      case VoiceEffect.echo:
        return _applyEchoEffect(audioData);
      case VoiceEffect.reverb:
        return _applyReverbEffect(audioData);
      case VoiceEffect.pitchHigh:
        return _applyPitchShift(audioData, 1.5);
      case VoiceEffect.pitchLow:
        return _applyPitchShift(audioData, 0.7);
      case VoiceEffect.whisper:
        return _applyWhisperEffect(audioData);
      case VoiceEffect.demon:
        return _applyDemonEffect(audioData);
      case VoiceEffect.chipmunk:
        return _applyPitchShift(audioData, 2.0);
      case VoiceEffect.deepVoice:
        return _applyPitchShift(audioData, 0.5);
      case VoiceEffect.spacey:
        return _applySpaceyEffect(audioData);
      case VoiceEffect.vintage:
        return _applyVintageEffect(audioData);
      default:
        return audioData;
    }
  }

  /// Play sound effect
  static Future<void> playSoundEffect(SoundEffect effect) async {
    if (!_isInitialized || _player == null) return;

    String assetPath = _getSoundEffectPath(effect);
    
    try {
      await _player!.startPlayer(
        fromURI: assetPath,
        codec: Codec.mp3,
      );
    } catch (e) {
      print('Failed to play sound effect: $e');
    }
  }

  /// Stop current playback
  static Future<void> stopPlayback() async {
    if (_player != null && _player!.isPlaying) {
      await _player!.stopPlayer();
    }
  }

  // Voice effect implementations
  static Uint8List _applyRobotEffect(Uint8List audioData) {
    // Simple robotization using bit crushing and filtering
    final samples = Int16List.view(audioData.buffer);
    final processed = Int16List(samples.length);
    
    for (int i = 0; i < samples.length; i++) {
      // Bit crushing
      int sample = samples[i];
      sample = (sample ~/ 256) * 256; // Reduce bit depth
      
      // Simple filtering
      if (i > 0 && i < samples.length - 1) {
        sample = (samples[i - 1] + sample + samples[i + 1]) ~/ 3;
      }
      
      processed[i] = (sample * _effectIntensity).round().clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applyEchoEffect(Uint8List audioData) {
    final samples = Int16List.view(audioData.buffer);
    final processed = Int16List(samples.length);
    final delayInSamples = (0.3 * 44100).round(); // 300ms delay at 44.1kHz
    
    for (int i = 0; i < samples.length; i++) {
      int sample = samples[i];
      
      // Add delayed signal
      if (i >= delayInSamples) {
        int delayedSample = samples[i - delayInSamples];
        sample += (delayedSample * _effectIntensity * 0.6).round();
      }
      
      processed[i] = sample.clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applyReverbEffect(Uint8List audioData) {
    final samples = Int16List.view(audioData.buffer);
    final processed = Int16List(samples.length);
    
    // Simple reverb with multiple delays
    final delays = [
      (0.03 * 44100).round(), // 30ms
      (0.07 * 44100).round(), // 70ms
      (0.15 * 44100).round(), // 150ms
    ];
    final gains = [0.3, 0.2, 0.1];
    
    for (int i = 0; i < samples.length; i++) {
      double sample = samples[i].toDouble();
      
      for (int j = 0; j < delays.length; j++) {
        if (i >= delays[j]) {
          sample += samples[i - delays[j]] * gains[j] * _effectIntensity;
        }
      }
      
      processed[i] = sample.round().clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applyPitchShift(Uint8List audioData, double pitchFactor) {
    final samples = Int16List.view(audioData.buffer);
    final outputLength = (samples.length / pitchFactor).round();
    final processed = Int16List(outputLength);
    
    for (int i = 0; i < outputLength; i++) {
      int sourceIndex = (i * pitchFactor).round();
      if (sourceIndex < samples.length) {
        processed[i] = (samples[sourceIndex] * _effectIntensity).round()
            .clamp(-32768, 32767);
      }
    }
    
    // Resize back to original length with interpolation
    final result = Int16List(samples.length);
    for (int i = 0; i < samples.length; i++) {
      double pos = i / samples.length * outputLength;
      int index = pos.floor();
      if (index < processed.length - 1) {
        double fraction = pos - index;
        result[i] = (processed[index] * (1 - fraction) + 
                    processed[index + 1] * fraction).round();
      }
    }
    
    return Uint8List.view(result.buffer);
  }

  static Uint8List _applyWhisperEffect(Uint8List audioData) {
    final samples = Int16List.view(audioData.buffer);
    final processed = Int16List(samples.length);
    
    for (int i = 0; i < samples.length; i++) {
      // Reduce amplitude and add subtle noise
      int sample = (samples[i] * 0.3 * _effectIntensity).round();
      
      // Add whisper-like noise
      int noise = (((i * 17) % 127) - 64) * 10;
      sample += noise;
      
      processed[i] = sample.clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applyDemonEffect(Uint8List audioData) {
    // Combine pitch shifting with distortion
    Uint8List lowPitch = _applyPitchShift(audioData, 0.4);
    final samples = Int16List.view(lowPitch.buffer);
    final processed = Int16List(samples.length);
    
    for (int i = 0; i < samples.length; i++) {
      int sample = samples[i];
      
      // Add distortion
      if (sample.abs() > 16384) {
        sample = sample > 0 ? 32767 : -32768;
      }
      
      processed[i] = (sample * _effectIntensity).round().clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applySpaceyEffect(Uint8List audioData) {
    // Combine reverb with chorus-like effect
    Uint8List reverbData = _applyReverbEffect(audioData);
    final samples = Int16List.view(reverbData.buffer);
    final processed = Int16List(samples.length);
    
    for (int i = 0; i < samples.length; i++) {
      double sample = samples[i].toDouble();
      
      // Add chorus effect with sine wave modulation
      double modulation = 0.1 * math.sin(2 * math.pi * i / 1000) * _effectIntensity;
      int delayedIndex = (i - (100 + modulation * 50)).round();
      
      if (delayedIndex >= 0 && delayedIndex < samples.length) {
        sample += samples[delayedIndex] * 0.3;
      }
      
      processed[i] = sample.round().clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  static Uint8List _applyVintageEffect(Uint8List audioData) {
    final samples = Int16List.view(audioData.buffer);
    final processed = Int16List(samples.length);
    
    for (int i = 0; i < samples.length; i++) {
      int sample = samples[i];
      
      // Simulate vintage compression and warmth
      double normalizedSample = sample / 32768.0;
      
      // Soft clipping for warmth
      if (normalizedSample.abs() > 0.7) {
        normalizedSample = normalizedSample > 0 ? 
            0.7 + 0.3 * _tanh((normalizedSample - 0.7) * 3) :
            -0.7 - 0.3 * _tanh((-normalizedSample - 0.7) * 3);
      }
      
      // Add subtle high-frequency roll-off
      if (i > 0) {
        normalizedSample = 0.8 * normalizedSample + 0.2 * processed[i-1] / 32768.0;
      }
      
      processed[i] = (normalizedSample * 32768 * _effectIntensity).round()
          .clamp(-32768, 32767);
    }
    
    return Uint8List.view(processed.buffer);
  }

  /// Get sound effect file path
  static String _getSoundEffectPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.applause:
        return 'assets/sounds/applause.mp3';
      case SoundEffect.laugh:
        return 'assets/sounds/laugh.mp3';
      case SoundEffect.drumRoll:
        return 'assets/sounds/drumroll.mp3';
      case SoundEffect.airhorn:
        return 'assets/sounds/airhorn.mp3';
      case SoundEffect.ninja:
        return 'assets/sounds/ninja.mp3';
      case SoundEffect.sword:
        return 'assets/sounds/sword.mp3';
      case SoundEffect.magic:
        return 'assets/sounds/magic.mp3';
      case SoundEffect.explosion:
        return 'assets/sounds/explosion.mp3';
      case SoundEffect.notification:
        return 'assets/sounds/notification.mp3';
      case SoundEffect.success:
        return 'assets/sounds/success.mp3';
      case SoundEffect.fail:
        return 'assets/sounds/fail.mp3';
      case SoundEffect.pop:
        return 'assets/sounds/pop.mp3';
      default:
        return 'assets/sounds/pop.mp3';
    }
  }

  /// Get voice effect display name
  static String getVoiceEffectName(VoiceEffect effect) {
    switch (effect) {
      case VoiceEffect.none:
        return 'Normal';
      case VoiceEffect.robot:
        return 'Robot';
      case VoiceEffect.echo:
        return 'Echo';
      case VoiceEffect.reverb:
        return 'Reverb';
      case VoiceEffect.pitchHigh:
        return 'High Pitch';
      case VoiceEffect.pitchLow:
        return 'Low Pitch';
      case VoiceEffect.whisper:
        return 'Whisper';
      case VoiceEffect.demon:
        return 'Demon';
      case VoiceEffect.chipmunk:
        return 'Chipmunk';
      case VoiceEffect.deepVoice:
        return 'Deep Voice';
      case VoiceEffect.spacey:
        return 'Spacey';
      case VoiceEffect.vintage:
        return 'Vintage';
    }
  }

  /// Get sound effect display name
  static String getSoundEffectName(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.applause:
        return 'Applause';
      case SoundEffect.laugh:
        return 'Laugh';
      case SoundEffect.drumRoll:
        return 'Drum Roll';
      case SoundEffect.airhorn:
        return 'Air Horn';
      case SoundEffect.ninja:
        return 'Ninja';
      case SoundEffect.sword:
        return 'Sword';
      case SoundEffect.magic:
        return 'Magic';
      case SoundEffect.explosion:
        return 'Explosion';
      case SoundEffect.notification:
        return 'Notification';
      case SoundEffect.success:
        return 'Success';
      case SoundEffect.fail:
        return 'Fail';
      case SoundEffect.pop:
        return 'Pop';
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    if (_player != null) {
      await _player!.closePlayer();
      _player = null;
    }
    _isInitialized = false;
  }
}

