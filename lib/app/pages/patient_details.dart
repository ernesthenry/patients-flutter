import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package:patients/app/data/pojo/partners.dart';
import 'package:package:patients/app/data/services/odoo_response.dart';
import 'package:package:patients/app/pages/addinvoice.dart';
import 'package:package:patients/app/pages/home.dart';
import 'package:package:patients/app/utility/strings.dart';
import 'package:package:patients/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerDetails extends StatefulWidget {
  PartnerDetails({this.data});

  final data;

  @override
  _PartnerDetailsState createState() => _PartnerDetailsState();
}

class _PartnerDetailsState extends Base<PartnerDetails>
    with SingleTickerProviderStateMixin {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  BuildContext dialogContext;
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
  var country = "";
  var account_name = "",
      spouts_account_type = "",
      region = "",
      district = "",
      county = "",
      subCounty = "",
      parish = "",
      village_name = "",
      start_time = "",
      time_end = "",
      female_att = 0,
      male_att = 0,
      late_att = 0,
      total_att = 0,
      collection_officer = "",
      post_d2c = false,
      leader_attended = false,
      lc_stayed = false,
      presentation_filter = false,
      additional_d2c = false,
      money_sent = false,
      when_group_meets = false,
      is_this_a_savings_group = false,
      no_of_groups = 0,
      flat = 0.0,
      flat_amount = 0.0,
      commission = 0.0,
      commission_amount = 0.0,
      other_commission = 0.0;
  Partner _partner;
  TabController _controller;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _jobTitleController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  var _selectedIndex = 0;
  List<Partner> _contacts = [];
  List<Partner> _allContacts = [];
  bool _registerPending = false;
  List<Widget> list = [
    Tab(
      text: 'Profile',
    ),
    Tab(text: 'D2C Details'),
    Tab(text: 'Commission'),
    Tab(text: 'Contacts'),
  ];

  //UPDATE CONTACTS LIST FOR THIS PARTNER AFTER ADDING NEW ONE.
  _updateContactsList() {
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.res_partner, [
          ['parent_id', "ilike", _partner.name],
          ['company_type', "=", 'person']
        ], [
          'email',
          'name',
          'phone'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                _contacts = [];
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  if (i["name"].toString().length > 1) {
                    _contacts.add(
                      new Partner(
                        id: i["id"],
                        email: i["email"] is! bool ? i["email"] : "N/A",
                        name: i["name"].toString(),
                        phone: i["phone"] is! bool ? i["phone"] : "N/A",
                      ),
                    );
                  }
                }
              });
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  //UPDATE CONTACTS FOR ALL PARTNERS
  _updateUniversalContacts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.res_partner, [
          ['parent_id', "!=", false],
          ['company_type', "=", 'person']
        ], [
          'email',
          'name',
          'phone',
          'parent_id'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  if (i["name"].toString().length > 1) {
                    _allContacts.add(
                      new Partner(
                          id: i["id"],
                          email: i["email"] is! bool ? i["email"] : "N/A",
                          name: i["name"].toString(),
                          phone: i["phone"] is! bool ? i["phone"] : "N/A",
                          parent_id: i["parent_id"]),
                    );
                  }
                }
              });
              var customerlist = jsonEncode(res.getRecords());
              preference.setString("offlinecontacts", customerlist);
              preference.setString(
                  "offlinecontactslastupdated", DateTime.now().toString());
              print("Updated offline contacts repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  //LOAD CONTACTS FOR THIS PARTNER
  _getContacts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {});
    if (preference.getString("offlinecontacts") != null) {
      print(preference.getString("offlinecontacts"));
      var cutomerlist = json.decode(preference.getString("offlinecontacts"));
      setState(() {
        for (var i in cutomerlist) {
          if (i["name"].toString().length > 1 &&
              i["parent_id"][0] == _partner.id) {
            print("PARENT ID IS " + i["parent_id"].toString());
            _contacts.add(
              new Partner(
                id: i["id"],
                email: i["email"] is! bool ? i["email"] : "N/A",
                name: i["name"].toString(),
                phone: i["phone"] is! bool ? i["phone"] : "N/A",
              ),
            );
          }
        }
      });
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.res_partner, [
            ['parent_id', "ilike", _partner.name],
            ['company_type', "=", 'person']
          ], [
            'email',
            'name',
            'phone'
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  for (var i in res.getRecords()) {
                    if (i["name"].toString().length > 1) {
                      _contacts.add(
                        new Partner(
                          id: i["id"],
                          email: i["email"] is! bool ? i["email"] : "N/A",
                          name: i["name"].toString(),
                          phone: i["phone"] is! bool ? i["phone"] : "N/A",
                        ),
                      );
                    }
                  }
                });
              } else {
                print(res.getError());
                showMessage("Warning", res.getErrorMessage());
              }
            },
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _partner = widget.data;
    _getContacts();
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });

    getOdooInstance().then((odoo) {
      _getProfileData();
    });
  }

  _getProfileData() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        odoo.searchRead(Strings.res_partner, [
          ["id", "=", _partner.id]
        ], []).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                final result = res.getResult()['records'][0];
                name = result["name"];
                email = result["email"];
                phone = result['phone'] is! bool ? result['phone'] : "N/A";
                print("----------phone-------------$phone");
                mobile = result['mobile'] is! bool ? result['mobile'] : "N/A";
                print("----------mobile-------------$mobile");
                street = result['street'] is! bool ? result['street'] : "";
                street2 = result['street2'] is! bool ? result['street2'] : "";
                city = result['city'] is! bool ? result['city'] : "";
                spouts_account_type = result['spouts_account_type'] is! bool
                    ? result['spouts_account_type']
                    : "";
                region = result['region'] is! bool ? result['region'][1] : "";
                subCounty =
                    result['subcounty'] is! bool ? result['subcounty'][1] : "";
                district =
                    result['district'] is! bool ? result['district'][1] : "";
                parish = result['parish'] is! bool ? result['parish'][1] : "";
                village_name = result['village_name'] is! bool
                    ? result['village_name'][1]
                    : "";
                spouts_account_type = result['spouts_account_type'] is! bool
                    ? result['spouts_account_type']
                    : "";
                state_id =
                    result['state_id'] is! bool ? result['state_id'][1] : "";
                zip = result['zip'] is! bool ? result['zip'] : "";
                title = result['title'] is! bool ? result['title'][1] : "N/A";
                website =
                    result['website'] is! bool ? result['website'] : "N/A";
                jobposition =
                    result['function'] is! bool ? result['function'] : "N/A";
                country = result["country_id"] is! bool
                    ? result["country_id"][1]
                    : "N/A";
                account_name = result['display_name'] is! bool
                    ? result['display_name']
                    : "";
                flat = result['flat'] is! bool ? result['flat'] : 0.0;
                flat_amount = result['flat_amount'] is! bool
                    ? result['flat_amount']
                    : 0.0;
                commission =
                    result['commission'] is! bool ? result['commission'] : 0.0;
                commission_amount = result['commission_amount'] is! bool
                    ? result['commission_amount']
                    : 0.0;
                other_commission = result['other_commission'] is! bool
                    ? result['other_commission']
                    : 0.0;
                start_time =
                    result['start_time'] is! bool ? result['start_time'] : "";
                time_end =
                    result['time_end'] is! bool ? result['time_end'] : "";
                female_att =
                    result['female_att'] is! bool ? result['female_att'] : 0;
                male_att = result['male_att'] is! bool ? result['male_att'] : 0;
                late_att = result['late_att'] is! bool ? result['late_att'] : 0;
                total_att =
                    result['total_att'] is! bool ? result['total_att'] : 0;
                collection_officer = result['collection_officer'] is! bool
                    ? result['collection_officer']
                    : "";
                post_d2c = result["post_d2c"];
                leader_attended = result["leader_attended"];
                lc_stayed = result["lc_stayed"];
                presentation_filter = result["presentation_filter"];
                money_sent = result["money_sent"];
                additional_d2c = result["additional_d2c"];
                when_group_meets = result["when_group_meets"];
                is_this_a_savings_group = result["is_this_a_savings_group"];
                no_of_groups = result['no_of_groups'] is! bool
                    ? result['no_of_groups']
                    : 0;
                image_URL = getURL() +
                    "/web/image?model=res.partner&field=image&" +
                    session +
                    "&id=" +
                    _partner.id.toString();
              });
            }
          },
        );
      } else {
        if (preference.getString("offlinecustomers") != null) {
          print(preference.getString("offlinecustomers"));
          var cutomerlist =
              json.decode(preference.getString("offlinecustomers"));
          setState(() {
            name = _partner.name;
            email = _partner.email;
            phone = _partner.phone;
            account_name = _partner.name;
            image_URL = "";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final upper_header = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          account_name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5.0, bottom: 5.0)),
        ],
      ),
    );

    final lower = Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            unselectedLabelColor: Colors.grey[700],
            labelColor: Color(0xff00a09d),
            indicatorColor: Color(0xff00a09d),
            tabs: [
              Tab(
                text: "Profile",
              ),
              Tab(
                text: "D2C Details",
              ),
              Tab(
                text: "Commission",
              ),
              Tab(
                text: "Contacts",
              ),
            ],
            controller: _controller,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Account Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Region",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "District",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Subcounty",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Village Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: VerticalDivider(
                            color: Colors.grey[400],
                            thickness: 1,
                          ),
                          height: 220,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: new Container(
                                      padding: new EdgeInsets.only(right: 13.0),
                                      child: new Text(
                                        account_name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              spouts_account_type,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              region,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              district,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              subCounty,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              village_name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: MaterialButton(
                        child: Text(
                          "New Order",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.indigo.shade400,
                        onPressed: () {
                          push(AddInvoice(
                            partner: [_partner.id, _partner.name],
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.42,
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Start Time",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "End Time",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Female Attendees",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Male Attendees",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Late Attendees",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Total Attendees",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Collection Officer",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Post-D2C?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Leader Attended?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "LC stayed entire time?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Leader had filter?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Money Sent?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Additional D2C",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "When does this group meet?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "Is this a savings group?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                "No. of groups",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: VerticalDivider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                            height: 420,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                start_time,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                time_end,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                female_att.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                male_att.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                late_att.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                total_att.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                collection_officer,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                post_d2c.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                leader_attended.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                lc_stayed.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                presentation_filter.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                money_sent.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                additional_d2c.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                when_group_meets.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                is_this_a_savings_group.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                no_of_groups.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Flat",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Flat Amount",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Commission",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Comission Amount",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Other",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: VerticalDivider(
                            color: Colors.grey[400],
                            thickness: 1,
                          ),
                          height: 200,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flat.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              flat_amount.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              commission.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              commission_amount.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              other_commission.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Add contact"),
                        IconButton(
                            icon: new Icon(
                              Icons.add_circle,
                              color: Colors.blue[900],
                              size: 22,
                            ),
                            onPressed: _addContact)
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                            itemCount: _contacts.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, i) => InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            PartnerDetails(
                                                data: _contacts[i])));
                              },
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    Divider(
                                      height: 10.0,
                                    ),
                                    ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Text(
                                                  _contacts[i].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      subtitle: Container(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.mail,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  _contacts[i].email,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  _contacts[i].phone,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.31,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(background: upper_header),
            ),
          ];
        },
        body: lower,
      ),
    );
  }

  _addContact() async {
    hideLoading();
    // setState(() {
    //   _lineQuantityController.text = "1";
    //   _linePriceSubtotalController.text = "0";
    //   _productSelection = "Select Product";
    // });
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            title: Text(
              "Add Contact",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Full Name",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _jobTitleController,
                          enabled: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Job Position",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.title,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
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
                  _saveContact(
                      _nameController.text,
                      _jobTitleController.text,
                      _partner.id,
                      _emailController.text,
                      _phoneNumberController.text);
                  // setState(() {
                  //   _invoiceLines.add(InvoiceLine(
                  //     name: _productSelection,
                  //     product_id: _productId,
                  //     account_id: [_accountId, _accountSelection],
                  //     quantity: double.tryParse(_lineQuantityController.text),
                  //     product_uom_id: [_uomId, _uomSelection],
                  //     price_unit:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //     price_total:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //   ));
                  // });
                  // _calculateTotals();
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
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
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return CupertinoAlertDialog(
            title: Text(
              "Add Product",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Full Name",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _jobTitleController,
                          enabled: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Job Position",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.title,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
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
                  _saveContact(
                      _nameController.text,
                      _jobTitleController.text,
                      _partner.id,
                      _emailController.text,
                      _phoneNumberController.text);
                  // setState(() {
                  //   _invoiceLines.add(InvoiceLine(
                  //     product_id: _productId,
                  //     account_id: [_accountId, _accountSelection],
                  //     quantity: double.tryParse(_lineQuantityController.text),
                  //     product_uom_id: [_uomId, _uomSelection],
                  //     price_total:
                  //         double.tryParse(_linePriceSubtotalController.text),
                  //   ));
                  // });
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
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
    }
  }

  _saveContact(name, position, parentId, email, phone) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      // _registerPending = true;
    });
    showDialog(
      context: context, // <<----
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text("Please wait"),
          content: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Processing ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.create(Strings.res_partner, {
          "name": name,
          "parent_id": parentId,
          "email": email,
          "phone": phone,
          "function": position,
          "company_type": "person"
        }).then(
          (OdooResponse res) async {
            if (!res.hasError()) {
              setState(() {
                _registerPending = false;
              });
              await _updateContactsList();
              Navigator.pop(dialogContext);
              showDialog(
                context: context, // <<----
                barrierDismissible: false,
                builder: (BuildContext context) {
                  dialogContext = context;
                  return AlertDialog(
                    title: Text("Success"),
                    content: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        new Text("Contact registered successfully"),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      MaterialButton(
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          _updateContactsList();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
              // showMessage("Success", "Contact registered successfully!");
              // pushReplacement(Partners());
            } else {
              setState(() {
                _registerPending = false;
              });
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinecontactsadded") != null &&
            preference.getString("offlinecontactsadded") != "") {
          print("ADDING SUBSEQUENT OFFLINE CONTACT");
          List _partners = [];
          String customersString = preference.getString("offlinecontactsadded");
          // print("THE OFFLINE CUSTOMERS STRING " +
          //     preference.getString("offlinecustomersadded"));
          var cutomerlist = jsonDecode(customersString);
          // print(
          //     "THE OFFLINE CUSTOMERS DECODED OBJECT " + cutomerlist.toString());
          setState(() {
            for (var i in cutomerlist) {
              _partners.add(
                {
                  "email": i["email"],
                  "name": i["name"],
                  "phone": i["phone"],
                  // "account_name": i["account_name"],
                  // "region": i["region"],
                  // "district": i["district"],
                  // "parish": i["parish"],
                  // "subCounty": i["subCounty"],
                  // "user_id": i["user_id"],
                  // "qb_cust": i["qb_cust"],
                },
              );
            }
            _partners.add(
              {
                "name": name,
                "email": email,
                "phone": phone,
              },
            );
          });
          var offlinecustomersadded = jsonEncode(_partners);
          // print("THE NEW OFFLINE ADDED CUSTOMERS OBJECT IS " +
          //     offlinecustomersadded);
          preference.setString("offlinecontactsadded", offlinecustomersadded);
          if (preference.getString("offlinecontacts") == null ||
              preference.getString("offlinecontacts") == "") {
            preference.setString("offlinecontacts", offlinecustomersadded);
          } else {
            String customersString = preference.getString("offlinecontacts");
            // print(preference.getString("offlinecustomers"));
            var cutomerlist = json.decode(customersString);
            List _offlinePartners = [];
            setState(() {
              for (var i in cutomerlist) {
                _offlinePartners.add(
                  {
                    "email": i["email"],
                    "name": i["name"],
                    "phone": i["phone"],
                  },
                );
              }
              _offlinePartners.add(
                {
                  "name": name,
                  "email": email,
                  "phone": phone,
                },
              );
            });
            var offlinecustomersupdate = jsonEncode(_offlinePartners);
            // print("THE NEW OFFLINE CUSTOMERS OBJECT IS " +
            //     offlinecustomersupdate);
            preference.setString("offlinecontacts", offlinecustomersupdate);
          }
          _showSuccessMessage(
              "Contact has been saved to your phone.\nPlease connect to the internet to sync.");
        } else {
          print("ADDING FIRST OFFLINE CONTACT");
          List _partners = [];
          _partners.add(
            {
              "name": name,
              "email": email,
              "phone": phone,
            },
          );
          var offlinecustomersadded = jsonEncode(_partners);
          preference.setString("offlinecontactsadded", offlinecustomersadded);
          if (preference.getString("offlinecontacts") == null ||
              preference.getString("offlinecontacts") == "") {
            preference.setString("offlinecontacts", offlinecustomersadded);
          } else {
            String customersString = preference.getString("offlinecontacts");
            print(preference.getString("offlinecontacts"));
            var cutomerlist = json.decode(customersString);
            List _offlinePartners = [];
            setState(() {
              for (var i in cutomerlist) {
                _offlinePartners.add(
                  {
                    'email': i["email"],
                    'name': i["name"],
                    'phone': i["phone"],
                  },
                );
              }
              _offlinePartners.add(
                {
                  "name": name,
                  "email": email,
                  "phone": phone,
                },
              );
            });
            var offlinecustomersaddedupdate = jsonEncode(_offlinePartners);
            preference.setString(
                "offlinecontacts", offlinecustomersaddedupdate);
          }
          _showSuccessMessage(
              "Contact has been saved to your phone.\nPlease connect to the internet to sync.");
        }
      }
    });
  }

  _showSuccessMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning: Offline",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // pushReplacement(Partners());
                await _getContacts();
                Navigator.of(context).pop();
              },
              child: Text(
                "Ok",
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
  }

  BoxDecoration customDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 2),
          color: Colors.grey[300],
          blurRadius: 5,
        )
      ],
    );
  }
}
