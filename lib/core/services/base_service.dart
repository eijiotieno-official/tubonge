import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

abstract class BaseService {
  final Logger logger = Logger();

  Future<Either<String, T>> handleError<T>(
      Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e, stackTrace) {
      logger.e('Error in service operation: $e\n$stackTrace');
      return Left(e.toString());
    }
  }

  String getErrorMessage(dynamic error) {
    if (error is String) return error;
    return error.toString();
  }
}
