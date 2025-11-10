enum AppRole { user, mechanic, admin, unknown }

AppRole parseRole(String? code) {
  switch (code) {
    case 'USER': return AppRole.user;
    case 'MECHANIC': return AppRole.mechanic;
    case 'ADMIN': return AppRole.admin;
    default: return AppRole.unknown;
  }
}

String roleName(AppRole r) {
  switch (r) {
    case AppRole.user: return 'USER';
    case AppRole.mechanic: return 'MECHANIC';
    case AppRole.admin: return 'ADMIN';
    default: return 'UNKNOWN';
  }
}
