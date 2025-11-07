import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Проверка фактического доступа к интернету
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return false;

      // Делаем лёгкий GET запрос
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get connectivityStream async* {
    await for (final result in _connectivity.onConnectivityChanged) {
      if (result == ConnectivityResult.none) {
        yield false;
      } else {
        try {
          final response = await http.get(Uri.parse('https://www.google.com'))
              .timeout(const Duration(seconds: 3));
          yield response.statusCode == 200;
        } catch (_) {
          yield false;
        }
      }
    }
  }
}