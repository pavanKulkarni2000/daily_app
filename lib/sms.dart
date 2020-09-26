import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dbHelper.dart';

const platform = const MethodChannel('nativeHelper');

Future sendSms(int i, recipient) async {
  await Permission.sms.request();
  // if(! await Permission.sms.isGranted | await Permission.sms.isUndetermined)
  //   if(!await Permission.sms.request().isGranted)
  //     return;
  String message = DatabaseHelper.items[i];
  if (i != 3)
    message += " ಬೇಕು";
  else
    message = DatabaseHelper.items[2] + " " + message;

  print("trying to send SMS");
  try {
    final String result = await platform.invokeMethod(
        'send', <String, dynamic>{"phone": "+91" + recipient, "msg": message});
    print(result);
  } on PlatformException catch (e) {
    print(e.toString());
  }
}
