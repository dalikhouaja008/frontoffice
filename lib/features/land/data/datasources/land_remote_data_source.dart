import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/error/exceptions.dart';
import 'package:the_boost/features/land/data/models/land_model.dart';

abstract class LandRemoteDataSource {
  Future<List<LandModel>> getMyLands();
}

class LandRemoteDataSourceImpl implements LandRemoteDataSource {
  final GraphQLClient client;

  LandRemoteDataSourceImpl({required this.client});

  @override
  Future<List<LandModel>> getMyLands() async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql('''
            query GetMyLands {
              myLands {
                id
                title
                description
                location
                surface
                totalTokens
                pricePerToken
                ownerId
                ownerAddress
                status
                landtype
                ipfsCIDs
                imageCIDs
                blockchainTxHash
                blockchainLandId
                validations
                amenities
                isTokenized
                availableTokens
                tokenIds
                tokenizationAttempts
                createdAt
                updatedAt
                blockchainDetails {
                  isTokenized
                  status
                  availableTokens
                  pricePerToken
                  cid
                }
                validationProgress {
                  totalValidations
                  completedValidations
                  percentage
                  validationStatuses {
                    role
                    validated
                  }
                }
              }
            }
          '''),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception!.graphqlErrors.first.message);
      }

      final List<dynamic> landsData = result.data!['myLands'];
      return landsData.map((land) => LandModel.fromJson(land)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
