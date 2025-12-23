import 'package:frontend/api_base.dart';
import 'package:frontend/model/data_model.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:http/http.dart';



 class ApiService {
  
  static Future<List<DataModel>> fetchData() async {
    Response response = await https.get(Uri.parse(BaseUrl.getBaseUrl()));
    if (response.statusCode == 200) {
      Map<String, dynamic> bodyResponse = json.decode(response.body);
      print(bodyResponse);
      
      // Extract the 'data' field from the response
      List<dynamic> dataList = bodyResponse['data'] ?? [];
      final data = dataList.map((data) => DataModel.fromJson(data as Map<String, dynamic>)).toList();

      print("💙💙💙 Response: $data");

      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

}
