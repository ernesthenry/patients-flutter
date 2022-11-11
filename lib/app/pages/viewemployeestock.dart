import 'dart:convert';
import 'dart:math' as math;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spouts_inventory_odoo/app/data/pojo/employees.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/employeestock.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/stocklocations.dart';
import 'package:spouts_inventory_odoo/app/data/services/odoo_response.dart';
import 'package:spouts_inventory_odoo/app/utility/strings.dart';
import '../../base.dart';
import 'home.dart';

List<Employees> _employees = [];
List<StockLocation> _employeeStockLocations = [];
List<EmployeeStock> _allEmployeeStock = [];

class ViewEmploeeStock extends StatefulWidget {
  @override
  _ViewEmploeeStockState createState() => _ViewEmploeeStockState();
}

class _ViewEmploeeStockState extends Base<ViewEmploeeStock> {
  var _width, _height;
  List<EmployeeStock> _singularEmployeeStock = [];
  String _result;
  int _userId;

  //GET EMPLOYEE STOCK LOCATIONS
  _getEmployeeStockLocations() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinestocklocations") != null) {
      print(preference.getString("offlinestocklocations"));
      var stocklist =
          json.decode(preference.getString("offlinestocklocations"));
      setState(() {
        _employeeStockLocations = [];
        for (var i in stocklist) {
          _employeeStockLocations.add(
            new StockLocation(
              id: i["id"],
              display_name: i["display_name"].toString(),
              usage: i["usage"] is! bool ? i["usage"] : "internal",
              location_id: i["location_id"] is! bool ? i["location_id"] : [],
            ),
          );
        }
      });
    }
  }

  //GET EMPLOYEES WITH STOCK LOCATIONS
  _getEmployees() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlineemployees") != null) {
      print(preference.getString("offlineemployees"));
      var stocklist = json.decode(preference.getString("offlineemployees"));
      setState(() {
        _allEmployeeStock = [];
        for (var i in stocklist) {
          _employees.add(
            new Employees(
              id: i["id"],
              name: i["name"],
              job_title: i["job_title"] is! bool ? i["job_title"] : "",
              location_id: i["location_id"] is! bool ? i["location_id"] : [],
              mobile_phone: i["mobile_phone"] is! bool ? i["mobile_phone"] : "",
              inventory_report:
                  i["inventory_report"] is! bool ? i["inventory_report"] : [],
              // employeeStock:
            ),
          );
        }
      });
      // _mapStockToLocation();
    }
  }

  //GET STOCK DATA FOR ALL EMPLOYEES UNDER RESPECTIVE LCOATIONS
  _getAllEmployeeStock() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlineallemployeestock") != null) {
      print(preference.getString(
          "<======================= EMPLOYEE STOCK ========================>"));
      print(preference.getString("offlineallemployeestock"));
      var stocklist =
          json.decode(preference.getString("offlineallemployeestock"));
      setState(() {
        _allEmployeeStock = [];
        for (var i in stocklist) {
          _allEmployeeStock.add(
            new EmployeeStock(
              id: i["id"],
              report_id: i["report_id"],
              categ_id: i["categ_id"] is! bool ? i["categ_id"] : [],
              product_id: i["product_id"] is! bool ? i["product_id"] : [],
              quantity_in: i["quantity_in"] is! bool ? i["quantity_in"] : 0.0,
              quantity_out:
                  i["quantity_out"] is! bool ? i["quantity_out"] : 0.0,
              quantity_adjust:
                  i["quantity_adjust"] is! bool ? i["quantity_adjust"] : 0.0,
              quantity_begin:
                  i["quantity_begin"] is! bool ? i["quantity_begin"] : 0.0,
              quantity_finish:
                  i["quantity_finish"] is! bool ? i["quantity_finish"] : 0.0,
              amount_adjust:
                  i["amount_adjust"] is! bool ? i["amount_adjust"] : 0.0,
              amount_begin:
                  i["amount_begin"] is! bool ? i["amount_begin"] : 0.0,
              amount_finish:
                  i["amount_finish"] is! bool ? i["amount_finish"] : 0.0,
              amount_in: i["amount_in"] is! bool ? i["amount_in"] : 0.0,
              amount_out: i["amount_out"] is! bool ? i["amount_out"] : 0.0,
            ),
          );
        }
      });
    }
  }

  void _mapStockToLocation() {
    print("+++++++ MAPPING STOCK TO LOCATION ++++++++ ");
    if (_employees.isNotEmpty) {
      for (var i in _employees) {
        print("+++++++ THE STOCK LOCATION IS " +
            i.location_id[1] +
            " " +
            i.id.toString() +
            " " +
            i.inventory_report.toString() +
            " ++++++++++++++++");
        if (_allEmployeeStock.indexWhere((element) =>
                element.report_id[0].toString().contains(i.id.toString())) >=
            0) {
          print("THE EMPLOYEE ID IS " + i.id.toString());
          print("THE MATCHED ID IS " +
              _allEmployeeStock
                  .indexWhere((element) => element.report_id[0] == i.id)
                  .toString());
          // _singularEmployeeStock.add();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // _getEmployeeStockLocations();
    _getEmployees();
    _getAllEmployeeStock();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          "Staff Stock Balance",
          // style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                var result = await showSearch<String>(
                  context: context,
                  delegate: CustomLocationDelegate(),
                );
                setState(() => _result = result);
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ExpandableTheme(
          data: const ExpandableThemeData(
            iconColor: Colors.blue,
            useInkWell: true,
          ),
          child: ListView.builder(
            itemCount: _employees.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) =>
                // Text(_employees[i].name))
                Card3(
              storeLabel: _employees[i].location_id[1],
              employeeId: _employees[i].id,
              stockLines: _employees[i].inventory_report,
              allEmployeeStock: _allEmployeeStock,
            ),
          ),
        ),
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

class Card3 extends StatelessWidget {
  final String storeLabel;
  final int employeeId;
  final List stockLines;
  final List<EmployeeStock> allEmployeeStock;
  Card3({
    this.storeLabel,
    this.employeeId,
    this.allEmployeeStock,
    this.stockLines,
  });

  @override
  Widget build(BuildContext context) {
    print("These are the employee lines " + stockLines.toString());
    buildItem(EmployeeStock item) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.product_id[1]),
                Text.rich(
                  TextSpan(
                    children: [
                      // TextSpan(
                      //   text: item.quantity_begin.toString(),
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold, color: Colors.green),
                      // ),
                      // TextSpan(
                      //   text: "  |  ",
                      // ),
                      TextSpan(
                        text: item.quantity_finish.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
          ],
        ),
      );
    }

    buildList() {
      // ListView.builder(
      //     itemCount: stockLines.length,
      //     physics: const AlwaysScrollableScrollPhysics(),
      //     itemBuilder: (context, i) => Text(allEmployeeStock[i].product_id[1]));
      return Column(
        children: <Widget>[
          for (var i in allEmployeeStock)
            if (stockLines.contains(i.id)) buildItem(i),
        ],
      );
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToExpand: true,
                  tapBodyToCollapse: true,
                  hasIcon: false,
                ),
                header: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ExpandableIcon(
                          theme: const ExpandableThemeData(
                            expandIcon: Icons.arrow_right,
                            collapseIcon: Icons.arrow_drop_down,
                            iconColor: Colors.white,
                            iconSize: 28.0,
                            iconRotationAngle: math.pi / 2,
                            iconPadding: EdgeInsets.only(right: 5),
                            hasIcon: false,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            storeLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: buildList(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class CustomLocationDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.chevron_left), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    var listToShow;
    if (query.isNotEmpty)
      listToShow = _employees
          .where((e) =>
              e.name.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    // .where((e) => e.contains(query) && e.startsWith(query))
    // .toList();
    else
      listToShow = _employees;
    print("This is the query $query");
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        itemCount: listToShow.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, i) =>
            // Text(listToShow[i].name)
            Card3(
          storeLabel: listToShow[i].location_id[1],
          employeeId: listToShow[i].id,
          stockLines: listToShow[i].inventory_report,
          allEmployeeStock: _allEmployeeStock,
        ),
      ),
    );
  }
}
