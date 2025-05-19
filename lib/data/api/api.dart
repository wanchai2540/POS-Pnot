import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kymscanner/common.dart';
import 'package:kymscanner/core_log.dart';
import 'package:kymscanner/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  DataService._privateConstructor();

  static final DataService _instance = DataService._privateConstructor();

  factory DataService() => _instance;

  static final _baseUrl = "api.kinyamalogistics.com";

  Map<String, dynamic> query_string = {};

  Future<Map<String, dynamic>> login(String username, String password) async {
    final String path = '/auth/m/sign-in';
    final Uri url = Uri.https(_baseUrl, path);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        prefs.setString("username", username);
        prefs.setString("password", password);
        prefs.setString("accessToken", body["data"]["accessToken"]);
        CoreLog().info("login: login success");
        return {"status": "success", "text": "login success"};
      } else {
        CoreLog().warning("login: login failed");
        return {"status": "failed", "text": "login failed"};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("login: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getDataHome(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/overview';
    final Uri url = Uri.https(_baseUrl, path, {"date": date});
    try {
      final response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        CoreLog().info("getDataHome: recieve data");
        return {"status": "success", "text": "recieve data", "data": body["data"]};
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getDataHome: tokenExpired");
        return {"status": "failed", "text": "tokenExpired", "data": null};
      } else {
        CoreLog().warning("getDataHome: get data failed");
        return {"status": "failed", "text": "get data failed", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("getDataHome: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getScanFindItems(String date, [String type = "all", String? barcode]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/item';
    Map<String, String> query = {"date": date};
    if (type != "99" && type != "all") {
      query.addAll({"status_code": type});
    } else if (type == "99") {
      List<String> typeOther = ["02", "06", "07"];
      List<Map<String, dynamic>> result = await _getDataTypeOther(typeOther, path, date, accessToken);
      try {
        if (result.length == 0) {
          CoreLog().warning("getScanFindItems: Scanned not found data");
          return {"status": "error", "text": "data not found", "data": null};
        } else {
          CoreLog().warning("getScanFindItems: Scanned found data");
          return {"status": "success", "text": "Scanned found data", "data": result};
        }
      } catch (e) {
        CoreLog().error("getScanFindItems: Exception occurred: $e");
        return {"status": "error", "text": "Exception occurred: $e", "data": null};
      }
    }
    final Uri url = Uri.https(_baseUrl, path, query);

    try {
      final response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> result = [];

        for (var data in body["data"]) {
          result.add({
            "uuid": data["uuid"].toString(),
            "itemNo": data["itemNo"].toString(),
            "productType": data["productType"].toString(),
            "hawb": data["hawb"].toString(),
            "type": data["type"].toString(),
            "pickUpBy": data["pickUpBy"].toString(),
            "statusCode": data["statusCode"].toString(),
            "subStatusCode": data["subStatusCode"].toString(),
            "lastStatus": data["lastStatus"].toString(),
            "isProblem": data["isProblem"].toString(),
            "ctns": data["ctns"].toString(),
            "consigneeName": data["consigneeName"].toString(),
          });
        }
        CoreLog().info("getScanFindItems: recieve data");
        return {"status": "success", "text": "recieve data", "data": result};
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getScanFindItems: tokenExpired");
        return {"status": "failed", "text": "tokenExpired", "data": null};
      } else {
        CoreLog().warning("getScanFindItems: get data failed");
        return {"status": "failed", "text": "get data failed", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("getScanFindItems: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getScanListener(String hawb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/scan/pickup';
    Map<String, String> body = {"hawb": hawb};
    final Uri url = Uri.https(_baseUrl, path);

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': "Bearer $accessToken", 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getScanListener: tokenExpired");
        return {"status": "failed", "text": "tokenExpired", "data": null};
      } else {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        CoreLog().info("getScanListener: receieve data");
        return {
          "status": "success",
          "text": "success",
          "code": response.statusCode,
          "body": bodyResponse["data"],
        };
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("getScanListener: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getPendingReleaseListener(String hawb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/scan/pending_release';
    Map<String, String> body = {"hawb": hawb};
    final Uri url = Uri.https(_baseUrl, path);

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': "Bearer $accessToken", 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getPendingReleaseListener: tokenExpired");
        return {"status": "error", "text": "tokenExpired", "data": null};
      } else {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        CoreLog().info("getPendingReleaseListener: receive data");
        return {
          "status": "success",
          "text": "success",
          "code": response.statusCode,
          "body": bodyResponse["data"],
        };
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().warning("getPendingReleaseListener: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getReleaseListener(String hawb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/scan/release';
    Map<String, String> body = {"hawb": hawb};
    final Uri url = Uri.https(_baseUrl, path);

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': "Bearer $accessToken", 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getReleaseListener: tokenExpired");
        return {"status": "error", "text": "tokenExpired", "data": null};
      } else {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        CoreLog().info("getReleaseListener: receive data");
        return {
          "status": "success",
          "text": "success",
          "code": response.statusCode,
          "body": bodyResponse["data"],
        };
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("getReleaseListener: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getProblemList([String? statusCode]) async {
    final String path = '/public/master/problem_pickup';
    final Uri url = Uri.https(_baseUrl, path, {"status_code": statusCode});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> result = [];

        for (var data in body["data"]) {
          result.add({
            "text": data["text"],
            "value": data["value"],
          });
        }
        CoreLog().info("getProblemList: receive data");
        return {"status": "success", "data": result};
      } else {
        CoreLog().error("getProblemList: failed to get data");
        throw "error";
      }
    } catch (e) {
      CoreLog().error("getProblemList: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<String> sendReport(String uuid, String date, String problemCode, String module,
      {List<File?>? image, String? remark}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/report';
    final Uri url = Uri.https(_baseUrl, path);

    try {
      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        'Authorization': "Bearer $accessToken",
        // 'Content-Type': 'multipart/form-data',
      });
      request.fields['uuid'] = uuid;
      request.fields['date'] = date;
      request.fields['problemCode'] = problemCode;
      request.fields['module'] = module;
      if (remark != null || remark!.isEmpty) {
        request.fields['remark'] = remark;
      }

      if (image != null) {
        for (File? img in image) {
          request.files.add(await http.MultipartFile.fromPath('image', img!.path));
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        CoreLog().info("sendReport: success");
        return Future.value("success");
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("sendReport: tokenExpired");
        return Future.value("tokenExpired");
      } else {
        CoreLog().warning("sendReport: failed");
        return Future.value("faild");
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("sendReport: Exception occurred: $e");
      return Future.value("error");
    }
  }

  Future<String> sendRepack(String uuid, String date, List<File?> image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/repack';
    final Uri url = Uri.https(_baseUrl, path);
    try {
      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'multipart/form-data',
      });
      request.fields['uuid'] = uuid;
      request.fields['date'] = date;
      for (File? img in image) {
        request.files.add(await http.MultipartFile.fromPath('image', img!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        CoreLog().info("sendRepack: success");
        return Future.value("success");
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("sendRepack: tokenExpired");
        return Future.value("tokenExpired");
      } else {
        CoreLog().warning("sendRepack: failed");
        return Future.value("faild");
      }
    } catch (e) {
      CoreLog().error("sendRepack: Exeption occurred: $e");
      return Future.value("error");
    }
  }

  Future<String> sendOnlyImage(String uuid, String date, List<File?> image, String module) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/image';

    final Uri url = Uri.https(_baseUrl, path);
    try {
      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'multipart/form-data',
      });
      request.fields['uuid'] = uuid;
      request.fields['date'] = date;
      for (File? img in image) {
        request.files.add(await http.MultipartFile.fromPath('image', img!.path));
      }
      request.fields['module'] = module;

      var response = await request.send();
      if (response.statusCode == 200) {
        CoreLog().info("sendOnlyImage: success");
        return Future.value("success");
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("sendOnlyImage: tokenExpired");
        return Future.value("tokenExpired");
      } else {
        CoreLog().warning("sendOnlyImage: failed");
        return Future.value("faild");
      }
    } catch (e) {
      CoreLog().error("sendOnlyImage: Exeption occurred: $e");
      return Future.value("error");
    }
  }

  Future<String> sendApproveProblem(String uuid, String date, String module, {List<File?>? image}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/approve_problem';
    final Uri url = Uri.https(_baseUrl, path);

    try {
      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'multipart/form-data',
      });
      request.fields['uuid'] = uuid;
      request.fields['date'] = date;
      request.fields['module'] = module;
      if (image != null) {
        for (File? img in image) {
          request.files.add(await http.MultipartFile.fromPath('image', img!.path));
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        CoreLog().info("sendApproveProblem: success");
        return Future.value("success");
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("sendApproveProblem: tokenExpired");
        return Future.value("tokenExpired");
      } else {
        CoreLog().warning("sendApproveProblem: failed");
        return Future.value("faild");
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("sendApproveProblem: Exception occurred: $e");
      return Future.value("error");
    }
  }

  Future<Map<String, dynamic>> getDetailItem(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/pickup/item/$uuid';

    final Uri url = Uri.https(_baseUrl, path);
    try {
      final response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        CoreLog().info("getDetailItem: receive data");
        return {"status": "success", "text": "receive data", "data": body["data"]};
      } else if (await _checkTokenExpire(response.statusCode)) {
        CoreLog().warning("getDetailItem: tokenExpired");
        return {"status": "failed", "text": "tokenExpired", "data": null};
      } else {
        CoreLog().warning("getDetailItem: not found data");
        return {"status": "failed", "text": "not found data", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      CoreLog().error("getDetailItem: Exception occurred: $e");
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<List<Map<String, dynamic>>> _getDataTypeOther(
      List<String> typeOther, String path, String date, String accessToken) async {
    List<Map<String, dynamic>> result = [];
    for (var type in typeOther) {
      Uri url = Uri.https(_baseUrl, path, {"date": date, "status_code": type});
      var response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (body["data"] != null) {
          for (var data in body["data"]) {
            result.add({"uuid": data["uuid"], "hawb": data["hawb"], "lastStatus": data["lastStatus"]});
          }
        }
      }
    }

    return result;
  }

  Future<bool> _checkTokenExpire(int statusCode) async {
    if (statusCode == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      showSessionExpiredDialog(navigatorKey.currentContext!).then((value) {
        prefs.setString("accessToken", "");
        Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil("/login", (_) => false);
      });
      return true;
    }
    return false;
  }
}
