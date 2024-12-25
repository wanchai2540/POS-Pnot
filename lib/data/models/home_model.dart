class HomeModel {
  int countGreen;
  int countRed;
  int countFad;
  int countOther;
  int countPickupByUps;
  int countPickupBySkl;
  int countPickupByL;
  int totalPickup;
  int scannedPickup;
  int pendingReleasePickup;
  int releasePickup;
  int problemPickup;
  int otherPickup;

  HomeModel({
    required this.countGreen,
    required this.countRed,
    required this.countFad,
    required this.countOther,
    required this.countPickupByUps,
    required this.countPickupBySkl,
    required this.countPickupByL,
    required this.totalPickup,
    required this.scannedPickup,
    required this.pendingReleasePickup,
    required this.releasePickup,
    required this.problemPickup,
    required this.otherPickup,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      countGreen: json["countGreen"],
      countRed: json["countRed"],
      countFad: json["countFad"],
      countOther: json["countOther"],
      countPickupByUps: json["countPickupByUps"],
      countPickupBySkl: json["countPickupBySkl"],
      countPickupByL: json["countPickupByL"],
      totalPickup: json["totalPickup"],
      scannedPickup: json["scannedPickup"],
      pendingReleasePickup: json["pendingReleasePickup"],
      releasePickup: json["releasePickup"],
      problemPickup: json["problemPickup"],
      otherPickup: json["otherPickup"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "countGreen": countGreen,
      "countRed": countRed,
      "countFad": countFad,
      "countOther": countOther,
      "countPickupByUps": countPickupByUps,
      "countPickupBySkl": countPickupBySkl,
      "countPickupByL": countPickupByL,
      "totalPickup": totalPickup,
      "scannedPickup": scannedPickup,
      "pendingReleasePickup": pendingReleasePickup,
      "releasePickup": releasePickup,
      "problemPickup": problemPickup,
      "otherPickup": otherPickup,
    };
  }
}
