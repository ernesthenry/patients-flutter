import 'package:flutter/material.dart';
import 'package:patients/app/data/pojo/user.dart';
import 'package:patients/app/data/services/odoo_api.dart';
// import 'package:patients/app/pages/patients.dart';
import 'package:patients/app/pages/settings.dart';
import "package:patients/base.dart";

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:video_player/video_player.dart';

import 'home.dart';
import 'welcome.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends Base<Login> {
  String odooURL;
  String _selectedProtocol = "https";
  String _selectedDb;
  String _email;
  String _pass;
  List<String> _dbList = [];
  List dynamicList = [];
  bool isCorrectURL = false;
  bool isDBFilter = false;
  bool _connectToServerPending = false;
  bool _loginPending = false;
  TextEditingController _urlCtrler = new TextEditingController();
  TextEditingController _emailCtrler = new TextEditingController();
  TextEditingController _passCtrler = new TextEditingController();
  // VideoPlayerController _controller;
  FocusNode emailFocusNode = new FocusNode();
  FocusNode passwordFocusNode = new FocusNode();
  FocusNode urlFocusNode = new FocusNode();

  _checkFirstTime() {
    if (getURL() != null) {
      odooURL = getURL();
      _checkURL();
    }
  }

  _login() {
    if (isValid()) {
      isConnected().then((isInternet) {
        if (isInternet) {
          setState(() {
            _urlCtrler.clear();
            _emailCtrler.clear();
            _passCtrler.clear();
            _loginPending = true;
          });
          showLoading();
          odoo.authenticate(  _email, _pass, _selectedDb).then(
            (http.Response auth) {
              if (auth.body != null) {
                User user = User.fromJson(jsonDecode(auth.body));
                if (user != null && user.result != null) {
                  print(auth.body.toString());
                  hideLoadingSuccess("Logged in successfully");
                  saveUser(json.encode(user));
                  saveOdooUrl(odooURL);
                  // pushReplacement(Home());
                  pushReplacement(Home());
                  setState(() {
                    _loginPending = false;
                  });
                } else {
                  setState(() {
                    _loginPending = false;
                  });
                  showMessage("Authentication Failed",
                      "Please Enter Valid Email or Password");
                }
              } else {
                setState(() {
                  _loginPending = false;
                });
                showMessage("Authentication Failed",
                    "Please Enter Valid Email or Password");
              }
            },
          );
        }
      });
    }
  }

  _checkURL() {
    setState(() {
      _connectToServerPending = true;
    });
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        // Init Odoo URL when URL is not saved
        odoo = new Odoo(url: odooURL);
        odoo.getDatabases().then((http.Response res) {
          setState(
            () {
              hideLoadingSuccess("Odoo Server Connected");
              isCorrectURL = true;
              _connectToServerPending = false;
              dynamicList = json.decode(res.body)['result'] as List;
              saveOdooUrl(odooURL);
              dynamicList.forEach((db) => _dbList.add(db));
              _selectedDb = _dbList[0];
              if (_dbList.length == 1) {
                isDBFilter = true;
              } else {
                isDBFilter = false;
              }
            },
          );
        }).catchError(
          (e) {
            showMessage("Warning", "Invalid URL");
            setState(() {
              _connectToServerPending = false;
            });
            // _urlCtrler.clear();
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getOdooInstance().then((odoo) {
      _checkFirstTime();
    });

    // _controller = VideoPlayerController.asset("assets/videos/water.mp4")
    //   ..initialize().then((_) {
    //     _controller.play();
    //     _controller.setLooping(true);
    //     // Ensure the first frame is shown after the video is initialized
    //     setState(() {});
    //   });
  }

  bool isValid() {
    _email = _emailCtrler.text;
    _pass = _passCtrler.text;
    if (_email.length > 0 && _pass.length > 0) {
      return true;
    } else {
      showSnackBar("Please enter valid email and password");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkButton = Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30),
        // ),
        onPressed: !isCorrectURL
            ? () {
                if (_urlCtrler.text.length == 0) {
                  showSnackBar("Please enter valid URL");
                  return;
                }
                odooURL = _selectedProtocol + "://" + _urlCtrler.text;
                _checkURL();
              }
            : null,
        // padding: EdgeInsets.all(12),
        // color: Color(0xff00a3d2),
        child: Text(
          'Connect Odoo Server',
          style: TextStyle(
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );

    final protocol = Container(
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border:
            Border.all(color: Color.fromRGBO(112, 112, 112, 3.0), width: 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedProtocol,
          onChanged: (String newValue) {
            setState(
              () {
                _selectedProtocol = newValue;
              },
            );
          },
          underline: SizedBox(height: 0.0),
          items: <String>['http', 'https'].map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Montserrat",
                  ),
                ),
              );
            },
          ).toList(),
        ), //DropDownButton
      ),
    );

    final dbs = isDBFilter
        ? SizedBox(height: 0.0)
        : Container(
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                    color: Color.fromRGBO(112, 112, 112, 3.0), width: 1.0)),
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: DropdownButton<String>(
                value: _selectedDb,
                onChanged: (String newValue) {
                  setState(() {
                    _selectedDb = newValue;
                  });
                },
                isExpanded: true,
                underline: SizedBox(height: 0.0),
                hint: Text(
                  "Select Database",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                  ),
                ),
                items: _dbList.map(
                  (db) {
                    return DropdownMenuItem(
                      child: Text(
                        db,
                        style:
                            TextStyle(fontFamily: "Montserrat", fontSize: 18),
                      ),
                      value: db,
                    );
                  },
                ).toList(),
              ),
            ),
          );

    final odooUrl = TextField(
      autofocus: false,
      controller: _urlCtrler,
      cursorColor: Color(0xff223e47),
      focusNode: urlFocusNode,
      decoration: InputDecoration(
        labelText: "Odoo Server URL",
        labelStyle: TextStyle(
            color:
                urlFocusNode.hasFocus ? Color(0xff00a3d2) : Colors.grey[700]),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 72, 175, 204), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 72, 175, 204), width: 1.2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: new BorderSide(color: Color(0xff00a3d2)),
        ),
      ),
    );

    final email = TextField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailCtrler,
      cursorColor: Color.fromARGB(255, 35, 69, 80),
      focusNode: emailFocusNode,
      decoration: InputDecoration(
        labelText: "E-mail",
        labelStyle: TextStyle(
            color:
                emailFocusNode.hasFocus ? Color(0xff00a3d2) : Colors.grey[700]),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        prefixIcon: Icon(
          Icons.mail,
          color: Color(0xff223e47),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xff00a3d2), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xff00a3d2), width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: new BorderSide(color: Color(0xff00a3d2)),
        ),
      ),
    );

    final password = TextField(
      controller: _passCtrler,
      obscureText: true,
      focusNode: passwordFocusNode,
      cursorColor: Color(0xff223e47),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(
            color: passwordFocusNode.hasFocus
                ? Color(0xff00a3d2)
                : Colors.grey[700]),
        prefixIcon: Icon(
          Icons.lock,
          color: Color(0xff223e47),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xff00a3d2), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xff00a3d2), width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: new BorderSide(color: Color(0xff00a3d2)),
        ),
      ),
    );

    final loginButton = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30),
        // ),
        onPressed: () {
          _login();
        },
        // padding: EdgeInsets.all(12),
        // color: Color(0xff00a3d2),
        child: Text(
          'Log In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat",
            color: Colors.white,
          ),
        ),
      ),
    );

    final checkURLWidget = Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(height: 8.0),
          protocol,
          SizedBox(height: 8.0),
          odooUrl,
          SizedBox(height: 8.0),
          _connectToServerPending
              ? CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(0xff223e47)),
                )
              : checkButton,
          SizedBox(height: 8.0),
        ],
      ),
    );

    final loginWidget = Container(
      child: Column(
        children: <Widget>[
          // dbs,
          // SizedBox(height: 8.0),
          email,
          SizedBox(height: 8.0),
          password,
          SizedBox(height: 24.0),
          _loginPending
              ? CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(0xff223e47)),
                )
              : loginButton
        ],
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Patients  - Login",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "Montserrat",
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                child: Container(),
                // width: _controller.value.size?.width ?? 0,
                // height: _controller.value.size?.height ?? 0,
                // child: VideoPlayer(_controller),
              ),
            ),
          ),
          Container(
            color: Colors.white.withAlpha(180),
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width - 30,
            height: 310,
            child: ListView(
              padding: EdgeInsets.all(10),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 70,
                        width: 80,
                        child: Image.asset("assets/images/spoutslogo.png")),
                  ],
                ),
                getURL() == null
                    ? checkURLWidget
                    :
                    // SizedBox(height: 0.0),
                    // checkURLWidget,
                    loginWidget,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isLoggedIn()
          ? FloatingActionButton(
              child: Icon(Icons.settings),
              onPressed: () {
                pushReplacement(Settings());
              },
            )
          : SizedBox(height: 0.0),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          width: 300,
          height: 250,
          color: Colors.white.withAlpha(400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    child: Text('Sign-In'),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    child: Text('Sign-Up'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
