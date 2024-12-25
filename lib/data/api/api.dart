import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos/data/models/detailItemScan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  DataService._privateConstructor();

  static final DataService _instance = DataService._privateConstructor();

  factory DataService() => _instance;

  static final _baseUrl = "skl.happycu.co";

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
        return {"status": "success", "text": "login success"};
      } else {
        return {"status": "failed", "text": "login failed"};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      return {"status": "error", "text": "Exception occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> getDataHome(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/ip/m';
    final Uri url = Uri.https(_baseUrl, path, {"date": date});
    try {
      final response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        return {"status": "success", "text": "login success", "data": body["data"]};
      } else {
        return {"status": "failed", "text": "login failed", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getscanFindItems(String date, [String type = "all", String? barcode]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/ip/m/item';
    Map<String, String> query = {"date": date};
    if (type != "99" && type != "all") {
      query.addAll({"status_code": type});
    } else if (type == "99") {
      List<String> typeOther = ["01", "02", "06", "07"];
      List<Map<String, dynamic>> result = await _getDataTypeOther(typeOther, path, date, accessToken);
      try {
        if (result.length == 0) {
          return {"status": "error", "text": "not found data", "data": null};
        }
        return {"status": "success", "text": "login success", "data": result};
      } catch (e) {
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
            "uuid": data["uuid"],
            "hawb": data["hawb"],
            "lastStatus": data["lastStatus"],
          });
        }

        return {"status": "success", "text": "login success", "data": result};
      } else {
        return {"status": "failed", "text": "login failed", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
      return {"status": "error", "text": "Exception occurred: $e", "data": null};
    }
  }

  Future<Map<String, dynamic>> getDetailItem(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final String path = '/v1/ip/m/item/$uuid';
    final Uri url = Uri.https(_baseUrl, path);
    try {
      final response = await http.get(url, headers: {'Authorization': "Bearer $accessToken"});
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> body = jsonDecode(response.body);
        return {"status": "success", "text": "login success", "data": body["data"]};
      } else {
        return {"status": "failed", "text": "login failed", "data": null};
      }
    } catch (e) {
      Exception('Exception occurred: $e');
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
}
