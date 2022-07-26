

class History {
  String pickUp;
  String destination;
  String fares;
  String status;
  String createdAt;
  String paymentMethod;

  History(
      {this.createdAt,
      this.destination,
      this.fares,
      this.paymentMethod,
      this.pickUp,
      this.status});
}
