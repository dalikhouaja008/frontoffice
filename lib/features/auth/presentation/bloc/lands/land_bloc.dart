import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';

part 'land_event.dart';
part 'land_state.dart';

class LandBloc extends Bloc<LandEvent, LandState> {
  final LandRepository _landRepository;

  LandBloc(this._landRepository) : super(LandInitial()) {
    on<LoadLands>(_onLoadLands);
    on<LoadLandById>(_onLoadLandById);
    on<NavigateToLandDetails>(_onNavigateToLandDetails);
  }

  Future<void> _onLoadLands(LoadLands event, Emitter<LandState> emit) async {
    emit(LandLoading());
    try {
      print('[${DateTime.now()}] LandBloc: Loading lands...');
      final lands = await _landRepository.fetchLands();
      print('[${DateTime.now()}] LandBloc: ✅ Lands loaded successfully: $lands');
      emit(LandLoaded(lands));
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading lands: $e');
      emit(LandError('Failed to load lands: $e'));
    }
  }

  Future<void> _onLoadLandById(LoadLandById event, Emitter<LandState> emit) async {
    emit(LandLoading());
    try {
      print('[${DateTime.now()}] LandBloc: Loading land by ID: ${event.landId}...');
      final land = await _landRepository.fetchLandById(event.landId);
      if (land != null) {
        print('[${DateTime.now()}] LandBloc: ✅ Land loaded successfully: $land');
        emit(LandDetailsLoaded(land));
      } else {
        print('[${DateTime.now()}] LandBloc: ⚠️ Land not found');
        emit(LandError('Land not found'));
      }
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading land by ID: $e');
      emit(LandError('Failed to load land: $e'));
    }
  }

  void _onNavigateToLandDetails(
    NavigateToLandDetails event,
    Emitter<LandState> emit,
  ) {
    emit(NavigatingToLandDetails(event.land));
  }
}