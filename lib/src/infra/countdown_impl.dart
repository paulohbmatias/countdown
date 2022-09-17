import 'dart:async';

import 'package:rxdart/subjects.dart';

import '../domain/countdown.dart';
import '../domain/countdown_error.dart';
import '../domain/countdown_exception.dart';
import '../domain/countdown_status.dart';

class CountdownTimer implements Countdown {
  final _statusController = BehaviorSubject<CountdownStatus>();
  final _durationController = BehaviorSubject<Duration>();
  final Stopwatch stopwatch;

  void Function(CountdownStatus)? onStatusCallback;
  void Function(Duration)? onTimeChangedCallback;
  void Function()? _onDone;
  late Timer timer;
  Duration _duration;

  CountdownTimer(
    this._duration, {
    required this.stopwatch,
  });

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
    stopwatch.stop();
    _setStatus(CountdownStatus.paused);
  }

  @override
  Duration get remaningTime =>
      _durationController.hasValue ? _durationController.value : _duration;

  @override
  void reset() {
    stop();
    _durationController.add(duration);
  }

  @override
  stop() {
    _verifyInitialized();
    timer.cancel();
    stopwatch.stop();
    stopwatch.reset();
    _setStatus(CountdownStatus.notStarted);
    _durationController.add(duration);
  }

  @override
  set duration(Duration duration) {
    _duration = duration;
  }

  @override
  play() {
    if (status == CountdownStatus.notStarted) {
      _listenTime();
    }
    stopwatch.start();
    _setStatus(CountdownStatus.running);
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
      final remaining = _duration.inSeconds - stopwatch.elapsed.inSeconds;
      if (remaining.isNegative) {
        if (_onDone != null) {
          _onDone!();
        }
        reset();
        return;
      }
      _durationController.add(Duration(seconds: remaining));
      if (onTimeChangedCallback != null) {
        onTimeChangedCallback!(_durationController.value);
      }
    });
  }

  @override
  CountdownStatus get status => _statusController.hasValue
      ? _statusController.value
      : CountdownStatus.notStarted;
}
