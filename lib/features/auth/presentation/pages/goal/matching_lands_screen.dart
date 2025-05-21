import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';

class MatchingLandsScreen extends StatefulWidget {
  const MatchingLandsScreen({super.key});

  @override
  State<MatchingLandsScreen> createState() => _MatchingLandsScreenState();
}

class _MatchingLandsScreenState extends State<MatchingLandsScreen> {
  late Future<GraphQLClient> _clientFuture;

  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  Map<String, dynamic> _criteria = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _clientFuture = _createAuthenticatedClient();
  }

  Future<GraphQLClient> _createAuthenticatedClient() async {
    final storage = SecureStorageService();
    final token = await storage.getAccessToken();
    return GraphQLService.getClientWithToken(token ?? '');
  }

  void _submitSearch() {
    setState(() {
      _submitted = true;
      _criteria = {
        if (_governorateController.text.isNotEmpty) 'governorate': _governorateController.text,
        if (_propertyTypeController.text.isNotEmpty) 'propertyType': _propertyTypeController.text,
        if (_minPriceController.text.isNotEmpty) 'minPrice': double.tryParse(_minPriceController.text),
        if (_maxPriceController.text.isNotEmpty) 'maxPrice': double.tryParse(_maxPriceController.text),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    const String searchLandsQuery = """
      query SearchLands(\$criteria: SearchLandsInput!) {
        searchLands(criteria: \$criteria) {
          _id
          description
          price
          address
          governorate
          areaInSqMeters
          propertyType
          zoning
        }
      }
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Matching Lands'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: FutureBuilder<GraphQLClient>(
        future: _clientFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final client = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search for Land',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField('Governorate', _governorateController),
                const SizedBox(height: 12),
                _buildInputField('Property Type', _propertyTypeController),
                const SizedBox(height: 12),
                _buildInputField('Min Price', _minPriceController, isNumber: true),
                const SizedBox(height: 12),
                _buildInputField('Max Price', _maxPriceController, isNumber: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Find Lands'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_submitted)
                  Query(
                    options: QueryOptions(
                      document: gql(searchLandsQuery),
                      variables: {'criteria': _criteria},
                      fetchPolicy: FetchPolicy.networkOnly,
                    ),
                    builder: (result, {fetchMore, refetch}) {
                      if (result.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (result.hasException) {
                        return Center(child: Text('Error: ${result.exception.toString()}'));
                      }
                      final lands = result.data?['searchLands'] ?? [];
                      if (lands.isEmpty) {
                        return const Center(child: Text('No matching lands found.'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lands.length,
                        itemBuilder: (context, index) {
                          final land = lands[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                land['address'] ?? 'No Address',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Governorate: ${land['governorate'] ?? 'N/A'}'),
                                  Text('Price: ${land['price'] ?? 'N/A'} TND'),
                                  Text('Type: ${land['propertyType'] ?? 'N/A'}'),
                                  Text('Area: ${land['areaInSqMeters'] ?? 'N/A'} m²'),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // you can navigate to land detail page if you want
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.teal.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
