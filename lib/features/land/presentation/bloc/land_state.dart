import 'package:equatable/equatable.dart';
import '../../domain/entities/land.dart';

abstract class LandState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LandInitial extends LandState {}

class LandLoading extends LandState {}

class LandAdded extends LandState {
  final Land land;
  LandAdded(this.land);

  @override
  List<Object?> get props => [land];
}

class LandsLoaded extends LandState {
  final List<Land> lands;
  LandsLoaded(this.lands);

  @override
  List<Object?> get props => [lands];
}

class LandError extends LandState {
  final String message;
  LandError(this.message);

  @override
  List<Object?> get props => [message];
}
