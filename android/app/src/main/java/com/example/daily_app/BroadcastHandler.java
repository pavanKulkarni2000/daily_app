package com.example.daily_app;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.time.Instant;
import java.util.Calendar;

public class BroadcastHandler extends BroadcastReceiver {
    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onReceive(Context context, Intent intent) {

        LocalBroadcastManager.getInstance(context).sendBroadcast(new Intent("daily_app.stopActivity"));

        SharedPreferences preferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("flutter.alarm", String.valueOf(Instant.now().toEpochMilli()));
        editor.apply();

        Log.d("received", intent.getStringExtra("start"));

        if (intent.getStringExtra("start").equals("service")) {

            Log.d("morning reset", "started");

            Intent intent1 = new Intent(context, BroadcastHandler.class);
            intent1.putExtra("start", "service");
            PendingIntent operation1 = PendingIntent.getBroadcast(context,
                    13, intent1, PendingIntent.FLAG_UPDATE_CURRENT);

            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.DATE, 1);
            calendar.set(Calendar.HOUR_OF_DAY, 9);
            alarmManager.setExact(AlarmManager.RTC, calendar.getTimeInMillis(), operation1);

            if (preferences.getBoolean("flutter.today", true)) {
                editor.putBoolean("flutter.today", false);
                editor.apply();
            }

            Log.d("morning reset", "finished");

        } else if (intent.getStringExtra("start").equals("activity")) {

            Log.d("evening", "started");

            Intent intent2 = new Intent(context, BroadcastHandler.class);
            intent2.putExtra("start", "activity");
            PendingIntent operation2 = PendingIntent.getBroadcast(context,
                    14, intent2, PendingIntent.FLAG_UPDATE_CURRENT);

            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.DATE, 1);
            calendar.set(Calendar.HOUR_OF_DAY, 11);
            calendar.set(Calendar.MINUTE, 30);
            alarmManager.setExact(AlarmManager.RTC, calendar.getTimeInMillis(), operation2);

            if (!preferences.getBoolean("flutter.today", true)) {

                context.startActivity(new Intent(context, BottomSheetActivity.class)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));

            }

            Log.d("evening", "finished");
        }
    }
}
