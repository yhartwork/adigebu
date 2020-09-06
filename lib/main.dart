import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    print("Native called background task");
    return Future.value(true);
  });
}

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: BottomNavPage(),
  ));

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  Workmanager.registerOneOffTask(
    "2",
    "simpleTask"
  );
}

class BottomNavPage extends StatefulWidget {
  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class ListDisplay extends StatefulWidget {
  @override
  State createState() => new DyanmicList();
}

AudioCache cache; // you have this
AudioPlayer player;

Future<AudioPlayer> playLocalAsset() async {
  cache = new AudioCache();
  //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
  //Just pass the file name only.
  return player = await cache.play("sound.mp3");
}

class DyanmicList extends State<ListDisplay> {
  List<String> litems = ["Gempa Sedang", "Gempa Tinggi"];
  final TextEditingController eCtrl = new TextEditingController();
  @override
  Widget build(BuildContext ctxt) {
    return new Container(
        child: new ListView.builder(
            itemCount: litems.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    size: 32,
                    color: Colors.orange,
                  ),
                  title: Text(litems[index]),
                  subtitle: Text('20 Agustus 2020 18:20',
                      style: TextStyle(fontSize: 12)),
                ),
              );
            }));
  }
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedTabIndex = 0;

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _listPage = <Widget>[
      Scaffold(
        body: Center(
          child: Container(
            width: 300.0,
            height: 100.0,
            child: Sparkline(
              data: [3, 1.0, 1.5, 2.0, 0.2, 0.4, 0.2, 0.1],
              fillMode: FillMode.below,
              fillGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 100, 100),
                  Color.fromARGB(0, 255, 100, 100)
                ],
              ),
            ),
          ),
        ),
      ),
      ListDisplay(),
      Scaffold(
          body: SingleChildScrollView(
              child: Image(
                  image: AssetImage('assets/antisipasi-infografik.jpg')))),
    ];

    final _bottomNavBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Beranda'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        title: Text('Riwayat'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bookmark),
        title: Text('Panduan'),
      ),
    ];

    final _bottomNavBar = BottomNavigationBar(
      items: _bottomNavBarItems,
      currentIndex: _selectedTabIndex,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      onTap: _onNavBarTapped,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ADIGEBU'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.notification_important,
              color: Colors.white,
            ),
            onPressed: () {
              playLocalAsset();
              //Vibration.vibrate(duration: 5000, amplitude: 100);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmMode()),
              );
            },
          )
        ],
      ),
      body: Center(child: _listPage[_selectedTabIndex]),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}

class AlarmMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Perhatian!"),
            centerTitle: true,
            backgroundColor: Colors.red,
          ),
          body: Column(
            children: [
              Image(image: AssetImage('assets/emergency.png')),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    // Navigate back to first route when tapped.
                    player?.stop();
                  },
                  child: Text('Matikan Alarm!'),
                ),
              )
            ],
          ),
        ),
        onWillPop: () => _willPopCallback());
  }
}

Future<bool> _willPopCallback() async {
  // await showDialog or Show add banners or whatever
  // then
  player?.stop();
  return true; // return true if the route to be popped
}
