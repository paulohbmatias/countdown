import 'package:countdown/src/domain/countdown_error.dart';

class CountdownException implements Exception {
  final String description;
  final CountdownError erro;
  CountdownException({required this.description, required this.erro});
}
