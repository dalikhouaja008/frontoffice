// lib/features/land_registration/presentation/pages/register_land_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../features/auth/presentation/widgets/app_nav_bar.dart';
import '../bloc/register_land_bloc.dart';
import '../bloc/register_land_event.dart';
import '../bloc/register_land_state.dart';
import '../widgets/step_indicator.dart';
import '../widgets/basic_info_step.dart';
import '../widgets/location_step.dart';
import '../widgets/amenities_step.dart';
import '../widgets/documentation_step.dart';
import '../widgets/evaluation_step.dart';
import '../widgets/review_step.dart';
import '../widgets/success_dialog.dart';
import '../../domain/entities/valuation_result.dart';

class RegisterLandPage extends StatefulWidget {
  const RegisterLandPage({Key? key}) : super(key: key);

  @override
  _RegisterLandPageState createState() => _RegisterLandPageState();
}

class _RegisterLandPageState extends State<RegisterLandPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  Set<Marker> _markers = {};

  final List<String> _steps = [
    'Basic Information',
    'Location & Details',
    'Amenities',
    'Documentation',
    'Evaluation',
    'Review & Submit'
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: BlocConsumer<RegisterLandBloc, RegisterLandState>(
        listener: (context, state) {
          // Handle error messages
          if (state.errorMessage != null) {
            _showSnackBar(state.errorMessage!, isError: true);
          }

          // Handle successful registration
          if (state.registrationStatus == RegistrationStatus.success &&
              state.successLandId != null) {
            _showSuccessDialog(state.successLandId!);
          }
        },
        builder: (context, state) {
          // Update markers when position changes
          if (state.position != null) {
            _markers = {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: state.position!,
                infoWindow: InfoWindow(title: 'Selected Land Location'),
              ),
            };
          }
          
          return SingleChildScrollView(
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
                          child: StepIndicator(
                            currentStep: state.currentStep,
                            steps: _steps,
                          ),
                        ),
                        Divider(height: 1),
                        Container(
                          padding: EdgeInsets.all(32),
                          child: state.registrationStatus == RegistrationStatus.loading
                              ? _buildLoadingIndicator()
                              : Form(
                                  key: _formKey,
                                  child: _buildCurrentStepContent(context, state),
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius:
                                BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                          child: _buildNavigationButtons(context, state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build content for current step
  Widget _buildCurrentStepContent(BuildContext context, RegisterLandState state) {
    switch (state.currentStep) {
      case 0:
        return BasicInfoStep(
          title: state.title,
          description: state.description,
          selectedLandType: state.landType,
          surface: state.surface,
          onTitleChanged: (value) {
            context.read<RegisterLandBloc>().add(TitleChangedEvent(value));
          },
          onDescriptionChanged: (value) {
            context.read<RegisterLandBloc>().add(DescriptionChangedEvent(value));
          },
          onLandTypeChanged: (value) {
            context.read<RegisterLandBloc>().add(LandTypeChangedEvent(value!));
          },
          onSurfaceChanged: (value) {
            context.read<RegisterLandBloc>().add(SurfaceChangedEvent(value));
          },
          formKey: _formKey,
        );
      case 1:
        return LocationStep(
          location: state.location,
          selectedLocation: state.position,
          markers: _markers,
          onMapTap: (position) {
            context.read<RegisterLandBloc>().add(PositionChangedEvent(position));
          },
          onLocationChanged: (value) {
            context.read<RegisterLandBloc>().add(LocationChangedEvent(value));
          },
          onResetLocation: () {
            context.read<RegisterLandBloc>().add(PositionChangedEvent(LatLng(0, 0)));
            setState(() {
              _markers = {};
            });
          },
        );
      case 2:
        return AmenitiesStep(
          amenities: state.amenities,
          onAmenityChanged: (name, value) {
            context.read<RegisterLandBloc>().add(AmenityChangedEvent(name, value));
          },
        );
      case 3:
        return DocumentationStep(
          documents: state.documents,
          images: state.images,
          onDocumentsUploaded: (files) {
            context.read<RegisterLandBloc>().add(DocumentsUploadedEvent(files));
          },
          onRemoveDocument: (file, isImage) {
            context.read<RegisterLandBloc>().add(RemoveDocumentEvent(file, isImage: isImage));
          },
          onPickDocuments: () => _pickDocument(context),
        );
      case 4:
        return EvaluationStep(
          totalTokens: state.totalTokens,
          ethPriceData: state.ethPriceData,
          evaluationResult: state.evaluationResult,
          isEvaluating: state.evaluationStatus == EvaluationStatus.loading,
          hasEvaluated: state.evaluationStatus == EvaluationStatus.success || 
                        state.evaluationStatus == EvaluationStatus.simulated,
          onTotalTokensChanged: (value) {
            context.read<RegisterLandBloc>().add(TotalTokensChangedEvent(value));
          },
          onEvaluateLand: () {
            context.read<RegisterLandBloc>().add(RequestLandEvaluationEvent());
          },
          onFetchEthPrice: () {
            context.read<RegisterLandBloc>().add(FetchEthPriceEvent());
          },
        );
      case 5:
        return ReviewStep(
          title: state.title,
          description: state.description,
          location: state.location,
          surface: state.surface,
          landType: state.landType,
          totalTokens: state.totalTokens,
          amenities: state.amenities,
          documents: state.documents,
          images: state.images,
          evaluationResult: state.evaluationResult,
          isAcceptingPrice: state.isAcceptingPrice,
          onAcceptPrice: (value) {
            context.read<RegisterLandBloc>().add(AcceptPriceEvent(value));
          },
          onSubmitRegistration: () {
            context.read<RegisterLandBloc>().add(SubmitRegistrationEvent());
          },
          isLoading: state.registrationStatus == RegistrationStatus.loading,
        );
      default:
        return Container();
    }
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
  Widget _buildNavigationButtons(BuildContext context, RegisterLandState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (state.currentStep > 0)
          TextButton.icon(
            onPressed: () {
              context.read<RegisterLandBloc>().add(GoToPreviousStepEvent());
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
        if (state.currentStep < _steps.length - 1)
          ElevatedButton.icon(
            onPressed: state.isStepValid
                ? () {
                    context.read<RegisterLandBloc>().add(GoToNextStepEvent());
                  }
                : null,
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
            onPressed: state.canSubmit
                ? () {
                    context.read<RegisterLandBloc>().add(SubmitRegistrationEvent());
                  }
                : null,
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

  Future<void> _pickDocument(BuildContext context) async {
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
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      context.read<RegisterLandBloc>().add(DocumentsUploadedEvent(result.files));
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
      builder: (context) => SuccessDialog(
        landId: landId,
        onGoToDashboard: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/dashboard');
        },
        onRegisterAnother: () {
          Navigator.of(context).pop();
          context.read<RegisterLandBloc>().add(ResetFormEvent());
        },
      ),
    );
  }
}