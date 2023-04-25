
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
        minimum: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 20,
            ),
            _ButtonMenu(),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: _MessageView(),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              child: CupertinoButton(
                color: CupertinoColors.black,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  context.read<MainProvider>().clearMessage();
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        )
      ),
    );
  }
}

class _ButtonMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.all(15),
            color: CupertinoColors.systemGroupedBackground,
            child: Text(
              'Open Server',
              style: TextStyle(
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onPressed: () {
              context.read<MainProvider>().openServer();
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.all(15),
            color: CupertinoColors.systemGroupedBackground,
            child: Text(
              'Close Server',
              style: TextStyle(
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onPressed: () {
              context.read<MainProvider>().closeServer();
            },
          ),
        ),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final msg = context.select((MainProvider provider) => provider.message);
    _scrolling();

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: CupertinoColors.black,
          width: 0.5,
        )
      ),
      child: SingleChildScrollView(
        controller: controller,
        child: Text(msg),
      ),
    );
  }

  _scrolling() {
    if(controller.positions.isNotEmpty) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}