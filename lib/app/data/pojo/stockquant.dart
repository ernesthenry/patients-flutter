class StockQuant {
  int id;
  String display_name;
  List location_id;
  List lot_id;
  List owner_id;
  List product_id;
  List product_uom_id;
  List package_id;
  double quantity;
  double reserved_quantity;
  bool on_hand;
  double value;

  StockQuant(
      {this.id,
      this.display_name,
      this.lot_id,
      this.location_id,
      this.owner_id,
      this.product_id,
      this.product_uom_id,
      this.on_hand,
      this.package_id,
      this.quantity,
      this.reserved_quantity,
      this.value});
}
