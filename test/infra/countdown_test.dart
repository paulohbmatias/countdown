import 'dart:async';
import 'dart:typed_data';

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
  Duration _duration;

  CountdownTimer(this._duration);

  @override
  Duration get duration => _duration;

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
    _setStatus(CountdownStatus.paused);
  }

  @override
  Duration get remaningTime => throw UnimplementedError();

  @override
  void reset() {
    clock.stopwatch().stop();
    clock.stopwatch().reset();

    _setStatus(CountdownStatus.notStarted);
  }

  @override
  set duration(Duration duration) {
    _duration = duration;
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

  void _setStatus(CountdownStatus status) {
    _statusController.add(status);
    if (onStatusCallback != null) {
      onStatusCallback!(_statusController.value);
    }
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
    clock.stopwatch().stop();
    clock.stopwatch().reset();
    _setStatus(CountdownStatus.notStarted);
  }
}

abstract class TimerFake {
  void onStatusChanged(CountdownStatus status);
  void Function(Duration) get onTimeChanged;
}

@GenerateMocks([],
    customMocks: [MockSpec<TimerFake>(returnNullOnMissingStub: false)])
void main() {
  late Countdown countdown;
  late TimerFake timerMock;

  setUp(() {
    countdown = CountdownTimer(const Duration(seconds: 3));
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
    when(timerMock.onStatusChanged(CountdownStatus.paused)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    countdown.onStatusChanged(timerMock.onStatusChanged);
    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.start();
    countdown.pause();

    expect(countdown.status, CountdownStatus.paused);
    verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.paused)).called(1);
    verify(timerMock.onTimeChanged).called(greaterThan(0));
  });

  test("Should test if countdown reset", () {
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.notStarted))
        .thenReturn((_) {});
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    countdown.onStatusChanged(timerMock.onStatusChanged);
    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.start();
    countdown.reset();

    expect(countdown.status, CountdownStatus.notStarted);
    verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.notStarted)).called(1);
  });

  test("Should test if Countdown stop", () {
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.notStarted))
        .thenReturn((_) {});

    countdown.onStatusChanged(timerMock.onStatusChanged);

    countdown.start();
    countdown.stop();

    expect(countdown.status, CountdownStatus.notStarted);
    verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.notStarted)).called(1);
  });

  test("Should test if Countdown resume time", () {
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.paused)).thenReturn((_) {});

    countdown.onStatusChanged(timerMock.onStatusChanged);

    countdown.start();
    countdown.pause();
    countdown.start();

    expect(countdown.status, CountdownStatus.running);

    verifyInOrder([
      timerMock.onStatusChanged(CountdownStatus.running),
      timerMock.onStatusChanged(CountdownStatus.paused),
      timerMock.onStatusChanged(CountdownStatus.running)
    ]);

    verifyNoMoreInteractions(timerMock);
  });

  test("Should reset duration", () {
    Duration duration = const Duration(seconds: 1);
    countdown.duration = duration;

    expect(countdown.duration, duration);
  });

  test("Should test listen time", () async {
    when(timerMock.onTimeChanged).thenReturn((p0) {});

    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.start();

    expect(countdown.status, CountdownStatus.running);
    await untilCalled(timerMock.onTimeChanged);
  });

  test("Should test listen status", () async {
    when(timerMock.onStatusChanged(CountdownStatus.running))
        .thenReturn((p0) {});

    countdown.onStatusChanged(timerMock.onStatusChanged);

    countdown.start();

    expect(countdown.status, CountdownStatus.running);
    await untilCalled(timerMock.onStatusChanged(CountdownStatus.running));
  });
}
