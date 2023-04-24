import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tcp_server/view/cupertino/main_cupertino_view.dart';
import 'package:flutter_tcp_server/view/material/main_material_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'TCP Server';

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MaterialPage(title),
    );
  }
}

class MaterialPage extends StatelessWidget {
  final String title;

  MaterialPage(this.title);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MaterialMainPage(title),
    );
  }
}


class CupertinoPage extends StatelessWidget {
  final String title;

  CupertinoPage(this.title);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoMainPage(title),
    );
  }
}