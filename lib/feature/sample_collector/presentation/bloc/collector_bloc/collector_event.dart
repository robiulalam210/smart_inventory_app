part of 'collector_bloc.dart';

@immutable
sealed class CollectorEvent {}
class LoadCollector extends CollectorEvent {}
