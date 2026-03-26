class City {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;
  final String? timezone;

  City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
    this.timezone,
  });

  String get label {
    final parts = <String>[name];
    final region = admin1?.trim();
    if (region != null && region.isNotEmpty) parts.add(region);
    parts.add(country);
    return parts.join(', ');
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String?,
    );
  }
}
