package com.example.daily_app;

import android.app.Activity;
import android.app.Dialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.time.Instant;

public class BottomSheetActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        SharedPreferences sharedPref = getApplicationContext().getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE | Context.MODE_MULTI_PROCESS);

        this.setTitle(null);
        CustomBottomSheetFragment bottomSheet = new CustomBottomSheetFragment(this, sharedPref);
        bottomSheet.show(getSupportFragmentManager(), CustomBottomSheetFragment.tag);
    }

    public static class CustomBottomSheetFragment extends BottomSheetDialogFragment implements View.OnClickListener {
        public static final String tag = "mybottomsheet";
        private Activity callingActivity;
        private SharedPreferences sharedPref;

        CustomBottomSheetFragment(Activity a, SharedPreferences s) {
            callingActivity = a;
            sharedPref = s;
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                                 @Nullable Bundle savedInstanceState) {
            return inflater.inflate(R.layout.bottom_sheet, container, false);
        }

        @Override
        public void onViewCreated(@NonNull View v, @Nullable Bundle savedInstanceState) {
            super.onViewCreated(v, savedInstanceState);
            v.setBackgroundColor(Color.TRANSPARENT);
            v.findViewById(R.id.opt0).setOnClickListener(this);
            v.findViewById(R.id.opt1).setOnClickListener(this);
            v.findViewById(R.id.opt2).setOnClickListener(this);
            v.findViewById(R.id.cancel).setOnClickListener(this);
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
            BottomSheetDialog dialog = new BottomSheetDialog(callingActivity, R.style.MyTransparentBottomSheetDialogTheme);
            dialog.setCancelable(false);
            dialog.setCanceledOnTouchOutside(false);
            return dialog;
        }

        @RequiresApi(api = Build.VERSION_CODES.O)
        @Override
        public void onClick(View view) {
            switch (view.getId()) {
                case R.id.opt0:
                    selection(getString(R.string.op0), 0);
                    break;
                case R.id.opt1:
                    selection(getString(R.string.op1), 1);
                    break;
                case R.id.opt2:
                    selection(getString(R.string.op2), 2);
                    break;
                case R.id.cancel:
                    Log.d("option", "cancel");
                    dismiss();
                    break;
            }
        }

        @RequiresApi(api = Build.VERSION_CODES.O)
        void selection(String option, int code) {
            Log.d("phone", sharedPref.getString("flutter.phone", ""));
            new updationThread(sharedPref.getString("flutter.phone", ""), option, code).start();

            SharedPreferences.Editor editor = sharedPref.edit();
            editor.putBoolean("flutter.today", true);
            editor.apply();

            dismiss();
        }

        @Override
        public void onDismiss(@NonNull DialogInterface dialog) {
            super.onDismiss(dialog);
            callingActivity.finish();
        }

        private class updationThread extends Thread {
            String phone;
            String option;
            int code;

            updationThread(String ph, String opt, int itemCode) {
                phone = ph;
                option = opt;
                code = itemCode;
            }

            @RequiresApi(api = Build.VERSION_CODES.O)
            @Override
            public void run() {
                try {
                    SmsManager smsManager = SmsManager.getDefault();
                    smsManager.sendTextMessage(phone, null, option + " ಬೇಕು", null, null);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                try {
                    SQLiteDatabase database = SQLiteDatabase.openDatabase(getContext().getDataDir().getPath(), null, 0);
                    ContentValues values = new ContentValues();
                    values.put("date", Instant.now().toEpochMilli());
                    values.put("purchase", code);
                    database.insert("my_table", null, values);
                } catch (Exception e) {
                    System.out.println("couldn't update choice to database, error: " + e);
                }
            }
        }
    }

}