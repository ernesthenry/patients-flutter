import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/accounts.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/currencies.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoices.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/invoicelines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/journals.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/partners.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/requisitionlines.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/requisitions.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/stockquant.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import 'package:spouts_inventory_odoo/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class RequisitionDetails extends StatefulWidget {
  RequisitionDetails({this.data});

  final data;

  @override
  _RequisitionDetailsState createState() => _RequisitionDetailsState();
}

class _RequisitionDetailsState extends Base<RequisitionDetails>
    with SingleTickerProviderStateMixin {
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  List<RequisitionLine> _issuedLines = [];
  List<RequisitionLine> _requisitionLines = [];
  List<String> _issuedLineBarcodes = [];
  var _stockMoveQuant = 0.0;
  String name = "";
  String image_URL = "";
  String email = "";
  List partner_id = [];
  List employee_id = [];
  List responsible = [];
  List requested_by = [];
  var request_date = "";
  var notes = "";
  var picking_type_id = [];
  var state = "";
  var country = "";
  var _lotId = [];
  var ref = "",
      product_lines = [],
      location_src_id = [],
      location_dest_id = [],
      parish = "";
  var _journalId;
  var _accountId;
  var _currencyId;
  Requisition _requisition;
  List<Journal> journals = [];
  List<Currency> currencies = [];
  List<Account> bankAccounts = [];
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _memoController = new TextEditingController();
  TextEditingController _paymentDateController = new TextEditingController();
  TextEditingController _barcodeNumberController = new TextEditingController();
  String _productSelection = "Select Product";
  String _accountSelection = "Select Account";
  String _uomSelection = "Unit of Measurement";
  String _bankSelection = "Select Bank Acct",
      _journalSelection = "Select Journal",
      _currencySelection = "Select Currency";
  TabController _controller;
  var _uomId = [];
  int _productId;
  List<StockQuant> _employeeStockQuant = [];
  List<String> _employeeStockQuantString = [];
  String _scanBarcode;
  BuildContext dialogContext;
  var _selectedIndex = 0;
  List<Widget> list = [
    Tab(
      text: 'Approved',
    ),
    Tab(
      text: 'To Issue',
    ),
    Tab(text: 'Other Info'),
  ];
  final List<Map<String, String>> listOfColumns = [
    {"Product": "AAAAAA", "Qty": "1", "Subtotal": "0"},
    {"Product": "BBBBBB", "Qty": "3", "Subtotal": "0"},
    {"Product": "CCCCCC", "Qty": "2", "Subtotal": "0"}
  ];

  @override
  void initState() {
    super.initState();

    _requisition = widget.data;
    _controller = TabController(length: list.length, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
    });
    _getEmployeeBarCodeStock();
    getOdooInstance().then((odoo) {
      _getInvoiceData();
    });
  }

  _getInvoiceData() async {
    setState(() {
      _requisitionLines = [];
      name = _requisition.name;
      state = _requisition.state;
      responsible = _requisition.responsible;
      employee_id = _requisition.employee_id;
      requested_by = _requisition.requested_by;
      request_date = _requisition.request_date;
      notes = _requisition.notes;
      location_src_id = _requisition.location_src_id;
      location_dest_id = _requisition.location_dest_id;
      picking_type_id = _requisition.picking_type_id;
      product_lines = _requisition.product_lines;
      print("========================================");
      print("The line ids are " + _requisition.product_lines.toString());
      print("========================================");
    });

    if (_requisition.product_lines.toString().isNotEmpty) {
      print("The line ids are " + _requisition.product_lines.toString());
      var invoicelines =
          jsonDecode(jsonEncode(_requisition.product_lines.toString()));
      // var decodedinvoicelines = json.decode(invoicelines);
      print("The requisition line ids are " + invoicelines.toString());
      for (var i in _requisition.product_lines) {
        print("Getting data for line " + i.toString());
        _getRequisitionLineData(i);
      }
    }
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

  //SCAN BARCODE FUNCTION
  Future<void> scanBarcodeNormal() async {
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
      _getProductByBarcode();
    });
    // showMessage("Alert",
    //     "Please select the parent account, the contact and payment terms before adding products.");
  }

  //SEARCH FOR BARCODE IN EMPLOYEE'S STOCK
  _getProductByBarcode() async {
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
        _addIssueLine();
      }
    } else {
      showMessage("Alert", "The item you have scanned is not in your stock");
    }
  }

  //DEBUGGING: ADD A LINE ITEM BY TYPING BARCODE NO< NOT SCANNING
  _addIssueLineManually() async {
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
                  _getProductByBarcode();
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

  _saveStockMoveLines() {
    var count = 0;
    var moveLineId;
    print("+++++++++++++++ THIS IS THE STOCK QUANTITY " +
        _stockMoveQuant.toString().split(".")[0] +
        " ++++++++++++++++++++++++++++++");
    print("+++++++++++++++ THIS IS THE STOCK MOVE LINES QUANTITY " +
        _issuedLines.length.toString() +
        " ++++++++++++++++++++++++++++++");
    if (_stockMoveQuant.toString().split(".")[0] !=
        _issuedLines.length.toString()) {
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
      for (var i in _issuedLines) {
        // print("THE MOVE ID IS - " + i..toString());
        // odoo.write(Strings.sale_order, [_salesOrderId], {"product_serial": ""});
        odoo.create(Strings.product_serial, {
          // "move_id": i.move_id[0],
          "request_id": _requisition.id,
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
              if (count == _issuedLines.length) {
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
          Strings.requisition,
          "add_serial",
          [_requisition.id],
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
                    _requisitionLines = [];
                    _issuedLines = [];
                    _issuedLineBarcodes = [];
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

  _getRequisitionLineData(int _lineId) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinerequisitionlines") != null) {
      print("+++++++++++++++++++++++++++++++++++++++++ => \n" +
          preference.getString("offlinerequisitionlines"));
      var requisitionlinelist =
          json.decode(preference.getString("offlinerequisitionlines"));
      setState(() {
        for (var i in requisitionlinelist) {
          if (i["id"] == _lineId) {
            _requisitionLines.add(new RequisitionLine(
              id: i["id"],
              quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
              product_id: i["product_id"] is! bool ? i["product_id"] : "Unkown",
            ));
            i["quantity"] is! bool
                ? _stockMoveQuant += i["quantity"]
                : _stockMoveQuant += 0.0;
          }
        }
      });
    }
    // isConnected().then((isInternet) {
    //   if (isInternet) {
    //     showLoading();
    //     odoo.searchRead(Strings.account_move_line, [
    //       ['id', "=", _lineId],
    //       ['product_id', "!=", false],
    //     ], [
    //       'product_id',
    //       'quantity',
    //       'price_subtotal'
    //     ]).then(
    //       (OdooResponse res) {
    //         if (!res.hasError()) {
    //           setState(() {
    //             hideLoading();
    //             String session = getSession();
    //             session = session.split(",")[0].split(";")[0];
    //             final result = res.getResult()['records'][0];
    //             _invoiceLines.add(
    //               new InvoiceLine(
    //                 id: result["id"],
    //                 quantity:
    //                     result["quantity"] is! bool ? result["quantity"] : 1.0,
    //                 price_subtotal: result["price_subtotal"] is! bool
    //                     ? result["price_subtotal"]
    //                     : 0.0,
    //                 price_unit: result["price_unit"] is! bool
    //                     ? result["price_unit"]
    //                     : 0.0,
    //                 name: result["product_id"] is! bool
    //                     ? result["product_id"][1]
    //                     : "Unkown",
    //                 // product_uom_id: result["product_uom_id"] is! bool
    //                 //     ? result["product_uom_id"][1]
    //                 //     : "pcs",
    //               ),
    //             );
    //             // _invoiceLines.add(
    //             //   new InvoiceLine(
    //             //     id: result["id"],
    //             //     quantity:
    //             //         result["quantity"] is! bool ? result["quantity"] : 0,
    //             //     name: result["name"].toString(),
    //             //     product_id: result["product_id"] is! bool
    //             //         ? result["product_id"][1]
    //             //         : "-",
    //             //     tax_ids:
    //             //         result["tax_ids"] is! bool ? result["tax_ids"][1] : "-",
    //             //     product_uom_id: result["product_uom_id"] is! bool
    //             //         ? result["product_uom_id"][1]
    //             //         : "-",
    //             //     price_subtotal: result["price_subtotal"] is! bool
    //             //         ? result["price_subtotal"]
    //             //         : 0,
    //             //     price_unit: result["price_unit"] is! bool
    //             //         ? result["price_unit"]
    //             //         : 0,
    //             //   ),
    //             // );
    //           });
    //         } else {
    //           print(res.getError());
    //           showMessage("Warning", res.getErrorMessage());
    //         }
    //       },
    //     );
    //   } else {
    //     if (preference.getString("offlineinvoicelines") != null) {
    //       print(preference.getString("offlineinvoicelines"));
    //       var invoicelinelist =
    //           json.decode(preference.getString("offlineinvoicelines"));
    //       setState(() {
    //         for (var i in invoicelinelist) {
    //           _invoiceLines.add(new InvoiceLine(
    //             id: i["id"],
    //             quantity: i["quantity"] is! bool ? i["quantity"] : 1.0,
    //             price_subtotal:
    //                 i["price_subtotal"] is! bool ? i["price_subtotal"] : 0.0,
    //             price_unit: i["price_unit"] is! bool ? i["price_unit"] : 0.0,
    //             name: i["product_id"] is! bool ? i["product_id"][1] : "Unkown",
    //           ));
    //         }
    //       });
    //     }
    //   }
    // });
  }

  issueStock() async {
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
              new Text("Issuing Stock ....."),
            ],
          ),
        );
      },
    );
    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.requisition,
          "issue_request",
          [_requisition.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("ISSUED REQUSITION STOCK");
              print("++++++++++++++++++++++");
              getOdooInstance().then((odoo) async {
                // await _getInvoices();
                // await _getDraftInvoices();
                Navigator.pop(context);
                showRequistionSuccessMessage("Success",
                    "Requisitioned stock issued successfully", "continue");
              });
            } else {
              print(res.getError());
              Navigator.pop(context);
              showMessage("Warning", res.getErrorMessage());
            }
          },
        );
      }
    });
  }

  _cancelRequistion() async {
    SharedPreferences preference = await SharedPreferences.getInstance();

    isConnected().then((isInternet) {
      if (isInternet) {
        showLoading();
        odoo.callKW(
          Strings.requisition,
          "reset",
          [_requisition.id],
        ).then(
          (OdooResponse res) {
            if (!res.hasError()) {
              print("++++++++++++++++++++++");
              print("CANCELLED REQUISITION");
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

  showRequistionSuccessMessage(String title, String message, String saveType) {
    hideLoading();
    if (Platform.isAndroid) {
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
                    pushReplacement(Home());
                  } else {
                    setState(() {
                      _requisitionLines = [];
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
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return CupertinoAlertDialog(
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
  }

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
                      width: 110,
                      child: TextButton(
                        // textColor: Colors.white,
                        // height: 60.0,
                        // color: state.toLowerCase() == "draft"
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
                              child: state.toLowerCase() == "draft"
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
                height: 20,
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Ref:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            name,
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
                          "Request Date:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          request_date,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    // Row(
                    //   children: [
                    //     Text(
                    //       "Due Date:",
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //     SizedBox(
                    //       width: 5,
                    //     ),
                    //     Text(
                    //       invoice_payment_term_id != null
                    //           ? invoice_payment_term_id
                    //           : "",
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.bold),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 6,
                    // ),
                    Row(
                      children: [
                        Text(
                          "Operation Type:",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            picking_type_id != null ? picking_type_id[1] : "",
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
                text: 'Approved',
              ),
              Tab(
                text: 'To Issue',
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
                          DataColumn(label: Text('Scan')),
                        ],
                        rows:
                            _requisitionLines // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(element.product_id[1]
                                          .toString())), //Extracting from Map element the value
                                      DataCell(
                                          Text(element.quantity.toString())),
                                      DataCell(
                                        new IconButton(
                                            icon: new Icon(
                                              Icons.qr_code_scanner,
                                              color: Color(0xff00a09d),
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              // scanBarcodeNormal();
                                              _addIssueLineManually();
                                            }),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (state.toLowerCase() == "confirm")
                            Container(
                              height: 35,
                              width: 100,
                              child: TextButton(
                                // textColor: Colors.red,
                                // height: 60.0,
                                // color: Colors.grey[300],
                                onPressed: () {
                                  _cancelRequistion();
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    _issuedLines.isNotEmpty
                        ? DataTable(
                            showBottomBorder: true,
                            columnSpacing: 10,
                            // dataRowHeight: 1,
                            columns: [
                              DataColumn(label: Text('Product')),
                              DataColumn(label: Text('Barcode')),
                              DataColumn(label: Text('Qty')),
                            ],
                            rows:
                                _issuedLines // Loops through dataColumnText, each iteration assigning the value to element
                                    .map(
                                      (element) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(element.product_id[1]
                                              .toString())), //Extracting from Map element the value
                                          DataCell(
                                              Text(element.barcode.toString())),
                                          DataCell(Text(
                                              element.quantity.toString())),
                                          // DataCell(
                                          //   new IconButton(
                                          //       icon: new Icon(
                                          //         Icons.delete_forever_sharp,
                                          //         color: Colors.red,
                                          //         size: 16,
                                          //       ),
                                          //       onPressed: () {
                                          //         _deleteProductToIssue(
                                          //             RequisitionLine(
                                          //                 id: _productId,
                                          //                 product_id: [
                                          //                   _productId,
                                          //                   _productSelection
                                          //                 ],
                                          //                 quantity: 1));
                                          //       }),
                                          // ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          )
                        : Text('No items to issue'),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    if (state.toLowerCase() == "confirm")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 35,
                            width: 120,
                            child: TextButton(
                              // textColor: Colors.white,
                              // height: 60.0,
                              // color: Color(0xff00a09d),
                              onPressed: () {
                                // issueStock();
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
                                      "Issue",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
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
                              "Stock Source",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Divider(),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Stock Destination",
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
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                location_src_id != null
                                    ? location_src_id[1]
                                    : "",
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 6,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                location_dest_id != null
                                    ? location_dest_id[1]
                                    : "",
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
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
              expandedHeight: MediaQuery.of(context).size.height * 0.28,
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

  _addIssueLine() async {
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
                  _addProductToIssue(RequisitionLine(
                      id: _productId,
                      product_id: [_productId, _productSelection],
                      quantity: 1,
                      lot_id: _lotId,
                      barcode: _scanBarcode));
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

  _addProductToIssue(RequisitionLine product) {
    var orderedproduct = _issuedLines.firstWhere(
        (orderedproduct) =>
            orderedproduct.product_id[1].toString() ==
            product.product_id[1].toString(),
        orElse: () =>
            RequisitionLine(id: 0, product_id: [], quantity: 1, barcode: ""));
    print("+++++++++ THIS IS THE AVAILABILITY OF A PRODUCT: $orderedproduct");
    // if (orderedproduct.id == 0) {
    if (_issuedLineBarcodes.contains(_scanBarcode)) {
      showMessage("Alert", "Item already scanned");
    } else {
      setState(() {
        _issuedLines.add(RequisitionLine(
          id: _productId,
          product_id: [_productId, _productSelection],
          quantity: 1,
          lot_id: _lotId,
          barcode: _scanBarcode,
        ));
        _issuedLineBarcodes.add(_scanBarcode);
      });
    }
    // } else {
    //   setState(() {
    //     var qty = orderedproduct.quantity;
    //     print("+++++++++ THIS IS THE AVAILABLE PRODUCT QTY: $qty");
    //     _issuedLines.removeWhere((element) => element.id == product.id);
    //     _issuedLines.add(RequisitionLine(
    //       id: _productId,
    //       product_id: [_productId, _productSelection],
    //       quantity: ++orderedproduct.quantity,
    //       barcode: orderedproduct.barcode,
    //     ));
    //   });
    // }
  }

  _deleteProductToIssue(RequisitionLine product) {
    print("Product to delete" + product.toString());
    var issuedproduct = _issuedLines.firstWhere(
        (issuedproduct) =>
            issuedproduct.product_id[1].toString() ==
            product.product_id[1].toString(),
        orElse: () => RequisitionLine(
              id: 0,
              product_id: [],
              quantity: 1,
            ));
    if (issuedproduct.id == 0) {
      setState(() {
        _issuedLines.removeWhere((element) => element.id == issuedproduct.id);
      });
    } else {
      setState(() {
        var qty = issuedproduct.quantity;
        print("+++++++++ THIS IS THE AVAILABLE PRODUCT QTY: $qty");
        _issuedLines.removeWhere((element) => element.id == product.id);
        _issuedLines.add(RequisitionLine(
          id: _productId,
          product_id: [_productId, _productSelection],
          quantity: --issuedproduct.quantity,
        ));
      });
    }
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
