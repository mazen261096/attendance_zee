import 'package:flutter/material.dart';
import '../utils/enums.dart';

class RequestStateWidget extends StatelessWidget {
  const RequestStateWidget({
    super.key,
    required this.state,
    required this.loading,
    required this.error,
    required this.success,
    this.isEmpty,
    this.empty,
  });

  final RequestState state;

  final Widget loading;
  final Widget error; // Ready-to-use Widget, not a function function
  final Widget success;

  final bool? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RequestState.loading:
        return loading;
      case RequestState.error:
        return error;
      case RequestState.loaded:
        if (isEmpty != null && isEmpty!) {
          return empty ?? const SizedBox.shrink();
        }
        return success;
      default:
        return const SizedBox.shrink();
    }
  }
}
