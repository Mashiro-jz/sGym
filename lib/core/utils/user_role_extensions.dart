import 'package:sgym/core/enums/user_role.dart';
import 'package:material_ui/material_ui.dart';

extension UserRoleExtensions on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.manager:
        return "Menedżer";
      case UserRole.trainer:
        return "Trener";
      case UserRole.cashier:
        return "Kasjer";
      case UserRole.client:
        return "Klient";
    }
  }

  Color get color {
    switch (this) {
      case UserRole.manager:
        return Colors.red;
      case UserRole.trainer:
        return Colors.orange;
      case UserRole.cashier:
        return Colors.blueGrey;
      case UserRole.client:
        return Colors.green;
    }
  }
}
