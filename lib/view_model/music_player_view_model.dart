import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song_model.dart';

class MusicPlayerAppViewModel with ChangeNotifier {
  List<Song> _songs = [];
  int _currentIndex = 0;
  final _player = AudioPlayer();
  final Duration _position = Duration.zero;
  bool _isLoadingSongs = true;

  bool get isLoadingSongs => _isLoadingSongs;
  Duration get positions => _position;
  List<Song> get songs => _songs;
  int get currentIndex => _currentIndex;
  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;
  Duration get duration => _player.duration ?? Duration.zero;
  Duration get position => _player.position;

  Future<void> fetchSongs() async {
    final DatabaseReference songsRef =
        FirebaseDatabase.instance.ref().child('songs');
    try {
      final DatabaseEvent event = await songsRef.once();
      final DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      List<Song> songs = data.entries.map((entry) {
        Map<dynamic, dynamic> songData = entry.value;
        String artist = songData['artist'];
        String title = songData['title'];
        String audioUrl = songData['audioUrl'];
        return Song(artist, title, audioUrl);
      }).toList();

      _songs = songs;

      _currentIndex = _currentIndex.clamp(0, _songs.length - 1);

      _isLoadingSongs = false;
      notifyListeners();
    } catch (error) {
      print('Error fetching songs: $error');
      _isLoadingSongs = false;
      notifyListeners();
    }
  }

  Future<void> playPreviousSong() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playSong(_songs[_currentIndex].audioUrl);
    }
    notifyListeners();
  }

  Future<void> playNextSong() async {
    if (_currentIndex < _songs.length - 1) {
      _currentIndex++;
      await _playSong(_songs[_currentIndex].audioUrl);
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
    notifyListeners();
  }

  Future<void> _playSong(String audioUrl) async {
    if (audioUrl.startsWith('gs://')) {
      final ref =
          firebase_storage.FirebaseStorage.instance.refFromURL(audioUrl);
      try {
        audioUrl = await ref.getDownloadURL();
      } catch (error) {
        print('Error getting download URL: $error');
        return;
      }
    }

    await _player.setUrl(audioUrl);
    await _player.play();
    notifyListeners();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
