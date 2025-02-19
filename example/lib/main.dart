import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_image_picker/model/photo.dart';
import 'package:flutter_facebook_image_picker/flutter_facebook_image_picker.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final FacebookLogin facebookSignIn = FacebookLogin();
  List<Photo> _photos = [];
  String? _accessToken;
  String? _error;

  Future<Null> _login() async {
    final FacebookLoginResult result =
        await facebookSignIn.logIn(permissions: [ FacebookPermission.publicProfile, FacebookPermission.email,]);

    switch (result.status) {
      
      case FacebookLoginStatus.success:
  
        final FacebookAccessToken? accessToken = result.accessToken;
        
        if(accessToken != null){
          setState(() {
            _accessToken = accessToken.token;
          });

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FacebookImagePicker(
                _accessToken!,
                onDone: (items) {
                  Navigator.pop(context);
                  if(items != null && items.isNotEmpty){
                    setState(() {
                      _error = null;
                      _photos = items;
                    });
                  }
                },
                onCancel: () => Navigator.pop(context),
              ),
            ),
          );
        }
        break;
        
      case FacebookLoginStatus.cancel:
        setState(() {
          _error = 'Login cancelled by the user.';
        });
        break;
        
      case FacebookLoginStatus.error:
        setState(() {
          _error = 'Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.error}';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: MaterialButton(
                onPressed: () => _login(),
                color: Colors.blue,
                child: Text(
                  "Pick images",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          _error != null ? Text(_error!) : Container(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(_photos.length, (index) {
                return Image.network(_photos[index].source!);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
