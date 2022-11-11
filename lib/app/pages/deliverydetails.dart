import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/accounts.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/currencies.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/delivery.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/deliverylinedetails.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/journals.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/partners.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/stockmovelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/stockmoves.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/stockquant.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/pages/home.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryDetails extends StatefulWidget {
  DeliveryDetails({this.data});

  final data;

  @override
  _DeliveryDetailsState createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends Base<DeliveryDetails>
    with SingleTickerProviderStateMixin {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<InvoiceLine> _invoiceLines = [];
  List<String> _issuedLineBarcodes = [];
  String _productSelection = "Select Product";
  int _productId;
  List<StockQuant> _employeeStockQuant = [];
  List<String> _employeeStockQuantString = [];
  String _scanBarcode;
  BuildContext dialogContext;
  String name = "";
  String move_type = "";
  String scheduled_date = "";
  var move_ids_without_package;
  var move_line_ids_without_package;
  var location_id;
  String email = "";
  List partner_id = [];
  var deadline = "";
  var origin = "", state = "", line_ids = [];
  Invoice _invoice;
  StockPicking _stockPicking;
  List<StockMoves> _stockMoves = [];
  List<StockMoveLines> _stockMoveLines = [];
  List<StockPickingLineDetails> _issuedLines = [];
  List<Journal> journals = [];
  List<Currency> currencies = [];
  List<Account> bankAccounts = [];
  TextEditingController _barcodeNumberController = new TextEditingController();
  String _uomSelection = "Unit of Measurement";
  var _uomId = [];
  var _lotId = [];
  var _stockMoveQuant = 0.0;
  TabController _controller;
  var _selectedIndex = 0;
  int _customerLocationId;
  String _customerLocationSelection = '';
  List<Widget> list = [
    Tab(
      text: 'Operations',
    ),
    Tab(
      text: 'Detailed Ops',
    ),
    Tab(text: 'Other Info'),
  ];
  final List<Map<String, String>> listOfColumns = [
    {"Product": "AAAAAA", "Qty": "1", "Subtotal": "0"},
    {"Product": "BBBBBB", "Qty": "3", "Subtotal": "0"},
    {"Product": "CCCCCC", "Qty": "2", "Subtotal": "0"}
  ];
  int _salesOrderId;

  @override
  void initState() {
    super.initState();

    // _invoice = widget.data;
    _stockPicking = widget.data;
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });

    getOdooInstance().then((odoo) {
      _getInvoiceData();
    });
    _getCustomerLocation();
    _getEmployeeBarCodeStock();
    _getStockMoves();
    _getStockMoveLines();
  }

  //GET SALES ORDER ID
  _getOperationType() async {
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        //GET STOCK LOCATIONS
        odoo.searchRead(Strings.sale_order, [
          ['name', 'ilike', '$origin']
        ], [
          'id',
          'name',
        ]).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              setState(() {
                hideLoading();
                String session = getSession();
                session = session.split(",")[0].split(";")[0];
                if (res.getRecords().toString().length > 3) {
                  _salesOrderId = res.getRecords()[0]["id"];
                  print("++++++THE SALES ORDER ID IS $_salesOrderId");
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

  _getEmployeeBarCodeStock() async {
    setState(() {
      _employeeStockQuant = [];
      _employeeStockQuantString = [];
    });
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlineemployeebarcodestock") != null) {
      print(preference.getString("offlineemployeebarcodestock"));
      var barcodelist =
          json.decode(preference.getString("offlineemployeebarcodestock"));
      setState(() {
        for (var i in barcodelist) {
          _employeeStockQuant.add(
            new StockQuant(
              id: i["id"],
              display_name: i["display_name"],
              lot_id: i["lot_id"] is! bool ? i["lot_id"] : [],
              location_id: i["location_id"] is! bool ? i["location_id"] : [],
              owner_id: i["owner_id"] is! bool ? i["owner_id"] : [],
              package_id: i["package_id"] is! bool ? i["package_id"] : [],
              product_id: i["product_id"] is! bool ? i["product_id"] : [],
              quantity: i["quantity"] is! bool ? i["quantity"] : 0.0,
              value: i["value"] is! bool ? i["value"] : 0.0,
              reserved_quantity: i["reserved_quantity"] is! bool
                  ? i["reserved_quantity"]
                  : 0.0,
              product_uom_id:
                  i["product_uom_id"] is! bool ? i["product_uom_id"] : [],
              on_hand: i["on_hand"],
            ),
          );
          _employeeStockQuantString
              .add(i["lot_id"] is! bool ? i["lot_id"][1] : "");
        }

        print("++++ THE AVAILABLE BARCODES ARE " +
            _employeeStockQuantString.toString() +
            " +++++++");
      });
    }
  }

  //GET CUSTOMER STOCK LOCATION
  _getCustomerLocation() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinecustomerlocation") != null) {
      print(preference.getString("offlinecustomerlocation"));
      var customerdata =
          json.decode(preference.getString("offlinecustomerlocation"));
      setState(() {
        _customerLocationId = customerdata[0]["id"];
        _customerLocationSelection =
            customerdata[0]["location_id"][1] + "/" + customerdata[0]["name"];
        print(
            "THE CUSTOMER LOCATION IS $_customerLocationSelection & $_customerLocationId");
      });
    } else {
      isConnected().then((isInternet) {
        if (isInternet) {
          showLoading();
          //GET STOCK LOCATIONS
          odoo.searchRead(Strings.stock_location, [
            ['usage', '=', 'customer'],
            ['location_id', 'ilike', 'Partner Locations']
          ], [
            'id',
            'name',
            'location_id',
            'usage',
          ]).then(
            (OdooResponse res) {
              if (!res.hasError()) {
                setState(() {
                  hideLoading();
                  String session = getSession();
                  session = session.split(",")[0].split(";")[0];
                  if (res.getRecords().toString().length > 3) {
                    _customerLocationId = res.getRecords()[0]["id"];
                    _customerLocationSelection = res.getRecords()[0]
                            ["location_id"][1] +
                        "/" +
                        res.getRecords()[0]["name"];
                  }
                });
                var customerlocationdata = jsonEncode(res.getRecords());
                preference.setString(
                    "offlinecustomerlocation", customerlocationdata);
                preference.setString("offlinecustomerlocationlastupdated",
                    DateTime.now().toString());
                print("Updated offline customer stock location repository at " +
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

  _getStockMoves() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinestockmoves") != null) {
      print(preference.getString("offlinestockmoves"));
      var invoicelist = json.decode(preference.getString("offlinestockmoves"));
      setState(() {
        for (var i in invoicelist) {
          if (move_ids_without_package.contains(i["id"])) {
            _stockMoves.add(
              new StockMoves(
                id: i["id"],
                product_uom_qty:
                    i["product_uom_qty"] is! bool ? i["product_uom_qty"] : 0.0,
                product_id: i["product_id"] is! bool ? i["product_id"] : [],
                product_uom: i["product_uom"] is! bool ? i["product_uom"] : [],
              ),
            );
            i["product_uom_qty"] is! bool
                ? _stockMoveQuant += i["product_uom_qty"]
                : _stockMoveQuant += 0.0;
          }
        }
      });
    } else {
      // print(res.getError());
      showMessage("Warning", "Failed to get moves");
    }
  }

  //GET STOCK MOVE LINES
  _getStockMoveLines() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinestockmovelines") != null) {
      print(preference.getString("offlinestockmovelines"));
      var invoicelist =
          json.decode(preference.getString("offlinestockmovelines"));
      setState(() {
        for (var i in invoicelist) {
          if (move_line_ids_without_package.isNotEmpty &&
              move_line_ids_without_package.contains(i["id"])) {
            _stockMoveLines.add(
              new StockMoveLines(
                id: i["id"],
                product_qty: i["product_qty"] is! bool ? i["product_qty"] : 1.0,
                product_uom_qty:
                    i["product_uom_qty"] is! bool ? i["product_uom_qty"] : 1.0,
                move_id: i["move_id"] is! bool ? i["move_id"] : [],
                product_id: i["product_id"] is! bool ? i["product_id"] : [],
                product_uom_id:
                    i["product_uom_id"] is! bool ? i["product_uom_id"] : "pcs",
                location_id: i["location_id"] is! bool ? i["location_id"] : [],
                location_dest_id:
                    i["location_dest_id"] is! bool ? i["location_dest_id"] : [],
              ),
            );
          }
        }
      });
    } else {
      showMessage("Warning", "Failed to get stock moves");
    }
  }

  _getInvoiceData() async {
    setState(() {
      _invoiceLines = [];
      state = _stockPicking.state;
      scheduled_date = _stockPicking.scheduled_date;
      partner_id = _stockPicking.partner_id;
      deadline = _stockPicking.date_deadline;
      origin = _stockPicking.origin;
      location_id = _stockPicking.location_id;
      move_line_ids_without_package =
          _stockPicking.move_line_ids_without_package;
      move_ids_without_package = _stockPicking.move_ids_without_package;
    });
    _getOperationType();
  }

  _checkAvailability() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
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
              new SizedBox(
                width: 10,
              ),
              new Text("Checking Availabilty ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.stock_picking,
          "action_assign",
          [_stockPicking.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("CHECKED FOR AVAILABILITY");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                // _getInvoiceData();
                Navigator.of(context).pop();
              });
            } else {
              Navigator.of(context).pop();
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _validateStockMove() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
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
              new SizedBox(
                width: 10,
              ),
              new Text("Issuing stock ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.sale_order,
          "add_serial",
          [_salesOrderId],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("VALIDATED STOCK MOVE");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                Navigator.of(context).pop();
                showInvoiceSuccessMessage(
                    "Success", "Stock Issued Successfully!", "continue");
                // _getInvoiceData();
              });
            } else {
              Navigator.of(context).pop();
              print(res.getError());
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  showInvoiceSuccessMessage(String title, String message, String saveType) {
    hideLoading();
    // if (Platform.isAndroid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            title,
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
                Navigator.pop(context);
                if (saveType == "continue") {
                  pushAndRemoveUntil(Home());
                } else {
                  setState(() {
                    _invoiceLines = [];
                    _productId = null;
                    _productSelection = "";
                  });
                }
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

  _cancelInvoice() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.account_move,
          "button_cancel",
          [_invoice.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("CANCELLED INVOICE");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) {
                _getInvoiceData();
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

  //SCAN BARCODE FUNCTION
  Future<void> scanBarcodeNormal(int moveid) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      print(
          "+++++++++++++++++++++++++++++ $_scanBarcode IS THE BARCODE +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      _getProductByBarcode(moveid);
    });
    // showMessage("Alert",
    //     "Please select the parent account, the contact and payment terms before adding products.");
  }

  //SEARCH FOR BARCODE IN EMPLOYEE'S STOCK
  _getProductByBarcode(int moveid) async {
    setState(() {
      // _lineQuantityController.text = "1";
      // _linePriceSubtotalController.text = "0";
      _productSelection = "Select Product";
      _productId = 0;
    });
    var confirmTitle = "Issue Product";
    print("++++ THE SCANNED BARCODE IS $_scanBarcode");
    // print("++++ THE SCANNED PRODUCT IS " +
    //     _employeeStockQuantString
    //         .indexWhere((element) => element.toString() == _scanBarcode)
    //         .toString() +
    //     " +++++++");

    final foundPeople = _employeeStockQuantString
        .indexWhere((element) => _scanBarcode.contains(element));

    if (foundPeople != null) {
      print('Using where: ${foundPeople}');
      if (foundPeople.toString() == "-1" && _scanBarcode != null) {
        showMessage("Alert", "The item you have scanned is not in your stock");
      }
    }

    StockQuant _scannedStockProduct = _employeeStockQuant[
        _employeeStockQuantString
            .indexWhere((element) => _scanBarcode.contains(element))];

    if (foundPeople >= 0) {
      print("+++++++++++THE ISSUED BARCODES " +
          _issuedLineBarcodes.toString() +
          "++++++++++++++++++++");
      if (_issuedLineBarcodes.contains(_scanBarcode)) {
        showMessage("Alert", "The product has already been scanned.");
      } else {
        setState(() {
          _productSelection = _scannedStockProduct.product_id[1];
          _productId = _scannedStockProduct.product_id[0];
          _uomSelection = _scannedStockProduct.product_uom_id[1];
          _uomId = _scannedStockProduct.product_uom_id;
          _lotId = _scannedStockProduct.lot_id;
        });
        print('THE SCANNED LOT ID IS ' + _lotId.toString());
        _addIssueLine(moveid);
      }
    } else {
      showMessage("Alert", "The item you have scanned is not in your stock");
    }
  }

  //DEBUGGING: ADD A LINE ITEM BY TYPING BARCODE NO< NOT SCANNING
  _addIssueLineManually(int moveid) async {
    hideLoading();
    setState(() {
      // _lineQuantityController.text = "1";
      // _linePriceSubtotalController.text = _scannedProductPrice.toString();
      // _productSelection = "Select Product";
    });
    // if (Platform.isAndroid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Enter Barcode Number",
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
                        controller: _barcodeNumberController,
                        enabled: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Barcode No.",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.qr_code,
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
                Navigator.pop(context);
                setState(() {
                  _scanBarcode = _barcodeNumberController.text;
                });
                if (_scanBarcode != "Unknown") {
                  _getProductByBarcode(moveid);
                }
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
    // }
  }

  _addIssueLine(int moveid) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          title: Text(
            "Confirm Product",
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
                  Row(
                    children: [
                      Text(
                        "Add 1 $_productSelection to \n the items to issue?",
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
          actions: <Widget>[
            Container(
              height: 35,
              width: 100,
              child: TextButton(
                // textColor: Color(0xff00a09d),
                // height: 60.0,
                // color: Colors.grey[300],
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 60,
                      child: Text(
                        "Cancel",
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff00a09d)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 35,
              width: 100,
              child: TextButton(
                // textColor: Colors.white,
                // height: 60.0,
                // color: Color(0xff00a09d),
                onPressed: () {
                  // _addIssueLine();
                  _addProductToIssue(StockMoveLines(
                    product_id: [_productId, _productSelection],
                    move_id: [moveid, ""],
                    lot_id: _lotId,
                    product_qty: 1,
                    qty_done: 1,
                  ));
                  Navigator.pop(context);
                  // _registerPayment();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 60,
                      child: Text(
                        "Add",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _addProductToIssue(StockMoveLines product) {
    // var orderedproduct = _stockMoveLines.firstWhere(
    //     (orderedproduct) =>
    //         orderedproduct.product_id[1].toString() ==
    //         product.product_id[1].toString(),
    //     orElse: () => StockMoveLines(
    //           product_id: [_productId, _productSelection],
    //           move_id: [],
    //           lot_id: [],
    //           product_qty: 1,
    //           qty_done: 1,
    //         ));
    // print(
    //     "+++++++++ THIS IS THE AVAILABLABILITY OF A PRODUCT: $orderedproduct");
    // if (orderedproduct.id == 0) {
    if (_issuedLineBarcodes.contains(_scanBarcode)) {
      showMessage("Alert", "Item already scanned");
    } else {
      setState(() {
        _stockMoveLines.add(StockMoveLines(
          product_id: [_productId, _productSelection],
          product_uom_id: _uomId,
          move_id: product.move_id,
          lot_id: product.lot_id,
          product_qty: 1,
          qty_done: 1,
        ));
        _issuedLineBarcodes.add(_scanBarcode);
      });
    }
  }

  _saveStockMoveLines() {
    var count = 0;
    var moveLineId;
    print("+++++++++++++++ THIS IS THE STOCK QUANTITY " +
        _stockMoveQuant.toString().split(".")[0] +
        " ++++++++++++++++++++++++++++++");
    print("+++++++++++++++ THIS IS THE STOCK MOVE LINES QUANTITY " +
        _stockMoveLines.length.toString() +
        " ++++++++++++++++++++++++++++++");
    if (_stockMoveQuant.toString().split(".")[0] !=
        _stockMoveLines.length.toString()) {
      showMessage("Alert!!",
          "You have not scanned exact number of requisitioned products.");
    } else {
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
                new SizedBox(
                  width: 10,
                ),
                new Text("Adding Barcodes ....."),
              ],
            ),
          );
        },
      );
      for (var i in _stockMoveLines) {
        print("THE MOVE ID IS - " + i.move_id.toString());
        // odoo.write(Strings.sale_order, [_salesOrderId], {"product_serial": ""});
        odoo.create(Strings.product_serial, {
          // "move_id": i.move_id[0],
          "sale_id": _salesOrderId,
          "product_id": i.product_id[0],
          "lot_id": i.lot_id[0],
          "qty": 1
        }).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              // moveLineId = jsonDecode(res.getResult().toString());
              // print("THE MOVE LINE ID IS" + moveLineId.toString());
              count++;
              print("CREATED STOCK MOVE LINE " + count.toString());
              if (count == _stockMoveLines.length) {
                print("VALIDATING DELIVERY ORDER");
                Navigator.of(dialogContext).pop();
                _validateStockMove();
              }
            } else {
              Navigator.of(dialogContext).pop();
              print(res.getError());
              showMessage("Warning!!", res.getErrorMessage());
            }
          },
        );
      }
    }
  }

  // _cancelStockMove() async {
  //   SharedPreferences preference = await SharedPreferences.getInstance();
  //   showDialog(
  //     context: context, // <<----
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       dialogContext = context;
  //       return AlertDialog(
  //         title: Text("Please wait"),
  //         content: new Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             new CircularProgressIndicator(),
  //             new SizedBox(
  //               width: 10,
  //             ),
  //             new Text("Cancelling stock move ....."),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //   isConnected().then((isInternet) {
  //     if (isInternet) {
  //       showLoading();
  //       odoo.callKW(
  //         Strings.stock_picking,
  //         "action_cancel",
  //         [_stockPicking.id],
  //       ).then(
  //         (OdooResponse res) {
  //           if (!res.hasError()) {
  //             print("++++++++++++++++++++++");
  //             print("CANCELLED STOCK MOVE");
  //             print("++++++++++++++++++++++");
  //             getOdooInstance().then((odoo) async {
  //               await _refreshDraftRequisitions();
  //               Navigator.pop(context);
  //               pushReplacement(ApproveRequisitions(
  //                 stockLocation: widget.stockLocation,
  //               ));
  //             });
  //           } else {
  //             print(res.getError());
  //             Navigator.pop(context);
  //             showMessage("Warning", res.getErrorMessage());
  //           }
  //         },
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final upper_header = Container(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.toString().length > 1)
                    Container(
                      height: 25,
                      width: 90,
                      child: TextButton(
                        // textColor: Colors.white,
                        // height: 60.0,
                        // color: state.toLowerCase() == "waiting"
                        //     ? Colors.amber
                        //     : state.toLowerCase() == "cancel"
                        //         ? Colors.red
                        //         : Colors.green,
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 0.0),
                              child: state.toLowerCase() == "waiting"
                                  ? Icon(
                                      Icons.hourglass_bottom,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : state.toLowerCase() == "cancel"
                                      ? Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 38,
                              child: Text(
                                state.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Customer:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            partner_id != null ? partner_id[1] : "-",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Text(
                          "Source Location:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          location_id != null ? location_id[1] : '-',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Text(
                          "Scheduled Date:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          scheduled_date != null ? scheduled_date : '-',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Text(
                          "Deadline:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          deadline != null ? deadline : "-",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Text(
                          "Sale Order:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            origin != null ? origin : "",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                text: 'Operations',
              ),
              Tab(
                text: 'Detailed Ops',
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
                  child: Column(
                    children: [
                      DataTable(
                        showBottomBorder: true,
                        columnSpacing: 10,
                        // dataRowHeight: 1,
                        columns: [
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('Qty')),
                          // DataColumn(label: Text('Subtotal')),
                          DataColumn(label: Text('Scan')),
                        ],
                        rows:
                            _stockMoves // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(element.product_id[1]
                                              .toString() +
                                          " " +
                                          element.product_uom[1]
                                              .toString())), //Extracting from Map element the value
                                      DataCell(Text(
                                          element.product_uom_qty.toString())),
                                      // DataCell(
                                      //     Text(element.price_total.toString())),
                                      DataCell(
                                        new IconButton(
                                          icon: new Icon(
                                            Icons.qr_code_scanner,
                                            color: Color(0xff00a09d),
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            // scanBarcodeNormal(element.id);
                                            _addIssueLineManually(element.id);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.42,
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DataTable(
                        showBottomBorder: true,
                        columnSpacing: 10,
                        // dataRowHeight: 1,
                        columns: [
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('Barcode')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Delete')),
                        ],
                        rows:
                            _stockMoveLines // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(element.product_id[1]
                                              .toString() +
                                          " " +
                                          element.product_uom_id[1]
                                              .toString())), //Extracting from Map element the value
                                      DataCell(Text(element.lot_id.toString())),
                                      DataCell(
                                          Text(element.qty_done.toString())),

                                      DataCell(
                                        new IconButton(
                                            icon: new Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            onPressed: null),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      if (_stockMoveLines.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 35,
                              width: 120,
                              child: TextButton(
                                // textColor: Colors.white,
                                // height: 60.0,
                                // color: Color(0xff00a09d),
                                onPressed: () {
                                  // _validateStockMove();
                                  _saveStockMoveLines();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: Icon(
                                        Icons.check_box,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 60,
                                      child: Text(
                                        "Validate",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 35,
                              width: 100,
                              child: TextButton(
                                // textColor: Colors.red,
                                // height: 60.0,
                                // color: Colors.grey[300],
                                onPressed: () {
                                  // _cancelRequisition();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 45,
                                      child: Text(
                                        "Cancel",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.red),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
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
                              "Procurement Group",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Shipping Policy",
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
                              // group_id != null ? group_id[1] : "",
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
                              move_type != null ? move_type : "",
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.35,
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
