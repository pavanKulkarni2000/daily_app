import 'package:flutter/material.dart';

waitingScreen() {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            child: CircularProgressIndicator(),
            padding: EdgeInsets.all(10),
          ),
        ),
        Flexible(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text('Awaiting result...'),
          ),
        )
      ],
    ),
  );
}

errorScreen(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Error: ${error}',
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    ),
  );
}
