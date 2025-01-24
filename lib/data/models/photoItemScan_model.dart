class PhotoItemScanModel {
  String uuid;
  String location;
  String imageUrl;
  List albums;
  String createdAt;
  String createdBy;

  PhotoItemScanModel({
    required this.uuid,
    required this.location,
    required this.imageUrl,
    required this.albums,
    required this.createdAt,
    required this.createdBy,
  });

  factory PhotoItemScanModel.fromJson(Map<String, dynamic> json) {
    return PhotoItemScanModel(
      uuid: json["uuid"] ?? "",
      location: json["location"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      albums: json["albums"] ?? [],
      createdAt: json["createdAt"] ?? "",
      createdBy: json["createdBy"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "location": location,
      "imageUrl": imageUrl,
      "albums": albums,
      "createdAt": createdAt,
      "createdBy": createdBy,
    };
  }
}
