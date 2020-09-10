import 'package:daily_app/myScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'preferences.dart';

Map data;

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(data),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data;
            return SettingsScreen();
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return errorScreen(snapshot.error);
          } else {
            print("waiting");
            return waitingScreen();
          }
        });
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool phone = false,
      milk = false,
      curd = false,
      today = prefs.getBool('today');
  TextEditingController controller1, controller2, controller3;

  @override
  void initState() {}

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller1 = TextEditingController(text: data['phone']);
    controller2 = TextEditingController(text: data['milk'].toString());
    controller3 = TextEditingController(text: data['curd'].toString());
    return Wrap(
      verticalDirection: VerticalDirection.down,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 80, 20),
          child: Wrap(
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                controller: controller1,
                readOnly: !phone,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Phone"),
              ),
              Wrap(
                spacing: 10,
                children: [
                  RaisedButton(
                    child: Text("Edit"),
                    onPressed: () =>
                        phone ? null : setState(() => phone = true),
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                    // splashColor: phone?null:Colors.grey,
                  ),
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () => {
                      if (!phone)
                        null
                      else
                        {
                          setState(() => phone = false),
                          data['phone'] = controller1.text,
                          setPhone(controller1.text)
                        },
                    },
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 80, 20),
          child: Wrap(
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                controller: controller2,
                readOnly: !milk,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "ಹಾಲು"),
              ),
              Wrap(
                spacing: 10,
                children: [
                  RaisedButton(
                    child: Text("Edit"),
                    onPressed: () => milk ? null : setState(() => milk = true),
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                    // splashColor: phone?null:Colors.grey,
                  ),
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () => {
                      if (!milk)
                        null
                      else
                        {
                          setState(() => milk = false),
                          data['milk'] = double.parse(controller2.text),
                          setMilk(data['milk'])
                        },
                    },
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 80, 20),
          child: Wrap(
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                controller: controller3,
                readOnly: !curd,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "ಮೊಸರು"),
              ),
              Wrap(
                spacing: 10,
                children: [
                  RaisedButton(
                    child: Text("Edit"),
                    onPressed: () => curd ? null : setState(() => curd = true),
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                    // splashColor: phone?null:Colors.grey,
                  ),
                  RaisedButton(
                    child: Text("OK"),
                    onPressed: () => {
                      if (!curd)
                        null
                      else
                        {
                          setState(() => curd = false),
                          data['curd'] = double.parse(controller3.text),
                          setCurd(data['curd'])
                        },
                    },
                    textTheme: ButtonTextTheme.accent,
                    color: Colors.white,
                    disabledTextColor: Colors.grey,
                    shape: BeveledRectangleBorder(
                        side: BorderSide(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: Text(
                "Today's Purchase over : ",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Switch(
              value: today,
              onChanged: (status) => setState(
                  () => {today = status, prefs.setBool('today', status)}),
            ),
          ],
        )
      ],
    );
  }
}
