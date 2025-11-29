import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import '../model/user_model.dart';
import '../model/person_model.dart';

class UserService {
  final Auth _auth;
  final Firestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _personRef;

  UserService(this._firestore, this._auth) {
    _personRef = _firestore.collection('person');
  }

  Future<User> getPersonByUid(String authUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('firebase_auth_uid', WhereFilter.equal, authUid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception(
            'Usuário não encontrado ou não vinculado (users collection).');
      }

      final userDoc = querySnapshot.docs.first;
      final personId = userDoc.id;

      //Buscar dado: buscando em 'person' pela 'role' do user.
      final personSnapshot =
          await _firestore.collection('person').doc(personId).get();

      if (!personSnapshot.exists) {
        throw Exception('Perfil de pessoa(person collection) não encontrado');
      }

      final data = personSnapshot.data();
      if (data == null) {
        throw Exception('Dados corrompidos');
      }

      //Criar o objeto para devolver ao flutter -
      return User(
        id: authUid,
        name: (data['name'] as String?) ?? 'Sem Nome',
        email: (data['email'] as String?) ?? '',
        role: (data['role'] as String?) ?? 'user',
        profileImg: data['profile_img'] as String?,
      );
    } catch (e) {
      print("Erro ao buscar usuário no Firestore: $e");
      rethrow;
    }
  }
}
