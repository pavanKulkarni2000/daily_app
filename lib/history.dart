import 'package:daily_app/myScreens.dart';
import 'package:flutter/material.dart';

import 'dbHelper.dart';
import 'main.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

DatabaseHelper helper = DatabaseHelper.instance;

class HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> allRows;
  List<Map<String, dynamic>> selected = List();

  List<Widget> calculate(List list) {
    var sum, m = 0, c = 0;
    for (var item in list)
      switch (item[DatabaseHelper.columnPurchased]) {
        case 0:
          m += 1;
          break;
        case 1:
          c += 1;
          break;
        case 2:
          m += 1;
          c += 1;
          break;
      }

    sum = m * prefs.getDouble('milk') + c * prefs.getDouble('curd');
    return [
      Text(
        "ಹಾಲು ⨉ $m",
        style: TextStyle(fontSize: 20),
      ),
      Text(
        "ಮೊಸರು ⨉ $c",
        style: TextStyle(fontSize: 20),
      ),
      Divider(color: Colors.black),
      Text(
        "$sum Rs",
        style: TextStyle(fontSize: 20),
      ),
    ];
  }


  void _alert() {
    if (selected.isNotEmpty) {
      setState(() => {for (var ele in selected) allRows.remove(ele)});
      Map mx = selected
          .reduce((value, ele) =>
      value[DatabaseHelper.columnDate] < ele[DatabaseHelper.columnDate]
          ? ele
          : value);
      helper.deleteAllBefore(mx[DatabaseHelper.columnDate]);
      selected.clear();
    } else if (allRows.isNotEmpty)
      showDialog(
        builder: (_) =>
            AlertDialog(
              title: Text("Alert"),
              content: Text("Do you want to delete all the history?"),
              actions: [
                FlatButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: Text("OK"),
                    onPressed: () =>
                    {
                      setState(() => {helper.deleteAll()}),
                      Navigator.pop(context)
                    }),
              ],
          elevation: 24.0,
        ),
        context: context,
        barrierDismissible: true,
      );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ನಂದಿನಿ'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete_sweep),
          onPressed: () => _alert(),
          alignment: Alignment.centerRight,
          iconSize: 30,
        ),
      ]),
      body: allRows == null
          ? FutureBuilder(
          future: helper.queryAllRows(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("done loading");
              allRows = List.generate(
                  snapshot.data.length,
                      (int index) =>
                  Map<String, dynamic>.from(snapshot.data[index]));
              return historyScreen();
            } else if (snapshot.hasError) {
              print("Error: ${snapshot.error}");
              return errorScreen(snapshot.error);
            } else {
              print("waiting");
              return waitingScreen();
            }
          })
          : historyScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
        allRows.isEmpty
            ? null
            : {
          showDialog(
            builder: (_) =>
                AlertDialog(
                  title: Text("Sum"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: calculate(
                        selected.length > 0 ? selected : allRows),
                  ),
                  actions: [
                    FlatButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.pop(context))
                  ],
                  elevation: 24.0,
                  contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                  buttonPadding: EdgeInsets.only(top: 0),
                ),
            context: context,
            barrierDismissible: true,
          )
        },
        tooltip: 'Increment',
        child: Icon(Icons.attach_money),
      ),
    );
  }

  Widget historyScreen() {
    if (allRows.length != 0)
      return HistoryList(this);
    else
      return Container(
        child: Column(
          children: [
            Flexible(
                flex: 5,
                child: Icon(
                  Icons.history,
                  size: 100,
                  color: Colors.grey[600],
                )),
            Flexible(
              flex: 1,
              child: Text(
                "No history",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  // backgroundColor: Colors.grey[300]
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        alignment: Alignment.center,
        color: Colors.grey[200],
      );
  }
}


class HistoryList extends StatefulWidget {

  HistoryPageState historyPage;

  HistoryList(this.historyPage);

  @override
  State<StatefulWidget> createState() => ListState(historyPage);
}

class ListState extends State<HistoryList> {

  HistoryPageState historyPage;

  ListState(this.historyPage);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: historyPage.allRows.length,
        itemBuilder: (context, i) {
          Map item = historyPage.allRows[i];
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              item[DatabaseHelper.columnDate]);
          return Dismissible(
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.grey),
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                historyPage.allRows.remove(item);
                if (historyPage.selected.contains(item))
                  historyPage.selected.remove(item);
              });
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "${date.day}/${date.month}/${date.year} : ${DatabaseHelper
                          .items[item[DatabaseHelper.columnPurchased]]}")));
            },
            child: Card(
              child: CheckboxListTile(
                subtitle: Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                selected: historyPage.selected.contains(item),
                title: Text(
                  DatabaseHelper.items[item[DatabaseHelper.columnPurchased]],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                value: historyPage.selected.contains(item),
                onChanged: (bool value) {
                  setState(() =>
                  {
                    if (value)
                      {
                        for (var ele in historyPage.allRows)
                          if (!historyPage.selected.contains(ele) &&
                              ele[DatabaseHelper.columnDate] <=
                                  item[DatabaseHelper.columnDate])
                            historyPage.selected.add(ele)
                      }
                    else
                      {
                        for (var ele in List.from(historyPage.selected))
                          if (ele[DatabaseHelper.columnDate] >=
                              item[DatabaseHelper.columnDate])
                            historyPage.selected.remove(ele)
                      }
                  });
                },
                secondary: PopupMenuButton(
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    for (var i = 0; i < 4; i++)
                      PopupMenuItem(
                          child: Text(DatabaseHelper.items[i]),
                          value: DatabaseHelper.items[i])
                  ],
                  icon: Icon(Icons.menu),
                  onSelected: (val) =>
                  {
                    print("selected $val"),
                    setState(() =>
                    {
                      item[DatabaseHelper.columnPurchased] =
                          DatabaseHelper.items.indexOf(val),
                      DatabaseHelper.instance.update(item)
                    })
                  },
                ),
              ),
            ),
          );
        });
  }
}
