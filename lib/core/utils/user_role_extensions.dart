import 'package:agym/core/enums/user_role.dart';
import 'package:flutter/material.dart';

extension UserRoleExtensions on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.manager:
        return "Menadżer";
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
