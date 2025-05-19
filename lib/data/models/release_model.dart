class ReleaseModel {
  String appCode;
  String statusCode;
  String subStatusCode;
  String uuid;
  String hawb;
  String productType;
  String pickupBy;
  String lastStatus;
  String itemNo;
  String consigneeName;
  String ctns;
  String reason;
  bool isSuspended;

  ReleaseModel({
    required this.appCode,
    required this.statusCode,
    required this.subStatusCode,
    required this.uuid,
    required this.hawb,
    required this.productType,
    required this.pickupBy,
    required this.lastStatus,
    required this.itemNo,
    required this.consigneeName,
    required this.ctns,
    required this.reason,
    required this.isSuspended,
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      appCode: json["appCode"] ?? "",
      statusCode: json["statusCode"] ?? "",
      subStatusCode: json["subStatusCode"] ?? "",
      uuid: json["uuid"] ?? "",
      hawb: json["hawb"] ?? "",
      productType: json["productType"] ?? "",
      pickupBy: json["pickupBy"] ?? "",
      lastStatus: json["lastStatus"] ?? "",
      itemNo: json["itemNo"].toString() ?? "",
      consigneeName: json["consigneeName"] ?? "",
      ctns: json["ctns"].toString() ?? "",
      reason: json["reason"] ?? "",
      isSuspended: json["isSuspended"] ?? false,
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
      "itemNo": itemNo,
      "consigneeName": consigneeName,
      "ctns": ctns,
      "reason": reason,
      "isSuspended": isSuspended,
    };
  }
}
