class Product {
  int id;
  String name;
  List categ_id;
  String taxes_id;
  double lst_price;
  List uom_id;
  List account_id;
  String barcode;

  Product(
      {this.id,
      this.name,
      this.categ_id,
      this.taxes_id,
      this.lst_price,
      this.uom_id,
      this.account_id,
      this.barcode});
}
