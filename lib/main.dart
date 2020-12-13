import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share/share.dart';
import 'logger.dart';
import './utils/Database.dart';
import './models/levelModel.dart';
import './models/Image.dart';

Logger getLogger(String className) {
  return Logger(printer: SimpleLogPrinter(className));
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final log = Logger();

  @override
  Widget build(BuildContext context) {
    final log = getLogger('PostService');
    log.i('The user entered the BeHealthy app.');
    return MaterialApp(
      title: 'Be Healthy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
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
  final log = Logger();

  createInitials() async {
    //  _defaultList.forEach((element) async {
    //    await DBProvider.db.createLevel(element);
    // });
    //  _default_images.forEach((element) async {
    //    await DBProvider.db.createImage(element);
    //  });
  }

  @override
  Widget build(BuildContext context) {
    log.i('The user has opened the side menu.');
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
  final log = Logger();

  @override
  Widget build(BuildContext context) {
    log.i('The user went to the About page');
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
    log.i('The user is sending message');
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
  final log = Logger();
  Future levelList;
  List<ImageModel> imageList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    levelList = getLevel();
  }

  getLevel() async {
    final _levelList = await DBProvider.db.getLevel();
    return _levelList;
  }

  @override
  Widget build(BuildContext context) {
    log.i('The user went to the Training page');
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      drawer: DrawerMain(selected: "level"),
      body: Center(
          child: FutureBuilder(
              future: levelList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Widget> children = [];
                if (snapshot.hasData) {
                  // List<levelModel> _levelList = [];
                  children = snapshot.data
                      .map<Widget>((e) => Card(
                          child: Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(children: <Widget>[
                                //
                                ListTile(
                                  leading: Image(
                                    image: AssetImage(e.image),
                                    fit: BoxFit.fitHeight,
                                    width: 320.0,
                                    height: 350.0,
                                  ),
                                  onTap: () {
                                    log.i('The user has chosen a level '+e.name+' workout');
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => WorkoutPage(e.id)),
                                    );
                                  },
                                ),
                                Text(
                                  e.name,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]))))
                      .toList();
                }
                return Center(
                  child: Column(
                    children: children,
                  ),
                );
              })),
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
  int levelId;

  WorkoutPage(this.levelId);

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final log = Logger();
  List<String> _images = [];
  int _index = 0;
  String _pred = 'image/start.gif';
  String _button_value = 'start';

  @override
  void initState() {
    super.initState();
     DBProvider.db.getImages(widget.levelId).then((models) {
       _images = models.map((e) => e.path).toList();
     });
  }

  void _change() {
    setState(() {
      if (_index < 2) {
        _pred = _images[_index];
        _index += 1;
        _button_value = 'next';
        log.i('The user has performed the $_index exercise.');
      } else {
        _pred = _images[_index];
        _index = 0;
        _button_value = 'start over';
        log.i('The user has finished training.');
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
          log.i('The user has started training.');
          _change();
        },
        label: Text('$_button_value'),
      ),
    );
  }
}
