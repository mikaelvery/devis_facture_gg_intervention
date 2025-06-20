class ItemLine {
  final String description;
  final int qty;
  final double puHt;
  final String type;
  final double tva;

  ItemLine({
    required this.description,
    required this.qty,
    required this.puHt,
    required this.type,
    this.tva = 10,
  });

  double get totalHt => qty * puHt;
  double get totalTva => totalHt * (tva / 100);

  ItemLine copyWith({
    String? description,
    int? qty,
    double? puHt,
    String? type,
    double? tva,
  }) {
    return ItemLine(
      description: description ?? this.description,
      qty: qty ?? this.qty,
      puHt: puHt ?? this.puHt,
      type: type ?? this.type,
      tva: tva ?? this.tva,
    );
  }

  Map<String, dynamic> toMap() => {
        'description': description,
        'quantite': qty,
        'puHt': puHt,
        'totalHt': totalHt,
        'type': type,
        'tva': tva,
        'totalTva': totalTva,
      };

  factory ItemLine.fromMap(Map<String, dynamic> map) {
    final puHtRaw = map['puHt'];
    final tvaRaw = map['tva'];

    return ItemLine(
      description: map['description'] ?? '',
      qty: (map['quantite'] ?? 0) as int,
      puHt: puHtRaw is num ? puHtRaw.toDouble() : 0.0,
      type: map['type'] ?? '',
      tva: tvaRaw is num ? tvaRaw.toDouble() : 0.0,
    );
  }
  @override
  String toString() {
    return 'ItemLine(description: $description, qty: $qty, puHt: $puHt, type: $type, tva: $tva, totalHt: $totalHt, totalTva: $totalTva)';
  }
}
