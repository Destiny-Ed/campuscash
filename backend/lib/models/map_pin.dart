class MapPin {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final bool isFree;
  final double? price;
  final String category; // study, food, admin, free-resource, other
  final List<String> photos;
  final String createdBy;
  final String universityId;
  final double rating;
  final int visitCount;
  final DateTime createdAt;

  MapPin({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.isFree,
    this.price,
    required this.category,
    this.photos = const [],
    required this.createdBy,
    required this.universityId,
    this.rating = 0.0,
    this.visitCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'lat': lat,
        'lng': lng,
        'isFree': isFree,
        'price': price,
        'category': category,
        'photos': photos,
        'createdBy': createdBy,
        'universityId': universityId,
        'rating': rating,
        'visitCount': visitCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MapPin.fromJson(Map<String, dynamic> json) => MapPin(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        isFree: json['isFree'] ?? true,
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        category: json['category'] ?? 'other',
        photos: List<String>.from(json['photos'] ?? []),
        createdBy: json['createdBy'],
        universityId: json['universityId'],
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        visitCount: json['visitCount'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
      );
}
