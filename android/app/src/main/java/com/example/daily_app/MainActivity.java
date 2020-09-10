package com.example.daily_app;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsManager;

import java.util.Calendar;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "nativeHelper";

    private MethodChannel.Result callResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("send")) {
                            String num = call.argument("phone");
                            String msg = call.argument("msg");
                            sendSMS(num, msg, result);
                        } else if (call.method.equals("setAlarm")) {
                            setAlarm(result);
                        } else {
                            result.notImplemented();
                        }
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

    private void setAlarm(MethodChannel.Result result) {
        try {
            PendingIntent operation1 = PendingIntent.getService(getApplicationContext(),
                    0, new Intent(getBaseContext(), ResetService.class), PendingIntent.FLAG_UPDATE_CURRENT);

            PendingIntent operation2 = PendingIntent.getActivity(getApplicationContext(),
                    0, new Intent(getBaseContext(), BottomSheetActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);

            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            AlarmManager alarmManager = (AlarmManager) getBaseContext().getSystemService(ALARM_SERVICE);
            calendar.set(Calendar.HOUR_OF_DAY, 9);
            alarmManager.setInexactRepeating(AlarmManager.RTC, calendar.getTimeInMillis(), AlarmManager.INTERVAL_DAY, operation1);
            calendar.set(Calendar.HOUR_OF_DAY, 17);
            calendar.set(Calendar.MINUTE, 30);
            alarmManager.setInexactRepeating(AlarmManager.RTC, calendar.getTimeInMillis(), AlarmManager.INTERVAL_DAY, operation2);
            result.success("registered");
        } catch (Exception ex) {
            ex.printStackTrace();
            result.error("alarm", "couldn't register", "");
        }
    }

}
