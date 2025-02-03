import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Future<Duration?> getAudioDuration(String audioUrl) async {
  final player = AudioPlayer();
  try {
    // Load audio from a URL
    await player.setUrl(audioUrl);
    return player.duration;
  } catch (e) {
    debugPrint("Error fetching audio duration: $e");
    return null;
  } finally {
    player.dispose();
  }
}
