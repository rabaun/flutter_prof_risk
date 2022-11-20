/// This example show you how to use the openSQLiteOnWindows function
///
/// It also show you how to create your database file and how to execute simple
/// SQL functions.
///
/// Here the table used have only one column and we use only one row to store
/// a count value. But you can use all SQLite possibilities and build complex
/// tables and queries, the only limitations are on SQLite side.
/// If you have a more relevant example in mind like TodoList app or other feel
/// free to do a pull request :)

import 'dart:io' show File;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import 'package:flutter/material.dart';

import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3_library_windows/sqlite3_library_windows.dart';

late final Database db;

Future<void> main() async {
  // Override the sqlite3 load config when OS is Windows
  open.overrideFor(OperatingSystem.windows, openSQLiteOnWindows);

  // Folder where the database will be stored
  final dbFolder = await getApplicationSupportDirectory();

  // If the database file doesn't exist, create it.
  File dbFile =
      await File("${dbFolder.path}\\sqlite3_library_windows_example\\db")
          .create(recursive: true);

  // Open the database file
  db = sqlite3.open(dbFile.path);

  // Create 'count' table if the table doesn't already exist
  db.execute(
      'CREATE TABLE IF NOT EXISTS count1 (count_value INTEGER, colDate_value INTEGER) ;');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _counter = 0;
  var _colDate = 0;
  TextEditingController descriptionController = TextEditingController();

  void _incrementCounter() {
    setState(() => _counter++);
    _updateCounterInDatabase();
  }

  void _incrementcoldDate() {
    setState(() => _colDate++);
    _updatecolDateInDatabase();
  }

  void _getCounterFromDatabase() {
    var values_count = db.select('SELECT count_value FROM count1;');
    if (values_count.isNotEmpty) _counter = values_count.first['count_value'];
  }

  void _getCounterFromData() {
    var values_colDate = db.select('SELECT colDate_value FROM count1;');
    if (values_colDate.isNotEmpty) {
      _colDate = values_colDate.first['colDate_value'];
    }
  }

  void _updateCounterInDatabase() {
    db.execute('DELETE FROM count1;');
    db.execute('INSERT INTO count1 (count_value) VALUES ($_counter);');
  }

  void _updatecolDateInDatabase() {
    db.execute('DELETE FROM count1;');
    db.execute('INSERT INTO count1 (colDate_value) VALUES ($_colDate);');
  }

  @override
  void initState() {
    super.initState();
    _getCounterFromDatabase();
    _getCounterFromData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_colDate',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: _incrementcoldDate,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
