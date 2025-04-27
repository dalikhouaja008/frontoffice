// lib/features/auth/presentation/bloc/lands/land_state.dart
part of 'land_bloc.dart';

abstract class LandState {}

class LandInitial extends LandState {}

class LandLoading extends LandState {}

class LandLoaded extends LandState {
  final List<Land> lands;
  LandLoaded({required this.lands});
}

class LandError extends LandState {
  final String message;
  LandError({required this.message});
}

class NavigatingToLandDetails extends LandState {
  final Land land;
  NavigatingToLandDetails({required this.land});
}