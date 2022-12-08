import '../../models/user.dart';
import '../../services/users.dart';

Future<KoalUser> getFriend(String friendId) async {
  KoalUser? friend = await getUser(friendId);

  return friend!;
}
