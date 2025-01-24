class DetailItemScanModel {
  String uuid;
  String sourceInfoCode;
  String statusCode;
  String status;
  String imageUrl;
  List albums;
  String remark;
  String createdAt;
  String createdBy;

  DetailItemScanModel({
    required this.uuid,
    required this.sourceInfoCode,
    required this.statusCode,
    required this.status,
    required this.imageUrl,
    required this.albums,
    required this.remark,
    required this.createdAt,
    required this.createdBy,
  });

  factory DetailItemScanModel.fromJson(Map<String, dynamic> json) {
    return DetailItemScanModel(
      uuid: json["uuid"] ?? "",
      sourceInfoCode: json["sourceInfoCode"] ?? "",
      statusCode: json["statusCode"] ?? "",
      status: json["status"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      albums: json["albums"] ?? [],
      remark: json["remark"] ?? "",
      createdAt: json["createdAt"] ?? "",
      createdBy: json["createdBy"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "sourceInfoCode": sourceInfoCode,
      "statusCode": statusCode,
      "status": status,
      "imageUrl": imageUrl,
      "albums": albums,
      "remark": remark,
      "createdAt": createdAt,
      "createdBy": createdBy,
    };
  }
}
