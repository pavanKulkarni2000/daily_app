import 'package:daily_app/myScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                  RawMaterialButton(
                    padding: EdgeInsets.all(10.0),
                    disabledElevation: 0,
                    fillColor: phone ? Colors.black45 : Colors.white,
                    textStyle: TextStyle(
                        color: phone ? Colors.white70 : Colors.black,
                        fontStyle: phone ? FontStyle.italic : FontStyle.normal),
                    child: Text("Edit"),
                    onPressed: () =>
                        phone ? null : setState(() => phone = true),
                  ),
                  RawMaterialButton(
                      padding: EdgeInsets.all(10.0),
                      disabledElevation: 0,
                      fillColor: !phone ? Colors.black45 : Colors.white,
                      child: Text("OK"),
                      textStyle: TextStyle(
                          color: !phone ? Colors.white70 : Colors.black,
                          fontStyle:
                              !phone ? FontStyle.italic : FontStyle.normal),
                      onPressed: () => {
                            if (!phone)
                              null
                            else
                              {
                                setState(() => phone = false),
                                data['phone'] = controller1.text,
                                setPhone(controller1.text)
                              },
                          }),
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
                  RawMaterialButton(
                    padding: EdgeInsets.all(10.0),
                    disabledElevation: 0,
                    fillColor: milk ? Colors.black45 : Colors.white,
                    textStyle: TextStyle(
                        color: milk ? Colors.white70 : Colors.black,
                        fontStyle: milk ? FontStyle.italic : FontStyle.normal),
                    child: Text("Edit"),
                    onPressed: () => milk ? null : setState(() => milk = true),
                  ),
                  RawMaterialButton(
                      padding: EdgeInsets.all(10.0),
                      disabledElevation: 0,
                      fillColor: !milk ? Colors.black45 : Colors.white,
                      child: Text("OK"),
                      textStyle: TextStyle(
                          color: !milk ? Colors.white70 : Colors.black,
                          fontStyle: !milk ? FontStyle.italic : FontStyle
                              .normal),
                      onPressed: () =>
                      {
                        if (!milk)
                          null
                        else
                          {
                            setState(() => milk = false),
                            data['milk'] = controller2.text,
                            setMilk(data['milk'])
                          },
                      }
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

                  RawMaterialButton(
                    padding: EdgeInsets.all(10.0),
                    disabledElevation: 0,
                    fillColor: curd ? Colors.black45 : Colors.white,
                    textStyle: TextStyle(
                        color: curd ? Colors.white70 : Colors.black,
                        fontStyle: curd ? FontStyle.italic : FontStyle.normal),
                    child: Text("Edit"),
                    onPressed: () => curd ? null : setState(() => curd = true),
                  ),
                  RawMaterialButton(
                      padding: EdgeInsets.all(10.0),
                      disabledElevation: 0,
                      fillColor: !curd ? Colors.black45 : Colors.white,
                      child: Text("OK"),
                      textStyle: TextStyle(
                          color: !curd ? Colors.white70 : Colors.black,
                          fontStyle: !curd ? FontStyle.italic : FontStyle
                              .normal),
                      onPressed: () =>
                      {
                        if (!curd)
                          null
                        else
                          {
                            setState(() => curd = false),
                            data['curd'] = controller3.text,
                            setCurd(data['curd'])
                          },
                      }
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
