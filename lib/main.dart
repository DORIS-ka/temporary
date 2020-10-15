import 'package:flutter/material.dart';
import 'dart:async';
import "package:http/http.dart" as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Healthy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

class DrawerMain extends StatefulWidget {
  DrawerMain({Key key, this.selected}) : super(key: key);

  final String selected;

  @override
  DrawerMainState createState() {
    return DrawerMainState();
  }
}

class DrawerMainState extends State<DrawerMain> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: Text(
          'Be Healthy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.0,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.red,
        ),
      ),
      ListTile(
        selected: widget.selected == 'about',
        leading: Icon(Icons.info),
        title: Text('About'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        },
      ),
      ListTile(
        selected: widget.selected == 'level',
        leading: Icon(Icons.list),
        title: Text('Training'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrainingLevelPage()),
          );
        },
      ),
    ]));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      drawer: DrawerMain(selected: "about"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text('Under development'),
              onTap: () => share(
                  context,
                  'In the future, you will have the '
                  'opportunity to send your results to trainer '),
            ),
            Image(
              image: AssetImage('image/mirror.jpg'),
              fit: BoxFit.fitHeight,
              width: 300.0,
              height: 300.0,
            ),
            Text(
              '\nWe believe fitness should be accessible to everyone, everywhere, '
              'regardless of income or access to a gym. With hundreds of '
              'professional workouts, healthy recipes and informative articles, '
              'as well as one of the most positive communities on the web, '
              'you’ll have everything you need to reach your personal fitness '
              'goals – for free!',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
        // child: Text(
        //   'Все і зразу.',
        // ),
      ),
    );
  }

  share(BuildContext context, String alligator) {
    final RenderBox box = context.findRenderObject();

    Share.share("$alligator",
        subject: 'Under development',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}

class TrainingLevelPage extends StatefulWidget {
  @override
  _TrainingLevelPageState createState() => _TrainingLevelPageState();
}

class _TrainingLevelPageState extends State<TrainingLevelPage> {
  final List<String> title = <String>['Beginner', 'Intermediate', 'Advanced'];

  final List<String> image = <String>[
    'image/beginner.jpg',
    'image/intermediate.jpg',
    'image/advanced.jpg'
  ];

  final List<Object> sUrl = <Object>[
    WorkoutPage([
      'image/b_1.gif',
      'image/b_2.gif',
      'image/b_3.gif',
      'image/complete.jpg',
    ]),
    WorkoutPage([
      'image/i_1.gif',
      'image/i_2.gif',
      'image/i_3.gif',
      'image/complete.jpg',
    ]),
    WorkoutPage([
      'image/a_1.gif',
      'image/a_2.gif',
      'image/a_3.gif',
      'image/complete.jpg',
    ])
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      drawer: DrawerMain(selected: "level"),
      body: Center(
        child: ListView.builder(
          itemCount: title.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    //
                    ListTile(
                      leading: Image(
                        image: AssetImage(image[index]),
                        fit: BoxFit.fitHeight,
                        width: 320.0,
                        height: 350.0,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => sUrl[index]),
                        );
                      },
                    ),
                    Text(
                      title[index],
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class WorkoutLayout extends StatelessWidget {
  Widget child;

  WorkoutLayout({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Training'),
        ),
        drawer: DrawerMain(selected: "level"),
        body: this.child);
  }
}

class WorkoutPage extends StatefulWidget {
  List<String> images;

  WorkoutPage(this.images);

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int _index = 0;
  String _pred = 'image/start.gif';
  String _button_value = 'start';

  void _change() {
    setState(() {
      if (_index < 3) {
        _pred = widget.images[_index];
        _index += 1;
        _button_value = 'next';
      } else {
        _pred = widget.images[_index];
        _index = 0;
        _button_value = 'start over';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      drawer: DrawerMain(selected: "level"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('$_pred'),
              fit: BoxFit.fitHeight,
              width: 400.0,
              height: 300.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _change();
        },
        label: Text('$_button_value'),
      ),
    );
  }
}
