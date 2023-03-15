import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery/battery_method_channel.dart';

void main() {
  MethodChannelBattery platform = MethodChannelBattery();
  const MethodChannel channel = MethodChannel('battery');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getBatteryLevel(), '42');
  });
}
