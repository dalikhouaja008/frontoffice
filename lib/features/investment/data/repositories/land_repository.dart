import 'package:dio/dio.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/interceptors/api_interceptor.dart';

class LandRepository {
  late final Dio _dio;

  LandRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: ApiConfig.defaultHeaders,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
      ),
    )..interceptors.add(ApiInterceptor());
  }

  Future<List<Land>> fetchLands() async {
    try {
      final response = await _dio.get(
        ApiConfig.landsEndpoint,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => Land.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map && response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((json) => Land.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Format de données invalide');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } on DioError catch (e) {
      String message;
      switch (e.type) {
        case DioErrorType.connectTimeout:
          message = 'Délai de connexion dépassé. Veuillez réessayer.';
          break;
        case DioErrorType.receiveTimeout:
          message = 'Délai de réception dépassé. Veuillez réessayer.';
          break;
        case DioErrorType.sendTimeout:
          message = 'Délai d\'envoi dépassé. Veuillez réessayer.';
          break;
        case DioErrorType.other:
          message = 'Erreur de connexion. Vérifiez votre connexion internet.';
          break;
        case DioErrorType.response:
          message = _handleResponseError(e.response?.statusCode);
          break;
        default:
          message = 'Erreur lors du chargement des terrains: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Une erreur inattendue s\'est produite: $e');
    }
  }

  String _handleResponseError(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Non autorisé. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé.';
      case 404:
        return 'Ressource non trouvée.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      default:
        return 'Erreur ${statusCode ?? "inconnue"}';
    }
  }

  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get(ApiConfig.healthEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Land> fetchLandById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.landsEndpoint}/$id');
      
      if (response.statusCode == 200) {
        return Land.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération du terrain');
      }
    } on DioError catch (e) {
      throw Exception(_handleResponseError(e.response?.statusCode));
    }
  }
}