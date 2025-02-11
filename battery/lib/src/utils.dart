import 'enum.dart';

BatteryState parseBatteryState(String state) {
  switch (state) {
    case 'full':
      return BatteryState.full;
    case 'charging':
      return BatteryState.charging;
    case 'discharging':
      return BatteryState.discharging;
    case 'unknown':
      return BatteryState.unknown;
    default:
      throw ArgumentError('$state is not a valid BatteryState.');
  }
}