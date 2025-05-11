// lib/features/land_registration/presentation/bloc/register_land_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:the_boost/features/land_registration/domain/usecases/usecase.dart';
import '../../domain/entities/valuation_result.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/usecases/evaluate_land.dart';
import '../../domain/usecases/get_eth_price.dart';
import '../../domain/usecases/register_land.dart';
import '../../../geolocator_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_helpers.dart';
import '../utils/form_validators.dart';
import 'register_land_event.dart';
import 'register_land_state.dart';

import '../../data/models/document_model.dart';

class RegisterLandBloc extends Bloc<RegisterLandEvent, RegisterLandState> {
  final EvaluateLand evaluateLand;
  final GetEthPrice getEthPrice;
  final RegisterLand registerLand;
  final GeolocatorService geolocatorService;
  final FileHelpers fileHelpers;
  final FormValidators formValidators;

  RegisterLandBloc({
    required this.evaluateLand,
    required this.getEthPrice,
    required this.registerLand,
    required this.geolocatorService,
    required this.fileHelpers,
    required this.formValidators,
  }) : super(RegisterLandState(
          amenities: {
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
          },
        )) {
    on<GoToNextStepEvent>(_onGoToNextStep);
    on<GoToPreviousStepEvent>(_onGoToPreviousStep);
    on<GoToSpecificStepEvent>(_onGoToSpecificStep);
    on<TitleChangedEvent>(_onTitleChanged);
    on<DescriptionChangedEvent>(_onDescriptionChanged);
    on<LandTypeChangedEvent>(_onLandTypeChanged);
    on<SurfaceChangedEvent>(_onSurfaceChanged);
    on<LocationChangedEvent>(_onLocationChanged);
    on<PositionChangedEvent>(_onPositionChanged);
    on<TotalTokensChangedEvent>(_onTotalTokensChanged);
    on<AmenityChangedEvent>(_onAmenityChanged);
    on<DocumentsUploadedEvent>(_onDocumentsUploaded);
    on<RemoveDocumentEvent>(_onRemoveDocument);
    on<FetchEthPriceEvent>(_onFetchEthPrice);
    on<RequestLandEvaluationEvent>(_onRequestLandEvaluation);
    on<AcceptPriceEvent>(_onAcceptPrice);
    on<SubmitRegistrationEvent>(_onSubmitRegistration);
    on<ResetFormEvent>(_onResetForm);

    // Auto-fetch ETH price when the bloc is created
    add(FetchEthPriceEvent());
    
    // Attempt to get current position
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    try {
      final position = await geolocatorService.getCurrentPosition();
      add(PositionChangedEvent(LatLng(position.latitude, position.longitude)));
    } catch (e) {
      // Just log the error and continue
      print('Error getting current position: $e');
    }
  }

  void _onGoToNextStep(GoToNextStepEvent event, Emitter<RegisterLandState> emit) {
    if (state.currentStep < 5 && state.isStepValid) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onGoToPreviousStep(GoToPreviousStepEvent event, Emitter<RegisterLandState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onGoToSpecificStep(GoToSpecificStepEvent event, Emitter<RegisterLandState> emit) {
    if (event.step >= 0 && event.step <= 5) {
      emit(state.copyWith(currentStep: event.step));
    }
  }

  void _onTitleChanged(TitleChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(DescriptionChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onLandTypeChanged(LandTypeChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(landType: event.landType));
  }

  void _onSurfaceChanged(SurfaceChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(surface: event.surface));
  }

  void _onLocationChanged(LocationChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(location: event.location));
  }

  void _onPositionChanged(PositionChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(position: event.position));
    
    // Attempt to get address from position
    _getAddressFromPosition(event.position);
  }

  Future<void> _getAddressFromPosition(LatLng position) async {
    try {
      // This could call a geocoding service to get the address
      // For now, we'll just use the coordinates as the address
      final addressText = "Location at ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      add(LocationChangedEvent(addressText));
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void _onTotalTokensChanged(TotalTokensChangedEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(totalTokens: event.totalTokens));
  }

  void _onAmenityChanged(AmenityChangedEvent event, Emitter<RegisterLandState> emit) {
    final updatedAmenities = Map<String, bool>.from(state.amenities);
    updatedAmenities[event.amenityName] = event.value;
    emit(state.copyWith(amenities: updatedAmenities));
  }

  void _onDocumentsUploaded(DocumentsUploadedEvent event, Emitter<RegisterLandState> emit) {
    List<PlatformFile> images = List<PlatformFile>.from(state.images);
    List<PlatformFile> documents = List<PlatformFile>.from(state.documents);

    for (var file in event.files) {
      if (fileHelpers.isImageFile(file.name)) {
        images.add(file);
      } else {
        documents.add(file);
      }
    }

    emit(state.copyWith(
      documents: documents,
      images: images,
    ));
  }

  void _onRemoveDocument(RemoveDocumentEvent event, Emitter<RegisterLandState> emit) {
    if (event.isImage) {
      final updatedImages = List<PlatformFile>.from(state.images)
        ..removeWhere((file) => file.name == event.document.name && file.size == event.document.size);
      emit(state.copyWith(images: updatedImages));
    } else {
      final updatedDocuments = List<PlatformFile>.from(state.documents)
        ..removeWhere((file) => file.name == event.document.name && file.size == event.document.size);
      emit(state.copyWith(documents: updatedDocuments));
    }
  }

  Future<void> _onFetchEthPrice(FetchEthPriceEvent event, Emitter<RegisterLandState> emit) async {
    try {
      final result = await getEthPrice(NoParams());
      
      result.fold(
        (failure) {
          // Handle failure silently - maybe log it
          print('Failed to fetch ETH price: ${failure.message}');
        },
        (ethPriceData) {
          emit(state.copyWith(ethPriceData: ethPriceData));
        },
      );
    } catch (e) {
      print('Error fetching ETH price: $e');
    }
  }

  Future<void> _onRequestLandEvaluation(RequestLandEvaluationEvent event, Emitter<RegisterLandState> emit) async {
    if (!formValidators.validateBasicInfo(state.title, state.landType, state.surface) || 
        state.position == null) {
      emit(state.copyWith(
        errorMessage: 'Please fill all required fields and select a location',
      ));
      return;
    }

    emit(state.copyWith(
      evaluationStatus: EvaluationStatus.loading,
      errorMessage: null,
    ));

    try {
      final params = EvaluateLandParams(
        position: state.position!,
        area: double.parse(state.surface),
        zoning: state.landType?.toLowerCase() ?? 'residential',
        nearWater: state.amenities['wellWater'] ?? false,
        roadAccess: state.amenities['roadAccess'] ?? true,
        utilities: (state.amenities['electricity'] ?? false) && 
                   (state.amenities['water'] ?? false),
      );

      final result = await evaluateLand(params);
      
      result.fold(
        (failure) {
          emit(state.copyWith(
            errorMessage: 'Error evaluating land: ${failure.message}',
            evaluationStatus: EvaluationStatus.failure,
          ));
          
          // Fallback to simulation in case of API errors
          _simulateEvaluation(emit);
        },
        (valuationResult) {
          emit(state.copyWith(
            evaluationResult: valuationResult,
            evaluationStatus: EvaluationStatus.success,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error evaluating land: $e',
        evaluationStatus: EvaluationStatus.failure,
      ));
      
      // Fallback to simulation in case of errors
      _simulateEvaluation(emit);
    }
  }

  void _simulateEvaluation(Emitter<RegisterLandState> emit) {
    if (!formValidators.validateBasicInfo(state.title, state.landType, state.surface)) return;

    double surfaceArea = double.parse(state.surface);
    double basePrice = 0.0001; // Base price in ETH per square meter

    // Apply price modifiers based on land type
    double typeMultiplier = 1.0;
    switch (state.landType) {
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
    state.amenities.forEach((key, value) {
      if (value) amenitiesMultiplier += 0.02; // 2% increase per amenity
    });

    // Create simulated ValuationResult
    final ethPriceInTND = state.ethPriceData?['ethPriceTND'] ?? 3000.0;
    final estimatedValue = (surfaceArea * basePrice * typeMultiplier * amenitiesMultiplier * ethPriceInTND).round();
    final estimatedValueEth = surfaceArea * basePrice * typeMultiplier * amenitiesMultiplier;

    // Create location info
    final locationInfo = LocationInfo(
      position: state.position ?? const LatLng(36.8065, 10.1815), // Default to Tunis
      address: state.location,
    );

    // Create valuation info
    final valuationInfo = ValuationInfo(
      estimatedValue: estimatedValue,
      estimatedValueETH: estimatedValueEth,
      areaInSqFt: surfaceArea,
      avgPricePerSqFt: estimatedValue / surfaceArea,
      avgPricePerSqFtETH: estimatedValueEth / surfaceArea,
      zoning: state.landType?.toLowerCase() ?? 'residential',
      valuationFactors: [
        ValuationFactor(
          factor: 'Land Type',
          adjustment: '${(typeMultiplier * 100 - 100).toStringAsFixed(0)}%',
        ),
        ValuationFactor(
          factor: 'Amenities',
          adjustment: '${((amenitiesMultiplier - 1) * 100).toStringAsFixed(0)}%',
        ),
      ],
      currentEthPriceTND: ethPriceInTND,
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
          nearWater: state.amenities['wellWater'] ?? false,
          roadAccess: state.amenities['roadAccess'] ?? true,
          utilities: (state.amenities['electricity'] ?? false) &&
              (state.amenities['water'] ?? false),
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
          nearWater: state.amenities['wellWater'] ?? false,
          roadAccess: state.amenities['roadAccess'] ?? true,
          utilities: (state.amenities['electricity'] ?? false) &&
              (state.amenities['water'] ?? false),
        ),
      ),
    ];

    // Create the full valuation result
    final valuationResult = ValuationResult(
      location: locationInfo,
      valuation: valuationInfo,
      comparables: comparables,
    );

    emit(state.copyWith(
      evaluationResult: valuationResult,
      evaluationStatus: EvaluationStatus.simulated,
      errorMessage: 'Using simulated evaluation (API unavailable)',
    ));
  }

  void _onAcceptPrice(AcceptPriceEvent event, Emitter<RegisterLandState> emit) {
    emit(state.copyWith(isAcceptingPrice: event.accept));
  }

  Future<void> _onSubmitRegistration(SubmitRegistrationEvent event, Emitter<RegisterLandState> emit) async {
    if (!state.canSubmit) {
      emit(state.copyWith(
        errorMessage: 'Please complete all required steps and accept the price',
      ));
      return;
    }

    emit(state.copyWith(
      registrationStatus: RegistrationStatus.loading,
      errorMessage: null,
    ));

    try {
      // Convert PlatformFile to LandDocument
      final documents = state.documents.map((file) => 
        LandDocumentModel.fromPlatformFile(file)
      ).toList();
      
      final images = state.images.map((file) => 
        LandDocumentModel.fromPlatformFile(file)
      ).toList();

      // Calculate price per token
      final ethPrice = state.ethPriceData?['ethPriceTND'] ?? 3000.0;
      final pricePerToken = state.evaluationResult!.valuation.estimatedValueETH != null
          ? state.evaluationResult!.valuation.estimatedValueETH! / double.parse(state.totalTokens)
          : state.evaluationResult!.valuation.estimatedValue / double.parse(state.totalTokens) / ethPrice;

      final params = RegisterLandParams(
        title: state.title,
        description: state.description.isNotEmpty ? state.description : null,
        location: state.location,
        surface: int.parse(state.surface),
        totalTokens: int.parse(state.totalTokens),
        pricePerToken: pricePerToken,
        status: 'pending_validation',
        landType: state.landType!.toLowerCase(),
        documents: documents,
        images: images,
        amenities: state.amenities,
      );

      final result = await registerLand(params);
      
      result.fold(
        (failure) {
          String errorMessage = 'Error registering land: ${failure.message}';
          
          // Handle CORS failure specially
          if (failure is CorsFailure) {
            errorMessage = 'CORS policy error: ${failure.message}';
          }
          
          emit(state.copyWith(
            registrationStatus: RegistrationStatus.failure,
            errorMessage: errorMessage,
          ));
        },
        (landId) {
          emit(state.copyWith(
            registrationStatus: RegistrationStatus.success,
            successLandId: landId,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        registrationStatus: RegistrationStatus.failure,
        errorMessage: 'Error registering land: $e',
      ));
    }
  }

  void _onResetForm(ResetFormEvent event, Emitter<RegisterLandState> emit) {
    emit(RegisterLandState(
      amenities: {
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
      },
      ethPriceData: state.ethPriceData, // Keep the ETH price data
    ));
  }
}