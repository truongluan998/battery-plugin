import Flutter
import UIKit

enum BatteryState {
  static let charging = "charging"
  static let discharging = "discharging"
}

public class BatteryPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "chat_gpt/battery", binaryMessenger: registrar.messenger())
    let instance = BatteryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let eventChannel = FlutterEventChannel(name: "chat_gpt/battery/event", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getBatteryLevel" : result(getBatteryLevel()); break
    case "isInBatterySaveMode" :receiveIsInBatterySaveMode(result:result); break
    case "getBatteryState": getBatteryState(result:result); break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  private func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        UIDevice.current.isBatteryMonitoringEnabled = false
        return batteryLevel
  }

  private func getBatteryState(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        switch device.batteryState {
            case UIDevice.BatteryState.full:
                result("full");break
            case UIDevice.BatteryState.charging:
                result("charging");break
            case UIDevice.BatteryState.unplugged:
                result("unplugged");break
            default:
                result(FlutterError(code: "UNAVAILABLE",
                                         message: "Battery level not available.",
                                                                 details: nil)); break
        }
  }
  private func receiveIsInBatterySaveMode(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery level not available.",
                            details: nil))
      } else {
        result(ProcessInfo.processInfo.isLowPowerModeEnabled)
      }
  }
  
  
  public func onListen(withArguments arguments: Any?,
                      eventSink: @escaping FlutterEventSink) -> FlutterError? {
  self.eventSink = eventSink
  UIDevice.current.isBatteryMonitoringEnabled = true
  sendBatteryStateEvent()
  NotificationCenter.default.addObserver(self, selector: #selector(onBatteryStateDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)

  return nil
  }
  @objc private func onBatteryStateDidChange(notification: NSNotification) {
      sendBatteryStateEvent()
    }
  private func sendBatteryStateEvent() {
    guard let eventSink = eventSink else {
      return
    }

    switch UIDevice.current.batteryState {
    case .full:
      eventSink(BatteryState.charging)
    case .charging:
      eventSink(BatteryState.charging)
    case .unplugged:
      eventSink(BatteryState.discharging)
    default:
        eventSink(FlutterError(code: "UNAVAILABLE",
                                      message: "Charging status unavailable",
                                      details: nil))
    }
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      NotificationCenter.default.removeObserver(self)
      eventSink = nil
      return nil
  }
}
