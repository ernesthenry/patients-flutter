import 'package:flutter/material.dart';
import 'package:package:patients/app/data/services/odoo_response.dart';
import 'package:package:patients/app/utility/constant.dart';
import 'package:package:patients/app/utility/strings.dart';
import 'package:package:patients/base.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends Base<ProfilePage> {
  String name = "";
  String image_URL = "";
  String email = "";
  var phone = "";
  var mobile = "";
  var street = "";
  var street2 = "";
  var city = "";
  var state_id = "";
  var zip = "";
  var title = "";
  var website = "";
  var jobposition = "";
  var location_id = [];
  var location = "";
  var company_user_code = "";

  _getUserData() async {
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.res_users, [
          ["id", "=", getUID()]
        ], []).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                final result = res.getResult()['records'][0];
                name = result['name'] is! bool ? result['name'] : "";
                image_URL = getURL() +
                    "/web/image?model=res.users&field=image&" +
                    session +
                    "&id=" +
                    getUID().toString();
                email = result['email'] is! bool ? result['email'] : "";
              });
            } else {
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _clearPrefs() async {
    odoo.destroy();
    preferences.remove(Constants.USER_PREF);
    preferences.remove(Constants.SESSION);
    pushAndRemoveUntil(Login());
  }

  _getProfileData() async {
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.hr_employee, [
          ["user_partner_id", "=", user.result.partnerId] //model
        ], [
          "name",
          "mobile_phone",
          "phone",
          "work_phone",
          "work_email",
          "user_id",
          "job_title",
          "location_id",
          "company_user_code"
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                final result = res.getResult()['records'][0];
                phone = result['work_phone'] is! bool
                    ? result['work_phone']
                    : "N/A";
                mobile = result['mobile_phone'] is! bool
                    ? result['mobile_phone']
                    : "N/A";
                location_id =
                    result['location_id'] is! bool ? result['location_id'] : [];
                jobposition =
                    result['job_title'] is! bool ? result['job_title'] : "N/A";
                company_user_code = result['company_user_code'] is! bool
                    ? result['company_user_code']
                    : "";
              });
            }
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getOdooInstance().then((odoo) {
      _getUserData();
      _getProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final upper_header = Container(
      color: Theme.of(context).primaryColor,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // new Container(
              //   width: 150.0,
              //   height: 150.0,
              //   padding: EdgeInsets.all(10.0),
              //   margin: EdgeInsets.all(25.0),
              //   decoration: new BoxDecoration(
              //     shape: BoxShape.circle,
              //     boxShadow: [
              //       BoxShadow(
              //         blurRadius: 25.0,
              //         color: Colors.orange,
              //       )
              //     ],
              //     image: new DecorationImage(
              //       fit: BoxFit.fill,
              //       image: new NetworkImage(
              //         image_URL != null
              //             ? image_URL
              //             : "https://i1.wp.com/www.molddrsusa.com/wp-content/uploads/2015/11/profile-empty.png.250x250_q85_crop.jpg?ssl=1",
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      company_user_code,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: "Montserrat",
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final lower = Container(
      child: ListView(
        children: <Widget>[
          Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Icon(Icons.person_pin),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Text(
                  jobposition,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Icon(Icons.phone_android, color: Colors.black),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Text(
                  mobile,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Icon(Icons.phone, color: Colors.black),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Icon(Icons.location_city, color: Colors.black),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Text(
                  location_id.isEmpty ? "N/A" : location_id[1].toString(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Profile"),
        elevation: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext ctxt) {
                    return AlertDialog(
                      title: Text(
                        "Logged Out",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearPrefs();
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              })
        ],
      ),
      body: Column(
        children: <Widget>[upper_header, Expanded(child: lower)],
      ),
    );
  }
}
