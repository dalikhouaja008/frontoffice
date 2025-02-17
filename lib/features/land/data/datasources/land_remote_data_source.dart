import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/land.dart';
import '../models/land_model.dart';

class LandRemoteDataSource {
  final GraphQLClient client;

  LandRemoteDataSource(this.client);

  Future<Land> addLandWithFiles({
    required String name,
    required String location,
    required int size,
    required List<MultipartFile> photos,
    required List<MultipartFile> documents,
  }) async {
    const String mutation = r'''
      mutation CreateLand($name: String!, $location: String!, $size: Int!, $photos: [Upload!], $documents: [Upload!]) {
        createLand(name: $name, location: $location, size: $size, photos: $photos, documents: $documents) {
          id
          name
          location
          size
          photos
          documents
          owner
        }
      }
    ''';

    final options = MutationOptions(
      document: gql(mutation),
      variables: {
        'name': name,
        'location': location,
        'size': size,
        'photos': photos,
        'documents': documents,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['createLand'];
    return LandModel.fromJson(data);  // Return Land object
  }

  Future<List<Land>> getAllLands() async {
    const String query = r'''
      query {
        getAllLands {
          id
          name
          location
          size
          photos
          documents
          owner
        }
      }
    ''';

    final options = QueryOptions(document: gql(query));

    final result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final lands = (result.data?['getAllLands'] as List)
        .map((json) => LandModel.fromJson(json))
        .toList();

    return lands;
  }
}
