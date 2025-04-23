import 'package:dio/dio.dart';
import 'package:shazam/services/models/deezer_song_model.dart';

class SongService {
  late Dio _dio;

  SongService() {
    BaseOptions options = BaseOptions(
        receiveTimeout: const Duration(milliseconds: 100000),
        connectTimeout: const Duration(milliseconds: 100000),
        baseUrl: 'https://api.deezer.com/');
    _dio = Dio(options);
  }

  Future<DeezerSongModel> getTrack(String id) async {
    try {
      final response = await _dio.get('track/$id',
          options: Options(headers: {
            'Content-type': 'application/json;charset=UTF-8',
            'Accept': 'application/json;charset=UTF-8',
          }));
      DeezerSongModel result = DeezerSongModel.fromJson(response.data);
      return result;
    } catch (e) {
      if (e is DioException) {
        throw 'An error has occurred';
      } else {
        print(e);
        throw e.toString();
      }
    }
  }

  Future<DeezerSongModel?> searchTrack(String query) async {
    try {
      final response = await _dio.get('search',
          queryParameters: {'q': query, 'limit': 1},
          options: Options(headers: {
            'Content-type': 'application/json;charset=UTF-8',
            'Accept': 'application/json;charset=UTF-8',
          }));

      final data = response.data;
      if (data != null && data['data'] != null && data['data'].isNotEmpty) {
        // Get the first track from search results
        final trackData = data['data'][0];
        // Fetch complete track details using the track ID
        return await getTrack(trackData['id'].toString());
      }
      return null;
    } catch (e) {
      print('Error searching for track: $e');
      return null;
    }
  }
}
