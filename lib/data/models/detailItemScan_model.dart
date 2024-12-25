class DetailitemScanModel {
  String sourceInfoCode;
  String statusCode;
  String status;
  String imageUrl;
  String remark;
  String createdAt;
  String createdBy;

  DetailitemScanModel({
    required this.sourceInfoCode,
    required this.statusCode,
    required this.status,
    required this.imageUrl,
    required this.remark,
    required this.createdAt,
    required this.createdBy,
  });

  factory DetailitemScanModel.fromJson(Map<String, dynamic> json) {
    return DetailitemScanModel(
      sourceInfoCode: json['sourceInfoCode'] ?? '',
      statusCode: json['statusCode'] ?? '',
      status: json['status'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      remark: json['remark'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceInfoCode': sourceInfoCode,
      'statusCode': statusCode,
      'status': status,
      'imageUrl': imageUrl,
      'remark': remark,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
