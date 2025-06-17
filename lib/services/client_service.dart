import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientService {
  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('clients');

  Future<Client> saveClient(Client client) async {
    // Génére les keywords pour la recherche
    final searchKeywords = _generateKeywords(client);

    if (client.id.isEmpty) {
      final docRef = await _clientsCollection.add({
        ...client.toMap(),
        'searchKeywords': searchKeywords,
      });
      return client.copyWith(id: docRef.id);
    } else {
      await _clientsCollection.doc(client.id).update({
        ...client.toMap(),
        'searchKeywords': searchKeywords,
      });
      return client;
    }
  }

  List<String> _generateKeywords(Client client) {
    final base =
        '${client.nom} ${client.prenom} ${client.telephone}'.toLowerCase();
    return base.split(' ').where((e) => e.isNotEmpty).toList();
  }
}
