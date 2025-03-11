class HomeBanner {
  final String title;
  final String link;
  final String image;

  HomeBanner({
    required this.title,
    required this.link,
    required this.image,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      image: json['image'] ?? '',
    );
  }
} 