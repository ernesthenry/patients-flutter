class Invoice {
  int id;
  String invoice_date;
  String payment_reference;
  double amount_total;
  double amount_residual;
  String state;
  String payment_state;
  List partner_id;
  String edi_state;
  String invoice_payment_term_id;
  String journal_id;
  String currency_id;
  String invoice_user_id;
  String picking_type_id;
  String team_id;
  double amount_untaxed;
  double amount_tax;
  List line_ids;

  Invoice(
      {this.id,
      this.invoice_date,
      this.payment_reference,
      this.amount_total,
      this.amount_residual,
      this.state,
      this.payment_state,
      this.partner_id,
      this.edi_state,
      this.invoice_payment_term_id,
      this.journal_id,
      this.currency_id,
      this.invoice_user_id,
      this.picking_type_id,
      this.team_id,
      this.amount_untaxed,
      this.amount_tax,
      this.line_ids});
}
