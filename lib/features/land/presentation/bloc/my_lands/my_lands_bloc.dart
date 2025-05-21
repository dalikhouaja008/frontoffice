import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/land/domain/entities/land.dart';
import 'package:the_boost/features/land/domain/repositories/land_repository.dart';

// Events
abstract class MyLandsEvent extends Equatable {
  const MyLandsEvent();

  @override
  List<Object> get props => [];
}

class LoadMyLands extends MyLandsEvent {}

// States
abstract class MyLandsState extends Equatable {
  const MyLandsState();

  @override
  List<Object> get props => [];
}

class MyLandsInitial extends MyLandsState {}

class MyLandsLoading extends MyLandsState {}

class MyLandsLoaded extends MyLandsState {
  final List<Land> lands;

  const MyLandsLoaded(this.lands);

  @override
  List<Object> get props => [lands];
}

class MyLandsError extends MyLandsState {
  final String message;

  const MyLandsError(this.message);

  @override
  List<Object> get props => [message];
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
    try {
      final lands = await repository.getMyLands();
      emit(MyLandsLoaded(lands as List<Land>));
    } catch (e) {
      emit(MyLandsError(e.toString()));
    }
  }
}
