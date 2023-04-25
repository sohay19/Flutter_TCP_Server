
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/main_provider.dart';


class MaterialMainPage extends StatefulWidget {
  final String title;

  MaterialMainPage(this.title);


  @override
  State<MaterialMainPage> createState() => _MaterialMainPageState();
}

class _MaterialMainPageState extends State<MaterialMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          minimum: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.black,
                    )
                  ),
                  child: Text('Clear',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    context.read<MainProvider>().clearMessage();
                  },
                ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child:
          ElevatedButton(
            child: Text('Open Server',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.white60,
              )
            ),
            onPressed: () {
              context.read<MainProvider>().openServer();
            },
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child:
          ElevatedButton(
            child: Text('Close Server',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.white60,
                )
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
            color: Colors.black,
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