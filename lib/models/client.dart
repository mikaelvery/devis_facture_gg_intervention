import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final String codePostal;
  final String ville;
  final String pays;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.pays,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'codePostal': codePostal,
        'ville': ville,
        'pays': pays,
      };

  factory Client.fromDocument(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      adresse: map['adresse'] ?? '',
      codePostal: map['codePostal'] ?? '',
      ville: map['ville'] ?? '',
      pays: map['pays'] ?? '',
    );
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      adresse: map['adresse'] ?? '',
      codePostal: map['codePostal'] ?? '',
      ville: map['ville'] ?? '',
      pays: map['pays'] ?? '',
    );
  }

  Client copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? adresse,
    String? codePostal,
    String? ville,
    String? pays,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      pays: pays ?? this.pays,
    );
  }
}
