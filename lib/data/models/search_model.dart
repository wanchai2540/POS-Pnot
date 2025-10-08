class SearchItemsModel {
  final String appCode;
  final String statusCode;
  final String subStatusCode;
  final String uuid;
  final String hawb;
  final String date;
  final String productType;
  final String pickUpBy;
  final String lastStatus;
  final String itemNo;
  final String consigneeName;
  final int ctns;
  final String reason;
  final bool isSuspended;

  SearchItemsModel({
    required this.appCode,
    required this.statusCode,
    required this.subStatusCode,
    required this.uuid,
    required this.hawb,
    required this.date,
    required this.productType,
    required this.pickUpBy,
    required this.lastStatus,
    required this.itemNo,
    required this.consigneeName,
    required this.ctns,
    required this.reason,
    required this.isSuspended,
  });

  factory SearchItemsModel.fromJson(Map<String, dynamic> json) {
    return SearchItemsModel(
      appCode: json["appCode"] ?? '',
      statusCode: json["statusCode"] ?? '',
      subStatusCode: json["subStatusCode"] ?? '',
      uuid: json["uuid"] ?? '',
      hawb: json["hawb"] ?? '',
      date: json["date"] ?? '',
      productType: json["productType"] ?? '',
      pickUpBy: json["pickUpBy"] ?? '',
      lastStatus: json["lastStatus"] ?? '',
      itemNo: json["itemNo"] ?? '',
      consigneeName: json["consigneeName"] ?? '',
      ctns: json["ctns"] ?? 0,
      reason: json["reason"] ?? '',
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
      "date": date,
      "productType": productType,
      "pickUpBy": pickUpBy,
      "lastStatus": lastStatus,
      "itemNo": itemNo,
      "consigneeName": consigneeName,
      "ctns": ctns,
      "reason": reason,
      "isSuspended": isSuspended,
    };
  }
}
