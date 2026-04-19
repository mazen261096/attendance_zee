import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message; // Translation key
  final String? code; // Error code for tracking
  final int? statusCode; // HTTP status code

  const Failure({required this.message, this.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}
