class ItemLine {
  final String description;
  final int qty;
  final double puHt;
  final String type; 

  ItemLine({
    required this.description,
    required this.qty,
    required this.puHt,
    required this.type,
  });

  double get totalHt => qty * puHt;

  ItemLine copyWith({
    String? description,
    int? qty,
    double? puHt,
    String? type,
  }) {
    return ItemLine(
      description: description ?? this.description,
      qty: qty ?? this.qty,
      puHt: puHt ?? this.puHt,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() => {
        'description': description,
        'quantite': qty,
        'puHt': puHt,
        'totalHt': totalHt,
        'type': type,
      };
}
