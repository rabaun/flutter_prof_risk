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

import 'table.dart';

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
      'CREATE TABLE IF NOT EXISTS list4 (id INTEGER PRIMARY KEY,name INTEGER NOT NULL, age INTEGER NOT NULL);');

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
  var _id = 0;
  var _name = 0;
  var _age = 0;
  late List<Map<String, dynamic>> _maps;

  void _incrementName() {
    setState(() => _name++);
    _updateCounterInDatabase();
    _getDatabase();
  }

  void _incrementAge() {
    setState(() => _age++);
    _updateCounterInDatabase();
    _getDatabase();
  }

  void _getCounterFromDatabase() {
    var values = db.select('SELECT id FROM list4;');
    if (values.isNotEmpty) _id = values.last['id'];
  }

  void _getNameFromDatabase() {
    var values = db.select('SELECT name FROM list4;');
    if (values.isNotEmpty) _name = values.last['name'];
  }

  void _getAgeFromDatabase() {
    var values = db.select('SELECT name FROM list4;');
    if (values.isNotEmpty) _age = values.last['age'];
  }

  void _updateCounterInDatabase() {
    // db.execute('DELETE FROM list;');
    db.execute('INSERT INTO list4 (name, age) VALUES ($_name, $_age);');
  }

  void _getDatabase() {
    _maps = db.select('SELECT * FROM list4;');
  }

  void _updateDatabase() {
    db.execute('UPDATE list4 SET name = name+1 WHERE id = $_id;');
  }

  void _deleteDatabase() {
    db.execute('DELETE FROM list4;');
    _getDatabase();
    _updateCounterInDatabase();
  }

  @override
  void initState() {
    super.initState();
    _getCounterFromDatabase();
    _getNameFromDatabase();
    _getAgeFromDatabase();
    _getDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$_id',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$_name',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$_age',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _maps.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Text(_maps[index]['id'].toString(),
                            style: const TextStyle(fontSize: 22)),
                        Text(_maps[index]['name'].toString(),
                            style: const TextStyle(fontSize: 22)),
                        Text(_maps[index]['age'].toString(),
                            style: const TextStyle(fontSize: 22)),
                      ],
                    );
                  }),
            ),
            Expanded(flex: 3, child: TablePage(maps: _maps)),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _incrementAge,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _incrementName,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _deleteDatabase,
            tooltip: 'Increment',
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
