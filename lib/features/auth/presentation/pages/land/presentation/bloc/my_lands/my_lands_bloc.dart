import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/entities/land.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/repositories/land_repository.dart';

// Events
abstract class MyLandsEvent {}

class LoadMyLands extends MyLandsEvent {}

// States
abstract class MyLandsState {}

class MyLandsInitial extends MyLandsState {}

class MyLandsLoading extends MyLandsState {}

class MyLandsLoaded extends MyLandsState {
  final List<Land> lands;

  MyLandsLoaded(this.lands);
}

class MyLandsError extends MyLandsState {
  final String message;

  MyLandsError(this.message);
}

// Bloc
class MyLandsBloc extends Bloc<MyLandsEvent, MyLandsState> {
  final LandRepository repository;

  MyLandsBloc({required this.repository}) : super(MyLandsInitial()) {
    on<LoadMyLands>(_onLoadMyLands);
  }

  Future<void> _onLoadMyLands(
    LoadMyLands event,
    Emitter<MyLandsState> emit,
  ) async {
    emit(MyLandsLoading());
    final result = await repository.getMyLands();
    result.fold(
      (failure) => emit(MyLandsError(failure.message)),
      (lands) => emit(MyLandsLoaded(lands)),
    );
  }
}
