import 'dart:async';

import 'package:countdown/countdown.dart';
import 'package:countdown/src/domain/countdown_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:clock/clock.dart';

import 'countdown_test.mocks.dart';

class CountdownTimer implements Countdown {
  final _statusController = BehaviorSubject<CountdownStatus>();
  void Function(CountdownStatus)? onStatusCallback;
  void Function(Duration)? onTimeChangedCallback;
  late Timer timer;

  @override
  Duration get duration => throw UnimplementedError();

  @override
  onDone() {
    // TODO: implement onDone
    throw UnimplementedError();
  }

  @override
  onStatusChanged(void Function(CountdownStatus) callback) {
    onStatusCallback = callback;
  }

  @override
  onTimeChanged(void Function(Duration) callback) {
    onTimeChangedCallback = callback;
  }

  @override
  pause() {
    clock.stopwatch().stop();
    _statusController.add(CountdownStatus.paused);
    if (onStatusCallback != null) {
      onStatusCallback!(_statusController.value);
    }
  }

  @override
  // TODO: implement remaningTime
  Duration get remaningTime => throw UnimplementedError();

  @override
  reset() {
    _statusController.add(CountdownStatus.notStarted);
  }

  @override
  setDuration(Duration duration) {
    // TODO: implement setDuration
    throw UnimplementedError();
  }

  @override
  start() {
    clock.stopwatch().start();
    _statusController.add(CountdownStatus.running);
    if (onStatusCallback != null) {
      onStatusCallback!(_statusController.value);
    }
    _listenTime();
  }

  _listenTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (onTimeChangedCallback != null) {
        onTimeChangedCallback!(clock.stopwatch().elapsed);
      }
    });
  }

  @override
  CountdownStatus get status => _statusController.hasValue
      ? _statusController.value
      : CountdownStatus.notStarted;

  @override
  stop() {
    _statusController.add(CountdownStatus.notStarted);
  }
}

abstract class TimerFake {
  void Function(CountdownStatus) get onStatusChanged;
  void Function(Duration) get onTimeChanged;
}

@GenerateMocks([],
    customMocks: [MockSpec<TimerFake>(returnNullOnMissingStub: false)])
void main() {
  late Countdown countdown;
  late TimerFake timerMock;

  setUp(() {
    countdown = CountdownTimer();
    timerMock = MockTimerFake();
  });

  test(
    "Should test if countdown start",
    () {
      when(timerMock.onStatusChanged).thenReturn((p0) {});
      when(timerMock.onTimeChanged).thenReturn((p0) {});

      countdown.onStatusChanged(timerMock.onStatusChanged);
      countdown.onTimeChanged(timerMock.onTimeChanged);
      countdown.start();
      expect(countdown.status, CountdownStatus.running);
      verify(timerMock.onStatusChanged).called(1);
      verify(timerMock.onTimeChanged).called(greaterThan(0));
    },
  );

  test("Should pause countdown", () {
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.paused)).thenReturn((_) {});
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    countdown.onStatusChanged(timerMock.onStatusChanged);
    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.start();
    countdown.pause();

    expect(countdown.status, CountdownStatus.paused);
    // verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.paused)).called(1);
    // verify(timerMock.onTimeChanged).called(greaterThan(0));
  });

  test("Should test if countdown reset", () {
    countdown.start();
    countdown.reset();
    expect(countdown.status, CountdownStatus.notStarted);
  });

  test("Should test if Countdown stop", () {
    countdown.start();
    countdown.stop();
    expect(countdown.status, CountdownStatus.notStarted);
  });
}
