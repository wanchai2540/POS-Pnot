class ReleaseRoundModel {
  String uuid;
  int itemNo;
  String productType;
  String hawb;
  String type;
  String pickUpBy;
  String statusCode;
  String subStatusCode;
  String lastStatus;
  bool isProblem;
  int ctns;
  String consigneeName;
  String createdAt;
  bool isSuspended;

  ReleaseRoundModel({
    required this.uuid,
    required this.itemNo,
    required this.productType,
    required this.hawb,
    required this.type,
    required this.pickUpBy,
    required this.statusCode,
    required this.subStatusCode,
    required this.lastStatus,
    required this.isProblem,
    required this.ctns,
    required this.consigneeName,
    required this.createdAt,
    required this.isSuspended,
  });

  factory ReleaseRoundModel.fromJson(Map<String, dynamic> json) {
    return ReleaseRoundModel(
      uuid: json["uuid"] ?? "",
      itemNo: json["itemNo"] ?? 0,
      productType: json["productType"] ?? "",
      hawb: json["hawb"] ?? "",
      type: json["type"] ?? "",
      pickUpBy: json["pickUpBy"] ?? "",
      statusCode: json["statusCode"] ?? "",
      subStatusCode: json["subStatusCode"] ?? "",
      lastStatus: json["lastStatus"] ?? "",
      isProblem: json["isProblem"] ?? false,
      ctns: json["ctns"] ?? 0,
      consigneeName: json["consigneeName"] ?? "",
      createdAt: json["createdAt"] ?? "",
      isSuspended: json["isSuspended"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "itemNo": itemNo,
      "productType": productType,
      "hawb": hawb,
      "type": type,
      "pickUpBy": pickUpBy,
      "statusCode": statusCode,
      "subStatusCode": subStatusCode,
      "lastStatus": lastStatus,
      "isProblem": isProblem,
      "ctns": ctns,
      "consigneeName": consigneeName,
      "createdAt": createdAt,
      "isSuspended": isSuspended,
    };
  }
}
