import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shazam/services/models/deezer_song_model.dart';
import 'package:shazam/services/song_service.dart';
import 'package:shazam/services/song_history_service.dart';

final homeViewModel = ChangeNotifierProvider<HomeViewModel>((ref) {
  return HomeViewModel();
});

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    initAcr();
  }
  final AcrCloudSdk acr = AcrCloudSdk();
  final songService = SongService();
  final songHistoryService = SongHistoryService();
  DeezerSongModel? currentSong;
  bool isRecognizing = false;
  bool success = false;
  String? errorMessage;

  Future<void> initAcr() async {
    try {
      print('Initializing ACRCloud with verified credentials...');
      print('Project ID: 67340');
      print('Service Type: Audio Fingerprinting');
      acr
        ..init(
          host: 'identify-ap-southeast-1.acrcloud.com', // Asia Pacific region
          accessKey: '860a77d57dc17b7ecdcad03021b857ee',
          accessSecret: '330vo6H4gcDfxRDDarKaicr2mjho6FkT6qJB7c6y',
          setLog: true,
          requestTimeout: const Duration(seconds: 30),
          recorderConfigRate: 44100,
          recorderConfigChannels: 2,
          isVolumeCallback: true,
        )
        ..songModelStream.listen(searchSong);
      print('ACRCloud initialized successfully with project ID: 67340');
    } catch (e) {
      print('ACR Cloud initialization error: ${e.toString()}');
    }
  }

  void searchSong(SongModel? song) async {
    // Reset error message
    errorMessage = null;

    print('Received song data: $song');
    if (song == null) {
      errorMessage = 'No song detected. Please try again.';
      print('Error: Received null song data');
      stopRecording();
      return;
    }

    try {
      final metaData = song.metadata;
      if (metaData == null) {
        errorMessage = 'Song detected but no metadata found. Please try again.';
        print('Error: No metadata found in response');
        stopRecording();
        return;
      }

      print('Metadata received: ${metaData.toString()}');

      // Check if music data exists
      if (metaData.music == null || metaData.music!.isEmpty) {
        errorMessage =
            'Song detected but not recognized. Please try again with a more popular song.';
        print('Error: No music matches found or music data is null');
        stopRecording();
        return;
      }

      print('Music data found: ${metaData.music?.length} items');
      final music = metaData.music![0];
      print(
          'Song details: ${music.title} by ${music.artists?.firstOrNull?.name}');

      // For some songs, Deezer metadata might not be available
      // Try to extract basic info even without Deezer data
      if (music.externalMetadata?.deezer == null) {
        print(
            'Warning: No Deezer metadata found, attempting to use basic information');

        // Check if we can create a minimal song model from the basic metadata
        if (music.title != null &&
            music.artists != null &&
            music.artists!.isNotEmpty) {
          try {
            // Try to search for the song using the title and artist instead
            final searchResult = await songService
                .searchTrack('${music.title} ${music.artists!.first.name}');

            if (searchResult != null) {
              // Save song to history
              await songHistoryService.addSongToHistory(searchResult);

              currentSong = searchResult;
              success = true;
              notifyListeners();
              print(
                  'Song found through search: ${searchResult.title} by ${searchResult.artist?.name}');
              return;
            }
          } catch (e) {
            print('Error searching for track: $e');
          }
        }

        errorMessage = 'Song recognized but no detailed information available.';
        stopRecording();
        return;
      }

      final trackId = music.externalMetadata?.deezer?.track?.id;
      print('Deezer track ID: $trackId');

      if (trackId == null) {
        errorMessage = 'Song recognized but track ID not found.';
        print('Error: No Deezer track ID found');
        stopRecording();
        return;
      }

      try {
        final res = await songService.getTrack(trackId);

        // Save song to history
        await songHistoryService.addSongToHistory(res);

        currentSong = res;
        success = true;
        notifyListeners();
        print('Song found: ${res.title} by ${res.artist?.name}');
      } catch (e) {
        errorMessage =
            'Error fetching song details. Please check your connection.';
        print('Error getting track details: $e');
        stopRecording();
      }
    } catch (e) {
      errorMessage = 'Unexpected error during song recognition.';
      print('Exception in searchSong: $e');
      stopRecording();
    }
  }

  void startRecognizing() {
    isRecognizing = true;
    success = false;
    errorMessage = null;
    notifyListeners();
    acr.start();
  }

  void stopRecognizing() {
    acr.stop();
    stopRecording();
  }

  void stopRecording() {
    isRecognizing = false;
    success = false;
    notifyListeners();
  }
}
