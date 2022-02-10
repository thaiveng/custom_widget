import 'dart:async';

import 'package:customwidget/recieve_task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  String? token = await messaging.getToken();
  print(token);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Navigator.of(context).push(
  //   CupertinoPageRoute(
  //     fullscreenDialog: true,
  //     builder: (context) => ReceiveTask(),
  //   ),
  // );

  print('message bg -- ${message.data}');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('thaiveng.dev/battery');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseMessaging.onMessage.listen(_firebaseMessagingHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) async {
        print('opened app -- ${message.data}');

        Navigator.of(context).push(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => ReceiveTask(),
          ),
        );
      },
    );
  }


  Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
    print('on message --${message.data}');
    _getBatteryLevel();
    // Navigator.of(context).push(
    //   CupertinoPageRoute(
    //     fullscreenDialog: true,
    //     builder: (context) => ReceiveTask(),
    //   ),
    // );
  }

  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: double.infinity,
              height: 30.0,
              color: Colors.lightBlueAccent,
              child: Text(_batteryLevel),
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );

  }
}
