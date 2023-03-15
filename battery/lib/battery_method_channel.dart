import 'package:battery/src/enum.dart';
import 'package:battery/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'battery_platform_interface.dart';

/// An implementation of [BatteryPlatform] that uses method channels.
class MethodChannelBattery extends BatteryPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery');

  final batteryChannel = const MethodChannel('chat_gpt/battery');
  final batteryEventChannel = const EventChannel('chat_gpt/battery/event');

  Stream<BatteryState>? _onBatteryStateChanged;

  @override
  Future<int?> getBatteryLevel() async =>
      await batteryChannel.invokeMethod('getBatteryLevel').then<int>((dynamic value) => value);

  @override
  Future<bool> isInBatterySaveMode() async =>
      await batteryChannel.invokeMethod<bool>('isInBatterySaveMode').then<bool>((dynamic result) => result);

  @override
  Future<BatteryState> batteryState() => batteryChannel.invokeMethod<String>('getBatteryState').then<BatteryState>(
        (dynamic result) => parseBatteryState(result),
  );

  @override
  Stream<BatteryState> onBatteryStateChanged() {
    _onBatteryStateChanged ??= batteryEventChannel.receiveBroadcastStream().map(
          (dynamic event) => parseBatteryState(event),
    );
    return _onBatteryStateChanged!;
  }
}
