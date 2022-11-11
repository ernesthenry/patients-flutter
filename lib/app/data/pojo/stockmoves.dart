class StockMoves {
  int id;
  List move_line_ids_without_package;
  List move_ids_without_package;
  List product_id;
  List product_uom;
  double product_uom_qty;
  String forecast_availabilty;

  StockMoves(
      {this.id,
      this.move_line_ids_without_package,
      this.move_ids_without_package,
      this.product_id,
      this.product_uom,
      this.product_uom_qty,
      this.forecast_availabilty});
}
