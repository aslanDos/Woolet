import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/usecases/analytics/get_analytics.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required GetAnalytics getAnalytics})
    : _getAnalytics = getAnalytics,
      super(const AnalyticsState()) {
    on<AnalyticsLoadRequested>(_load);
  }

  final GetAnalytics _getAnalytics;

  Future<void> _load(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, clearError: true));
    final result = await _getAnalytics(event.query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (analytics) => emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          analytics: analytics,
          clearError: true,
        ),
      ),
    );
  }
}
