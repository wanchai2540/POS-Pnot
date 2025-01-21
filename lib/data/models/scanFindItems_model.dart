class ScanfinditemsModel {
  final String uuid;
  final String itemNo;
  final String productType;
  final String hawb;
  final String lastStatus;
  final String type;
  final String pickUpBy;
  final String statusCode;
  final String subStatusCode;
  final String isProblem;
  final String ctns;
  final String consigneeName;

  ScanfinditemsModel({
    required this.uuid,
    required this.itemNo,
    required this.productType,
    required this.hawb,
    required this.lastStatus,
    required this.type,
    required this.pickUpBy,
    required this.statusCode,
    required this.subStatusCode,
    required this.isProblem,
    required this.ctns,
    required this.consigneeName,
  });

  factory ScanfinditemsModel.fromJson(Map<String, dynamic> json) {
    return ScanfinditemsModel(
      uuid: json["uuid"] ?? '',
      itemNo: json["itemNo"].toString(),
      productType: json["productType"] ?? '',
      hawb: json["hawb"] ?? '',
      lastStatus: json["lastStatus"] ?? '',
      type: json["type"] ?? '',
      pickUpBy: json["pickUpBy"] ?? '',
      statusCode: json["statusCode"] ?? '',
      subStatusCode: json["subStatusCode"] ?? '',
      isProblem: json["isProblem"] ?? '',
      ctns: json["ctns"].toString(),
      consigneeName: json["consigneeName"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "itemNo": itemNo,
      "productType": productType,
      "hawb": hawb,
      "lastStatus": lastStatus,
      "type": type,
      "pickUpBy": pickUpBy,
      "statusCode": statusCode,
      "subStatusCode": subStatusCode,
      "isProblem": isProblem,
      "ctns": ctns,
      "consigneeName": consigneeName,
    };
  }
}
