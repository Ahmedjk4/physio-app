import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

Future<Duration?> getAudioDuration(String audioUrl) async {
  final player = AudioPlayer();
  try {
    // Load audio from a URL with timeout
    await player
        .setUrl(
      audioUrl,
      preload: true,
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint("Timeout fetching audio duration for: $audioUrl");
        return null;
      },
    );

    // Wait a bit for duration to be available
    final duration = player.duration;
    if (duration != null) {
      debugPrint("Audio duration fetched: $duration");
      return duration;
    }

    // If duration is null, wait a bit and try again
    await Future.delayed(const Duration(milliseconds: 500));
    final retryDuration = player.duration;
    debugPrint("Audio duration after retry: $retryDuration");
    return retryDuration;
  } catch (e) {
    debugPrint("Error fetching audio duration: $e");
    return null;
  } finally {
    await player.dispose();
  }
}
