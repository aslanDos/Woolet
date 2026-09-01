import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/repositories/analytics_repository.dart';

class GetAnalytics implements UseCase<AnalyticsEntity, AnalyticsQuery> {
  const GetAnalytics(this.repository);

  final AnalyticsRepository repository;

  @override
  Future<Either<Failure, AnalyticsEntity>> call(AnalyticsQuery params) =>
      repository.getAnalytics(params);
}
