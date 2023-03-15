package com.example.mock_project.battery

import android.content.*
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class BatteryPlugin : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, FlutterPlugin {
  private var applicationContext: Context? = null
  private var chargingStateChangeReceiver: BroadcastReceiver? = null
  private var methodChannel: MethodChannel? = null
  private var eventChannel: EventChannel? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    this.applicationContext = binding.applicationContext
    methodChannel = MethodChannel(binding.binaryMessenger, "chat_gpt/battery")
    eventChannel = EventChannel(binding.binaryMessenger, "chat_gpt/battery/event")
    eventChannel!!.setStreamHandler(this)
    methodChannel!!.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = null
    methodChannel!!.setMethodCallHandler(null)
    methodChannel = null
    eventChannel!!.setStreamHandler(null)
    eventChannel = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getBatteryLevel" -> {
        val currentBatteryLevel = getBatteryLevel()
        if (currentBatteryLevel != -1) {
          result.success(currentBatteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
      }
      "getBatteryState" -> {
        val currentBatteryStatus = getBatteryStatus()
        if (currentBatteryStatus != null) {
          result.success(currentBatteryStatus)
        } else {
          result.error("UNAVAILABLE", "Charging status not available.", null)
        }
      }
      "isInBatterySaveMode" -> {
        val isInPowerSaveMode = isInPowerSaveMode()
        if (isInPowerSaveMode != null) {
          result.success(isInPowerSaveMode)
        } else {
          result.error("UNAVAILABLE", "Battery save mode not available.", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    chargingStateChangeReceiver = createChargingStateChangeReceiver(events)
    applicationContext?.registerReceiver(chargingStateChangeReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val status = getBatteryStatus()
    publishBatteryStatus(events, status)
  }

  override fun onCancel(arguments: Any?) {
    applicationContext!!.unregisterReceiver(chargingStateChangeReceiver)
    chargingStateChangeReceiver = null
  }

  private fun getBatteryStatus(): String? {
    val status: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      getBatteryProperty(BatteryManager.BATTERY_PROPERTY_STATUS)
    } else {
      val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    }
    return convertBatteryStatus(status)
  }

  private fun getBatteryLevel(): Int {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      getBatteryProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      val level = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
      val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
      (level * 100 / scale)
    }
  }

  private fun isInPowerSaveMode(): Boolean? {
    val deviceManufacturer = Build.MANUFACTURER.lowercase(Locale.getDefault())

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      when (deviceManufacturer) {
        "xiaomi" -> isXiaomiPowerSaveModeActive()
        "huawei" -> isHuaweiPowerSaveModeActive()
        "samsung" -> isSamsungPowerSaveModeActive()
        else -> {
          val powerManager = applicationContext!!.getSystemService(Context.POWER_SERVICE) as PowerManager
          powerManager.isPowerSaveMode
        }
      }
    } else {
      null
    }
  }

  private fun isSamsungPowerSaveModeActive(): Boolean {
    val mode = Settings.System.getString(applicationContext!!.contentResolver, "psm_switch")
    return if (mode == null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      val powerManager = applicationContext!!.getSystemService(Context.POWER_SERVICE) as PowerManager
      powerManager.isPowerSaveMode
    } else {
      POWER_SAVE_MODE_SAMSUNG == mode
    }
  }

  private fun isHuaweiPowerSaveModeActive(): Boolean? {
    val mode = Settings.System.getInt(applicationContext!!.contentResolver, "SmartModeStatus", -1)
    return if (mode != -1) {
      mode == POWER_SAVE_MODE_HUAWEI
    } else {
      null
    }
  }

  private fun isXiaomiPowerSaveModeActive(): Boolean? {
    val mode = Settings.System.getInt(applicationContext!!.contentResolver, "POWER_SAVE_MODE_OPEN", -1)
    return if (mode != -1) {
      mode == POWER_SAVE_MODE_XIAOMI
    } else {
      null
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private fun getBatteryProperty(property: Int): Int {
    val batteryManager = applicationContext!!.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(property)
  }

  private fun createChargingStateChangeReceiver(events: EventChannel.EventSink): BroadcastReceiver {
    return object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        publishBatteryStatus(events, convertBatteryStatus(status))
      }
    }
  }

  private fun convertBatteryStatus(status: Int): String? {
    return when (status) {
      BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
      BatteryManager.BATTERY_STATUS_FULL -> "full"
      BatteryManager.BATTERY_STATUS_DISCHARGING, BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "discharging"
      BatteryManager.BATTERY_STATUS_UNKNOWN -> "unknown"
      else -> null
    }
  }

  private fun publishBatteryStatus(events: EventChannel.EventSink, status: String?) {
    if (status != null) {
      events.success(status)
    } else {
      events.error("UNAVAILABLE", "Charging status unavailable", null)
    }
  }

  companion object {
    private const val POWER_SAVE_MODE_SAMSUNG = "1"
    private const val POWER_SAVE_MODE_XIAOMI = 1
    private const val POWER_SAVE_MODE_HUAWEI = 4
  }
}
