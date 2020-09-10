import 'package:daily_app/myScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history.dart';
import 'dbHelper.dart';
import 'settings.dart';
import 'sms.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: HomePage(title: 'ನಂದಿನಿ'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

SharedPreferences prefs;

class _HomePageState extends State<HomePage> {
  int currentTab = 1;
  Widget currentPage;
  List<Widget> homeStack;

  @override
  initState() {
    super.initState();
    currentPage = waitingScreen();
    (SharedPreferences.getInstance()).then((val) => {
          prefs = val,
          print("init"),
          setState(() => currentPage = getHomeScreen(this)),
        });
  }

  @override
  Widget build(BuildContext context) {
    print("build");

    return Scaffold(
      appBar: AppBar(
        title: Text('ನಂದಿನಿ'),
        backgroundColor: Colors.blueAccent,
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("settings")),
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), title: Text("history")),
        ],
        onTap: (int index) => {
          if (index == 2)
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HistoryPage()))
          else
            {
              setState(() => currentPage =
                  index == 0 ? SettingsPage() : getHomeScreen(this)),
              currentTab = index,
            }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

getHomeScreen(_HomePageState state) {
  state.homeStack = [
    Center(
      child: Wrap(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var i = 0; i < 4; i++) getHomeButton(i, state)
          ],
        )
      ]),
    ),
  ];
  if (prefs.getBool('today')) state.homeStack.insert(1, getDoneScreen());
  return Stack(
    children: state.homeStack,
    fit: StackFit.expand,
  );
}

getHomeButton(int i, _HomePageState state) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
    child: RaisedButton(
      onPressed: () => {
        sendSms(i, prefs.getString('phone')),
        DatabaseHelper.instance.insert({
          DatabaseHelper.columnDate: DateTime.now().microsecondsSinceEpoch,
          DatabaseHelper.columnPurchased: i
        }),
        prefs.setBool("today", true),
        state.setState(() => state.homeStack.insert(1, getDoneScreen())),
      },
      child: Text(DatabaseHelper.items[i],
          style: TextStyle(
            fontSize: 40,
            color: Colors.indigoAccent,
          )),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      color: Colors.white,
      splashColor: Colors.black12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.blueAccent, width: 3)),
    ),
  );
}

getDoneScreen() {
  return Stack(fit: StackFit.expand, children: [
    Opacity(
      opacity: 0.75,
      child: Container(
        color: Colors.black,
      ),
    ),
    Icon(
      Icons.done,
      color: Colors.green,
      size: 100,
    ),
    Container(
      alignment: Alignment.center,
      child: Text(
        "Done for Today",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
      ),
    )
  ]);
}
