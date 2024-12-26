class ScanListenerModel {
  String appCode;
  String statusCode;
  String subStatusCode;
  String uuid;
  String hawb;
  String productType;
  String pickupBy;
  String lastStatus;

  ScanListenerModel({
    required this.appCode,
    required this.statusCode,
    required this.subStatusCode,
    required this.uuid,
    required this.hawb,
    required this.productType,
    required this.pickupBy,
    required this.lastStatus,
  });

  factory ScanListenerModel.fromJson(Map<String, dynamic> json) {
    return ScanListenerModel(
      appCode: json["appCode"] ?? "",
      statusCode: json["statusCode"] ?? "",
      subStatusCode: json["subStatusCode"] ?? "",
      uuid: json["uuid"] ?? "",
      hawb: json["hawb"] ?? "",
      productType: json["productType"] ?? "",
      pickupBy: json["pickupBy"] ?? "",
      lastStatus: json["lastStatus"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "appCode": appCode,
      "statusCode": statusCode,
      "subStatusCode": subStatusCode,
      "uuid": uuid,
      "hawb": hawb,
      "productType": productType,
      "pickupBy": pickupBy,
      "lastStatus": lastStatus,
    };
  }
}
