import 'package:countdown/countdown.dart';
import 'package:countdown/src/domain/countdown_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';

class CountdownTimer implements Countdown {
  final _statusController = BehaviorSubject<CountdownStatus>();

  @override
  // TODO: implement duration
  Duration get duration => throw UnimplementedError();

  @override
  onDone() {
    // TODO: implement onDone
    throw UnimplementedError();
  }

  @override
  onStatusChanged(void Function(CountdownStatus) callback) {
    // TODO: implement onStatusChanged
    throw UnimplementedError();
  }

  @override
  onTimeChanged(void Function(Duration) callback) {
    // TODO: implement onTimeChanged
    throw UnimplementedError();
  }

  @override
  pause() {
    _statusController.add(CountdownStatus.paused);
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
    _statusController.add(CountdownStatus.running);
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

class TimerMock {}

void main() {
  late Countdown countdown;

  setUpAll(() {
    countdown = CountdownTimer();
  });

  test(
    "Should test if countdown start",
    () {
      countdown.start();
      expect(countdown.status, CountdownStatus.running);
    },
  );

  test("Should pause countdown", () {
    countdown.start();
    countdown.pause();
    expect(countdown.status, CountdownStatus.paused);
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
