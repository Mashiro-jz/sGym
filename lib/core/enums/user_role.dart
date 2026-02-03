enum UserRole {
  /// Just normal user, access to generate QR Code, join into trainings etc.
  client("Client"),

  /// Cashier - access do checking carnet access, and sells carnets
  cashier("Cashier"),

  /// Trainer - access to manage trainings, see clients etc.
  trainer("Trainer"),

  /// Manager - full access, manage cashiers, statistics, etc.
  manager("Manager");

  final String value;
  const UserRole(this.value);
}
