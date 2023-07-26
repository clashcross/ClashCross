package com.clashcross.clashcross

import alihoseinpoor.com.open_settings.OpenSettingsPlugin
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.ProxyInfo
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat
import com.baseflow.permissionhandler.PermissionHandlerPlugin
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import com.kaivean.system_proxy.SystemProxyPlugin
import com.mr.flutter.plugin.filepicker.FilePickerPlugin
import com.tekartik.sqflite.SqflitePlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin
import io.flutter.plugins.imagepicker.ImagePickerPlugin
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import io.flutter.plugins.urllauncher.UrlLauncherPlugin
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin
import io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin
import java.net.Socket

class FClashVPNService : VpnService() {

    companion object {
        const val TAG = "ClashCrossPlugin"
        const val CHANNEL = "ClashCrossVpn"

        enum class Action {
            StartProxy,
            StopProxy,
            SetHttpPort
        }
    }

    private var mFd: ParcelFileDescriptor? = null
    private var serverPort = 7890
        set(value) {
            field = value
        }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "creating fclash vpn service.")
        val channel = NotificationChannel(CHANNEL, "ClashCross", NotificationManager.IMPORTANCE_HIGH)
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        val notification = with(NotificationCompat.Builder(this, CHANNEL)) {
            setContentTitle("ClashCross启动")
            setContentText("ClashCross正在运行")
            build()
        }
        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            when (it.action) {
                "start" -> {
//                    stopVpnService()
                    startVpnService()
                    return START_STICKY
                }
                "stop" -> {
                    stopVpnService()
                    stopForeground(Service.STOP_FOREGROUND_REMOVE)
                    stopSelf()
                    return START_NOT_STICKY
                }
                Action.SetHttpPort.toString() -> {
                    val port = it.extras!!.getInt("port")
                    this.serverPort = port
                    if (mFd != null) {
                        stopVpnService()
                        startVpnService()
                    }
                }
                else -> {
                    return START_NOT_STICKY
                }
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopVpnService()
        super.onDestroy()
    }

    private fun startVpnService() {
        mFd?.close()
        mFd = with(Builder()) {
            addAddress("10.0.0.2", 32)
            setMtu(1500)
            setHttpProxy(ProxyInfo.buildDirectProxy("127.0.0.1", serverPort))
            setSession("FClash服务")
            establish()
        }
        if (mFd == null) {
            Log.e("FClash", "Interface creation failed")
        }
    }

    private fun stopVpnService() {
        try {
            // Close the VPN interface
            mFd?.close()
            Log.d(TAG, "fclash service stopped")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}