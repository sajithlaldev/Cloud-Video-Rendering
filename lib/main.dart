import 'dart:convert';

import 'package:cloud_video/video.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:js' as js;
import 'package:dart_ipify/dart_ipify.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Video Editing',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;

  getTimeLine(String name, loc) {
    String time =
        DateFormat('h:mm a').format(DateTime.now().add(Duration(seconds: 16)));
    var json = {
      "timeline": {
        "soundtrack": {
          "src":
              "https://shotstack-assets.s3-ap-southeast-2.amazonaws.com/music/freepd/motions.mp3"
        },
        "background": "#000000",
        "tracks": [
          {
            "clips": [
              {
                "asset": {
                  "type": "title",
                  "text": "Hello ${name}",
                  "style": "minimal"
                },
                "start": 1,
                "length": 3,
                "transition": {"in": "fade", "out": "fade"}
              },
              {
                "asset": {
                  "type": "title",
                  "text": "You are from ${loc}",
                  "style": "minimal"
                },
                "start": 4,
                "length": 3,
                "transition": {"in": "fade", "out": "fade"}
              },
              {
                "asset": {
                  "type": "title",
                  "text": "And the time is ${time}",
                  "style": "minimal"
                },
                "start": 7,
                "length": 3,
                "transition": {"in": "fade", "out": "fade"}
              },
              {
                "asset": {
                  "type": "html",
                  "html":
                      "<font color='white'><h4>Created By</h4><br><h1><b>@sajithlal.dev</h1>"
                },
                "start": 10,
                "length": 5,
                "transition": {"in": "fade", "out": "fade"}
              }
            ]
          },
          {
            "clips": [
              {
                "asset": {
                  "type": "video",
                  "src":
                      "https://shotstack-assets.s3-ap-southeast-2.amazonaws.com/footage/earth.mp4"
                },
                "start": 0,
                "length": 15
              }
            ]
          }
        ]
      },
      "output": {"format": "mp4", "resolution": "1080"}
    };

    return json;
  }

  final nameController = TextEditingController();

  getLocation() async {
    var ip = await Ipify.ipv4();
    var options = BaseOptions(
      baseUrl: 'https://ipapi.co/',
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    var res = await Dio(options).get('${ip}/json/');
    print(res);
    return res.data;
  }

  makeVideo(name, loc) async {
    var options = BaseOptions(
      baseUrl: 'https://api.shotstack.io',
      headers: {'x-api-key': 'cWA1mBseaH1D0P1A9mvgu5qyJgI4Vd3jIqKhEnn4'},
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    return (await Dio(options)
            .post('/stage/render', data: getTimeLine(name, loc)))
        .data;
  }

  getVideoUrl(String id) async {
    var options = BaseOptions(
      baseUrl: 'https://api.shotstack.io',
      headers: {'x-api-key': 'cWA1mBseaH1D0P1A9mvgu5qyJgI4Vd3jIqKhEnn4'},
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    var res = (await Dio(options).get('/stage/render/${id}')).data;

    return res;
  }

  login() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter your name')));
    } else {
      setState(() {
        isLoading = true;
      });
      final location = (await getLocation())['city'];
      print('Location : ${location}');

      final name = nameController.text;

      String id = (await makeVideo(name, location))['response']['id'];

      print('id : ' + id);

      await Future.delayed(Duration(seconds: 15));

      var res = (await getVideoUrl(id))['response'];

      print(res['status'].runtimeType.toString());

      if (res['status'] != 'done' || res['url'] == null) {
        Future.delayed(Duration(seconds: 10), () async {
          res = (await getVideoUrl(id))['response'];

          print(res['url']);

          Navigator.push(context,
              MaterialPageRoute(builder: (_) => Video(url: res['url'])));
        });
      } else {
        print(res['url']);

        Navigator.push(
            context, MaterialPageRoute(builder: (_) => Video(url: res['url'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Rendering',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TweenAnimationBuilder<Duration>(
                          duration: Duration(seconds: 15),
                          tween: Tween(
                              begin: Duration(seconds: 15), end: Duration.zero),
                          builder: (BuildContext context, Duration value,
                              Widget? child) {
                            final seconds = value.inSeconds;
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                    seconds == 0
                                        ? 'Finalizing..'
                                        : 'Estimated remaining time : $seconds',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)));
                          }),
                      // child: Text(
                      //   'Estimated time : 15 sec',
                      //   style: TextStyle(color: Colors.white, fontSize: 12),
                      // ),
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'CLOUD VIDEO EDITING TEST',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () => js.context.callMethod(
                          'open', ['https://www.instagram.com/sajithlal.dev/']),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          'Created by @sajithlal.dev',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: TextField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                            isDense: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hoverColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: RaisedButton.icon(
                          onPressed: () {
                            login();
                          },
                          color: Colors.white,
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Render',
                            style: TextStyle(color: Colors.black),
                          )),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
