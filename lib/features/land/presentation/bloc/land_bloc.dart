import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/use_cases/add_land_use_case.dart';
import '../../domain/use_cases/get_all_lands_use_case.dart';
import 'land_event.dart';
import 'land_state.dart';

class LandBloc extends Bloc<LandEvent, LandState> {
  final AddLandUseCase addLandUseCase;
  final GetAllLandsUseCase getAllLandsUseCase;

  LandBloc(this.addLandUseCase, this.getAllLandsUseCase) : super(LandInitial()) {
    on<AddLandEvent>((event, emit) async {
      emit(LandLoading());
      try {
        final land = await addLandUseCase(
          name: event.name,
          location: event.location,
          size: event.size,
          photos: event.photos,
          documents: event.documents,
        );
        emit(LandAdded(land)); // Provide the Land object
      } catch (e) {
        emit(LandError('Failed to add land: ${e.toString()}'));
      }
    });

    on<GetAllLandsEvent>((event, emit) async {
      emit(LandLoading());
      final result = await getAllLandsUseCase();

      result.fold(
        (failure) => emit(LandError('Failed to fetch lands')),
        (lands) => emit(LandsLoaded(lands)),
      );
    });
  }
}
