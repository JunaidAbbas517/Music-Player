import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../view_model/music_player_view_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();
    _fetchAndPlaySongs();
  }

  Future<void> _fetchAndPlaySongs() async {
    final musicPlayerState =
        Provider.of<MusicPlayerAppViewModel>(context, listen: false);

    await musicPlayerState.fetchSongs();
    musicPlayerState.playNextSong();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Consumer<MusicPlayerAppViewModel>(
        builder: (context, musicPlayerState, child) {
          final player = musicPlayerState.player;
          bool isPlaying = musicPlayerState.isPlaying;
          Duration duration = musicPlayerState.duration;

          void togglePlayPause() {
            musicPlayerState.togglePlayPause();
          }

          void playPreviousSong() {
            musicPlayerState.playPreviousSong();
          }

          void playNextSong() {
            musicPlayerState.playNextSong();
          }

          if (musicPlayerState.isLoadingSongs) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (musicPlayerState.songs.isEmpty) {
            return Center(
              child: Text('No songs available',
                  style: GoogleFonts.mulish(
                      fontSize: 0.04 * screenWidth, color: Colors.black)),
            );
          }

          return Padding(
            padding: EdgeInsets.all(0.04 * screenWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  musicPlayerState.songs[musicPlayerState.currentIndex].title,
                  style: GoogleFonts.mulish(
                    fontSize: 0.05 * screenWidth,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 0.015 * screenHeight,
                ),
                Text(
                  musicPlayerState.songs[musicPlayerState.currentIndex].artist,
                  style: GoogleFonts.mulish(
                    fontSize: 0.04 * screenWidth,
                  ),
                ),
                SizedBox(
                  height: 0.025 * screenHeight,
                ),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await player.seek(position);
                      },
                    );
                  },
                ),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.06 * screenWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(musicPlayerState.formatTime(position),
                              style: GoogleFonts.mulish(
                                  fontSize: 0.035 * screenWidth)),
                          Text(musicPlayerState.formatTime(duration - position),
                              style: GoogleFonts.mulish(
                                  fontSize: 0.035 * screenWidth)),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 0.06 * screenHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      iconSize: 0.1 * screenWidth,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: playPreviousSong,
                    ),
                    CircleAvatar(
                      radius: 0.15 * screenWidth,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        iconSize: 0.08 * screenWidth,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: togglePlayPause,
                      ),
                    ),
                    IconButton(
                      iconSize: 0.1 * screenWidth,
                      icon: const Icon(Icons.skip_next),
                      onPressed: playNextSong,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
