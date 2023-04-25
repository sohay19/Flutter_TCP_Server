
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/main_provider.dart';


class CupertinoMainPage extends StatefulWidget {
  final String title;

  CupertinoMainPage(this.title);


  @override
  State<CupertinoMainPage> createState() => _MaterialMainPageState();
}

class _MaterialMainPageState extends State<CupertinoMainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Center(
          child: CupertinoButton(
            child: Text('open Server'),
            onPressed: () {
              context.read<MainProvider>().openServer();
            },
          ),
        ),
      ),
    );
  }
}