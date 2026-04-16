import 'package:equatable/equatable.dart';
import '../error/failures.dart';

// I will use a simple Future with a custom Result class
// I will write a simple Either representation to avoid adding dependencies if not strictly necessary, or I'll just use simple Futures throwing exceptions if it exceeds the scope. Let's install dartz! Wait, I can't run flutter commands. I'll make a custom Result class.

abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
