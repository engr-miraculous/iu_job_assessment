enum MediaType { image, video }

enum MediaSource { camera, gallery }

class MediaItem {
  final String path;
  final MediaType type;
  final String? coordinates;
  final DateTime createdAt;
  final String? originalPath; // Store original path if different from processed

  MediaItem({
    required this.path,
    required this.type,
    this.coordinates,
    required this.createdAt,
    this.originalPath,
  });

  MediaItem copyWith({
    String? path,
    MediaType? type,
    String? coordinates,
    DateTime? createdAt,
    String? originalPath,
  }) {
    return MediaItem(
      path: path ?? this.path,
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      originalPath: originalPath ?? this.originalPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type.toString(),
      'coordinates': coordinates,
      'createdAt': createdAt.toIso8601String(),
      'originalPath': originalPath,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      path: json['path'],
      type: MediaType.values.firstWhere((e) => e.toString() == json['type']),
      coordinates: json['coordinates'],
      createdAt: DateTime.parse(json['createdAt']),
      originalPath: json['originalPath'],
    );
  }

  @override
  String toString() {
    return 'MediaItem(path: $path, type: $type, coordinates: $coordinates, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem &&
        other.path == path &&
        other.type == type &&
        other.coordinates == coordinates &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        type.hashCode ^
        coordinates.hashCode ^
        createdAt.hashCode;
  }
}

// State class for media management
class MediaState {
  final List<MediaItem> items;
  final bool isLoading;
  final String? error;

  const MediaState({this.items = const [], this.isLoading = false, this.error});

  MediaState copyWith({
    List<MediaItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return MediaState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
