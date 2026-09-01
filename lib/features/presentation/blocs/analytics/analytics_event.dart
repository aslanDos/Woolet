part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => const [];
}

final class AnalyticsLoadRequested extends AnalyticsEvent {
  const AnalyticsLoadRequested(this.query);

  final AnalyticsQuery query;

  @override
  List<Object?> get props => [query];
}
