// ignore_for_file: avoid_print

import 'package:countdown/countdown.dart';

void main(List<String> arguments) async {
  final Countdown countdown =
      CountdownTimer(const Duration(seconds: 5), stopwatch: Stopwatch());

  countdown.onTimeChanged(print);

  countdown.onStatusChanged(print);

  countdown.onDone(() {
    print("Done");
  });

  countdown.play();

  await Future.delayed(const Duration(seconds: 2));

  countdown.pause();

  await Future.delayed(const Duration(seconds: 2));

  countdown.play();
}
