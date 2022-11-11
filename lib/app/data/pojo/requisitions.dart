class Requisition {
  int id;
  List company_id;
  List employee_id;
  List location_src_id;
  List location_dest_id;
  String name;
  String state;
  String notes;
  String request_date;
  List requested_by;
  List picking_type_id;
  List product_lines;
  List user_id;
  List responsible;

  Requisition(
      {this.id,
      this.company_id,
      this.user_id,
      this.employee_id,
      this.state,
      this.request_date,
      this.notes,
      this.requested_by,
      this.name,
      this.product_lines,
      this.location_dest_id,
      this.location_src_id,
      this.responsible,
      this.picking_type_id});
}
