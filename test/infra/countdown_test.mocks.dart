// Mocks generated by Mockito 5.1.0 from annotations
// in countdown/test/infra/countdown_test.dart.
// Do not manually edit this file.

import 'package:countdown/src/domain/countdown_status.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

import 'countdown_test.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [TimerFake].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimerFake extends _i1.Mock implements _i2.TimerFake {
  MockTimerFake() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void Function(Duration) get onTimeChanged =>
      (super.noSuchMethod(Invocation.getter(#onTimeChanged),
          returnValue: (Duration __p0) {}) as void Function(Duration));
  @override
  void Function() get onDone =>
      (super.noSuchMethod(Invocation.getter(#onDone), returnValue: () {})
          as void Function());
  @override
  void onStatusChanged(_i3.CountdownStatus? status) =>
      super.noSuchMethod(Invocation.method(#onStatusChanged, [status]),
          returnValueForMissingStub: null);
}
