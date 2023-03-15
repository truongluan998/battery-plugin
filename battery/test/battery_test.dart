import 'package:battery/src/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery/battery_imp.dart';
import 'package:battery/battery_platform_interface.dart';
import 'package:battery/battery_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBatteryPlatform
    with MockPlatformInterfaceMixin
    implements BatteryPlatform {

  @override
  Future<BatteryState> batteryState() {
    // TODO: implement batteryState
    throw UnimplementedError();
  }

  @override
  Future<int?> getBatteryLevel() {
    // TODO: implement getBatteryLevel
    throw UnimplementedError();
  }

  @override
  Future<bool> isInBatterySaveMode() {
    // TODO: implement isInBatterySaveMode
    throw UnimplementedError();
  }

  @override
  Stream<BatteryState> onBatteryStateChanged() {
    // TODO: implement onBatteryStateChanged
    throw UnimplementedError();
  }
}

void main() {
  final BatteryPlatform initialPlatform = BatteryPlatform.instance;

  test('$MethodChannelBattery is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBattery>());
  });

  test('getPlatformVersion', () async {
    BatteryImp batteryPlugin = BatteryImp();
    MockBatteryPlatform fakePlatform = MockBatteryPlatform();
    BatteryPlatform.instance = fakePlatform;

    expect(await batteryPlugin.getBatteryLevel(), '42');
  });
}
