import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';

abstract interface class AnalyticsRepository {
  Future<Either<Failure, AnalyticsEntity>> getAnalytics(AnalyticsQuery query);
}
