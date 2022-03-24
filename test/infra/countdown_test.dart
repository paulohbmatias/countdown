// ignore_for_file: void_checks
import 'package:clock/clock.dart';
import 'package:countdown/countdown.dart';
import 'package:countdown/src/domain/countdown_exception.dart';
import 'package:countdown/src/domain/countdown_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'countdown_test.mocks.dart';

abstract class TimerFake {
  void onStatusChanged(CountdownStatus status);
  void Function(Duration) get onTimeChanged;
  void Function() get onDone;
}

@GenerateMocks([],
    customMocks: [MockSpec<TimerFake>(returnNullOnMissingStub: false)])
void main() {
  late Countdown countdown;
  late TimerFake timerMock;
  late Duration countDuration;

  setUp(() {
    final stopwatch = clock.stopwatch();
    countDuration = const Duration(seconds: 3);
    countdown = CountdownTimer(countDuration, stopwatch: stopwatch);
    timerMock = MockTimerFake();
  });

  test(
    "Should test if countdown start",
    () {
      when(timerMock.onStatusChanged(CountdownStatus.running))
          .thenReturn((p0) {});
      when(timerMock.onTimeChanged).thenReturn((p0) {});

      countdown.onStatusChanged(timerMock.onStatusChanged);
      countdown.onTimeChanged(timerMock.onTimeChanged);
      countdown.play();
      expect(countdown.status, CountdownStatus.running);
      verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
      verify(timerMock.onTimeChanged).called(greaterThan(0));
    },
  );

  test("Should pause countdown", () {
    when(timerMock.onStatusChanged(CountdownStatus.paused)).thenReturn(() {});
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    countdown.onStatusChanged(timerMock.onStatusChanged);
    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.play();
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

    countdown.play();
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

    countdown.play();
    countdown.stop();

    expect(countdown.status, CountdownStatus.notStarted);
    verify(timerMock.onStatusChanged(CountdownStatus.running)).called(1);
    verify(timerMock.onStatusChanged(CountdownStatus.notStarted)).called(1);
  });

  test("Should test if Countdown resume time", () {
    when(timerMock.onStatusChanged(CountdownStatus.running)).thenReturn((_) {});
    when(timerMock.onStatusChanged(CountdownStatus.paused)).thenReturn((_) {});

    countdown.onStatusChanged(timerMock.onStatusChanged);

    countdown.play();
    countdown.pause();
    countdown.play();

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

    countdown.play();

    expect(countdown.status, CountdownStatus.running);
    await untilCalled(timerMock.onTimeChanged);
  });

  test("Should test listen status", () async {
    when(timerMock.onStatusChanged(CountdownStatus.running))
        .thenReturn((p0) {});

    countdown.onStatusChanged(timerMock.onStatusChanged);

    countdown.play();

    expect(countdown.status, CountdownStatus.running);
    await untilCalled(timerMock.onStatusChanged(CountdownStatus.running));
  });

  test("Should get duration", () {
    final duration = countdown.duration;

    expect(duration, countDuration);
  });

  test("Should get remaining duration", () async {
    final duration = countdown.remaningTime;

    expect(duration, countDuration);
  });

  test("Should return the current status", () {
    final status = countdown.status;

    expect(status, CountdownStatus.notStarted);
  });

  test("Should test listen onDone", () async {
    when(timerMock.onDone).thenReturn(() {});
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    countdown.onDone(timerMock.onDone);
    countdown.onTimeChanged(timerMock.onTimeChanged);

    countdown.duration = const Duration(seconds: 1);
    countdown.play();

    expect(countdown.status, CountdownStatus.running);
    await untilCalled(timerMock.onDone);
  });

  test("Test if countdown count the duration to 0", () async {
    when(timerMock.onTimeChanged).thenReturn((p0) {});
    when(timerMock.onDone()).thenReturn(() {});

    countdown.duration = const Duration(seconds: 2);

    countdown.onTimeChanged((d) => timerMock.onTimeChanged);
    countdown.onDone(() => timerMock.onDone());
    countdown.play();

    await untilCalled(timerMock.onDone());

    verify(timerMock.onTimeChanged).called(greaterThan(1));
  });

  test("Shoul throw exception if try pause countdonw but it's not initialized",
      () {
    expect(() => countdown.pause(), throwsA(isA<CountdownException>()));
  });

  test("Shoul throw exception if try stop countdonw but it's not initialized",
      () {
    expect(() => countdown.stop(), throwsA(isA<CountdownException>()));
  });
}
