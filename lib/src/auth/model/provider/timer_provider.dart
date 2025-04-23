import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A StateNotifier to manage a timer, which counts down from 60 seconds.
class TimerNotifier extends StateNotifier<int> {
  // Initialize the timer state with 60 seconds.
  TimerNotifier() : super(60);

  // Private Timer object to handle the periodic countdown.
  Timer? _timer;

  // Starts the timer that counts down every second.
  void startTimer() {
    // Cancel any existing timer before starting a new one.
    _timer?.cancel();
    // Reset the state to 60 seconds when starting the timer.
    state = 60;

    // Create a periodic timer that ticks every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Ensure the widget is still mounted before updating the state.
      if (!mounted) {
        timer.cancel(); // Cancel the timer if the widget is not mounted.
        return;
      }

      // If the timer is still running, decrement the state (countdown).
      if (state > 0) {
        state--;
      } else {
        // Cancel the timer once the state reaches 0.
        timer.cancel();
      }
    });
  }

  // Resets the timer back to 60 seconds and cancels any active timer.
  void resetTimer() {
    _timer?.cancel(); // Cancel the current timer.
    state = 60; // Reset the state to 60 seconds.
  }

  // Dispose the timer when the notifier is disposed.
  @override
  void dispose() {
    _timer?.cancel(); // Ensure the timer is canceled when disposed.
    super.dispose(); // Call the super dispose method.
  }
}

// A Riverpod provider that manages the TimerNotifier.
final timerProvider =
    StateNotifierProvider<TimerNotifier, int>((ref) => TimerNotifier());
