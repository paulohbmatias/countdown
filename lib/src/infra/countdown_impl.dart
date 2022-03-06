import 'dart:async';

import 'package:clock/clock.dart';
import 'package:rxdart/subjects.dart';

import '../domain/countdown.dart';
import '../domain/countdown_error.dart';
import '../domain/countdown_exception.dart';
import '../domain/countdown_status.dart';

class CountdownTimer implements Countdown {
  final _statusController = BehaviorSubject<CountdownStatus>();
  final _durationController = BehaviorSubject<Duration>();

  void Function(CountdownStatus)? onStatusCallback;
  void Function(Duration)? onTimeChangedCallback;
  void Function()? _onDone;
  late Timer timer;
  Duration _duration;

  CountdownTimer(this._duration);

  @override
  Duration get duration => _duration;

  @override
  onDone(void Function() callback) {
    _onDone = callback;
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
    _verifyInitialized();
    clock.stopwatch().stop();
    _setStatus(CountdownStatus.paused);
  }

  @override
  Duration get remaningTime =>
      _durationController.hasValue ? _durationController.value : _duration;

  @override
  void reset() {
    clock.stopwatch().stop();
    clock.stopwatch().reset();

    _durationController.add(duration);

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

  _verifyInitialized() {
    if (status == CountdownStatus.notStarted) {
      throw (CountdownException(
          description: "Countdown not started",
          erro: CountdownError.countdownNotInitialized));
    }
  }

  _listenTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (onTimeChangedCallback != null) {
        final elapsed = clock.stopwatch().elapsed;

        if (elapsed.isNegative) {
          if (_onDone != null) {
            _onDone!();
          }
          reset();
        }

        _durationController.add(_duration - elapsed);
        onTimeChangedCallback!(_durationController.value);
      }
    });
  }

  @override
  CountdownStatus get status => _statusController.hasValue
      ? _statusController.value
      : CountdownStatus.notStarted;

  @override
  stop() {
    _verifyInitialized();
    clock.stopwatch().stop();
    clock.stopwatch().reset();
    _setStatus(CountdownStatus.notStarted);
  }
}
