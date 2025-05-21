import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:http_parser/http_parser.dart' as http_parser;

import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/property/valuation_result.dart';
import 'package:the_boost/core/services/session_service.dart';

import '../../data/models/property/property.dart';

// Enhanced LandRegistrationService with better web support and error handling
class LandRegistrationService {
  // Base URLs for the two different backends
  final String registrationBaseUrl;
  final SessionService _sessionService = SessionService();

  // Constructor with configurable base URL
  LandRegistrationService({String? customBaseUrl})
      : registrationBaseUrl = customBaseUrl ?? 'http://localhost:5000';

  // API call to register land with files
  Future<Map<String, dynamic>> registerLand({
    required String title,
    String? description,
    required String location,
    required int surface,
    required int totalTokens,
    required String pricePerToken,
    required String status,
    required String landtype,
    required List<PlatformFile> documents,
    required List<PlatformFile> images,
    required Map<String, bool> amenities,
  }) async {
    try {
      print('====== REGISTER LAND REQUEST STARTED ======');

      // Get authentication tokens
      final sessionData = await _sessionService.getSession();
      if (sessionData == null) {
        print('❌ Authentication failed: No session data available');
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$registrationBaseUrl/lands');
      print('Request URI: $uri');

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add headers with proper content type for multipart
      request.headers.addAll({
        'Authorization': 'Bearer ${sessionData.accessToken}',
        'Accept': 'application/json',
        // Don't set Content-Type for multipart/form-data, it's automatically set
      });

      // Add fields
      request.fields['title'] = title;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      request.fields['location'] = location;
      request.fields['surface'] = surface.toString();
      request.fields['totalTokens'] = totalTokens.toString();
      request.fields['pricePerToken'] = pricePerToken;
      request.fields['status'] = status;
      request.fields['landtype'] = landtype;

      // Add amenities as individual fields
      amenities.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      print('Adding ${documents.length} documents to request');

      // Add document files
      for (var i = 0; i < documents.length; i++) {
        final document = documents[i];
        if (document.bytes != null) {
          final multipartFile = http.MultipartFile.fromBytes(
            'documents',
            document.bytes!,
            filename: document.name,
            contentType: http_parser.MediaType('application', 'octet-stream'),
          );
          request.files.add(multipartFile);
          print('Added document ${i + 1}: ${document.name}');
        }
      }

      print('Adding ${images.length} images to request');

      // Add image files
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        if (image.bytes != null) {
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            image.bytes!,
            filename: image.name,
            contentType: http_parser.MediaType('application', 'octet-stream'),
          );
          request.files.add(multipartFile);
          print('Added image ${i + 1}: ${image.name}');
        }
      }

      print('Sending request with ${request.files.length} files');

      // Send the request
      final streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          print('❌ Request timed out after 60 seconds');
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Log status code and response body
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Request successful (${response.statusCode})');
        final decodedResponse = jsonDecode(response.body);
        return decodedResponse;
      } else {
        print('❌ Request failed with status code ${response.statusCode}');
        throw Exception('Failed to register land: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in registerLand: $e');

      // Check if it's a ClientException with more details
      if (e is http.ClientException) {
        print('Client Exception details:');
        print('- Message: ${e.message}');
        print('- URI: ${e.uri}');
      }

      throw Exception('Error registering land: $e');
    } finally {
      print('====== REGISTER LAND REQUEST COMPLETED ======');
    }
  }
}

// API call to upload documents to IPFS

class RegisterLandPage extends StatefulWidget {
  const RegisterLandPage({Key? key}) : super(key: key);

  @override
  _RegisterLandPageState createState() => _RegisterLandPageState();
}

class _RegisterLandPageState extends State<RegisterLandPage> {
  // Controllers
  final _locationController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _totalTokensController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form fields data
  String? _selectedLandType;
  bool _isAcceptingPrice = false;
  List<PlatformFile> _documents = [];
  ValuationResult? _evaluationResult;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isEvaluating = false;
  bool _hasEvaluated = false;
List<PlatformFile> _images = [];
  int _currentStep = 0;
  Map<String, dynamic>? _ethPriceData;
  Position? _currentPosition;

  // Amenities
  Map<String, bool> _amenities = {
    'electricity': false,
    'gas': false,
    'water': false,
    'sewer': false,
    'headquarters': false,
    'internet': false,
    'geotechnicalSurvey': false,
    'soilAnalysis': false,
    'topographicalSurvey': false,
    'environmentalStudy': false,
    'roadAccess': false,
    'publicTransport': false,
    'pavedRoad': false,
    'buildingPermit': false,
    'zoned': false,
    'boundaryMarkers': false,
    'drainage': false,
    'floodRisk': false,
    'rainwaterCollection': false,
    'fenced': false,
    'securitySystem': false,
    'trees': false,
    'wellWater': false,
    'flatTerrain': false,
  };

  // Services
  late ApiService _apiService;
  final LandRegistrationService _registrationService =
      LandRegistrationService();

  // Constants
  final List<String> landTypes = [
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'AGRICULTURAL'
  ];

  // Map controller
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  // Step titles for the stepper
  final List<String> _steps = [
    'Basic Information',
    'Location & Details',
    'Amenities',
    'Documentation',
    'Evaluation',
    'Review & Submit'
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _totalTokensController.text = '100'; // Default to 100 tokens
    _determinePosition();
    _fetchEthPrice();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _surfaceController.dispose();
    _totalTokensController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch current ETH price data
  Future<void> _fetchEthPrice() async {
    try {
      final priceData = await _apiService.getEthPrice();
      if (mounted) {
        setState(() {
          _ethPriceData = priceData;
        });
      }
    } catch (e) {
      print('Error fetching ETH price: $e');
    }
  }

  // Get user's current position
  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _setMarker();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  // Update marker on map
  void _setMarker() {
    if (_selectedLocation == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: InfoWindow(title: 'Selected Land Location'),
        ),
      };
    });
  }

  // Update location when map is tapped
  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _setMarker();
    });

    // Attempt to get address from location
    _getAddressFromLatLng(location);
  }

  // Get address from latitude and longitude
  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      setState(() {
        _locationController.text =
            "Location at ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}";
      });
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  // Upload documents to IPFS

  // Evaluate land and get proposed price
  Future<void> _evaluateLand() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      _showSnackBar('Please fill all required fields and select a location',
          isError: true);
      return;
    }

    setState(() {
      _isEvaluating = true;
      _hasEvaluated = false;
    });

    try {
      // Call the land evaluator API
      final result = await _apiService.estimateLandValue(
        position: _selectedLocation!,
        area: double.parse(_surfaceController.text),
        zoning: _selectedLandType?.toLowerCase() ?? 'residential',
        nearWater: _amenities['wellWater'] ?? false,
        roadAccess: _amenities['roadAccess'] ?? true,
        utilities: (_amenities['electricity'] ?? false) &&
            (_amenities['water'] ?? false),
      );

      if (mounted) {
        setState(() {
          _evaluationResult = result;
          _isEvaluating = false;
          _hasEvaluated = true;
        });
      }

      _showSnackBar('Land evaluation completed successfully');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEvaluating = false;
        });
        _showSnackBar('Error evaluating land: $e', isError: true);

        // Fallback to simulation in case of API errors
        _simulateEvaluation();
      }
    }
  }

  // Fallback evaluation simulation
  void _simulateEvaluation() {
    if (!_formKey.currentState!.validate()) return;

    double surfaceArea = double.parse(_surfaceController.text);
    double basePrice = 0.0001; // Base price in ETH per square meter

    // Apply price modifiers based on land type
    double typeMultiplier = 1.0;
    switch (_selectedLandType) {
      case 'RESIDENTIAL':
        typeMultiplier = 1.5;
        break;
      case 'COMMERCIAL':
        typeMultiplier = 2.0;
        break;
      case 'INDUSTRIAL':
        typeMultiplier = 1.8;
        break;
      case 'AGRICULTURAL':
        typeMultiplier = 1.0;
        break;
    }

    // Apply amenities modifier
    double amenitiesMultiplier = 1.0;
    _amenities.forEach((key, value) {
      if (value) amenitiesMultiplier += 0.02; // 2% increase per amenity
    });

    // Create simulated ValuationResult
    final estimatedValue =
        (surfaceArea * basePrice * typeMultiplier * amenitiesMultiplier * 3000)
            .round(); // Convert to TND
    final estimatedValueEth =
        surfaceArea * basePrice * typeMultiplier * amenitiesMultiplier;

    // Create location info
    final locationInfo = LocationInfo(
      position:
          _selectedLocation ?? LatLng(36.8065, 10.1815), // Default to Tunis
      address: _locationController.text,
    );

    // Create valuation info
    final valuationInfo = ValuationInfo(
      estimatedValue: estimatedValue,
      estimatedValueETH: estimatedValueEth,
      areaInSqFt: surfaceArea,
      avgPricePerSqFt: estimatedValue / surfaceArea,
      avgPricePerSqFtETH: estimatedValueEth / surfaceArea,
      zoning: _selectedLandType?.toLowerCase() ?? 'residential',
      valuationFactors: [
        ValuationFactor(
          factor: 'Land Type',
          adjustment: '${(typeMultiplier * 100 - 100).toStringAsFixed(0)}%',
        ),
        ValuationFactor(
          factor: 'Amenities',
          adjustment:
              '${((amenitiesMultiplier - 1) * 100).toStringAsFixed(0)}%',
        ),
      ],
      currentEthPriceTND: _ethPriceData?['ethPriceTND'] ?? 3000,
    );

    // Create comparable properties
    final comparables = [
      ComparableProperty(
        id: 'comp1',
        address: 'Nearby Property 1',
        price: estimatedValue * 0.85,
        priceInETH: estimatedValueEth * 0.85,
        area: surfaceArea * 0.9,
        pricePerSqFt: (estimatedValue * 0.85) / (surfaceArea * 0.9),
        pricePerSqFtETH: (estimatedValueEth * 0.85) / (surfaceArea * 0.9),
        features: PropertyFeatures(
          nearWater: _amenities['wellWater'] ?? false,
          roadAccess: _amenities['roadAccess'] ?? true,
          utilities: (_amenities['electricity'] ?? false) &&
              (_amenities['water'] ?? false),
        ),
      ),
      ComparableProperty(
        id: 'comp2',
        address: 'Nearby Property 2',
        price: estimatedValue * 1.1,
        priceInETH: estimatedValueEth * 1.1,
        area: surfaceArea * 1.1,
        pricePerSqFt: (estimatedValue * 1.1) / (surfaceArea * 1.1),
        pricePerSqFtETH: (estimatedValueEth * 1.1) / (surfaceArea * 1.1),
        features: PropertyFeatures(
          nearWater: _amenities['wellWater'] ?? false,
          roadAccess: _amenities['roadAccess'] ?? true,
          utilities: (_amenities['electricity'] ?? false) &&
              (_amenities['water'] ?? false),
        ),
      ),
    ];

    // Create the full valuation result
    final valuationResult = ValuationResult(
      location: locationInfo,
      valuation: valuationInfo,
      comparables: comparables,
    );

    setState(() {
      _evaluationResult = valuationResult;
      _hasEvaluated = true;
    });

    _showSnackBar('Using simulated evaluation (API unavailable)',
        isError: false);
  }

  bool isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'tiff']
        .contains(extension);
  }

  // Submit land registration
  // Submit land registration
  Future<void> _submitRegistration() async {
    print('====== SUBMIT REGISTRATION STARTED ======');

    if (!_hasEvaluated || !_isAcceptingPrice) {
      print('❌ Validation failed: Price not evaluated or accepted');
      _showSnackBar('Please evaluate and accept the price first',
          isError: true);
      return;
    }

    if (_formKey.currentState?.validate() != true) {
      print('❌ Form validation failed');
      _showSnackBar('Please complete all required fields', isError: true);
      return;
    }

    if (_documents.isEmpty) {
      print('❌ No documents uploaded');
      _showSnackBar('Please upload required documents', isError: true);
      return;
    }

    print('✅ Pre-submission validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      // Get price per token from evaluation result
      final pricePerToken =
          _evaluationResult!.valuation.estimatedValueETH != null
              ? _evaluationResult!.valuation.estimatedValueETH! /
                  double.parse(_totalTokensController.text)
              : _evaluationResult!.valuation.estimatedValue /
                  double.parse(_totalTokensController.text) /
                  3000;

      // Register land with files directly
      final result = await _registrationService.registerLand(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        location: _locationController.text,
        surface: int.parse(_surfaceController.text),
        totalTokens: int.parse(_totalTokensController.text),
        pricePerToken: pricePerToken.toString(),
        status: 'pending_validation',
        landtype: _selectedLandType!.toLowerCase(),
        documents: _documents,
        images: _images, // Passez les images séparément ici
        amenities: _amenities,
      );

      print('✅ Registration completed successfully');
      print('Land ID: ${result['landId'] ?? 'Unknown'}');

      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      _showSuccessDialog(result['landId'] ?? 'Unknown');
    } catch (e) {
      print('❌ Registration failed: $e');

      setState(() {
        _isLoading = false;
      });

      // Handle errors
      if (kIsWeb && e.toString().contains('CORS issue')) {
        print('Detected CORS issue in web environment');
        _showCorsErrorDialog();
      } else {
        _showSnackBar('Error registering land: $e', isError: true);
      }
    } finally {
      print('====== SUBMIT REGISTRATION COMPLETED ======');
    }
  }

  // Enhanced CORS error dialog with more detailed information
  void _showCorsErrorDialog() {
    print('Showing detailed CORS error dialog');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('CORS Configuration Issue'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your browser blocked the request to the backend server due to CORS (Cross-Origin Resource Sharing) policy.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Technical details:'),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    '• Frontend origin: ${Uri.base.origin}\n• Backend URL: ${_registrationService.registrationBaseUrl}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                SizedBox(height: 20),
                Text('To fix this issue:'),
                SizedBox(height: 8),
                _buildCorsFixItem(
                    '1. Ensure your NestJS backend has CORS properly enabled:'),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'app.enableCors({\n  origin: ["${Uri.base.origin}", "*"],\n  methods: "GET,PUT,POST,DELETE,OPTIONS",\n  allowedHeaders: ["Content-Type", "Authorization", "Accept"],\n  credentials: true\n});',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                _buildCorsFixItem(
                    '2. Make sure the server responds to OPTIONS preflight requests'),
                SizedBox(height: 12),
                _buildCorsFixItem(
                    '3. For development, try running Chrome with web security disabled:'),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'chrome --disable-web-security --user-data-dir="[temp-directory]"',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                _buildCorsFixItem(
                    '4. Check the browser console for detailed errors:'),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Press F12 > Console tab > Look for red error messages',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Simulated success for testing
                Navigator.of(context).pop();
                _showSuccessDialog(
                    'test-land-${DateTime.now().millisecondsSinceEpoch}');
              },
              child: Text('Simulate Success (For Testing)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorsFixItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'pdf',
        'png',
        'doc',
        'docx',
        'tiff',
        'bmp'
      ],
      allowMultiple: true, // Permettre la sélection de plusieurs fichiers
    );

    if (result != null) {
      // Séparez les fichiers en images et documents selon leur extension
      List<PlatformFile> images = [];
      List<PlatformFile> documents = [];

      for (var file in result.files) {
        if (isImageFile(file.name)) {
          images.add(file);
        } else {
          documents.add(file);
        }
      }

      setState(() {
        // Si vous avez séparé les listes dans votre état
        if (images.isNotEmpty) {
          print('Ajout de ${images.length} images');
        }

        if (documents.isNotEmpty) {
          print('Ajout de ${documents.length} documents');
        }

        // Mettre à jour vos listes d'images et de documents
        _documents.addAll(documents); // Documents non-images
        _images.addAll(images); // Images uniquement
      });
    }
  }

  // Utility function to show snackbars
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // Show success dialog after registration
  void _showSuccessDialog(String landId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(32),
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: Colors.green[700], size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registration Successful',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your land has been successfully registered for tokenization!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.key, color: Colors.blue[700], size: 24),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Land ID',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            landId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/my-lands');
                    },
                    child: const Text('Go to my lands'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Register Another Land'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reset form for new submission
  void _resetForm() {
    setState(() {
      _locationController.clear();
      _titleController.clear();
      _descriptionController.clear();
      _surfaceController.clear();
      _totalTokensController.text = '100'; // Default value
      _selectedLandType = null;
      _isAcceptingPrice = false;
      _documents = [];
      _evaluationResult = null;
      _hasEvaluated = false;
      _currentStep = 0;
      _amenities = _amenities.map((key, value) => MapEntry(key, false));
    });
  }

  // Helper widget for info rows in dialogs
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppNavBar(
          currentRoute: '/register-land',
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Text(
                    'Land Registration',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tokenize your property and unlock its digital value',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: _buildStepIndicator(),
                    ),
                    Divider(height: 1),
                    Container(
                      padding: EdgeInsets.all(32),
                      child: _isLoading
                          ? _buildLoadingIndicator()
                          : Form(
                              key: _formKey,
                              child: _buildCurrentStepContent(),
                            ),
                    ),
                    Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: _buildNavigationButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step indicator at top of form
  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(_steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              return Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: stepIndex < _currentStep
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8)
                            ],
                          )
                        : null,
                    color: stepIndex < _currentStep ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            } else {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < _currentStep;
              final isActive = stepIndex == _currentStep;

              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCompleted || isActive
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8)
                          ],
                        )
                      : null,
                  color: isCompleted || isActive ? null : Colors.grey[200],
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 20, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }
          }),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_steps.length, (index) {
            return Expanded(
              child: Text(
                _steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: index == _currentStep
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: index == _currentStep
                      ? AppColors.primary
                      : Colors.grey[600],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Build content for current step
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildAmenitiesStep();
      case 3:
        return _buildDocumentationStep();
      case 4:
        return _buildEvaluationStep();
      case 5:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  // Step 1: Basic Information
  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Land Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Enter the basic details about your land property',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Property Title',
            hintText: 'Enter a descriptive title for your property',
            prefixIcon: Icon(Icons.title, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a property title';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Property Description (Optional)',
            hintText: 'Enter a detailed description of your property',
            prefixIcon: Icon(Icons.description, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        SizedBox(height: 24),

        // Land type dropdown
        DropdownButtonFormField<String>(
          value: _selectedLandType,
          decoration: InputDecoration(
            labelText: 'Land Type',
            hintText: 'Select the type of land',
            prefixIcon: Icon(Icons.category, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: landTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type.capitalize()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLandType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a land type';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Surface area field
        TextFormField(
          controller: _surfaceController,
          decoration: InputDecoration(
            labelText: 'Surface Area (sq meters)',
            hintText: 'Enter the total surface area in square meters',
            prefixIcon: Icon(Icons.square_foot, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the surface area';
            }
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return 'Please enter a valid surface area';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Step 2: Location Information
  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Provide the location details of your land',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Location field
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location Address',
            hintText: 'Enter the full address of your property',
            prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location address';
            }
            return null;
          },
        ),
        SizedBox(height: 32),

        // Real interactive Google Maps
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ??
                        LatLng(36.8065, 10.1815), // Default to Tunis
                    zoom: 14,
                  ),
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLocation != null
                                    ? 'Location Selected'
                                    : 'Select Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _selectedLocation != null
                                    ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                                    : 'Tap on the map to select your land location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedLocation != null)
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedLocation = null;
                                _markers = {};
                              });
                            },
                            tooltip: 'Reset selection',
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Map location note
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select the exact location of your land on the map by clicking on it. You can zoom in for better precision.',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Amenities
  Widget _buildAmenitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Amenities',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Select the amenities and features available on your property',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Basic Utilities
        _buildAmenitySection(
          'Basic Utilities',
          Icons.power,
          [
            'electricity',
            'gas',
            'water',
            'sewer',
            'internet',
          ],
        ),
        SizedBox(height: 24),

        // Studies & Surveys
        _buildAmenitySection(
          'Studies & Surveys',
          Icons.assignment,
          [
            'geotechnicalSurvey',
            'soilAnalysis',
            'topographicalSurvey',
            'environmentalStudy',
          ],
        ),
        SizedBox(height: 24),

        // Access & Transportation
        _buildAmenitySection(
          'Access & Transportation',
          Icons.directions_car,
          [
            'roadAccess',
            'publicTransport',
            'pavedRoad',
          ],
        ),
        SizedBox(height: 24),

        // Legal & Administrative
        _buildAmenitySection(
          'Legal & Administrative',
          Icons.gavel,
          [
            'buildingPermit',
            'zoned',
            'boundaryMarkers',
            'headquarters',
          ],
        ),
        SizedBox(height: 24),

        // Water Management
        _buildAmenitySection(
          'Water Management',
          Icons.water_drop,
          [
            'drainage',
            'floodRisk',
            'rainwaterCollection',
            'wellWater',
          ],
        ),
        SizedBox(height: 24),

        // Security & Nature
        _buildAmenitySection(
          'Security & Nature',
          Icons.security,
          [
            'fenced',
            'securitySystem',
            'trees',
            'flatTerrain',
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitySection(
      String title, IconData icon, List<String> amenities) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: amenities.map((amenity) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width > 600
                      ? (MediaQuery.of(context).size.width - 150) / 3
                      : (MediaQuery.of(context).size.width - 100) / 2,
                  child: CheckboxListTile(
                    title: Text(_formatAmenityName(amenity)),
                    value: _amenities[amenity] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        _amenities[amenity] = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmenityName(String amenity) {
    // Convert camelCase to words
    String result = amenity.replaceAllMapped(
      RegExp(r'([A-Z]|[0-9]+)'),
      (Match match) => ' ${match.group(0)}',
    );

    // Capitalize first letter
    return result[0].toUpperCase() + result.substring(1);
  }

  // Step 4: Documentation
  Widget _buildDocumentationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Documentation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Upload documents to verify your land ownership',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Document upload section
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section images
              Text(
                'Images (${_images.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 8),
              _images.isEmpty
                  ? Text('Aucune image téléchargée',
                      style: TextStyle(color: Colors.grey[600]))
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _images
                          .map((image) => _buildFileCard(image, true))
                          .toList(),
                    ),
              SizedBox(height: 24),

              // Section documents
              Text(
                'Documents (${_documents.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(height: 8),
              _documents.isEmpty
                  ? Text('Aucun document téléchargé',
                      style: TextStyle(color: Colors.grey[600]))
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _documents
                          .map((doc) => _buildFileCard(doc, false))
                          .toList(),
                    ),

              // Bouton téléchargement
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Télécharger des fichiers'),
                onPressed: _pickDocument,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

// Required documents info
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  SizedBox(width: 12),
                  Text(
                    'Required Documents',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildRequiredDocItem('Proof of ownership (title deed)'),
              _buildRequiredDocItem('Land survey document'),
              _buildRequiredDocItem('Property tax receipts (if applicable)'),
              _buildRequiredDocItem('Government ID of the owner'),
              SizedBox(height: 16),
              Text(
                '* These documents will be reviewed by validators for land verification',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(PlatformFile file, bool isImage) {
    return Container(
      width: 220,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImage ? Colors.blue[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isImage ? Colors.blue[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isImage ? Colors.blue[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isImage ? Icons.image : Icons.description,
              color: isImage ? Colors.blue[700] : Colors.orange[700],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${(file.size / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              setState(() {
                if (isImage) {
                  _images.remove(file);
                } else {
                  _documents.remove(file);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Build document item in list

  // Required document item
  Widget _buildRequiredDocItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Colors.orange[700],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 5: Land Evaluation
  Widget _buildEvaluationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Land Value Evaluation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Get an estimated value for your land before tokenization',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // ETH Price indicator
        if (_ethPriceData != null)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.currency_exchange,
                    color: Colors.blue[700], size: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current ETH Price',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_ethPriceData!['ethPriceTND'].toStringAsFixed(2)} TND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue[700]),
                  onPressed: _fetchEthPrice,
                  tooltip: 'Refresh ETH price',
                ),
              ],
            ),
          ),
        SizedBox(height: 24),

        // Token configuration
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _totalTokensController,
                decoration: InputDecoration(
                  labelText: 'Total Tokens',
                  hintText: 'Number of tokens to create',
                  prefixIcon: Icon(Icons.token, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  helperText:
                      'How many tokens do you want to create for your land?',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total number of tokens';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of tokens';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // Evaluation Button or Results
        if (_isEvaluating)
          Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                Text(
                  'Evaluating your land...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          )
        else if (_hasEvaluated && _evaluationResult != null)
          _buildValuationResultDisplay()
        else
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.analytics, size: 48, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Ready to evaluate your land?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _evaluateLand,
                    icon: Icon(Icons.calculate),
                    label: Text('Evaluate Land Value'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Display for the valuation result
  Widget _buildValuationResultDisplay() {
    final valuation = _evaluationResult!.valuation;
    final ethPrice = valuation.currentEthPriceTND ??
        (_ethPriceData != null ? _ethPriceData!['ethPriceTND'] : 3000.0);

    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: Colors.green[700], size: 32),
              ),
              SizedBox(width: 16),
              Text(
                'Evaluation Complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Main value display
          Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Land Value',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${NumberFormat('#,###').format(valuation.estimatedValue)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'TND',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (valuation.estimatedValueETH != null) ...[
                    SizedBox(height: 8),
                    Text(
                      '≈ ${valuation.estimatedValueETH!.toStringAsFixed(4)} ETH',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Token info grid
          Row(
            children: [
              Expanded(
                child: _buildEvalDetailCard(
                  'Total Tokens',
                  _totalTokensController.text,
                  Icons.token,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildEvalDetailCard(
                  'Price Per Token (TND)',
                  NumberFormat('#,###').format(valuation.estimatedValue /
                      double.parse(_totalTokensController.text)),
                  Icons.price_check,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEvalDetailCard(
                  'Price Per Token (ETH)',
                  ((valuation.estimatedValueETH ??
                              valuation.estimatedValue / ethPrice) /
                          double.parse(_totalTokensController.text))
                      .toStringAsFixed(6),
                  Icons.currency_exchange,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildEvalDetailCard(
                  'Land Area',
                  '${valuation.areaInSqFt} sq m',
                  Icons.square_foot,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Re-evaluate button
          Center(
            child: TextButton.icon(
              onPressed: _evaluateLand,
              icon: Icon(Icons.refresh),
              label: Text('Re-evaluate'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Evaluation detail card
  Widget _buildEvalDetailCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  // Step 6: Review and Submit
  Widget _buildReviewStep() {
    if (!_hasEvaluated) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 64, color: Colors.orange[700]),
              SizedBox(height: 24),
              Text(
                'Please complete the evaluation step first',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'You need to evaluate your land before proceeding to the final review',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 4; // Go back to evaluation step
                  });
                },
                child: Text('Go to Evaluation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ethPrice = _evaluationResult!.valuation.currentEthPriceTND ??
        (_ethPriceData != null ? _ethPriceData!['ethPriceTND'] : 3000.0);
    final ethValue = _evaluationResult!.valuation.estimatedValueETH ??
        _evaluationResult!.valuation.estimatedValue / ethPrice;
    final pricePerToken = ethValue / double.parse(_totalTokensController.text);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Review your land details and submit for registration',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          SizedBox(height: 32),

          // Land details summary
          _buildReviewSection(
            title: 'Land Details',
            icon: Icons.landscape,
            items: [
              {'label': 'Title', 'value': _titleController.text},
              {
                'label': 'Description',
                'value': _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : 'Not provided'
              },
              {'label': 'Location', 'value': _locationController.text},
              {
                'label': 'Surface Area',
                'value': '${_surfaceController.text} sq m'
              },
              {
                'label': 'Land Type',
                'value': _selectedLandType ?? 'Not specified'
              },
              {'label': 'Status', 'value': 'Pending Validation'},
            ],
          ),
          SizedBox(height: 24),

          // Amenities summary
          _buildReviewSection(
            title: 'Amenities',
            icon: Icons.check_circle,
            items: _amenities.entries
                .where((entry) => entry.value)
                .map((entry) => {
                      'label': _formatAmenityName(entry.key),
                      'value': 'Available'
                    })
                .toList(),
          ),
          SizedBox(height: 24),

          // Tokenization details summary
          _buildReviewSection(
            title: 'Tokenization Details',
            icon: Icons.token,
            items: [
              {'label': 'Total Tokens', 'value': _totalTokensController.text},
              {
                'label': 'Price Per Token',
                'value': '${pricePerToken.toStringAsFixed(6)} ETH'
              },
              {
                'label': 'Total Land Value (TND)',
                'value':
                    '${NumberFormat('#,###').format(_evaluationResult!.valuation.estimatedValue)}'
              },
              {
                'label': 'Total Land Value (ETH)',
                'value': '${ethValue.toStringAsFixed(4)}'
              },
            ],
          ),
          SizedBox(height: 24),

          // Documentation summary
          _buildReviewSection(
            title: 'Documentation',
            icon: Icons.folder_special,
            items: [
              {
                'label': 'Documents Uploaded',
                'value': '${_documents.length} files'
              },
            ],
          ),
          SizedBox(height: 32),

          // Price acceptance section
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isAcceptingPrice
                    ? [Colors.green[50]!, Colors.green[100]!]
                    : [Colors.amber[50]!, Colors.amber[100]!],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _isAcceptingPrice ? Colors.green[300]! : Colors.amber[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isAcceptingPrice
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _isAcceptingPrice
                          ? Colors.green[700]
                          : Colors.amber[800],
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Price Acceptance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isAcceptingPrice
                            ? Colors.green[800]
                            : Colors.amber[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  _isAcceptingPrice
                      ? 'You have accepted the proposed price for your land.'
                      : 'You must accept the proposed price to proceed with registration.',
                  style: TextStyle(
                    color: _isAcceptingPrice
                        ? Colors.green[700]
                        : Colors.amber[800],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proposed Price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${ethValue.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ETH',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '≈ ${NumberFormat('#,###').format(_evaluationResult!.valuation.estimatedValue)} TND',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      Divider(height: 32),
                      Text(
                        'Price per token: ${pricePerToken.toStringAsFixed(6)} ETH',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _isAcceptingPrice,
                      onChanged: (value) {
                        setState(() {
                          _isAcceptingPrice = value ?? false;
                        });
                      },
                      activeColor: Colors.green[700],
                    ),
                    Expanded(
                      child: Text(
                        'I accept the proposed price for my land and wish to proceed with registration.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Disclaimer section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.grey[700]),
                    SizedBox(width: 12),
                    Text(
                      'Important Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '• All provided information must be accurate and verifiable\n'
                  '• You must be the legal owner of the land\n'
                  '• Documents will be validated by certified validators\n'
                  '• The tokenization process is irreversible once completed',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build review sections
  Widget _buildReviewSection(
      {required String title,
      required IconData icon,
      required List<Map<String, String>> items}) {
    if (items.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            item['label']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item['value']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Loading indicator
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Processing your request...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            icon: Icon(Icons.arrow_back_ios, size: 18),
            label: Text('Back'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          )
        else
          SizedBox(width: 100),
        if (_currentStep < _steps.length - 1)
          ElevatedButton.icon(
            onPressed: () {
              // Validate current step before proceeding
              if (_currentStep == 0) {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() {
                    _currentStep++;
                  });
                }
              } else if (_currentStep == 1) {
                if (_locationController.text.isNotEmpty &&
                    _selectedLocation != null) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  _showSnackBar(
                      'Please enter a location and select a position on the map',
                      isError: true);
                }
              } else if (_currentStep == 2) {
                // Amenities step - no validation required, just proceed
                setState(() {
                  _currentStep++;
                });
              } else if (_currentStep == 3) {
                if (_documents.isEmpty) {
                  _showSnackBar('Please upload at least one document',
                      isError: true);
                } else {
                  setState(() {
                    _currentStep++;
                  });
                }
              } else if (_currentStep == 4) {
                if (!_hasEvaluated) {
                  _showSnackBar('Please evaluate your land before proceeding',
                      isError: true);
                } else {
                  setState(() {
                    _currentStep++;
                  });
                }
              }
            },
            icon: Text('Next'),
            label: Icon(Icons.arrow_forward_ios, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed:
                !_isAcceptingPrice || _isLoading ? null : _submitRegistration,
            icon: Icon(Icons.check_circle),
            label: Text('Submit Registration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withOpacity(0.5),
              disabledBackgroundColor: Colors.green[600]!.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  // Format file size helper method
  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
