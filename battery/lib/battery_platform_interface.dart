import 'package:battery/src/enum.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'battery_method_channel.dart';

export 'src/enum.dart';

abstract class BatteryPlatform extends PlatformInterface {
  /// Constructs a BatteryPlatform.
  BatteryPlatform() : super(token: _token);

  static final Object _token = Object();

  static BatteryPlatform _instance = MethodChannelBattery();

  /// The default instance of [BatteryPlatform] to use.
  ///
  /// Defaults to [MethodChannelBattery].
  static BatteryPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BatteryPlatform] when
  /// they register themselves.
  static set instance(BatteryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<int?> getBatteryLevel() {
    throw UnimplementedError('batteryLevel() has not been implemented.');
  }

  Future<bool> isInBatterySaveMode() {
    throw UnimplementedError('isInBatterySaveMode() has not been implemented.');
  }

  /// Returns the current battery state in percent.
  Future<BatteryState> batteryState() {
    throw UnimplementedError('batteryState() has not been implemented.');
  }

  /// Returns a Stream of BatteryState changes.
  Stream<BatteryState> onBatteryStateChanged() {
    throw UnimplementedError('get onBatteryStateChanged has not been implemented.');
  }
}
