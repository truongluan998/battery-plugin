import 'package:battery/src/enum.dart';

import 'battery_platform_interface.dart';

class BatteryImp {
  Future<int?> getBatteryLevel() async => await BatteryPlatform.instance.getBatteryLevel();

  Future<bool> isInBatterySaveMode() async => await BatteryPlatform.instance.isInBatterySaveMode();

  Future<BatteryState> batteryState() async => await BatteryPlatform.instance.batteryState();

  Stream<BatteryState> onBatteryStateChanged() => BatteryPlatform.instance.onBatteryStateChanged();
}
