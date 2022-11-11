class StockPickingLineDetails {
  int id;
  int product_id;
  List lot_id;
  double product_uom_qty;
  List product_uom_id;
  double qty_done;
  String barcode;

  StockPickingLineDetails(
      {this.id,
      this.product_id,
      this.lot_id,
      this.product_uom_qty,
      this.product_uom_id,
      this.barcode});
}
