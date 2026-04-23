class CategoryGroup {
  final String id;
  final String name;
  final double vendorRoundOff;
  final double storeOfferPercent;

  CategoryGroup({
    required this.id,
    required this.name,
    this.vendorRoundOff = 0,
    this.storeOfferPercent = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vendorRoundOff': vendorRoundOff,
        'storeOfferPercent': storeOfferPercent,
      };

  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
        id: json['id'],
        name: json['name'],
        vendorRoundOff: (json['vendorRoundOff'] as num).toDouble(),
        storeOfferPercent: (json['storeOfferPercent'] as num).toDouble(),
      );

  CategoryGroup copyWith({
    String? id,
    String? name,
    double? vendorRoundOff,
    double? storeOfferPercent,
  }) {
    return CategoryGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      vendorRoundOff: vendorRoundOff ?? this.vendorRoundOff,
      storeOfferPercent: storeOfferPercent ?? this.storeOfferPercent,
    );
  }
}
