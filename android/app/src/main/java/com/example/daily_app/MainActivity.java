package com.example.daily_app;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.telephony.SmsManager;

import androidx.annotation.RequiresApi;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Calendar;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "nativeHelper";

    private MethodChannel.Result callResult;

    private BroadcastReceiver activityStopper = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d("receiver", "Got message: ");
            finish();
        }
    };

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LocalBroadcastManager.getInstance(this).registerReceiver(activityStopper,
                new IntentFilter("daily_app.stopActivity"));

        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("send")) {
                        String num = call.argument("phone");
                        String msg = call.argument("msg");
                        sendSMS(num, msg, result);
                    } else if (call.method.equals("setAlarm")) {
                        setAlarm(result);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private void sendSMS(String phoneNo, String msg, MethodChannel.Result result) {
        try {
            SmsManager smsManager = SmsManager.getDefault();
            smsManager.sendTextMessage(phoneNo, null, msg, null, null);
            result.success("SMS Sent");
        } catch (Exception ex) {
            ex.printStackTrace();
            result.error("Err", "Sms Not Sent", "");
        }
    }

    @Override
    protected void onDestroy() {
        // Unregister since the activity is about to be closed.
        LocalBroadcastManager.getInstance(this).unregisterReceiver(activityStopper);
        super.onDestroy();
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void setAlarm(MethodChannel.Result result) {
        SharedPreferences preferences = getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
        );
        try {
            Instant instant = Instant.
                    ofEpochMilli(
                            Long.parseLong(
                                    preferences.getString(
                                            "flutter.alarm", "0")
                            )
                    );
            if (ChronoUnit.DAYS.between(instant, Instant.now()) < 2) {
                result.success("already set");
                return;
            }

            SharedPreferences.Editor editor = preferences.edit();
            editor.putString("flutter.alarm", String.valueOf(Instant.now().toEpochMilli()));
            editor.apply();

            Intent intent1 = new Intent(getBaseContext(), BroadcastHandler.class);
            intent1.putExtra("start", "service");
            PendingIntent operation1 = PendingIntent.getBroadcast(getApplicationContext(),
                    13, intent1, PendingIntent.FLAG_UPDATE_CURRENT);

            Intent intent2 = new Intent(getBaseContext(), BroadcastHandler.class);
            intent2.putExtra("start", "activity");
            PendingIntent operation2 = PendingIntent.getBroadcast(getApplicationContext(),
                    14, intent2, PendingIntent.FLAG_UPDATE_CURRENT);

            AlarmManager alarmManager = (AlarmManager) getBaseContext().getSystemService(ALARM_SERVICE);
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.DATE, 1);
            calendar.set(Calendar.HOUR_OF_DAY, 11);
            calendar.set(Calendar.MINUTE, 30);
            alarmManager.setExact(AlarmManager.RTC, calendar.getTimeInMillis(), operation2);
            calendar.set(Calendar.HOUR_OF_DAY, 9);
            alarmManager.setExact(AlarmManager.RTC, calendar.getTimeInMillis(), operation1);
            result.success("registered");
        } catch (Exception ex) {
            ex.printStackTrace();
            result.error("alarm", "couldn't register", "");
        }
    }

}
