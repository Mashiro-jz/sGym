import 'package:agym/core/enums/sex_role.dart';

extension SexRoleExtensions on SexRole {
  String get displayName {
    switch (this) {
      case SexRole.man:
        return "Mężczyzna";
      case SexRole.woman:
        return "Kobieta";
      case SexRole.other:
        return "Inne";
    }
  }
}
