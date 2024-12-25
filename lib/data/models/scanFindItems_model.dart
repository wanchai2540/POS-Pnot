class ScanfinditemsModel {
  final String uuid;
  final String hawb;
  final String lastStatus;

  ScanfinditemsModel({required this.uuid, required this.hawb, required this.lastStatus});
   factory ScanfinditemsModel.fromJson(Map<String, dynamic> json) {
    return ScanfinditemsModel(
      uuid: json['uuid'] ?? '',
      hawb: json['hawb'] ?? '',
      lastStatus: json['lastStatus'] ?? '',
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'hawb': hawb,
      'lastStatus': lastStatus,
    };
  }
}
