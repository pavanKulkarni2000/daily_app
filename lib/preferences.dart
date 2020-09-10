import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

setPhone(String phone) async {
  await prefs.setString('phone', phone);
}

setMilk(double milk) async {
  await prefs.setDouble('milk', milk);
}

setCurd(double curd) async {
  await prefs.setDouble('curd', curd);
}

Future<String> getPhone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString('phone');
  return stringValue;
}

getData(Map map) async {
  String phone;
  phone = prefs.getString('phone');
  if (phone == null) {
    print("setting phone");
    phone = "9035163860";
    await prefs.setString('phone', phone);
  }
  double milk;
  milk = prefs.getDouble('milk');
  if (milk == null) {
    print("setting price1");
    milk = 20;
    await prefs.setDouble('milk', milk);
  }
  double curd;
  curd = prefs.getDouble('curd');
  if (curd == null) {
    print("setting price2");
    curd = 21;
    await prefs.setDouble('curd', curd);
  }

  bool today;
  today = prefs.getBool('today');
  if (today == null) {
    print("setting today");
    today = false;
    await prefs.setBool('today', today);
  }
  // SharedPreferences.setMockInitialValues(map);
  map = Map.from({'phone': phone, 'milk': milk, 'curd': curd, 'today': today});
  return map;
}
