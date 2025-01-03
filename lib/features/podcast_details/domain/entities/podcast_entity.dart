import '../../../../core/enums/image_size_enums.dart';

class Podcast {
  final String id;
  final String name;
  final String publisher;
  final String? description;
  final String? smallImageUrl;
  final String? mediumImageUrl;
  final String? largeImageUrl;

  Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    this.description,
    this.smallImageUrl,
    this.mediumImageUrl,
    this.largeImageUrl,
  });

  String? getImageForSize(ImageSize size) {
    switch (size) {
      case ImageSize.small:
        return smallImageUrl;
      case ImageSize.medium:
        return mediumImageUrl;
      case ImageSize.large:
        return largeImageUrl;
    }
  }
}
