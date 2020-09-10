import 'package:daily_app/myScreens.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';
import 'dbHelper.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  List<int> sel = List<int>();
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Map<String, dynamic>> allRows = null;

  List<Widget> calculate() {
    var sum, m = 0, c = 0;
    for (var item in allRows) {
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
    }
    ;
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

  Future<List<Map<String, dynamic>>> _fetchAllRows() async {
    List<Map<String, dynamic>> list = await helper.queryAllRows();
    this.allRows = List.generate(
        list.length, (int index) => Map<String, dynamic>.from(list[index]));
    return list;
  }

  void _delete(int till) {
    if (till == 0) {
      helper.deleteAll();
      setState(() => allRows.clear());
    } else {
      helper.deleteAllBefore(till);
      setState(() => {
            for (var i = 0; i < allRows.length; i++)
              if (allRows[i][DatabaseHelper.columnDate] <= till)
                {allRows.removeAt(i), i--}
          });
    }
  }

  void _alert() {
    if (sel.isEmpty) {
      showDialog(
        builder: (_) => AlertDialog(
          title: Text("Alert"),
          content: Text("Do you want to delete all the history?"),
          actions: [
            FlatButton(
                child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
            FlatButton(
                child: Text("OK"),
                onPressed: () => {_delete(0), Navigator.pop(context)}),
          ],
          elevation: 24.0,
        ),
        context: context,
        barrierDismissible: true,
      );
    } else {
      sel.sort();
      _delete(sel.last);
      sel.clear();
    }
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
              future: _fetchAllRows(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("done loading");
                  return historyScreen(snapshot.data, sel);
                } else if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return errorScreen(snapshot.error);
                } else {
                  print("waiting");
                  return waitingScreen();
                }
              })
          : historyScreen(allRows, sel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showDialog(
            builder: (_) => AlertDialog(
              title: Text("Sum"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: calculate(),
              ),
              actions: [
                FlatButton(
                    child: Text("OK"), onPressed: () => Navigator.pop(context))
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
}

Widget historyScreen(List<Map<String, dynamic>> list, List sel) {
  if (list.length != 0)
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          return historyTile(list.elementAt(i), sel, key: UniqueKey());
        });
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

class historyTile extends StatefulWidget {
  Map<String, dynamic> row;
  List<int> sel;

  historyTile(this.row, this.sel, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _historyTile(this.row, this.sel);
}

// (Map<String, dynamic> row)
class _historyTile extends State<historyTile> {
  Map<String, dynamic> row;
  bool selected = false;
  Color color = Colors.white;
  List<int> sel;

  _historyTile(this.row, this.sel);

  @override
  Widget build(BuildContext context) {
    DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(row[DatabaseHelper.columnDate]);
    return Card(
      color: color,
      child: ListTile(
        title: new Text(
            DatabaseHelper.items[row[DatabaseHelper.columnPurchased]],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        subtitle: new Text("${date.day}/${date.month}/${date.year}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        hoverColor: Colors.grey[400],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        selected: selected,
        trailing: PopupMenuButton(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            for (var i = 0; i < 4; i++)
              PopupMenuItem(
                  child: Text(DatabaseHelper.items[i]),
                  value: DatabaseHelper.items[i])
          ],
          icon: Icon(Icons.menu),
          onSelected: (val) => {
            print("selected $val"),
            setState(() => {
                  row[DatabaseHelper.columnPurchased] =
                      DatabaseHelper.items.indexOf(val),
                  DatabaseHelper.instance.update(row)
                })
          },
        ),
        contentPadding: EdgeInsets.all(10),
        onLongPress: () => {
          setState(() => {
                selected = !selected,
                color = selected ? Colors.grey[300] : Colors.white
              }),
          if (selected)
            sel.add(row[DatabaseHelper.columnDate])
          else
            sel.remove(row[DatabaseHelper.columnDate])
        },
      ),
    );
  }
}
