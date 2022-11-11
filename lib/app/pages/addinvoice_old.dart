import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spouts_inventory_odoo/app/data/pojo/accounts.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/partners.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/paymentterms.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/products.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/uom.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_api.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/utility/constant.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'login.dart';

class AddInvoiceOld extends StatefulWidget {
  @override
  _AddInvoiceOldState createState() => _AddInvoiceOldState();
}

class _AddInvoiceOldState extends Base<AddInvoiceOld>
    with SingleTickerProviderStateMixin {
  TextEditingController _urlCtrler = new TextEditingController();
  TextEditingController _customerController = new TextEditingController();
  TextEditingController _invoiceDateController = new TextEditingController();
  TextEditingController _dueDateController = new TextEditingController();
  TextEditingController _paymentRefController = new TextEditingController();
  TextEditingController _lineQuantityController = new TextEditingController();
  TextEditingController _linePriceSubtotalController =
      new TextEditingController();
  TextEditingController _linePriceunitController = new TextEditingController();
  String odooURL = "";
  bool _postD2c, _additionalD2c;
  List<PaymentTerm> _paymentTerms = [];
  List<Product> _products = [];
  List<InvoiceLine> _invoiceLines = [];
  List<Partner> _partners = [];
  List<Partner> _contacts = [];
  List<Uom> _uoms = [];
  List<Account> _accounts = [];
  String _partnerSelection = "Select Parent";
  String _contactSelection = "Select Contact";
  String _termSelection = "Terms";
  String _productSelection = "Select Product";
  String _accountSelection = "Select Account";
  String _uomSelection = "Unit of Measurement";
  String _categorySelection = "Product Category";
  String _taxSelection = "Taxes";
  String _currencySelection = "UGX";
  String _journalSelection = "Customer Invoices";
  double _productPrice = 0;
  double _invoiceTotal = 0.0, _taxTotal = 0.0, _untaxedTotal = 0.0;
  int _partnerId,
      _contactId,
      _termId,
      _userId,
      _productId,
      _accountId,
      _categoryId,
      _currencyId,
      _journalId,
      _taxId;
  var _uomId = [];
  String userfullname;
  final _dateFormat = DateFormat("yyyy-MM-dd");
  TabController _controller;
  var _selectedIndex = 0;
  List<Widget> list = [
    Tab(
      text: 'Invoice Lines',
    ),
    Tab(text: 'Other Info'),
  ];

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
                _userId = result['id'] is! bool ? result['id'] : null;
                print("UID is " + _userId.toString());
              });
            } else {
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _getPartners() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      userfullname = getUserFullName();
    });
    if (preference.getString("offlinecustomers") != null) {
      print(preference.getString("offlinecustomers"));
      var cutomerlist = json.decode(preference.getString("offlinecustomers"));
      setState(() {
        for (var i in cutomerlist) {
          if (i["name"].toString().length > 1) {
            _partners.add(
              new Partner(
                  id: i["id"],
                  email: i["email"] is! bool ? i["email"] : "N/A",
                  name: i["name"].toString(),
                  phone: i["phone"] is! bool ? i["phone"] : "N/A",
                  imageUrl: ""),
            );
          }
        }
      });
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          odoo.searchRead(Strings.res_partner, [
            ['user_id', "ilike", '$userfullname'],
            ['company_type', "=", 'company']
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
                      _partners.add(
                        new Partner(
                          id: i["id"],
                          email: i["email"] is! bool ? i["email"] : "N/A",
                          name: i["name"].toString(),
                          phone: i["phone"] is! bool ? i["phone"] : "N/A",
                          imageUrl: getURL() +
                              "/web/image?model=res.partner&field=image&" +
                              session +
                              "&id=" +
                              i["id"].toString(),
                        ),
                      );
                    }
                  }
                });
                var customerlist = jsonEncode(res.getRecords());
                preference.setString("offlinecustomers", customerlist);
                preference.setString(
                    "offlinecustomerslastupdated", DateTime.now().toString());
                print("Updated offline customer repository at " +
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
  }

  _getContacts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.res_partner, [
          ['parent_id', "ilike", '$_partnerSelection'],
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
                  _contacts.add(
                    new Partner(
                      id: i["id"],
                      email: i["email"] is! bool ? i["email"] : "N/A",
                      name: i["name"].toString(),
                      phone: i["phone"] is! bool ? i["phone"] : "N/A",
                    ),
                  );
                }
              });
              var customerlist = jsonEncode(res.getRecords());
              // preference.setString("offlinecontacts", customerlist);
              // preference.setString(
              //     "offlinecontactslastupdated", DateTime.now().toString());
              // print("Updated offline con repository at " +
              //     DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinecustomers") != null) {
          print(preference.getString("offlinecustomers"));
          var cutomerlist =
              json.decode(preference.getString("offlinecustomers"));
          setState(() {
            for (var i in cutomerlist) {
              _partners.add(
                new Partner(
                    id: i["id"],
                    email: i["email"] is! bool ? i["email"] : "N/A",
                    name: i["name"].toString(),
                    phone: i["phone"] is! bool ? i["phone"] : "N/A",
                    imageUrl: ""),
              );
            }
          });
        }
      }
    });
  }

  _getUoms() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.uom, [], ['id', 'name']).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  _uoms.add(
                    new Uom(
                      id: i["id"],
                      name: i["name"].toString(),
                    ),
                  );
                }
              });
              var uomlist = jsonEncode(res.getRecords());
              preference.setString("offlineuoms", uomlist);
              preference.setString(
                  "offlineuomslastupdated", DateTime.now().toString());
              print("Updated offline uoms repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlineuoms") != null) {
          print(preference.getString("offlineuoms"));
          var uomlist = json.decode(preference.getString("offlineuoms"));
          setState(() {
            for (var i in uomlist) {
              _uoms.add(new Uom(
                id: i["id"],
                name: i["name"].toString(),
              ));
            }
          });
        }
      }
    });
  }

  _getAndSetCurrency() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.res_currency, [
          ['name', 'ilike', 'UGX']
        ], [
          'id',
          'name'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];

                _currencyId = res.getRecords()[0]["id"];
                _currencySelection = res.getRecords()[0]["name"];

                print("================================================");
                print(
                    "CURRENCY ID IS $_currencyId AND CURRENCY NAME IS $_currencySelection");
                print("================================================");
              });
              var currencydict = jsonEncode([
                {"id": _currencyId, "name": _currencySelection}
              ]);
              preference.setString("offlinecurrency", currencydict);
              preference.setString(
                  "offlinecurrencylastupdated", DateTime.now().toString());
              print("Updated offline currency value at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinecurrency") != null) {
          print(preference.getString("offlinecurrency"));
          var currencyval =
              json.decode(preference.getString("offlinecurrency"));
          setState(() {
            _currencyId = currencyval["id"];
            _currencySelection = currencyval["name"];
          });
        }
      }
    });
  }

  _getAndSetJournal() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.account_journal, [
          ['name', 'ilike', 'Customer Invoices']
        ], [
          'id',
          'name'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];

                _journalId = res.getRecords()[0]["id"];
                _journalSelection = res.getRecords()[0]["name"];

                print("================================================");
                print(
                    "JOURNAL ID IS $_journalId AND JOURNAL NAME IS $_journalSelection");
                print("================================================");
              });
              var currencydict = jsonEncode([
                {"id": _currencyId, "name": _currencySelection}
              ]);
              preference.setString("offlinecurrency", currencydict);
              preference.setString(
                  "offlinecurrencylastupdated", DateTime.now().toString());
              print("Updated offline currency value at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlinecurrency") != null) {
          print(preference.getString("offlinecurrency"));
          var currencyval =
              json.decode(preference.getString("offlinecurrency"));
          setState(() {
            _currencyId = currencyval["id"];
            _currencySelection = currencyval["name"];
          });
        }
      }
    });
  }

  _getAccounts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.account, [
          ['name', 'ilike', 'Product Sales'],
        ], [
          'id',
          'name'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                _accountId = res.getRecords()[0]["id"];
                _accountSelection = res.getRecords()[0]["name"];

                print("================================================");
                print(
                    "PRODUCT ACCOUNT ID IS $_accountId AND ACCOUNT NAME IS $_accountSelection");
                print("================================================");
                // for (var i in res.getRecords()) {
                //   _accounts.add(
                //     new Account(
                //       id: i["id"],
                //       name: i["name"].toString(),
                //     ),
                //   );
                // }
              });
              var accountlist = jsonEncode(res.getRecords());
              preference.setString("offlineaccounts", accountlist);
              preference.setString(
                  "offlineaccountslastupdated", DateTime.now().toString());
              print("Updated offline accounts repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        if (preference.getString("offlineaccounts") != null) {
          print(preference.getString("offlineaccounts"));
          var productlist =
              json.decode(preference.getString("offlineaccounts"));
          setState(() {
            for (var i in productlist) {
              _accounts.add(new Account(
                id: i["id"],
                name: i["name"].toString(),
              ));
            }
          });
        }
      }
    });
  }

  _getProducts() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    // if (preference.getString("offlineproducts") != null) {
    //   print(preference.getString("offlineproducts"));
    //   var productlist = json.decode(preference.getString("offlineproducts"));
    //   setState(() {
    //     for (var i in productlist) {
    //       _products.add(new Product(
    //         id: i["id"],
    //         name: i["name"],
    //         uom_id: i["uom_id"],
    //         categ_id: i["categ_id"],
    //         lst_price: i["lst_price"],
    //         taxes_id: i["taxes_id"].toString(),
    //       ));
    //     }
    //   });
    // } else {
    isConnected().then((isInternet) {
      //property_account_income_categ_id - product.category
      if (isInternet) {
        showLoading();
        odoo.searchRead(Strings.product, [
          // ['user_id', "ilike", '$userfullname']
        ], [
          'id',
          'name',
          'categ_id',
          'taxes_id',
          'uom_id',
          'lst_price',
          // 'account_id'
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                for (var i in res.getRecords()) {
                  _products.add(
                    new Product(
                      id: i["id"],
                      name: i["name"].toString(),
                      uom_id: i["uom_id"],
                      categ_id: i["categ_id"],
                      lst_price: i["lst_price"],
                      taxes_id: i["taxes_id"].toString(),
                      // account_id: i["account_id"].toString()
                    ),
                  );
                }
              });
              var productlist = jsonEncode(res.getRecords());
              preference.setString("offlineproducts", productlist);
              preference.setString(
                  "offlineproductslastupdated", DateTime.now().toString());
              print("Updated offline products repository at " +
                  DateTime.now().toString());
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      } else {
        showMessage("Error", "Failed to load products!");
      }
    });
    // }
  }

  _deleteInvoiceLine(int productId) {
    setState(() {
      _invoiceLines.removeWhere((element) => element.product_id == productId);
    });
    _calculateTotals();
  }

  _calculateTotals() {
    var untaxedamount = 0.0;
    var taxamount = 0.0;
    var total = 0.0;
    if (_invoiceLines.isNotEmpty) {
      for (var i in _invoiceLines) {
        untaxedamount += (i.price_total * 0.72);
        taxamount += (i.price_total * 0.18);
        total += i.price_total;
      }
    }

    setState(() {
      _invoiceTotal = total;
      _untaxedTotal = untaxedamount;
      _taxTotal = taxamount;
    });
  }

  _getPaymentTerms() async {
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        // GET VILLAGES
        odoo.searchRead(Strings.account_payment_term, [], ['id', 'name']).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                int count = 0;
                session = session.split(",")[0].split(";")[0];
                while (count < 10)
                  for (var i in res.getRecords()) {
                    _paymentTerms.add(
                      new PaymentTerm(
                        id: i["id"],
                        name: i["name"].toString(),
                      ),
                    );
                    count++;
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

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });
    _getUserData();
    _getAndSetCurrency();
    _getAndSetJournal();
    _getPartners();
    // _getPaymentTerms();
    _getProducts();
    _getAccounts();
    // _getUoms();
    getOdooInstance().then((odoo) {
      // _checkFirstTime();
    });
  }

  // _checkFirstTime() async {
  //   if (getURL() != null) {
  //     setState(() {
  //       _urlCtrler.text = odooURL = getURL();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    final upperWidget = ListView(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            width: _width * 0.89,
            decoration: customDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              _partnerSelection,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        items: _partners.map((item) {
                          return new DropdownMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                new Text(
                                  item.name,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            value: item.id,
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          List itemsList = _partners.map((item) {
                            if (item.id == newVal) {
                              setState(() {
                                _partnerSelection = item.name;
                                _partnerId = item.id;
                                print(_partnerSelection);
                                print(_partnerId);
                              });
                              _getContacts();
                            }
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            width: _width * 0.89,
            decoration: customDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              _contactSelection,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        items: _contacts.map((item) {
                          return new DropdownMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                new Text(
                                  item.name,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            value: item.id,
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          List itemsList = _partners.map((item) {
                            if (item.id == newVal) {
                              setState(() {
                                _contactSelection = item.name;
                                _contactId = item.id;
                                print(_contactSelection);
                                print(_contactId);
                              });
                            }
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            width: _width * 0.89,
            decoration: customDecoration(),
            child: TextFormField(
              controller: _paymentRefController,
              decoration: InputDecoration(
                hintText: "Payment Reference",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  Icons.book,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            width: _width * 0.89,
            decoration: customDecoration(),
            child: DateTimeField(
              format: _dateFormat,
              controller: _invoiceDateController,
              decoration: new InputDecoration(
                hintText: "Invoice Date",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            width: double.infinity,
            decoration: customDecoration(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: DropdownButton(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        _productSelection,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  items: _products.map((item) {
                    return new DropdownMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          new Text(
                            item.name,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      value: item.id,
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    List itemsList = _products.map((item) {
                      if (item.id == newVal) {
                        setState(() {
                          _productSelection = item.name;
                          _productId = item.id;
                          _taxId = int.tryParse(item.taxes_id[0]);
                          _taxSelection = item.taxes_id[1];
                          _uomId = item.uom_id;
                          _uomSelection = item.uom_id[1];
                          _productPrice =
                              double.tryParse(item.lst_price.toString());
                          double total =
                              double.tryParse(_lineQuantityController.text) *
                                  _productPrice;
                          _linePriceSubtotalController.text = total.toString();
                          print(_productSelection);
                          print(_taxId);
                        });
                      }
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 15),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       Container(
        //         margin: EdgeInsets.only(bottom: 15),
        //         width: _width * 0.89,
        //         decoration: customDecoration(),
        //         child: DateTimeField(
        //           format: _dateFormat,
        //           controller: _dueDateController,
        //           decoration: new InputDecoration(
        //             hintText: "Due Date",
        //             border: InputBorder.none,
        //             hintStyle: TextStyle(color: Colors.grey),
        //             prefixIcon: Icon(
        //               Icons.calendar_today,
        //               color: Theme.of(context).primaryColor,
        //             ),
        //           ),
        //           onShowPicker: (context, currentValue) {
        //             return showDatePicker(
        //                 context: context,
        //                 firstDate: DateTime.now(),
        //                 initialDate: currentValue ?? DateTime.now(),
        //                 lastDate: DateTime(2100));
        //           },
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Text(
        //           "or",
        //           style: TextStyle(color: Colors.grey),
        //         ),
        //       ),
        //       Container(
        //         margin: EdgeInsets.only(bottom: 15),
        //         width: _width * 0.89,
        //         decoration: customDecoration(),
        //         child: Row(
        //           children: [
        //             Expanded(
        //               child: Container(
        //                 width: double.infinity,
        //                 padding: EdgeInsets.symmetric(horizontal: 10),
        //                 child: Center(
        //                   child: DropdownButton(
        //                     isExpanded: true,
        //                     hint: Row(
        //                       children: [
        //                         Icon(
        //                           Icons.account_balance,
        //                           color: Theme.of(context).primaryColor,
        //                         ),
        //                         SizedBox(
        //                           width: 10,
        //                         ),
        //                         Text(
        //                           _termSelection,
        //                           style: TextStyle(
        //                               color: Colors.grey,
        //                               fontSize: 16,
        //                               fontWeight: FontWeight.w400),
        //                         ),
        //                       ],
        //                     ),
        //                     items: _paymentTerms.map((item) {
        //                       return new DropdownMenuItem(
        //                         child: Row(
        //                           children: [
        //                             Icon(
        //                               Icons.account_balance,
        //                               color: Theme.of(context).primaryColor,
        //                             ),
        //                             SizedBox(
        //                               width: 10,
        //                             ),
        //                             new Text(
        //                               item.name,
        //                               style: TextStyle(
        //                                   color: Colors.grey,
        //                                   fontSize: 16,
        //                                   fontWeight: FontWeight.w400),
        //                             ),
        //                           ],
        //                         ),
        //                         value: item.id,
        //                       );
        //                     }).toList(),
        //                     onChanged: (newVal) {
        //                       List itemsList = _paymentTerms.map((item) {
        //                         if (item.id == newVal) {
        //                           setState(() {
        //                             _termSelection = item.name;
        //                             _termId = item.id;
        //                             print(_termSelection);
        //                             print(_termId);
        //                           });
        //                         }
        //                       }).toList();
        //                     },
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
    final lowerWidget = Column(
      children: [
        Container(
          width: _width * 0.9,
          color: Colors.white,
          child: TabBar(
            unselectedLabelColor: Colors.blue[900],
            labelColor: Colors.blue[900],
            indicatorColor: Colors.blue[900],
            tabs: [
              Tab(
                text: "Invoice Lines",
              ),
              Tab(
                text: "Other Info",
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
                width: MediaQuery.of(context).size.width * 0.42,
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: _invoiceLines.length > 0
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("Add items"),
                                IconButton(
                                    icon: new Icon(
                                      Icons.add_circle,
                                      color: Colors.blue[900],
                                      size: 22,
                                    ),
                                    onPressed: _addInvoiceLine)
                              ],
                            ),
                            DataTable(
                              showBottomBorder: true,
                              columnSpacing: 10,
                              // dataRowHeight: 1,
                              columns: [
                                DataColumn(label: Text('Product')),
                                DataColumn(label: Text('Qty')),
                                DataColumn(label: Text('Subtotal')),
                                DataColumn(label: Text('Delete')),
                              ],
                              rows:
                                  _invoiceLines // Loops through dataColumnText, each iteration assigning the value to element
                                      .map(
                                        (element) => DataRow(
                                          cells: <DataCell>[
                                            DataCell(Text(element.name
                                                    .toString() +
                                                " " +
                                                element.product_uom_id[1]
                                                    .toString())), //Extracting from Map element the value
                                            DataCell(Text(
                                                element.quantity.toString())),
                                            DataCell(Text(element.price_total
                                                .toString())),
                                            DataCell(
                                              new IconButton(
                                                  icon: new Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 16,
                                                  ),
                                                  onPressed: () {
                                                    _deleteInvoiceLine(
                                                        element.product_id);
                                                  }),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Untaxed Amount:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _untaxedTotal.toString(),
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Tax:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _taxTotal.toString(),
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: Divider(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Total:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _invoiceTotal.toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: MaterialButton(
                                    child: Text(
                                      "Save Invoice",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: Colors.indigo.shade400,
                                    onPressed: () {
                                      _saveInvoice();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: MaterialButton(
                                    child: Text(
                                      "Save & Add New",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: Colors.indigo.shade400,
                                    onPressed: () {
                                      _saveInvoice();
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Add items"),
                                  IconButton(
                                      icon: new Icon(
                                        Icons.add_circle,
                                        color: Colors.blue[900],
                                        size: 22,
                                      ),
                                      onPressed: _addInvoiceLine)
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Ivoice Line Items",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                              "Customer Reference",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Salesperson",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Sales Team",
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
                              "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "",
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
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Create New Order"),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(background: upperWidget),
            ),
          ];
        },
        body: lowerWidget,
      ),
    );
  }

  _saveInvoice(
      // accountName, region, district, parish, subCounty, village, email,
      //   phone
      ) async {
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.create(Strings.account_move, {
          "partner_id": _contactId != null ? _contactId : _partnerId,
          "invoice_user_id": _userId,
          "invoice_payment_term_id": _termId,
          "payment_reference": _paymentRefController.text,
          "invoice_date": _invoiceDateController.text + " 09:55:52",
          "currency_id": _currencyId,
          "journal_id": _journalId,
          // "invoice_date_due": _dueDateController.text,
          "move_type": "out_invoice",
          "stock_move_direct": true,
          "amount_total": _invoiceTotal,
          "amount_tax": _taxTotal,
          "amount_untaxed": _untaxedTotal
        }).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              var moveId = jsonDecode(res.getResult().toString());
              print("THE MOVE ID IS" + moveId.toString());
              for (var i in _invoiceLines) {
                int count = 0;
                print("THE UNIT PRICE IS - " + i.price_unit.toString());
                odoo.create(Strings.account_move_line, {
                  "move_id": moveId,
                  "currency_id": _currencyId,
                  "journal_id": _journalId,
                  "price_total": i.price_total,
                  "price_unit": i.price_total,
                  // "tax_ids": 2,
                  "name": i.name,
                  "product_id": i.product_id,
                  "quantity": i.quantity,
                  "product_uom_id": i.product_uom_id[0][0],
                  "account_id": i.account_id[0]
                }).then(
                  (OdooResponse res) {
                    if (!res.hasError()) {
                      count++;
                      print("CREATED INVOICE LINE " + count.toString());
                    } else {
                      print(res.getError());
                      showMessage("Warning", res.getErrorMessage());
                    }
                  },
                );
              }
              showMessage("Success", "Invoice created successfully");
            } else {
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _addInvoiceLine() async {
    hideLoading();
    setState(() {
      _lineQuantityController.text = "1";
      _linePriceSubtotalController.text = "0";
      _productSelection = "Select Product";
    });
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctxt) {
          return AlertDialog(
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
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _productSelection,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              items: _products.map((item) {
                                return new DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      new Text(
                                        item.name,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  value: item.id,
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                List itemsList = _products.map((item) {
                                  if (item.id == newVal) {
                                    setState(() {
                                      _productSelection = item.name;
                                      _productId = item.id;
                                      _taxId = int.tryParse(item.taxes_id[0]);
                                      _taxSelection = item.taxes_id[1];
                                      _uomId = item.uom_id;
                                      _uomSelection = item.uom_id[1];
                                      _productPrice = double.tryParse(
                                          item.lst_price.toString());
                                      double total = double.tryParse(
                                              _lineQuantityController.text) *
                                          _productPrice;
                                      _linePriceSubtotalController.text =
                                          total.toString();
                                      print(_productSelection);
                                      print(_taxId);
                                    });
                                  }
                                }).toList();
                              },
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    disabledHint: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _accountSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _accountSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    items: _accounts.map((item) {
                                      return new DropdownMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            new Text(
                                              item.name,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        value: item.id,
                                      );
                                    }).toList(),
                                    onChanged: null,
                                    // (newVal) {
                                    //   List itemsList = _accounts.map((item) {
                                    //     if (item.id == newVal) {
                                    //       setState(() {
                                    //         _accountSelection = item.name;
                                    //         _accountId = item.id;
                                    //         print(_accountSelection);
                                    //         print(_accountId);
                                    //       });
                                    //     }
                                    //   }).toList();
                                    // },
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          controller: _lineQuantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Quantity",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.calculate,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: (value) {
                            if (value != "" && value != null) {
                              double total =
                                  double.tryParse(value) * _productPrice;
                              _linePriceSubtotalController.text =
                                  total.toString();
                            } else {
                              _linePriceSubtotalController.text = "0";
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: double.infinity,
                        decoration: customDecoration(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    disabledHint: Row(
                                      children: [
                                        Icon(
                                          Icons.unfold_more_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _uomSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.unfold_more_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _uomSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    items: _uoms.map((item) {
                                      return new DropdownMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            new Text(
                                              item.name,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        value: item.id,
                                      );
                                    }).toList(),
                                    onChanged: null,
                                    // (newVal) {
                                    //   List itemsList = _uoms.map((item) {
                                    //     if (item.id == newVal) {
                                    //       setState(() {
                                    //         _uomSelection = item.name;
                                    //         _uomId = [item.id, item.name];
                                    //         print(_uomSelection);
                                    //         print(_uomId);
                                    //       });
                                    //     }
                                    //   }).toList();
                                    // },
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          controller: _linePriceSubtotalController,
                          enabled: false,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Unit Price",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.shopping_cart_outlined,
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
                  setState(() {
                    _invoiceLines.add(InvoiceLine(
                      name: _productSelection,
                      product_id: _productId,
                      account_id: [_accountId, _accountSelection],
                      quantity: double.tryParse(_lineQuantityController.text),
                      product_uom_id: [_uomId, _uomSelection],
                      price_unit:
                          double.tryParse(_linePriceSubtotalController.text),
                      price_total:
                          double.tryParse(_linePriceSubtotalController.text),
                    ));
                  });
                  _calculateTotals();
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
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _productSelection,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              items: _products.map((item) {
                                return new DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      new Text(
                                        item.name,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  value: item.id,
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                List itemsList = _products.map((item) {
                                  if (item.id == newVal) {
                                    setState(() {
                                      _productSelection = item.name;
                                      _productId = item.id;
                                      print(_productSelection);
                                      print(_productId);
                                    });
                                  }
                                }).toList();
                              },
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    disabledHint: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _accountSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _accountSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    items: _accounts.map((item) {
                                      return new DropdownMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            new Text(
                                              item.name,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        value: item.id,
                                      );
                                    }).toList(),
                                    onChanged: null,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          controller: _lineQuantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Quantity",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.calculate,
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.unfold_more_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          _uomSelection,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    items: _uoms.map((item) {
                                      return new DropdownMenuItem(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            new Text(
                                              item.name,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        value: item.id,
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      List itemsList = _uoms.map((item) {
                                        if (item.id == newVal) {
                                          setState(() {
                                            _uomSelection = item.name;
                                            _uomId = [item.id, item.name];
                                            print(_uomSelection);
                                            print(_uomId);
                                          });
                                        }
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          controller: _linePriceSubtotalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Unit Price",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.shopping_cart_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "_",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        color: Colors.black,
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
                  setState(() {
                    _invoiceLines.add(InvoiceLine(
                      product_id: _productId,
                      account_id: [_accountId, _accountSelection],
                      quantity: double.tryParse(_lineQuantityController.text),
                      product_uom_id: [_uomId, _uomSelection],
                      price_total:
                          double.tryParse(_linePriceSubtotalController.text),
                    ));
                  });
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

  _showMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning",
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
              onPressed: () {
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

  _showLogoutMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Warning",
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
  }

  _clearPrefs() async {
    odoo.destroy();
    preferences.remove(Constants.USER_PREF);
    preferences.remove(Constants.SESSION);
    pushAndRemoveUntil(Login());
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
