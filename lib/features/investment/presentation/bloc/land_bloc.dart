import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import '../../data/repositories/land_repository.dart';

// Events
abstract class LandEvent {}

class LoadLandsEvent extends LandEvent {}

class RefreshLandsEvent extends LandEvent {}

// States
abstract class LandState {}

class LandInitialState extends LandState {}

class LandLoadingState extends LandState {}

class LandLoadedState extends LandState {
  final List<Land> lands;
  final DateTime lastUpdated;

  LandLoadedState(this.lands) : lastUpdated = DateTime.now();
}

class LandErrorState extends LandState {
  final String message;
  final bool isConnectionError;

  LandErrorState(this.message, {this.isConnectionError = false});
}

class LandBloc extends Bloc<LandEvent, LandState> {
  final LandRepository _landRepository;

  LandBloc(this._landRepository) : super(LandInitialState()) {
    on<LoadLandsEvent>(_onLoadLands);
    on<RefreshLandsEvent>(_onRefreshLands);
  }

  Future<void> _onLoadLands(LoadLandsEvent event, Emitter<LandState> emit) async {
    emit(LandLoadingState());
    try {
      final lands = await _landRepository.fetchLands();
      emit(LandLoadedState(lands));
    } catch (e) {
      final isConnectionError = e.toString().contains('connexion');
      emit(LandErrorState(
        e.toString(),
        isConnectionError: isConnectionError,
      ));
    }
  }

  Future<void> _onRefreshLands(
    RefreshLandsEvent event,
    Emitter<LandState> emit,
  ) async {
    try {
      final lands = await _landRepository.fetchLands();
      emit(LandLoadedState(lands));
    } catch (e) {
      // Garder l'ancien état si le rafraîchissement échoue
      if (state is LandLoadedState) {
        emit(LandLoadedState((state as LandLoadedState).lands));
      } else {
        final isConnectionError = e.toString().contains('connexion');
        emit(LandErrorState(
          e.toString(),
          isConnectionError: isConnectionError,
        ));
      }
    }
  }
}