import 'acc.dart';

class AppUser {
  final int id;
  final int accId;
  final Acc acc;

  AppUser({required this.id, required this.accId, required this.acc});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'],
    accId: j['acc_id'],
    acc: Acc.fromJson(j['Acc']),
  );
}
