part of 'land_bloc.dart';

abstract class LandEvent {}

class LoadLands extends LandEvent {}

class LoadLandById extends LandEvent {
  final String landId;

  LoadLandById(this.landId);
}