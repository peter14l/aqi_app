import 'package:equatable/equatable.dart';

class PurifierFailure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const PurifierFailure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'PurifierFailure: $message';
}
