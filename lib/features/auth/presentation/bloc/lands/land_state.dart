part of 'land_bloc.dart';

abstract class LandState {}

class LandInitial extends LandState {}

class LandLoading extends LandState {}

class LandLoaded extends LandState {
  final List<Land> lands;

  LandLoaded(this.lands);
}

class LandDetailsLoaded extends LandState {
  final Land land;

  LandDetailsLoaded(this.land);
}

class LandError extends LandState {
  final String message;

  LandError(this.message);
}