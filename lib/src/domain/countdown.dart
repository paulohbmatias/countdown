import 'countdown_status.dart';

abstract class Countdown {
  CountdownStatus get status;
  Duration get duration;
  Duration get remaningTime;
  reset();
  setDuration(Duration duration);
  stop();
  start();
  pause();
  onTimeChanged(void Function(Duration) callback);
  onStatusChanged(void Function(CountdownStatus) callback);
  onDone();
}
