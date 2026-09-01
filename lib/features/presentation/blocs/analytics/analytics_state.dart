part of 'analytics_bloc.dart';

enum AnalyticsStatus { initial, loading, success, failure }

final class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.analytics = const AnalyticsEntity.empty(),
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final AnalyticsEntity analytics;
  final String? errorMessage;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsEntity? analytics,
    String? errorMessage,
    bool clearError = false,
  }) => AnalyticsState(
    status: status ?? this.status,
    analytics: analytics ?? this.analytics,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, analytics, errorMessage];
}
