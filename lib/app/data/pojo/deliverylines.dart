class StockPickingLine {
  int id;
  int product_id;
  String description_picking;
  double product_uom_qty;
  List product_uom;
  String forecast_availability;
  String barcode;

  StockPickingLine(
      {this.id,
      this.product_id,
      this.description_picking,
      this.product_uom_qty,
      this.product_uom,
      this.forecast_availability,
      this.barcode});
}
